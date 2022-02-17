#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_post_nest.sh
# Script description:  Run nam post jobs for NAM nests
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract: This script runs the Nam post jobs for NAM nests

# Script history log:
# 1999-06-23  Eric Rogers
# 1999-08-17  Brent Gordon  -- Modified for production.
# 2007-10-03  Bradley Mabe  -- Implemented latest changes
# 2011-??-??  Rogers -- Initial script for NAM nests
# 2015-??-??  Rogers/Carley -- Converted to GRIB2 and for NAMv4
#

set -xa

msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA 

#
# Get needed variables from exnam_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh

offset=-`echo $tmmark | cut -c 3-4`
SDATE=`${NDATE} $offset ${PDY}${cyc}`
export MODELTYPE=NMM
export OUTTYP=binarynemsio
export GTYPE=grib2
export FORT_BUFFERED=true

if [ $tmmark = tm00 ]
then
  if [ $RUNTYPE = CATCHUP ]
  then
    endcopy=06
  else
    endcopy=06
  fi
else
   endcopy=01
fi  

for fhr in $post_times
do

  icnt=1
  while [ $icnt -lt 1000 ]
  do
    if [ -s $FCSTDIR/fcstdone.${numdomain}.00${fhr}h_00m_00.00s ]
    then
      break
    else
      icnt=$((icnt + 1))
      sleep 5
    fi
    if [ $icnt -ge 360 ]
    then
      msg="ABORTING after 30 minutes of waiting for Nam FCST F${fhr} to end."
      err_exit $msg
    fi
  done

   cp $FIXnam/nam_micro_lookup.dat eta_micro_lookup.dat
   cp $PARMnam/nam_post_avblflds.xml post_avblflds.xml
   cp $PARMnam/nam_params_grib2_tbl params_grib2_tbl_new

  nposts=01
  incpst=01

  export fhr

  y=`expr $fhr % 3`

  if [ $domain = hawaii -o $domain = prico ] ; then
    if [ $fhr -eq 00 ] ; then
      cp $PARMnam/nam_cntrl_nest_noconv_flatfile_small.txt_00h postxconfig-NT.txt
    else
      cp $PARMnam/nam_cntrl_nest_noconv_flatfile_small.txt postxconfig-NT.txt
    fi
  else
    if [ $fhr -eq 00 ] ; then
      if [ $domain = conus ] ; then
        cp $PARMnam/nam_cntrl_conusnest_noconv_flatfile.txt_00h postxconfig-NT.txt
      else
        cp $PARMnam/nam_cntrl_nest_noconv_flatfile.txt_00h postxconfig-NT.txt
      fi
    else
      if [ $domain = conus ] ; then
        cp $PARMnam/nam_cntrl_conusnest_noconv_flatfile.txt postxconfig-NT.txt
      else
        cp $PARMnam/nam_cntrl_nest_noconv_flatfile.txt postxconfig-NT.txt
      fi
    fi
  fi

  VALDATE=`${NDATE} ${fhr} ${SDATE}`

  valyr=`echo $VALDATE | cut -c1-4`
  valmn=`echo $VALDATE | cut -c5-6`
  valdy=`echo $VALDATE | cut -c7-8`
  valhr=`echo $VALDATE | cut -c9-10`

  timeform=${valyr}"-"${valmn}"-"${valdy}"_"${valhr}":00:00"

if [ ! -s $FCSTDIR/nmmb_hst_${numdomain}_nio_00${fhr}h_00m_00.00s ]; then
 msg="$FCSTDIR/nmmb_hst_${numdomain}_nio_00${fhr}h_00m_00.00s DOES NOT EXIST. CANNOT POST PROCESS FILE. EXIT!"
 postmsg "$msg"
 exit 99
fi

