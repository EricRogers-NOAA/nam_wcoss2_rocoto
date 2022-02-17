#!/bin/bash
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         nam_prdgen2.sh
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
#                             files GRB5FM (#5) and GRBGRD (#104)
# 2002-07-15  Eric Rogers/Geoff Manikin - added AWP242
# 2003-03-18  Eric Rogers   Changed script to process special hourly
#                           output if variable hswitch is not set to zero
#
# 2005-01-10  Geoff Manikin  Added AWP150
# 2015-03-19  Eric Rogers  Converted to GRIB2
# 2016-10-31  Rogers  Removed AWP150, GRB5FM
 
set -x

export fhr=$(printf "%.2d" "${1#0}")  #two digit formatting in bash
export hswitch=$2
export PS4='PRDGEN2_F${fhr}_T$SECONDS + '
export compress_type=c3

cd $DATA/prdgen2_${fhr}

if [ $hswitch -ne 0 ] ; then

grid="104 242"

for gridnum in $grid
do

cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

if [ $gridnum -eq 104 ] 
then
  filnam=grbgrd
  gridspecs="nps:255:60 220.525:147:90755 -0.268:110:90755"
fi
if [ $gridnum -eq 242 ] 
then
  filnam=awp242
  gridspecs="nps:225:60 187.000:553:11250 30.000:425:11250"
fi

if [ $gridnum -eq 104 ] ; then 

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

if [ $gridnum -eq 242 ] ; then

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

cat ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.inst > ${filnam}${fhr}.${tmmark}.grib2
rm ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.inst
rm neighbor.txt budget.txt

fi

done

