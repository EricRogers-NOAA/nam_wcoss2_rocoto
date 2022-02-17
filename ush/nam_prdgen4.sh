#!/bin/bash
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         nam_prdgen4.sh
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
#                             timely nam-12 output. This job processes
#                             grids GRB_FM (#6,101), AWIP44 (#209),
#                             AWIP12 (#218), AWIP88 (#222)
# 2002-07-10  Geoff Manikin - added 3-hour precip buckets to grid 218
# 2003-03-18  Eric Rogers   Changed script to process special hourly
#                           output if variable hswitch is not set to zero
# 2015-03-20  Eric Rogers   Converted to GRIB2
# 2016-10-31  Eric Rogers   Removed awip44
#

set -x

export fhr=$(printf "%.2d" "${1#0}")  #two digit formatting in bash
export hswitch=$2
export PS4='PRDGEN4_F${fhr}_T$SECONDS + '
export compress_type=c3

cd $DATA/prdgen4_${fhr}

if [ $hswitch -ne 0 ] ; then

cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

gridspecs_218="lambert:265:25:25 226.541:614:12191 12.190:428:12191"

if [ $fhr -eq 00 ] ; then

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_awip12_inst.txt | grep ':anl:' | $WGRIB2 -i -grib inputs.grib218_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib218_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs_218} awip12${fhr}.${tmmark}.grib2.inst

else

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_awip12_inst.txt | grep 'hour fcst' | $WGRIB2 -i -grib inputs.grib218_inst $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib218_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -new_grid ${gridspecs_218} awip12${fhr}.${tmmark}.grib2.inst

fi

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_awip12.txt | $WGRIB2 -i -grib inputs.grib218 $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib218 -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib218.uv
python $USHnam/wgrib2_parm_filter.py $PARMnam/wgrib2.txtlists/forpyscript/nam_awip12.txt
#Extract NEIGHBOR and BUDGET envars
NEIGHBOR=`cat neighbor.txt`
BUDGET=`cat budget.txt`
$WGRIB2 inputs.grib218.uv -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -if $NEIGHBOR -new_grid_interpolation neighbor -fi \
     -if $BUDGET -new_grid_interpolation budget -fi \
     -new_grid ${gridspecs_218} awip12${fhr}.${tmmark}.uv
$WGRIB2 awip12${fhr}.${tmmark}.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv awip12${fhr}.${tmmark}.grib2.therest
export err=$?;err_chk

cat awip12${fhr}.${tmmark}.grib2.therest awip12${fhr}.${tmmark}.grib2.inst > awip12${fhr}.${tmmark}.grib2
rm awip12${fhr}.${tmmark}.grib2.therest awip12${fhr}.${tmmark}.grib2.inst
rm neighbor.txt budget.txt

