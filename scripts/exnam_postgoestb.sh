#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_postgoestb.sh.ecf
# Script description:  Make GOES lookalike grids for 12 km NAM parent
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract: Make GOES lookalike grids for 12 km NAM paren
#
# Script history log:
# 1999-06-23  Eric Rogers
# 1999-08-17  Brent Gordon  -- Modified for production.
# 2015-??-??  Rogers converted to GRIB2 for NAMv4
#

set -xa

msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA 

offset=-`echo $tmmark | cut -c 3-4`
SDATE=`${NDATE} $offset ${PDY}${cyc}`
export MODELTYPE=NMM
export OUTTYP=binarynemsio
export GTYPE=grib2
####export FORT_BUFFERED=true

ls -l $FCSTDIR/nampost_goestb.done*
err1=$?

if [ $err1 -ne 0 ]
then
  fhr=00
else
  cp $FCSTDIR/nampost_goestb.done* .
  fhr=`ls -1 nampost_goestb.done*.${tmmark} | tail -1 | cut -c 20-21`
fi

if [ $tmmark = tm00 ]; then
 if [ $RUNTYPE = CATCHUP ]; then
   TEND=${FMAX_CATCHUP_PARENT}
 else
   TEND=${FMAX_HOURLY_PARENT}
 fi
else
TEND=01
fi

while [ $fhr -le $TEND ] 
do

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
    if [ $icnt -ge 1080 ]
    then
      msg="ABORTING after 30 minutes of waiting for NAM FCST F${fhr} to end."
      err_exit $msg
    fi
  done

  cp $FIXnam/nam_micro_lookup.dat eta_micro_lookup.dat

  nposts=01
  incpst=01

  y=`expr $fhr % 3`

  cp $PARMnam/nam_post_avblflds.xml post_avblflds.xml
  cp $PARMnam/nam_params_grib2_tbl params_grib2_tbl_new
  cp $FIXnam/nam_micro_lookup.dat eta_micro_lookup.dat
  cp $PARMnam/nam_cntrl_goestb_flatfile.txt postxconfig-NT.txt

  export FIXCRTM=$FIXnam/BE_POST_GOES
  $USHnam/nam_link_crtm_fix.sh $FIXCRTM

  VALDATE=`${NDATE} ${fhr} ${SDATE}`

  valyr=`echo $VALDATE | cut -c1-4`
  valmn=`echo $VALDATE | cut -c5-6`
  valdy=`echo $VALDATE | cut -c7-8`
  valhr=`echo $VALDATE | cut -c9-10`

  timeform=${valyr}"-"${valmn}"-"${valdy}"_"${valhr}":00:00"

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
  ${MPIEXEC} -n ${procs} -ppn ${procspernode} --cpu-bind core --depth 1 $EXECnam/nam_ncep_post >> $pgmout 2>errfile
  export err=$?;err_chk

# add wgrib2 here

file="151 218 221 243"

for grid in $file
do

if [ $grid -eq 151 ] ; then
  gridspecs="nps:250:60 215.860:478:33812 -7.450:429:33812"
fi
if [ $grid -eq 218 ] ; then
  gridspecs="lambert:265:25:25 226.541:614:12191 12.190:428:12191"
fi
if [ $grid -eq 221 ] ; then
  gridspecs="lambert:253:50:50 214.5:349:32463 1.0:277:32463"
fi
if [ $grid -eq 243 ] ; then
  gridspecs_243="latlon 190.0:126:0.400 10.000:101:0.400"
fi

$WGRIB2 BGGOES${fhr}.tm00 -set_bitmap 1 -set_grib_type c3 -new_grid_interpolation neighbor -new_grid ${gridspecs} nam.GOESTB${grid}${fhr}.grib2
$WGRIB2 nam.GOESTB${grid}${fhr}.grib2 -s > nam.GOESTB${grid}${fhr}.grib2.idx

done

############################
# Convert to grib2 format
############################

if test $SENDCOM = 'YES'
then

file="151 218 221 243"

  for grid in $file
  do
    mv nam.GOESTB${grid}${fhr}.grib2 $COMOUT/${RUN}.${cycle}.goes${grid}${fhr}.tm00.grib2
    mv nam.GOESTB${grid}${fhr}.grib2.idx $COMOUT/${RUN}.${cycle}.goes${grid}${fhr}.tm00.grib2.idx
  done

fi

if test $SENDDBN = 'YES'
then
   $DBNROOT/bin/dbn_alert MODEL NAM_GOESSIMPGB2_218 exnam_postgoestb $COMOUT/${RUN}.${cycle}.goes218${fhr}.${tmmark}.grib2
   $DBNROOT/bin/dbn_alert MODEL NAM_GOESSIMPGB2_221 exnam_postgoestb $COMOUT/${RUN}.${cycle}.goes221${fhr}.${tmmark}.grib2
   $DBNROOT/bin/dbn_alert MODEL NAM_GOESSIMPGB2_243 exnam_postgoestb $COMOUT/${RUN}.${cycle}.goes243${fhr}.${tmmark}.grib2
fi

postmsg "NAM GOES POST done for F${fhr}"

echo done > $FCSTDIR/nampost_goestb.done${fhr}.${tmmark}

if [ $fhr -le 35 ] 
then
  let "fhr=fhr+1"
else
  let "fhr=fhr+3"
fi

typeset -Z2 fhr

done

echo EXITING $0
exit $err
#
