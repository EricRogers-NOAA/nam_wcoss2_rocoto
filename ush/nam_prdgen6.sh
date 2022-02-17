#!/bin/bash
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         nam_prdgen6.sh
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
# 2006-10-31  Eric Rogers   This script creates NAM grids over the CONUS
#                           and Hawaii for AFWA
#                           Grids are only made a 3-h intervals.
# 2015-03-19  Eric Rogers  Converted to GRIB2
#

set -x

export fhr=$(printf "%.2d" "${1#0}")  #two digit formatting in bash
export hswitch=$2
export PS4='PRDGEN6_F${fhr}_T$SECONDS + '
export compress_type=c3

cd $DATA/prdgen6_${fhr}

# NAM grids for AFWA only made at 3-hourly intervals, so just exit script
# with condition code=0 if hswitch not equal to zero

if [ $hswitch -eq 0 ] ; then

grid="180 182"

for gridnum in $grid
do

cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

if [ $gridnum -eq 180 ] ; then
  filnam=afwacs
  gridspecs="latlon 233.0:759:0.108 17.146:352:0.108"
fi
if [ $gridnum -eq 182 ] ; then
  filnam=afwahi
  gridspecs="latlon 190.0:278:0.108 8.133:231:0.108"
fi

if [ $fhr -eq 00 ] ; then

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_afwagrids_inst.txt | grep ':anl:' | $WGRIB2 -i -grib inputs.grib${gridnum}_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.inst

else

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_afwagrids_inst.txt | grep 'hour fcst' | $WGRIB2 -i -grib inputs.grib${gridnum}_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.inst

fi

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_afwagrids.txt | $WGRIB2 -i -grib inputs.grib${gridnum} $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib${gridnum} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib${gridnum}.uv
python $USHnam/wgrib2_parm_filter.py $PARMnam/wgrib2.txtlists/forpyscript/nam_afwagrids.txt
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

cat ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.inst > ${filnam}${fhr}.${tmmark}.grib2
rm ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.inst

rm neighbor.txt budget.txt

done

#######################################################
# Generate 3-hour precip for on-time runs.
#######################################################

file="afwacs afwahi"
                                                                                  
for filename in $file
do

if [ $cyc -eq 00 -o $cyc -eq 12 ] ; then
  if [ $fhr -ne 00 -a $fhr -ne 03 -a $fhr -ne 15 -a $fhr -ne 27 -a \
       $fhr -ne 39 -a $fhr -ne 51 -a $fhr -ne 63 -a $fhr -ne 75 ] ; then
    ${GRB2INDEX} ${filename}${fhr}.${tmmark}.grib2 ${filename}${fhr}.${tmmark}.grib2.idxbin
    bashfhr=$(echo $fhr | sed 's/^0*//')
    let fhr3=bashfhr-3
    export fhr3=$(printf "%.2d" "${fhr3#0}")  #two digit formatting in bash
    #
    # Make sure fhr3 prdgen files are available before
    # proceeding.
    #
    ic=0
    while [ ! -r $COMOUT/${RUN}.${cycle}.${filename}${fhr3}.${tmmark}.grib2.idxbin -o \
            ! -r $COMOUT/${RUN}.${cycle}.${filename}${fhr3}.${tmmark}.grib2 ] ; do
      let ic=ic+1
      if [ $ic -gt 180 ] ; then
        err_exit "F$fhr PRDGEN GIVING UP AFTER 45 MINUTES WAITING FOR F$fhr3 files"
      fi
      sleep 15
    done

    cp $COMOUT/${RUN}.${cycle}.${filename}${fhr3}.${tmmark}.grib2 ${filename}${fhr3}.${tmmark}.grib2
    cp $COMOUT/${RUN}.${cycle}.${filename}${fhr3}.${tmmark}.grib2.idxbin ${filename}${fhr3}.${tmmark}.grib2.idxbin

    IARW=0
    ISNOW=1
    ILSM=0
    pfhr1=${fhr}
    pfhr2=${fhr3}
    pfhr3=00
    pfhr4=00

    export pgm=nam_makeprecip;. prep_step
    ln -sf ${filename}${fhr3}.${tmmark}.grib2      fort.13
    ln -sf ${filename}${fhr3}.${tmmark}.grib2.idxbin  fort.14
    ln -sf ${filename}${fhr}.${tmmark}.grib2       fort.15
    ln -sf ${filename}${fhr}.${tmmark}.grib2.idxbin   fort.16
    ln -sf ${filename}.precip.${fhr}           fort.50
    ln -sf ${filename}.cprecip.${fhr}          fort.51
    ln -sf ${filename}.snow.${fhr}          fort.52
$EXECnam/nam_makeprecip << EOF >> $pgmout 2>errfile
$pfhr1 $pfhr2 $pfhr3 $pfhr4 $IARW $ISNOW $ILSM
EOF
    export err=$?;err_chk

    cat ${filename}.precip.${fhr} >> ${filename}${fhr}.${tmmark}.grib2
    cat ${filename}.cprecip.${fhr} >> ${filename}${fhr}.${tmmark}.grib2
    cat ${filename}.snow.${fhr} >> ${filename}${fhr}.${tmmark}.grib2
  fi
fi

if test $SENDCOM = 'YES'
then
    ${GRB2INDEX} ${filename}${fhr}.${tmmark}.grib2 ${filename}${fhr}.${tmmark}.grib2.idxbin
    mv ${filename}${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.${filename}${fhr}.${tmmark}.grib2
    mv ${filename}${fhr}.${tmmark}.grib2.idxbin $COMOUT/${RUN}.${cycle}.${filename}${fhr}.${tmmark}.grib2.idxbin

    if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
    then
     REGION=`echo $filename | tr '[a-z]' '[A-Z]'`
     $DBNROOT/bin/dbn_alert MODEL NAM_${REGION}_GB2 $job $COMOUT/${RUN}.${cycle}.${filename}${fhr}.${tmmark}.grib2
    fi
fi

#end region loop
done

# end hswitch test
fi

# NAM grids for AFWA only made at 3-hourly intervals, so just exit script
# with condition code=0 if hswitch not equal to zero

wait

if test "$SENDECF" = 'YES'
then
  ecflow_client --event post_6_complete
fi

echo EXITING $0

wait