if test $SENDCOM = 'YES'
then

    $WGRIB2 awip12${fhr}.${tmmark}.grib2 -s > awip12${fhr}.${tmmark}.grib2.idx
    mv awip12${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.t${cyc}z.awip12${fhr}.${tmmark}.grib2.idx
    mv awip12${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.t${cyc}z.awip12${fhr}.${tmmark}.grib2

#   if [ $tmmark = tm00 ] ; then
#     FILE=$COMOUT/${RUN}.${cycle}.awip12${fhr}.${tmmark}
#     GRIB_LIST="UGRD:10 m.a|VGRD:10 m.a"
#     $WGRIB2 -s ${FILE}.grib2 | egrep "$GRIB_LIST" | $WGRIB2 ${FILE}.grib2 -s -i -grib ${FILE}.10m.uv.grib2
#     $WGRIB2 -s ${FILE}.10m.uv.grib2 > ${FILE}.10m.uv.grib2.idx
#   fi

    if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
    then
     $DBNROOT/bin/dbn_alert MODEL NAM_AW12_GB2 $job $COMOUT/${RUN}.${cycle}.awip12${fhr}.${tmmark}.grib2
     $DBNROOT/bin/dbn_alert MODEL NAM_AW12_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awip12${fhr}.${tmmark}.grib2.idx
#    $DBNROOT/bin/dbn_alert MODEL NAM_AW12_USCG_GB2 $job $COMOUT/${RUN}.${cycle}.awip12${fhr}.tm00.10m.uv.grib2
#    $DBNROOT/bin/dbn_alert MODEL NAM_AW12_USCG_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awip12${fhr}.tm00.10m.uv.grib2.idx
    fi
fi

else

gridspecs_006="nps:255:60 226.557:53:190500 7.647:45:190500"
gridspecs_101="nps:255:60 222.854:113:91452 10.528:91:91452"

cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_grb_fm_grid006.txt | $WGRIB2 -i -grib inputs.grib006 $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib006 -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib006.uv
python $USHnam/wgrib2_parm_filter.py $PARMnam/wgrib2.txtlists/forpyscript/nam_grb_fm_grid006.txt
#Extract NEIGHBOR and BUDGET envars
BUDGET=`cat budget.txt`
$WGRIB2 inputs.grib006.uv -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -if $BUDGET -new_grid_interpolation budget -fi \
     -new_grid ${gridspecs_006} grb_fm${fhr}.${tmmark}.uv_006
$WGRIB2 grb_fm${fhr}.${tmmark}.uv_006 -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv grb_fm${fhr}.${tmmark}_006
export err=$?;err_chk

rm neighbor.txt budget.txt

$WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_grb_fm_grid101.txt | $WGRIB2 -i -grib inputs.grib101 $DATA/BGDAWP${fhr}.${tmmark}
$WGRIB2 inputs.grib101 -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib101.uv
python $USHnam/wgrib2_parm_filter.py $PARMnam/wgrib2.txtlists/forpyscript/nam_grb_fm_grid101.txt
#Extract BUDGET envars
BUDGET=`cat budget.txt`
$WGRIB2 inputs.grib101.uv -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -if $BUDGET -new_grid_interpolation budget -fi \
     -new_grid ${gridspecs_101} grb_fm${fhr}.${tmmark}.uv_101
$WGRIB2 grb_fm${fhr}.${tmmark}.uv_101 -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv grb_fm${fhr}.${tmmark}_101
export err=$?;err_chk

rm budget.txt

cat grb_fm${fhr}.${tmmark}_006 grb_fm${fhr}.${tmmark}_101 > grb_fm${fhr}.${tmmark}.grib2
rm grb_fm${fhr}.${tmmark}_006 grb_fm${fhr}.${tmmark}_101 grb_fm${fhr}.${tmmark}.uv_006 grb_fm${fhr}.${tmmark}.uv_101

grid="218 242"

for gridnum in $grid
do

cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

if [ $gridnum -eq 218 ]
then
  filnam=awip12
  gridspecs="lambert:265:25:25 226.541:614:12191 12.190:428:12191"
fi
if [ $gridnum -eq 242 ]
then
  filnam=awak3d
  gridspecs="nps:225:60 187.000:553:11250 30.000:425:11250"
fi

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

done

#######################################################
# Generate 3-hour precip for on-time runs.
#######################################################
if [ $cyc -eq 00 -o $cyc -eq 12 ] ; then
  if [ $fhr -ne 00 -a $fhr -ne 03 -a $fhr -ne 15 -a $fhr -ne 27 -a \
       $fhr -ne 39 -a $fhr -ne 51 -a $fhr -ne 63 -a $fhr -ne 75 ] ; then
    ${GRB2INDEX} awip12${fhr}.${tmmark}.grib2 awip12${fhr}.${tmmark}.grib2.idxbin
    ${GRB2INDEX} awak3d${fhr}.${tmmark}.grib2 awak3d${fhr}.${tmmark}.grib2.idxbin
    bashfhr=$(echo $fhr | sed 's/^0*//')
    let fhr3=bashfhr-3
    export fhr3=$(printf "%.2d" "${fhr3#0}")  #two digit formatting in bash
    #
    # Make sure fhr3 prdgen files are available before
    # proceeding.
    #
    ic=0
    while [ ! -r $COMOUT/${RUN}.${cycle}.awip12${fhr3}.${tmmark}.grib2.idxbin -o \
            ! -r $COMOUT/${RUN}.${cycle}.awak3d${fhr3}.${tmmark}.grib2.idxbin -o \
            ! -r $COMOUT/${RUN}.${cycle}.awip12${fhr3}.${tmmark}.grib2 -o \
            ! -r $COMOUT/${RUN}.${cycle}.awak3d${fhr3}.${tmmark}.grib2 ] ; do
      let ic=ic+1
      if [ $ic -gt 180 ] ; then
        err_exit "F$fhr PRDGEN GIVING UP AFTER 45 MINUTES WAITING FOR F$fhr3 files"
      fi
      sleep 15
    done

# start grid 218 processing

    cp $COMOUT/${RUN}.${cycle}.awip12${fhr3}.${tmmark}.grib2 awip12${fhr3}.${tmmark}.grib2
    cp $COMOUT/${RUN}.${cycle}.awip12${fhr3}.${tmmark}.grib2.idxbin awip12${fhr3}.${tmmark}.grib2.idxbin

    IARW=0
    ISNOW=0
    ILSM=0
    pfhr1=${fhr}
    pfhr2=${fhr3}
    pfhr3=00
    pfhr4=00

    export pgm=nam_makeprecip;. prep_step
    ln -sf awip12${fhr3}.${tmmark}.grib2      fort.13
    ln -sf awip12${fhr3}.${tmmark}.grib2.idxbin  fort.14
    ln -sf awip12${fhr}.${tmmark}.grib2       fort.15
    ln -sf awip12${fhr}.${tmmark}.grib2.idxbin   fort.16
    ln -sf precip218.${fhr}           fort.50
    ln -sf cprecip218.${fhr}          fort.51
$EXECnam/nam_makeprecip << EOF >> $pgmout 2>errfile
$pfhr1 $pfhr2 $pfhr3 $pfhr4 $IARW $ISNOW $ILSM
EOF
export err=$?;err_chk

    cat precip218.${fhr} >> awip12${fhr}.${tmmark}.grib2
    cat cprecip218.${fhr} >> awip12${fhr}.${tmmark}.grib2

# end grid 218 processing

# start grid 242 processing
                  
    cp $COMOUT/${RUN}.${cycle}.awak3d${fhr3}.${tmmark}.grib2 awak3d${fhr3}.${tmmark}.grib2
    cp $COMOUT/${RUN}.${cycle}.awak3d${fhr3}.${tmmark}.grib2.idxbin awak3d${fhr3}.${tmmark}.grib2.idxbin

    IARW=0
    ISNOW=0
    ILSM=0
    pfhr1=${fhr}
    pfhr2=${fhr3}
    pfhr3=00
    pfhr4=00

    export pgm=nam_makeprecip;. prep_step
    ln -sf awak3d${fhr3}.${tmmark}.grib2      fort.13
    ln -sf awak3d${fhr3}.${tmmark}.grib2.idxbin  fort.14
    ln -sf awak3d${fhr}.${tmmark}.grib2       fort.15
    ln -sf awak3d${fhr}.${tmmark}.grib2.idxbin   fort.16
    ln -sf precip242.${fhr}           fort.50
    ln -sf cprecip242.${fhr}          fort.51
$EXECnam/nam_makeprecip << EOF >> $pgmout 2>errfile
$pfhr1 $pfhr2 $pfhr3 $pfhr4 $IARW $ISNOW $ILSM
EOF
export err=$?;err_chk

    cat precip242.${fhr} >> awak3d${fhr}.${tmmark}.grib2
    cat cprecip242.${fhr} >> awak3d${fhr}.${tmmark}.grib2
# end grid 242 processing
  fi
# end on-time cycle processing
fi

#############################
$WGRIB2 awip12${fhr}.${tmmark}.grib2 -s > awip12${fhr}.${tmmark}.grib2.idx
$WGRIB2 grb_fm${fhr}.${tmmark}.grib2 -s > grb_fm${fhr}.${tmmark}.grib2.idx
$WGRIB2 awak3d${fhr}.${tmmark}.grib2 -s > awak3d${fhr}.${tmmark}.grib2.idx

${GRB2INDEX} awip12${fhr}.${tmmark}.grib2 awip12${fhr}.${tmmark}.grib2.idxbin
${GRB2INDEX} awak3d${fhr}.${tmmark}.grib2 awak3d${fhr}.${tmmark}.grib2.idxbin

if test $SENDCOM = 'YES'
then

    mv awak3d${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awak3d${fhr}.${tmmark}.grib2
    mv awak3d${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awak3d${fhr}.${tmmark}.grib2.idx
    mv awip12${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awip12${fhr}.${tmmark}.grib2
    mv awip12${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awip12${fhr}.${tmmark}.grib2.idx
    mv grb_fm${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.grb_fm${fhr}.${tmmark}.grib2
    mv grb_fm${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.grb_fm${fhr}.${tmmark}.grib2.idx

    mv awip12${fhr}.${tmmark}.grib2.idxbin $COMOUT/${RUN}.${cycle}.awip12${fhr}.${tmmark}.grib2.idxbin
    mv awak3d${fhr}.${tmmark}.grib2.idxbin $COMOUT/${RUN}.${cycle}.awak3d${fhr}.${tmmark}.grib2.idxbin

    if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
    then
     $DBNROOT/bin/dbn_alert MODEL NAM_AW12_GB2 $job $COMOUT/${RUN}.${cycle}.awip12${fhr}.${tmmark}.grib2
     $DBNROOT/bin/dbn_alert MODEL NAM_AW12_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awip12${fhr}.${tmmark}.grib2.idx
     $DBNROOT/bin/dbn_alert MODEL NAM_A242_3D_GB2 $job $COMOUT/nam.t${cyc}z.awak3d${fcsthrs}.tm00.grib2
     $DBNROOT/bin/dbn_alert MODEL NAM_A242_3D_GB2_WIDX $job $COMOUT/nam.t${cyc}z.awak3d${fcsthrs}.tm00.grib2.idx
#    $DBNROOT/bin/dbn_alert MODEL NAM_AW12_USCG_GB2 $job $COMOUT/${RUN}.${cycle}.awip12${fhr}.tm00.10m.uv.grib2
#    $DBNROOT/bin/dbn_alert MODEL NAM_AW12_USCG_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awip12${fhr}.tm00.10m.uv.grib2.idx
    fi
fi

# end hswitch test
fi

if test "$SENDECF" = 'YES'
then
  ecflow_client --event post_4_complete
fi

echo EXITING $0
 exit
