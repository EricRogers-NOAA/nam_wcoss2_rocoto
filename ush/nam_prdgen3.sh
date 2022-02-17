#!/bin/bash
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         nam_prdgen3.sh
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
# 2001-10-23  Eric Rogers   Changes for nam-12
#                           - Use one master control file only
#                           - Split up prdgen into 4 separate jobs for
#                             timely nam-12 output. This job creates
#                             files AWIP3D (#212), AWIP20 (#215), AWIPAK (#216),
#                             AWP237 (#237), and AWIPHI (#243)
# 2003-03-18  Eric Rogers   Changed script to process special hourly
#                           output if variable hswitch is not set to zero
# 2015-03-19  Eric Rogers   Converted to GRIB2
#

set -x


export fhr=$(printf "%.2d" "${1#0}")  #two digit formatting in bash
export hswitch=$2
export PS4='PRDGEN3_F${fhr}_T$SECONDS + '
export compress_type=c3

cd $DATA/prdgen3_${fhr}

if [ $hswitch -ne 0 ] ; then

cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

gridspecs_212="lambert:265:25:25 226.541:185:40635 12.190:129:40635"

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_awip3d_ave.txt | grep 'ave' | $WGRIB2 -i -grib inputs.grib212_ave $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib212_ave -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs_212} awip3d${fhr}.${tmmark}.grib2.ave

if [ $fhr -eq 00 ] ; then

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_awip3d_inst.txt | grep ':anl:' | $WGRIB2 -i -grib inputs.grib212_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib212_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs_212} awip3d${fhr}.${tmmark}.grib2.inst

else

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_awip3d_inst.txt | grep 'hour fcst' | $WGRIB2 -i -grib inputs.grib212_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib212_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs_212} awip3d${fhr}.${tmmark}.grib2.inst

fi

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_awip3d.txt | $WGRIB2 -i -grib inputs.grib212 $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib212 -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib212.uv
python $USHnam/wgrib2_parm_filter.py $PARMnam/wgrib2.txtlists/forpyscript/nam_awip3d.txt
#Extract NEIGHBOR and BUDGET envars
NEIGHBOR=`cat neighbor.txt`
BUDGET=`cat budget.txt`
$WGRIB2 inputs.grib212.uv -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -if $NEIGHBOR -new_grid_interpolation neighbor -fi \
     -if $BUDGET -new_grid_interpolation budget -fi \
     -new_grid ${gridspecs_212} awip3d${fhr}.${tmmark}.uv
$WGRIB2 awip3d${fhr}.${tmmark}.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv awip3d${fhr}.${tmmark}.grib2.therest
export err=$?;err_chk

cat awip3d${fhr}.${tmmark}.grib2.therest awip3d${fhr}.${tmmark}.grib2.ave awip3d${fhr}.${tmmark}.grib2.inst > awip3d${fhr}.${tmmark}.grib2
rm awip3d${fhr}.${tmmark}.grib2.therest awip3d${fhr}.${tmmark}.grib2.ave awip3d${fhr}.${tmmark}.grib2.inst
rm neighbor.txt budget.txt

