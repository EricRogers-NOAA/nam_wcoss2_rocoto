#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_post.sh
# Script description:  Run nam post jobs for 12 km parent domain
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract: This script runs the Nam post jobs for the 12 km parent domain
#
# Script history log:
# 1999-06-23  Eric Rogers
# 1999-08-17  Brent Gordon  -- Modified for production.
# 2007-10-03  Bradley Mabe  -- Implemented latest changes
# 2015-??-??  Rogers/Carley -- Convert to GRIB2, NAMv4 changes
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

if [ $tmmark != tm00 ]
then
 
  #CATCHUP cycling only does a 1 hour forecast, which is always the case then tmmark != tm00
  #  HOURLY always has a tmmark=tm00
     
  lastfhr=01
else
  if [ $RUNTYPE = HOURLY ]
  then
    lastfhr=${FMAX_HOURLY_PARENT}
  else
    lastfhr=${FMAX_CATCHUP_PARENT}
  fi
fi

for fhr in $post_times
do

# The following rst file copy is not necessary if not running the hourly cycle

  icnt=1
  while [ $icnt -lt 1000 ]
  do
    if [ -s $FCSTDIR/fcstdone.01.00${fhr}h_00m_00.00s ]
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


  nposts=01
  incpst=01

  y=`expr $fhr % 3`

  cp $PARMnam/nam_post_avblflds.xml post_avblflds.xml
  cp $PARMnam/nam_params_grib2_tbl params_grib2_tbl_new
  cp $FIXnam/nam_micro_lookup.dat eta_micro_lookup.dat

  if [ $fhr -le 48 ]
  then
    if [ $fhr -le 36 ]
    then
      if [ $fhr -eq 00 ] ; then
        cp $PARMnam/nam_cntrl_cmaq_flatfile.txt_00h postxconfig-NT.txt
      else
        cp $PARMnam/nam_cntrl_cmaq_flatfile.txt postxconfig-NT.txt
      fi
    fi
    if [ $fhr -gt 36 ]
    then
      if [ $y -eq 0 ]
      then
        cp $PARMnam/nam_cntrl_cmaq_flatfile.txt postxconfig-NT.txt
      else
        cp $PARMnam/nam_cntrl_cmaqonly_flatfile.txt postxconfig-NT.txt
      fi
    fi
  else
    cp $PARMnam/nam_cntrl_cmaq_flatfile.txt postxconfig-NT.txt
  fi

  if [ $fhr -gt 49 -a $y -ne 0 ]
  then
    cp $PARMnam/nam_cntrl_bgrd3d_hourly_flatfile.txt postxconfig-NT.txt
  fi

  if [ $fhr -eq 49 ]
  then
    cp $PARMnam/nam_cntrl_cmaqonly_flatfile.txt postxconfig-NT.txt
  fi

  VALDATE=`${NDATE} ${fhr} ${SDATE}`

  valyr=`echo $VALDATE | cut -c1-4`
  valmn=`echo $VALDATE | cut -c5-6`
  valdy=`echo $VALDATE | cut -c7-8`
  valhr=`echo $VALDATE | cut -c9-10`

  timeform=${valyr}"-"${valmn}"-"${valdy}"_"${valhr}":00:00"

#Rename nam_cntrl.parm for nam execution

#mv nam_cntrl.parm.${fhr} nam_cntrl.parm.${fhr}

if [ ! -s $FCSTDIR/nmmb_hst_01_nio_00${fhr}h_00m_00.00s ]; then
 msg="$FCSTDIR/nmmb_hst_01_nio_00${fhr}h_00m_00.00s DOES NOT EXIST. CANNOT POST PROCESS FILE. EXIT!"
 postmsg "$msg"
 exit 99
fi

