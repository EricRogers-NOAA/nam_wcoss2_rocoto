#!/bin/bash
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         nam_prdgen1.sh
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
#                             files AWP207 (#207), AWP211 (#211), 
#                             AWP217 (#217), AWIP32 (#221), and 221 tiles 
# 2003-03-18  Eric Rogers   Changed script to process special hourly
#                           output if variable hswitch is not set to zero 
# 2015-03-19  Eric Rogers  Converted to GRIB2
# 2016-11-08  Eric Rogers  Drop awp217
#

set -x

export fhr=$(printf "%.2d" "${1#0}")  #two digit formatting in bash
export hswitch=$2
export PS4='PRDGEN1_F${fhr}_T$SECONDS + '
export compress_type=c3

cd $DATA/prdgen1_${fhr}

if [ $hswitch -ne 0 ] ; then

cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

gridspecs_221="lambert:253:50:50 214.5:349:32463 1.0:277:32463"

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_awip32_ave.txt | grep 'ave'| $WGRIB2 -i -grib inputs.grib221_ave $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib221_ave -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs_221} awip32${fhr}.${tmmark}.grib2.ave

if [ $fhr -eq 00 ] ; then

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_awip32_inst.txt | grep ':anl:' | $WGRIB2 -i -grib inputs.grib221_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib221_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs_221} awip32${fhr}.${tmmark}.grib2.inst

else

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_awip32_inst.txt | grep 'hour fcst' | $WGRIB2 -i -grib inputs.grib221_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib221_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs_221} awip32${fhr}.${tmmark}.grib2.inst

fi

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_awip32.txt | $WGRIB2 -i -grib inputs.grib221 $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib221 -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib221.uv
python $USHnam/wgrib2_parm_filter.py $PARMnam/wgrib2.txtlists/forpyscript/nam_awip32.txt
#Extract NEIGHBOR and BUDGET envars
NEIGHBOR=`cat neighbor.txt`
BUDGET=`cat budget.txt`
$WGRIB2 inputs.grib221.uv -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -if $NEIGHBOR -new_grid_interpolation neighbor -fi \
     -if $BUDGET -new_grid_interpolation budget -fi \
     -new_grid ${gridspecs_221} awip32${fhr}.${tmmark}.uv
$WGRIB2 awip32${fhr}.${tmmark}.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv awip32${fhr}.${tmmark}.grib2.therest
export err=$?;err_chk

cat awip32${fhr}.${tmmark}.grib2.therest awip32${fhr}.${tmmark}.grib2.ave awip32${fhr}.${tmmark}.grib2.inst > awip32${fhr}.${tmmark}.grib2
rm awip32${fhr}.${tmmark}.grib2.therest awip32${fhr}.${tmmark}.grib2.ave awip32${fhr}.${tmmark}.grib2.inst