cat > itag <<EOF
$FCSTDIR/nmmb_hst_${numdomain}_nio_00${fhr}h_00m_00.00s
$OUTTYP
$GTYPE
$timeform
$MODELTYPE
EOF

  export pgm=nam_ncep_post
  . prep_step
  
  startmsg
  ${MPIEXEC} -n ${procs} -ppn ${procspernode} $EXECnam/nam_ncep_post >> $pgmout 2>errfile
  export err=$?;err_chk

  export post_err=$err

  
  if [ $fhr -le 49 ] 
  then
    mv BGRD3D${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.${domain}nest.bgrd3d${fhr}.${tmmark}
  fi

  if [ $fhr -gt 49 -a $y -eq 0 ] 
  then
    mv BGRD3D${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.${domain}nest.bgrd3d${fhr}.${tmmark}
  fi

  if [ $domain = conus -a $SENDDBN = YES -a $tmmark = tm00 ]; then
      if [ -e $COMOUT/${RUN}.${cycle}.${domain}nest.bgrd3d${fhr}.${tmmark} ] ; then
	  $DBNROOT/bin/dbn_alert MODEL NAM_CONUSNEST_BGB3D_GB2 $job $COMOUT/${RUN}.${cycle}.${domain}nest.bgrd3d${fhr}.${tmmark}
      fi
  fi 

  if [ $domain != firewx ]
  then
    mv BSMART${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.${domain}nest.bsmart${fhr}.${tmmark}
  fi

  mv BGDAWP${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.${domain}nest.bgdawp${fhr}.${tmmark}

#If this is fhr=00 then also post the gsi analysis file.  This is because
# the fhr=00 file corresponds to the filtered state, not the analysis from GSI,
# when the DF is turned on.

if [ $fhr -eq 00 ]; then
  # Added SENDECF test so I could run this script in dev test
  if test "$SENDECF" = 'YES'
  then
     ecflow_client --event release_postf00_downstream
  fi

#All necessary post files are still in the working directoy, only need a new itag
# file and to run the post one more time

  if [ $domain = conus -o $domain = alaska ]     
  then
  #remove old itag  
  rm -f itag

if [ $tmmark = tm06 ]; then
  files="${RUN}.t${cyc}z.input_domain_${domain}nest_nemsio.anl.${tmmark} ${RUN}.t${cyc}z.input_domain_${domain}nest_nemsio.${tmmark}"
else
  files="${RUN}.t${cyc}z.nmm_b_restart_${domain}nest_nemsio_anl.${tmmark}"
fi

for fil in ${files}; do

if [ $tmmark = tm06 -a $fil = ${RUN}.t${cyc}z.input_domain_${domain}nest_nemsio.${tmmark} ]; then
  suf="ges"
  fullpath=$GESDIR/${fil}
  # No radar/hydromets so use truncated flat file
  cp $PARMnam/nam_cntrl_tm06_anl_flatfile.txt postxconfig-NT.txt
elif [ $fil = ${RUN}.t${cyc}z.nmm_b_restart_${domain}nest_nemsio_anl.${tmmark} ]; then
  suf="anl"
  fullpath=$GESDIR/${fil}
  cp $PARMnam/nam_cntrl_nest_noconv_flatfile.txt_00h postxconfig-NT.txt
elif [ $fil = ${RUN}.t${cyc}z.input_domain_${domain}nest_nemsio.anl.${tmmark} ]; then
  suf="anl"
  fullpath=$GESDIR/${fil}
  # No radar/hydromets so use truncated flat file
  cp $PARMnam/nam_cntrl_tm06_anl_flatfile.txt postxconfig-NT.txt
fi

if [ $tmmark = tm00 ] ; then
  if [ $GUESStm00 = GDAS ] ; then
    cp $PARMnam/nam_cntrl_tm06_anl_flatfile.txt postxconfig-NT.txt
  fi
fi

if [ ! -s ${fullpath} ]; then
  export err=99
  echo "${fullpath} does not exist! Exit with err=${err}!"
  err_chk
fi

cat > itag <<EOF
$fullpath
$OUTTYP
$GTYPE
$timeform
$MODELTYPE
EOF
  
   cp $FIXnam/nam_micro_lookup.dat eta_micro_lookup.dat
   cp $PARMnam/nam_post_avblflds.xml post_avblflds.xml
   cp $PARMnam/nam_params_grib2_tbl params_grib2_tbl_new 
  
  export pgm=nam_ncep_post
  . prep_step

  startmsg
  ${MPIEXEC} -n ${procs} -ppn ${procspernode} $EXECnam/nam_ncep_post >> $pgmout 2>errfile
  export err=$?;err_chk

  if [ $domain != firewx ]
  then
    mv BSMART${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.${domain}nest.bsmart${fhr}.${tmmark}.${suf}
  fi


  mv BGDAWP${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.${domain}nest.bgdawp${fhr}.${tmmark}.${suf}

  done #End loop over files
  fi #end if conus or alaska
  
fi #end analysis time check

 if [ $post_err -eq 0 ]; then
   echo done > $FCSTDIR/nampost.done${fhr}_${numdomain}.${tmmark}
 else
   echo "NAM POST FAILED FOR F${fhr}!"
 fi

  if [ $domain = firewx ] 
  then
     cp latlons_corners.txt $COMOUT/${RUN}.t${cyc}z.latlons_corners_firewxnest.txt.f${fhr}
  fi

cd $DATA

done

echo EXITING $0
exit $err
#