cat > itag <<EOF
$FCSTDIR/nmmb_hst_01_nio_00${fhr}h_00m_00.00s
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

  if [ $y -eq 0 ] 
  then
    mv BGRD3D${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.bgrd3d${fhr}.${tmmark}
    mv BGDAWP${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.bgdawp${fhr}.${tmmark}
    mv BGRDSF${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.bgrdsf${fhr}.${tmmark}
    if [ $fhr -le 48 ] 
    then
      mv ETAPROFILE.txt $COMOUT/${RUN}.${cycle}.nmmprofile.${fhr}.txt
    fi
  fi

  if [ $y -ne 0 ] 
  then

    if [ $fhr -le $lastfhr ]
    then
      mv BGRD3D${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.bgrd3d${fhr}.${tmmark}
    fi
     
    if [ $fhr -le 36 ] 
    then
      mv BGDAWP${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.bgdawp${fhr}.${tmmark}
      mv BGRDSF${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.bgrdsf${fhr}.${tmmark}
      mv ETAPROFILE.txt $COMOUT/${RUN}.${cycle}.nmmprofile.${fhr}.txt
    else
      mv ETAPROFILE.txt $COMOUT/${RUN}.${cycle}.nmmprofile.${fhr}.txt
    fi
  fi

  if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
  then
    $DBNROOT/bin/dbn_alert MODEL NAM_BGB3D $job $COMOUT/nam.${cycle}.bgrd3d${fhr}.tm00
    if [ $y -eq 0 ]
    then
      if [ $fhr -eq 00 -o $fhr -eq 06 ] 
      then
        cp $COMOUT/nam.${cycle}.bgrd3d${fhr}.tm00 $COMOUT/nam.${cycle}.bgrd3d${fhr}.tm00.grib2
        $WGRIB2 $COMOUT/nam.${cycle}.bgrd3d${fhr}.tm00.grib2 -s > $COMOUT/nam.${cycle}.bgrd3d${fhr}.tm00.grib2.idx
        $DBNROOT/bin/dbn_alert MODEL NAM_BGB3D_GB2 $job $COMOUT/nam.${cycle}.bgrd3d${fhr}.tm00.grib2
        $DBNROOT/bin/dbn_alert MODEL NAM_BGB3D_GB2_WIDX $job $COMOUT/nam.${cycle}.bgrd3d${fhr}.tm00.grib2.idx
      fi
    fi
    if [ $fhr -le 36 ]
    then
      $WGRIB2 $COMOUT/nam.${cycle}.bgrdsf${fhr}.tm00 -s > $COMOUT/nam.${cycle}.bgrdsf${fhr}.tm00.grib2.idx 
      $DBNROOT/bin/dbn_alert MODEL WRFEVAL_GB2 $job $COMOUT/nam.${cycle}.bgrdsf${fhr}.tm00
      $DBNROOT/bin/dbn_alert MODEL WRFEVAL_GB2_WIDX $job $COMOUT/nam.${cycle}.bgrdsf${fhr}.tm00.grib2.idx
    fi
    if [ $fhr -gt 36 -a $y -eq 0 ]
    then
      $WGRIB2 $COMOUT/nam.${cycle}.bgrdsf${fhr}.tm00 -s > $COMOUT/nam.${cycle}.bgrdsf${fhr}.tm00.grib2.idx 
      $DBNROOT/bin/dbn_alert MODEL WRFEVAL_GB2 $job $COMOUT/nam.${cycle}.bgrdsf${fhr}.tm00
      $DBNROOT/bin/dbn_alert MODEL WRFEVAL_GB2_WIDX $job $COMOUT/nam.${cycle}.bgrdsf${fhr}.tm00.grib2.idx
    fi
  fi
  
# If this is fhr=00 then also post the gsi analysis file.  This is because
# the fhr=00 file corresponds to the filtered state, not the analysis from GSI,
# when the DF is turned on.

if [ $fhr -eq 00 ]; then
  # added SENDECF test so I could run this script in dev testing
  if test "$SENDECF" = 'YES'
  then
    ecflow_client --event release_postf00_downstream
  fi

# All necessary post files are still in the working directory, only need a new itag
# file and to run the post one more time.

if [ $tmmark = tm06 ]; then
files="${RUN}.t${cyc}z.input_domain_01_nemsio.anl.${tmmark} ${RUN}.t${cyc}z.input_domain_01_nemsio.${tmmark}"
else
files="${RUN}.t${cyc}z.nmm_b_restart_nemsio_anl.${tmmark}"
fi

if [ $tmmark = tm00 ] ; then
  if [ $GUESStm00 = GDAS ] ; then
    files="${RUN}.t${cyc}z.input_domain_01_nemsio.anl.tm00"
  fi
fi

for fil in ${files}; do

if [ $tmmark = tm06 -a $fil = ${RUN}.t${cyc}z.input_domain_01_nemsio.${tmmark} ]; then
  suf="ges"
  fullpath=$GESDIR/${fil}
  # No radar/hydromets so use truncated flat file
  cp $PARMnam/nam_cntrl_tm06_anl_flatfile.txt postxconfig-NT.txt
elif [ $fil = ${RUN}.t${cyc}z.nmm_b_restart_nemsio_anl.${tmmark} ]; then
  suf="anl"
  fullpath=$GESDIR/${fil}
  cp $PARMnam/nam_cntrl_cmaq_flatfile.txt_00h postxconfig-NT.txt
elif [ $fil = ${RUN}.t${cyc}z.input_domain_01_nemsio.anl.${tmmark} ]; then
  suf="anl"
  fullpath=$GESDIR/${fil}
  # No radar/hydromets so use truncated flat file
  cp $PARMnam/nam_cntrl_tm06_anl_flatfile.txt postxconfig-NT.txt
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
  
  cp $PARMnam/nam_post_avblflds.xml post_avblflds.xml
  cp $PARMnam/nam_params_grib2_tbl params_grib2_tbl_new
  cp $FIXnam/nam_micro_lookup.dat eta_micro_lookup.dat

  startmsg
  ${MPIEXEC} -n ${procs} -ppn ${procspernode} $EXECnam/nam_ncep_post >> $pgmout 2>errfile
  export err=$?;err_chk

  mv BGDAWP${fhr}.${tmmark} $COMOUT/${RUN}.${cycle}.bgdawp${fhr}.${tmmark}.${suf}
  mv ETAPROFILE.txt $COMOUT/${RUN}.${cycle}.nmmprofile.${fhr}.txt.${suf}

done
 
fi

echo done > $FCSTDIR/nampost.done${fhr}.${tmmark}

cd $DATA

done

echo EXITING $0
exit $err