if test $SENDCOM = 'YES'
then

  $WGRIB2 awip3d${fhr}.${tmmark}.grib2 -s > awip3d${fhr}.${tmmark}.grib2.idx
  mv awip3d${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.t${cyc}z.awip3d${fhr}.${tmmark}.grib2.idx
  mv awip3d${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.t${cyc}z.awip3d${fhr}.${tmmark}.grib2

  if test $SENDDBN = 'YES'
  then
   $DBNROOT/bin/dbn_alert MODEL NAM_AW3D_GB2 $job $COMOUT/${RUN}.${cycle}.awip3d${fhr}.${tmmark}.grib2
   $DBNROOT/bin/dbn_alert MODEL NAM_AW3D_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awip3d${fhr}.${tmmark}.grib2.idx
  fi
fi

else

grid="212 215 216 237 243"

for gridnum in $grid
do

cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

if [ $gridnum -eq 212 ]
then
  filnam=awip3d
  gridspecs="lambert:265:25:25 226.541:185:40635 12.190:129:40635"
fi
if [ $gridnum -eq 215 ]
then
  filnam=awip20
  gridspecs="lambert:265:25:25 226.541:369:20318 12.190:257:20318"
fi
if [ $gridnum -eq 216 ]
then
  filnam=awipak
  gridspecs="nps:225:60 187.000:139:45000 30.000:107:45000"
fi
if [ $gridnum -eq 237 ]
then
  filnam=awp237
  gridspecs="lambert:253:50:50 285.720:54:32463 16.201:47:32463"
fi
if [ $gridnum -eq 243 ]
then
  filnam=awiphi
  gridspecs="latlon 190.0:126:0.400 10.000:101:0.400"
fi

if [ $gridnum -eq 212 -o $gridnum -eq 243 ] ; then

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

fi

if [ $gridnum -eq 215 ] ; then

if [ $fhr -eq 00 ] ; then

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_inst.txt | grep ':anl:' | $WGRIB2 -i -grib inputs.grib${gridnum}_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.inst

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_ave.txt | grep 'ave fcst:' | $WGRIB2 -i -grib inputs.grib${gridnum}_ave $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_ave -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.ave

else

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_inst.txt | grep 'hour fcst' | $WGRIB2 -i -grib inputs.grib${gridnum}_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.inst

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_ave.txt | grep 'hour ave fcst:' | $WGRIB2 -i -grib inputs.grib${gridnum}_ave $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_ave -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.ave


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

cat ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.inst ${filnam}${fhr}.${tmmark}.grib2.ave > ${filnam}${fhr}.${tmmark}.grib2
rm ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.inst ${filnam}${fhr}.${tmmark}.grib2.ave
rm neighbor.txt budget.txt

fi

if [ $gridnum -eq 216 ] ; then

if [ $fhr -eq 00 ] ; then

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_inst.txt | grep ':anl:' | $WGRIB2 -i -grib inputs.grib${gridnum}_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.inst

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_ave.txt | grep 'ave fcst:' | $WGRIB2 -i -grib inputs.grib${gridnum}_ave $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_ave -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.ave

else

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_inst.txt | grep 'hour fcst' | $WGRIB2 -i -grib inputs.grib${gridnum}_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.inst

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_ave.txt | grep 'hour ave fcst:' | $WGRIB2 -i -grib inputs.grib${gridnum}_ave $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_ave -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.ave

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

cat ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.inst ${filnam}${fhr}.${tmmark}.grib2.ave > ${filnam}${fhr}.${tmmark}.grib2
rm ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.inst ${filnam}${fhr}.${tmmark}.grib2.ave
rm neighbor.txt budget.txt

fi

if [ $gridnum -eq 237 ] ; then

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_ave.txt | grep 'ave' | $WGRIB2 -i -grib inputs.grib${gridnum}_ave $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_ave -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.ave

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

cat ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.ave > ${filnam}${fhr}.${tmmark}.grib2
rm ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.ave
rm neighbor.txt budget.txt

fi

done

#######################################################
# Generate 3-hour precip for on-time runs.
#######################################################
if [ $cyc -eq 00 -o $cyc -eq 12 ] ; then
  if [ $fhr -ne 00 -a $fhr -ne 03 -a $fhr -ne 15 -a $fhr -ne 27 -a \
       $fhr -ne 39 -a $fhr -ne 51 -a $fhr -ne 63 -a $fhr -ne 75 ] ; then
    ${GRB2INDEX} awip3d${fhr}.${tmmark}.grib2 awip3d${fhr}.${tmmark}.grib2.idxbin
    ${GRB2INDEX} awip20${fhr}.${tmmark}.grib2 awip20${fhr}.${tmmark}.grib2.idxbin
    bashfhr=$(echo $fhr | sed 's/^0*//')
    let fhr3=bashfhr-3
    export fhr3=$(printf "%.2d" "${fhr3#0}")  #two digit formatting in bash
    #
    # Make sure fhr3 prdgen files are available before
    # proceeding.
    #
    ic=0
    while [ ! -r $COMOUT/${RUN}.${cycle}.awip3d${fhr3}.${tmmark}.grib2.idxbin -o \
            ! -r $COMOUT/${RUN}.${cycle}.awip20${fhr3}.${tmmark}.grib2.idxbin -o \
            ! -r $COMOUT/${RUN}.${cycle}.awip20${fhr3}.${tmmark}.grib2 -o \
            ! -r $COMOUT/${RUN}.${cycle}.awip3d${fhr3}.${tmmark}.grib2 ] ; do
      let ic=ic+1
      if [ $ic -gt 180 ] ; then
        err_exit "F$fhr PRDGEN GIVING UP AFTER 45 MINUTES WAITING FOR F$fhr3 files"
      fi
      sleep 15
    done

# start grid 212 processing

    cp $COMOUT/${RUN}.${cycle}.awip3d${fhr3}.${tmmark}.grib2 awip3d${fhr3}.${tmmark}.grib2
    cp $COMOUT/${RUN}.${cycle}.awip3d${fhr3}.${tmmark}.grib2.idxbin awip3d${fhr3}.${tmmark}.grib2.idxbin

    IARW=0
    ISNOW=0
    ILSM=0
    pfhr1=${fhr}
    pfhr2=${fhr3}
    pfhr3=00
    pfhr4=00

    export pgm=nam_makeprecip;. prep_step
    ln -sf awip3d${fhr3}.${tmmark}.grib2      fort.13
    ln -sf awip3d${fhr3}.${tmmark}.grib2.idxbin  fort.14
    ln -sf awip3d${fhr}.${tmmark}.grib2       fort.15
    ln -sf awip3d${fhr}.${tmmark}.grib2.idxbin   fort.16
    ln -sf precip212.${fhr}           fort.50
    ln -sf cprecip212.${fhr}          fort.51
$EXECnam/nam_makeprecip << EOF >> $pgmout 2>errfile
$pfhr1 $pfhr2 $pfhr3 $pfhr4 $IARW $ISNOW $ILSM
EOF
    export err=$?;err_chk

    cat precip212.${fhr} >> awip3d${fhr}.${tmmark}.grib2
    cat cprecip212.${fhr} >> awip3d${fhr}.${tmmark}.grib2

# end grid 212 processing
# start grid 215 processing

    cp $COMOUT/${RUN}.${cycle}.awip20${fhr3}.${tmmark}.grib2 awip20${fhr3}.${tmmark}.grib2
    cp $COMOUT/${RUN}.${cycle}.awip20${fhr3}.${tmmark}.grib2.idxbin awip20${fhr3}.${tmmark}.grib2.idxbin

    IARW=0
    ISNOW=0
    ILSM=0
    pfhr1=${fhr}
    pfhr2=${fhr3}
    pfhr3=00
    pfhr4=00

    export pgm=nam_makeprecip;. prep_step
    ln -sf awip20${fhr3}.${tmmark}.grib2      fort.13
    ln -sf awip20${fhr3}.${tmmark}.grib2.idxbin  fort.14
    ln -sf awip20${fhr}.${tmmark}.grib2       fort.15
    ln -sf awip20${fhr}.${tmmark}.grib2.idxbin   fort.16
    ln -sf precip215.${fhr}           fort.50
    ln -sf cprecip215.${fhr}          fort.51
$EXECnam/nam_makeprecip << EOF >> $pgmout 2>errfile
$pfhr1 $pfhr2 $pfhr3 $pfhr4 $IARW $ISNOW $ILSM
EOF
    export err=$?;err_chk

    cat precip215.${fhr} >> awip20${fhr}.${tmmark}.grib2
    cat cprecip215.${fhr} >> awip20${fhr}.${tmmark}.grib2

# end grid 215 processing

  fi
fi
# end on-time cycle processing

############################
$WGRIB2 awip3d${fhr}.${tmmark}.grib2 -s > awip3d${fhr}.${tmmark}.grib2.idx
$WGRIB2 awip20${fhr}.${tmmark}.grib2 -s > awip20${fhr}.${tmmark}.grib2.idx
$WGRIB2 awipak${fhr}.${tmmark}.grib2 -s > awipak${fhr}.${tmmark}.grib2.idx
$WGRIB2 awiphi${fhr}.${tmmark}.grib2 -s > awiphi${fhr}.${tmmark}.grib2.idx
$WGRIB2 awp237${fhr}.${tmmark}.grib2 -s > awp237${fhr}.${tmmark}.grib2.idx

${GRB2INDEX} awip20${fhr}.${tmmark}.grib2 awip20${fhr}.${tmmark}.grib2.idxbin
${GRB2INDEX} awip3d${fhr}.${tmmark}.grib2 awip3d${fhr}.${tmmark}.grib2.idxbin

if test $SENDCOM = 'YES'
then
    mv awipak${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awipak${fhr}.${tmmark}.grib2
    mv awiphi${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awiphi${fhr}.${tmmark}.grib2
    mv awip20${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awip20${fhr}.${tmmark}.grib2
    mv awip3d${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awip3d${fhr}.${tmmark}.grib2
    mv awp237${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awp237${fhr}.${tmmark}.grib2

    mv awipak${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awipak${fhr}.${tmmark}.grib2.idx
    mv awiphi${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awiphi${fhr}.${tmmark}.grib2.idx
    mv awip20${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awip20${fhr}.${tmmark}.grib2.idx
    mv awip3d${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awip3d${fhr}.${tmmark}.grib2.idx
    mv awp237${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awp237${fhr}.${tmmark}.grib2.idx

    mv awip20${fhr}.${tmmark}.grib2.idxbin $COMOUT/${RUN}.${cycle}.awip20${fhr}.${tmmark}.grib2.idxbin
    mv awip3d${fhr}.${tmmark}.grib2.idxbin $COMOUT/${RUN}.${cycle}.awip3d${fhr}.${tmmark}.grib2.idxbin

    if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
    then
     $DBNROOT/bin/dbn_alert MODEL NAM_AWAK_GB2 $job $COMOUT/${RUN}.${cycle}.awipak${fhr}.${tmmark}.grib2
     $DBNROOT/bin/dbn_alert MODEL NAM_AWHI_GB2 $job $COMOUT/${RUN}.${cycle}.awiphi${fhr}.${tmmark}.grib2
     $DBNROOT/bin/dbn_alert MODEL NAM_AW20_GB2 $job $COMOUT/${RUN}.${cycle}.awip20${fhr}.${tmmark}.grib2
     $DBNROOT/bin/dbn_alert MODEL NAM_AW3D_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awip3d${fhr}.${tmmark}.grib2.idx
     $DBNROOT/bin/dbn_alert MODEL NAM_AWAK_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awipak${fhr}.${tmmark}.grib2.idx
     $DBNROOT/bin/dbn_alert MODEL NAM_AWHI_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awiphi${fhr}.${tmmark}.grib2.idx
     $DBNROOT/bin/dbn_alert MODEL NAM_AW20_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awip20${fhr}.${tmmark}.grib2.idx
    fi
# alert awip3d for all tm forecasts
    if test $SENDDBN = 'YES'
    then
     $DBNROOT/bin/dbn_alert MODEL NAM_AW3D_GB2 $job $COMOUT/${RUN}.${cycle}.awip3d${fhr}.${tmmark}.grib2
    fi
fi

# end hswitch test
fi

if test "$SENDECF" = 'YES'
then
  ecflow_client --event post_3_complete
fi

echo EXITING $0
exit