if test $SENDCOM = 'YES'
then
  $WGRIB2 awip32${fhr}.${tmmark}.grib2 -s > awip32${fhr}.${tmmark}.grib2.idx
  mv awip32${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.t${cyc}z.awip32${fhr}.${tmmark}.grib2.idx
  mv awip32${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.t${cyc}z.awip32${fhr}.${tmmark}.grib2
  if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
  then
   $DBNROOT/bin/dbn_alert MODEL NAM_AW32_GB2 $job $COMOUT/${RUN}.${cycle}.awip32${fhr}.${tmmark}.grib2
   $DBNROOT/bin/dbn_alert MODEL NAM_AW32_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awip32${fhr}.${tmmark}.grib2.idx
  fi
fi

else

grid="207 211 221"

for gridnum in $grid
do

cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

if [ $gridnum -eq 207 ]
then
  filnam=awp207
  gridspecs="nps:210:60 184.359:49:95250 42.085:35:95250"
fi
if [ $gridnum -eq 211 ]
then
  filnam=awp211
  gridspecs="lambert:265:25:25 226.541:93:81271 12.190:65:81271"
fi
if [ $gridnum -eq 221 ]
then
  filnam=awip32
  gridspecs="lambert:253:50:50 214.5:349:32463 1.0:277:32463"
fi

if [ $gridnum -eq 207 ] ; then

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}.txt | $WGRIB2 -i -grib inputs.grib${gridnum} $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib${gridnum}.uv
python $USHnam/wgrib2_parm_filter.py $PARMnam/wgrib2.txtlists/forpyscript/nam_${filnam}.txt
#Extract BUDGET envars
BUDGET=`cat budget.txt`
$WGRIB2 inputs.grib${gridnum}.uv -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -if $BUDGET -new_grid_interpolation budget -fi \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.uv
$WGRIB2 ${filnam}${fhr}.${tmmark}.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv ${filnam}${fhr}.${tmmark}.grib2
export err=$?;err_chk

rm neighbor.txt budget.txt
rm inputs.grib${gridnum}

fi

if [ $gridnum -eq 211 ] ; then

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
$WGRIB2 ${filnam}${fhr}.${tmmark}.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv ${filnam}${fhr}.${tmmark}.grib2
export err=$?;err_chk

rm neighbor.txt budget.txt
rm inputs.grib${gridnum}

fi

if [ $gridnum -eq 221 ] ; then

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

rm neighbor.txt budget.txt
rm inputs.grib${gridnum}

fi

done

# Generate 6-h precip for off-time run for awip32

if [ $cyc -eq 06 -o $cyc -eq 18 ] ; then
  let preciphr=fhr%6
  if [ $fhr -ne 00 -a $preciphr -eq 0 ] ; then
    ${GRB2INDEX} awip32${fhr}.${tmmark}.grib2 awip32${fhr}.${tmmark}.grib2.idxbin
    bashfhr=$(echo $fhr | sed 's/^0*//')
    let fhr3=bashfhr-3
    export fhr3=$(printf "%.2d" "${fhr3#0}")  #two digit formatting in bash
    #
    # Make sure fhr3 prdgen files are available before
    # proceeding.
    #
    ic=0
    while [ ! -r $COMOUT/${RUN}.${cycle}.awip32${fhr3}.${tmmark}.grib2.idxbin  -o \
            ! -r $COMOUT/${RUN}.${cycle}.awip32${fhr3}.${tmmark}.grib2 ] ; do
      let ic=ic+1
      if [ $ic -gt 180 ] ; then
        err_exit "F$fhr PRDGEN GIVING UP AFTER 45 MINUTES WAITING FOR F$fhr3 files"
      fi
      sleep 15
    done

# start grid 221 processing

    cp $COMOUT/${RUN}.${cycle}.awip32${fhr3}.${tmmark}.grib2 awip32${fhr3}.${tmmark}.grib2
    cp $COMOUT/${RUN}.${cycle}.awip32${fhr3}.${tmmark}.grib2.idxbin awip32${fhr3}.${tmmark}.grib2.idxbin

    IARW=0
    ISNOW=0
    pfhr1=${fhr3}
    pfhr2=${fhr}
    pfhr3=-99
    pfhr4=-01

    export pgm=nam_makeprecip;. prep_step
    ln -sf awip32${fhr3}.${tmmark}.grib2      fort.13
    ln -sf awip32${fhr3}.${tmmark}.grib2.idxbin  fort.14
    ln -sf awip32${fhr}.${tmmark}.grib2       fort.15
    ln -sf awip32${fhr}.${tmmark}.grib2.idxbin   fort.16
    ln -sf precip221.${fhr}         fort.50
    ln -sf cprecip221.${fhr}        fort.51
$EXECnam/nam_makeprecip << EOF >> $pgmout 2>errfile 
$pfhr1 $pfhr2 $pfhr3 $pfhr4 $IARW $ISNOW
EOF
    export err=$?;err_chk

    cat precip221.${fhr} >> awip32${fhr}.${tmmark}.grib2
    cat cprecip221.${fhr} >> awip32${fhr}.${tmmark}.grib2

# end grid 221 processing
  fi
fi
# end off-time cycle processing

$WGRIB2 awip32${fhr}.${tmmark}.grib2 -s >awip32${fhr}.${tmmark}.grib2.idx
$WGRIB2 awp207${fhr}.${tmmark}.grib2 -s >awp207${fhr}.${tmmark}.grib2.idx
$WGRIB2 awp211${fhr}.${tmmark}.grib2 -s >awp211${fhr}.${tmmark}.grib2.idx

${GRB2INDEX} awip32${fhr}.${tmmark}.grib2 awip32${fhr}.${tmmark}.grib2.idxbin

if test $SENDCOM = 'YES'
then
    mv awip32${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awip32${fhr}.${tmmark}.grib2
    mv awp207${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awp207${fhr}.${tmmark}.grib2
    mv awp211${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awp211${fhr}.${tmmark}.grib2
    mv awip32${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awip32${fhr}.${tmmark}.grib2.idx
    mv awp207${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awp207${fhr}.${tmmark}.grib2.idx
    mv awp211${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awp211${fhr}.${tmmark}.grib2.idx
    mv awip32${fhr}.${tmmark}.grib2.idxbin $COMOUT/${RUN}.${cycle}.awip32${fhr}.${tmmark}.grib2.idxbin

    if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
    then
     $DBNROOT/bin/dbn_alert MODEL NAM_AW32_GB2 $job $COMOUT/${RUN}.${cycle}.awip32${fhr}.${tmmark}.grib2
     $DBNROOT/bin/dbn_alert MODEL NAM_AW32_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awip32${fhr}.${tmmark}.grib2.idx
     let sendhr=fhr%6
     if [ $sendhr -eq 0 ]
     then
        $DBNROOT/bin/dbn_alert MODEL NAM_AW211_GB2 $job $COMOUT/${RUN}.${cycle}.awp211${fhr}.${tmmark}.grib2
        $DBNROOT/bin/dbn_alert MODEL NAM_AW211_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awp211${fhr}.${tmmark}.grib2.idx
     fi
    fi
fi


# end hswitch test
fi

if test "$SENDECF" = 'YES'
then
  ecflow_client --event post_1_complete
fi

echo EXITING $0
exit
