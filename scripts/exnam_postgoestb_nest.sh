#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_postgoestb_nest.sh.ecf
# Script description:  Run nam post to make GOES lookalike grids for NAM nests
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract: This script makes GOES lookalike grids for NAM nests
#
# Script history log:
# 1999-06-23  Eric Rogers
# 1999-08-17  Brent Gordon  -- Modified for production.
# 2014-08-18  Rogers : Turned on in NAMv3 for CONUS nest only
# 2015-??-??  Rogers convert to GRIB2; changed to 3-h frequency due 
#             to timing issues
#

set -xa

msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA 

numdomain=02
domain=conus

offset=-`echo $tmmark | cut -c 3-4`
SDATE=`${NDATE} $offset ${PDY}${cyc}`
export MODELTYPE=NMM
export OUTTYP=binarynemsio
export GTYPE=grib2
###export FORT_BUFFERED=true

ls -l $FCSTDIR/nampost_goestb_${domain}nest.done*
err1=$?

if [ $err1 -ne 0 ]
then
  fhr=00
else
  if [ $domain = conus ]
  then
    cp $FCSTDIR/nampost_goestb_${domain}nest.done* .
    fhr=`ls -1 nampost_goestb_${domain}nest.done* | tail -1 | cut -c 30-31`
  fi
fi

if [ $tmmark = tm00 ]; then
 if [ $RUNTYPE = CATCHUP ]; then
   TEND=60
 else
   TEND=18
 fi
else
TEND=01
fi

while [ $fhr -le $TEND ] 
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
    if [ $icnt -ge 1080 ]
    then
      msg="ABORTING after 30 minutes of waiting for NAM FCST F${fhr} to end."
      err_exit $msg
    fi
  done

  nposts=01
  incpst=01

  y=`expr $fhr % 3`

  cp $PARMnam/nam_post_avblflds.xml post_avblflds.xml
  cp $PARMnam/nam_params_grib2_tbl params_grib2_tbl_new
  cp $FIXnam/nam_micro_lookup.dat eta_micro_lookup.dat
  cp $PARMnam/nam_cntrl_goestb_nest_flatfile.txt postxconfig-NT.txt

  export FIXCRTM=$FIXnam/BE_POST_GOES
  $USHnam/nam_link_crtm_fix.sh $FIXCRTM

  VALDATE=`${NDATE} ${fhr} ${SDATE}`

  valyr=`echo $VALDATE | cut -c1-4`
  valmn=`echo $VALDATE | cut -c5-6`
  valdy=`echo $VALDATE | cut -c7-8`
  valhr=`echo $VALDATE | cut -c9-10`

  timeform=${valyr}"-"${valmn}"-"${valdy}"_"${valhr}":00:00"

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
  ${MPIEXEC} -n ${procs} -ppn ${procspernode} --cpu-bind core --depth 1 $EXECnam/nam_ncep_post >> $pgmout 2>errfile
  export err=$?;err_chk

# add wgrib2 here

  if [ $domain = alaska ] ; then
  area=alaska
  gridspecs="nps:210:60 181.429:1649:2976 40.530:1105:2976"
  fi
  if [ $domain = conus ] ; then
  area=conus
  gridspecs="lambert:262.5:38.5:38.5 237.280:1799:3000 21.138:1059:3000"
  fi

$WGRIB2 BGGOES${fhr}.tm00 -set_bitmap 1 -set_grib_type c3 -new_grid_interpolation neighbor -new_grid ${gridspecs} nam.GOESTB${fhr}.grib2
$WGRIB2 nam.GOESTB${fhr}.grib2 -s >nam.GOESTB${fhr}.grib2.idx

if test $SENDCOM = 'YES'
then
  mv nam.GOESTB${fhr}.grib2 $COMOUT/${RUN}.${cycle}.${domain}nest.goestb${fhr}.tm00.grib2
  mv nam.GOESTB${fhr}.grib2.idx $COMOUT/${RUN}.${cycle}.${domain}nest.goestb${fhr}.tm00.grib2.idx
fi

if test $SENDDBN = 'YES'
then
   $DBNROOT/bin/dbn_alert MODEL NAM_GOESSIMPGB2_NEST exnam_postgoestb_${domain}nest $COMOUT/${RUN}.${cycle}.${domain}nest.goestb${fhr}.tm00.grib2
fi

postmsg "NAM ${domain}nest GOES POST done for F${fhr}"

echo done > $FCSTDIR/nampost_goestb_${domain}nest.done${fhr}

##if [ $fhr -le 35 ] 
##then
##  let "fhr=fhr+1"
##else
  let "fhr=fhr+3"
##fi

typeset -Z2 fhr

done

echo EXITING $0
exit $err
#