if test $SENDCOM = 'YES'
then

    mv awp242${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awp242${fhr}.${tmmark}.grib2
    $WGRIB2 $COMOUT/${RUN}.${cycle}.awp242${fhr}.${tmmark}.grib2 -s >\
      $COMOUT/${RUN}.${cycle}.awp242${fhr}.${tmmark}.grib2.idx

    mv grbgrd${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.grbgrd${fhr}.${tmmark}.grib2
    $WGRIB2 -s $COMOUT/${RUN}.${cycle}.grbgrd${fhr}.${tmmark}.grib2 >\
      $COMOUT/${RUN}.${cycle}.grbgrd${fhr}.${tmmark}.grib2.idx

    if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
    then
       $DBNROOT/bin/dbn_alert MODEL NAM_A242_GB2 $job $COMOUT/${RUN}.${cycle}.awp242${fhr}.${tmmark}.grib2
       $DBNROOT/bin/dbn_alert MODEL NAM_A242_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awp242${fhr}.${tmmark}.grib2.idx
       $DBNROOT/bin/dbn_alert MODEL NAM_GBGD_GB2 $job $COMOUT/${RUN}.${cycle}.grbgrd${fhr}.${tmmark}.grib2
       $DBNROOT/bin/dbn_alert MODEL NAM_GBGD_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.grbgrd${fhr}.${tmmark}.grib2.idx
    fi
fi

else

grid="104 242"

for gridnum in $grid
do

cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

if [ $gridnum -eq 104 ]
then
  filnam=grbgrd
  gridspecs="nps:255:60 220.525:147:90755 -0.268:110:90755"
fi
if [ $gridnum -eq 242 ]
then
  filnam=awp242
  gridspecs="nps:225:60 187.000:553:11250 30.000:425:11250"
fi

if [ $gridnum -eq 104 ] ; then

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

if [ $gridnum -eq 242 ] ; then

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

cat ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.inst > ${filnam}${fhr}.${tmmark}.grib2
rm ${filnam}${fhr}.${tmmark}.grib2.therest ${filnam}${fhr}.${tmmark}.grib2.inst
rm neighbor.txt budget.txt

fi

done

if [ $cyc -eq 06 -o $cyc -eq 18 ] ; then
  let preciphr=fhr%6
  if [ $fhr -ne 00 -a $preciphr -eq 0 ] ; then
    ${GRB2INDEX} grbgrd${fhr}.${tmmark}.grib2 grbgrd${fhr}.${tmmark}.grib2.idxbin

    bashfhr=$(echo $fhr | sed 's/^0*//')
    let fhr3=bashfhr-3
    export fhr3=$(printf "%.2d" "$fhr3")  #two digit formatting in bash
    #
    # Make sure fhr3 prdgen files are available before
    # proceeding.
    #
    ic=0
    while [ ! -r $COMOUT/${RUN}.${cycle}.grbgrd${fhr3}.${tmmark}.grib2.idxbin  -o \
            ! -r $COMOUT/${RUN}.${cycle}.grbgrd${fhr3}.${tmmark}.grib2 ] ; do
      let ic=ic+1
      if [ $ic -gt 180 ] ; then
        err_exit "F$fhr PRDGEN GIVING UP AFTER 45 MINUTES WAITING FOR F$fhr3 files"
      fi
      sleep 15
    done

# start grid 104 processing

    cp $COMOUT/${RUN}.${cycle}.grbgrd${fhr3}.${tmmark}.grib2 grbgrd${fhr3}.${tmmark}.grib2
    cp $COMOUT/${RUN}.${cycle}.grbgrd${fhr3}.${tmmark}.grib2.idxbin grbgrd${fhr3}.${tmmark}.grib2.idxbin

    IARW=0
    ISNOW=0
    ILSM=0
    pfhr1=${fhr3}
    pfhr2=${fhr}
    pfhr3=-99
    pfhr4=-01

    export pgm=nam_makeprecip;. prep_step
    ln -sf grbgrd${fhr3}.${tmmark}.grib2      fort.13
    ln -sf grbgrd${fhr3}.${tmmark}.grib2.idxbin  fort.14
    ln -sf grbgrd${fhr}.${tmmark}.grib2       fort.15
    ln -sf grbgrd${fhr}.${tmmark}.grib2.idxbin   fort.16
    ln -sf precip104.${fhr}         fort.50
    ln -sf cprecip104.${fhr}        fort.51
$EXECnam/nam_makeprecip << EOF >> $pgmout 2>errfile
$pfhr1 $pfhr2 $pfhr3 $pfhr4 $IARW $ISNOW $ILSM
EOF
    export err=$?;err_chk

    cat precip104.${fhr} >> grbgrd${fhr}.${tmmark}.grib2
    cat cprecip104.${fhr} >> grbgrd${fhr}.${tmmark}.grib2
  fi
fi
# end grid 104 processing
# end off-time cycle processing

# start grid 242 processing

if [ $cyc -eq 00 -o $cyc -eq 12 ] ; then
  if [ $fhr -ne 00 -a $fhr -ne 03 -a $fhr -ne 15 -a $fhr -ne 27 -a \
       $fhr -ne 39 -a $fhr -ne 51 -a $fhr -ne 63 -a $fhr -ne 75 ] ; then
    ${GRB2INDEX} awp242${fhr}.${tmmark}.grib2 awp242${fhr}.${tmmark}.grib2.idxbin
    bashfhr=$(echo $fhr | sed 's/^0*//')
    let fhr3=bashfhr-3
    export fhr3=$(printf "%.2d" "$fhr3")  #two digit formatting in bash

    #
    # Make sure fhr3 prdgen files are available before
    # proceeding.
    #
    ic=0
    while [ ! -r $COMOUT/${RUN}.${cycle}.awp242${fhr3}.${tmmark}.grib2.idxbin -o \
            ! -r $COMOUT/${RUN}.${cycle}.awp242${fhr3}.${tmmark}.grib2 ] ; do
      let ic=ic+1
      if [ $ic -gt 180 ] ; then
        err_exit "F$fhr PRDGEN GIVING UP AFTER 45 MINUTES WAITING FOR F$fhr3 files"
      fi
      sleep 15
    done

    cp $COMOUT/${RUN}.${cycle}.awp242${fhr3}.${tmmark}.grib2 awp242${fhr3}.${tmmark}.grib2
    cp $COMOUT/${RUN}.${cycle}.awp242${fhr3}.${tmmark}.grib2.idxbin awp242${fhr3}.${tmmark}.grib2.idxbin

    IARW=0
    ISNOW=0
    ILSM=0
    pfhr1=${fhr}
    pfhr2=${fhr3}
    pfhr3=00
    pfhr4=00

    export pgm=nam_makeprecip;. prep_step
    ln -sf awp242${fhr3}.${tmmark}.grib2      fort.13
    ln -sf awp242${fhr3}.${tmmark}.grib2.idxbin  fort.14
    ln -sf awp242${fhr}.${tmmark}.grib2       fort.15
    ln -sf awp242${fhr}.${tmmark}.grib2.idxbin   fort.16
    ln -sf precip242.${fhr}           fort.50
    ln -sf cprecip242.${fhr}          fort.51
$EXECnam/nam_makeprecip << EOF >> $pgmout 2>errfile
$pfhr1 $pfhr2 $pfhr3 $pfhr4 $IARW $ISNOW $ILSM
EOF
    export err=$?;err_chk

    cat precip242.${fhr} >> awp242${fhr}.${tmmark}.grib2
    cat cprecip242.${fhr} >> awp242${fhr}.${tmmark}.grib2
# end grid 242 processing
  fi
# end on-time cycle processing
fi

$WGRIB2 grbgrd${fhr}.${tmmark}.grib2 -s > grbgrd${fhr}.${tmmark}.grib2.idx
$WGRIB2 awp242${fhr}.${tmmark}.grib2 -s > awp242${fhr}.${tmmark}.grib2.idx
${GRB2INDEX} grbgrd${fhr}.${tmmark}.grib2 grbgrd${fhr}.${tmmark}.grib2.idxbin
${GRB2INDEX} awp242${fhr}.${tmmark}.grib2 awp242${fhr}.${tmmark}.grib2.idxbin

if test $SENDCOM = 'YES'
then
    mv grbgrd${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.grbgrd${fhr}.${tmmark}.grib2
    mv awp242${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awp242${fhr}.${tmmark}.grib2
    mv grbgrd${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.grbgrd${fhr}.${tmmark}.grib2.idx
    mv awp242${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awp242${fhr}.${tmmark}.grib2.idx
    mv grbgrd${fhr}.${tmmark}.grib2.idxbin $COMOUT/${RUN}.${cycle}.grbgrd${fhr}.${tmmark}.grib2.idxbin
    mv awp242${fhr}.${tmmark}.grib2.idxbin $COMOUT/${RUN}.${cycle}.awp242${fhr}.${tmmark}.grib2.idxbin

   if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
   then
      $DBNROOT/bin/dbn_alert MODEL NAM_GBGD_GB2 $job $COMOUT/${RUN}.${cycle}.grbgrd${fhr}.${tmmark}.grib2
      $DBNROOT/bin/dbn_alert MODEL NAM_GBGD_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.grbgrd${fhr}.${tmmark}.grib2.idx
      $DBNROOT/bin/dbn_alert MODEL NAM_A242_GB2 $job $COMOUT/${RUN}.${cycle}.awp242${fhr}.${tmmark}.grib2
      $DBNROOT/bin/dbn_alert MODEL NAM_A242_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awp242${fhr}.${tmmark}.grib2.idx
   fi
fi

# end hswitch test
fi

if test "$SENDECF" = 'YES'
then
  ecflow_client --event post_2_complete
fi

echo EXITING $0
exit
