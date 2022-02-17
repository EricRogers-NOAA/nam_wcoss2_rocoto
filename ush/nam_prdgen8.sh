#!/bin/bash
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         nam_prdgen8.sh
# Script description:  Run nam product generator jobs
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract: This script runs the Nam PRDGEN jobs
#
# Script history log:
# 1999-06-23  Eric Rogers
# 1999-08-25  Brent Gordon  Pulled the PRDGEN here file out of the post
#                           jobs into this script.
# 2008-08-14  Eric Rogers   This script created the expanded NAM 32 km
#                           output grid, made at 3-h intervals
# 2011-02-18  Eric Rogers   Changed to make grid #151 hourly to 36-h
# 2012-01-28  Eric Rogers   Add 3-h precip buckets for 00z/12z cycles
#                           and reinstate hswitch test
# 2015-03-19  Eric Rogers  Converted to GRIB2
#

set -x

export fhr=$(printf "%.2d" "${1#0}")  #two digit formatting in bash
export hswitch=$2
export PS4='PRDGEN8_F${fhr}_T$SECONDS + '
export compress_type=c3

cd $DATA/prdgen8_${fhr}

# No need for hswitch test since we're adding 3-h precip buckets to 00z/12z runs

cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

gridnum=151
filnam=awp151
gridspecs="nps:250:60 215.860:478:33812 -7.450:429:33812"

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_ave.txt | grep 'ave' | $WGRIB2 -i -grib inputs.grib${gridnum}_ave $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_ave -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.ave

if [ $fhr -eq 00 ] ; then

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_inst.txt | grep ':anl:' | $WGRIB2 -i -grib inputs.grib${gridnum}_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.inst

else

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_inst.txt | grep 'hour fcst' | $WGRIB2 -i -grib inputs.grib${gridnum}_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.inst

fi

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}.txt | $WGRIB2 -i -grib inputs.grib${gridnum} $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib${gridnum}.uv
python $USHnam/wgrib2_parm_filter.py $PARMnam/wgrib2.txtlists/forpyscript/nam_${filnam}.txt
#Extract NEIGHBOR and BUDGET envars
NEIGHBOR=`cat neighbor.txt`
BUDGET=`cat budget.txt`
$WGRIB2 inputs.grib${gridnum}.uv -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -if $NEIGHBOR -new_grid_interpolation neighbor -fi \
     -if $BUDGET -new_grid_interpolation budget -fi \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.uv
$WGRIB2 ${filnam}${fhr}.${tmmark}.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv ${filnam}${fhr}.${tmmark}.grib2.therest
export err=$?;err_chk

cat ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.ave ${filnam}${fhr}.${tmmark}.grib2.inst > ${filnam}${fhr}.${tmmark}.grib2
rm ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.ave ${filnam}${fhr}.${tmmark}.grib2.inst

rm neighbor.txt budget.txt

${GRB2INDEX} ${filnam}${fhr}.${tmmark}.grib2 ${filnam}${fhr}.${tmmark}.grib2.idxbin

if [ $hswitch -eq 0 ] ; then

#######################################################
# Generate 3-hour precip for on-time runs.
#######################################################
if [ $cyc -eq 00 -o $cyc -eq 12 ] ; then
  if [ $fhr -ne 00 -a $fhr -ne 03 -a $fhr -ne 15 -a $fhr -ne 27 -a \
       $fhr -ne 39 -a $fhr -ne 51 -a $fhr -ne 63 -a $fhr -ne 75 ] ; then
    bashfhr=$(echo $fhr | sed 's/^0*//')
    let fhr3=bashfhr-3
    export fhr3=$(printf "%.2d" "${fhr3#0}")  #two digit formatting in bash
    #
    # Make sure fhr3 prdgen files are available before
    # proceeding.
    #
    ic=0
    while [ ! -r $COMOUT/${RUN}.${cycle}.awp151${fhr3}.${tmmark}.grib2 -o \
            ! -r $COMOUT/${RUN}.${cycle}.awp151${fhr3}.${tmmark}.grib2.idxbin ] ; do
      let ic=ic+1
      if [ $ic -gt 180 ] ; then
        err_exit "F$fhr PRDGEN GIVING UP AFTER 45 MINUTES WAITING FOR F$fhr3 files"
      fi
      sleep 15
    done

# start grid 151 processing

    cp $COMOUT/${RUN}.${cycle}.awp151${fhr3}.${tmmark}.grib2 awp151${fhr3}.${tmmark}.grib2
    cp $COMOUT/${RUN}.${cycle}.awp151${fhr3}.${tmmark}.grib2.idxbin awp151${fhr3}.${tmmark}.grib2.idxbin

    IARW=0
    ISNOW=0
    ILSM=0
    pfhr1=${fhr}
    pfhr2=${fhr3}
    pfhr3=00
    pfhr4=00

    export pgm=nam_makeprecip;. prep_step
    ln -sf awp151${fhr3}.${tmmark}.grib2      fort.13
    ln -sf awp151${fhr3}.${tmmark}.grib2.idxbin  fort.14
    ln -sf awp151${fhr}.${tmmark}.grib2       fort.15
    ln -sf awp151${fhr}.${tmmark}.grib2.idxbin   fort.16
    ln -sf precip151.${fhr}           fort.50
    ln -sf cprecip151.${fhr}          fort.51
$EXECnam/nam_makeprecip << EOF >> $pgmout 2>errfile
$pfhr1 $pfhr2 $pfhr3 $pfhr4 $IARW $ISNOW $ILSM
EOF
    export err=$?;err_chk

    cat precip151.${fhr} >> awp151${fhr}.${tmmark}.grib2
    cat cprecip151.${fhr} >> awp151${fhr}.${tmmark}.grib2

  fi # fhr test

fi # end on-time cycle processing

fi # end hswitch test

if test $SENDCOM = 'YES'
then
  $WGRIB2 awp151${fhr}.${tmmark}.grib2 -s > awp151${fhr}.${tmmark}.grib2.idx
  mv awp151${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awp151${fhr}.${tmmark}.grib2
  mv awp151${fhr}.${tmmark}.grib2.idxbin $COMOUT/${RUN}.${cycle}.awp151${fhr}.${tmmark}.grib2.idxbin
  mv awp151${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awp151${fhr}.${tmmark}.grib2.idx

  if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
  then
   $DBNROOT/bin/dbn_alert MODEL NAM_AW151_GB2 $job $COMOUT/${RUN}.${cycle}.awp151${fhr}.${tmmark}.grib2
   $DBNROOT/bin/dbn_alert MODEL NAM_AW151_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awp151${fhr}.${tmmark}.grib2.idx
  fi

fi

if test "$SENDECF" = 'YES'
then
  ecflow_client --event post_8_complete
fi

echo EXITING $0

wait
