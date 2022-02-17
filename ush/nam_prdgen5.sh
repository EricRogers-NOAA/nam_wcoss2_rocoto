#!/bin/bash
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         nam_prdgen5.sh
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
#                           - Split up prdgen into 5 separate jobs for
#                             timely nam-12 output. This job processes
#                             grids AWPHYS (#218)
# 2002-01-04  Eric Rogers   Added special 12 km grid (#251) for Salt
#                           Lake City Olympic Support
# 2002-03-19  Eric Rogers   Removed special 12 km grid (#251) for Salt
#                           Lake City Olympic Support
# 2003-03-18  Eric Rogers   Added 1/8 lat/lon CONUS grid #110 (LDAS grid);
#                           changed script to process special hourly
#                           output if variable hswitch is not set to zero
# 2015-03-19  Eric Rogers   Converted to GRIB2
#

set -x

export fhr=$(printf "%.2d" "${1#0}")  #two digit formatting in bash
export hswitch=$2
export PS4='PRDGEN5_F${fhr}_T$SECONDS + '
export compress_type=c3

cd $DATA/prdgen5_${fhr}

# Append a suffix for plotting 218 anl and ges fields
if [ $fhr -eq 00 -a $tmmark != tm00 ]; then
  if [ $tmmark = tm06 ]; then
    sufs=".anl .ges None"  #have to do a little extra work at tm06 to get the ges included here
  else
    sufs=".anl None"
  fi
else
  sufs="None"
fi

grid="110 218"

for gridnum in ${grid}; do

  cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

  if [ $gridnum -eq 110 ]; then
    filnam=awldas
    gridspecs="latlon 235.0625:464:.125 25.0625:224:.125"

    $WGRIB2 $DATA/BGDAWP${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}.txt | $WGRIB2 -i -grib inputs.grib${gridnum} $DATA/BGDAWP${fhr}.${tmmark}
    $WGRIB2 inputs.grib${gridnum} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib${gridnum}.uv
    $WGRIB2 inputs.grib${gridnum}.uv -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
    -new_grid_interpolation neighbor -if ":(WEASD|APCP|NCPCP|ACPCP|SNOD):" -new_grid_interpolation budget -fi -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.uv
    $WGRIB2 ${filnam}${fhr}.${tmmark}.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv ${filnam}${fhr}.${tmmark}.grib2
    export err=$?;err_chk

  elif [ $gridnum -eq 218 ]; then

    filnam=awphys
    gridspecs="lambert:265:25:25 226.541:614:12191 12.190:428:12191"

# Insert some extra steps in the event we need to make prdgen
#  files for the analysis

    for suf in ${sufs}; do

      if [ ${suf} == "None" ]; then
        suf=""
      fi
      if [ $fhr -eq 00 ] ; then
        mygrep=':anl:'
      else
        mygrep='hour fcst'
      fi

      $WGRIB2 $DATA/BGDAWP${fhr}.${tmmark}${suf} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}_inst.txt | grep "${mygrep}" | $WGRIB2 -i -grib inputs.grib${gridnum}_inst${suf} $DATA/BGDAWP${fhr}.${tmmark}${suf}
      $WGRIB2 inputs.grib${gridnum}_inst${suf} -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
         -new_grid_interpolation bilinear \
         -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.grib2.inst${suf}

      $WGRIB2 $DATA/BGDAWP${fhr}.${tmmark}${suf} | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}.txt | $WGRIB2 -i -grib inputs.grib${gridnum}${suf} $DATA/BGDAWP${fhr}.${tmmark}${suf}
      $WGRIB2 inputs.grib${gridnum}${suf} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib${gridnum}.uv${suf}
      python $USHnam/wgrib2_parm_filter.py $PARMnam/wgrib2.txtlists/forpyscript/nam_${filnam}.txt
      #Extract NEIGHBOR and BUDGET envars
      NEIGHBOR=`cat neighbor.txt`
      BUDGET=`cat budget.txt`
      $WGRIB2 inputs.grib${gridnum}.uv${suf} -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
         -new_grid_interpolation bilinear \
         -if $NEIGHBOR -new_grid_interpolation neighbor -fi \
         -if $BUDGET -new_grid_interpolation budget -fi \
         -new_grid ${gridspecs} ${filnam}${fhr}.${tmmark}.uv${suf}
      $WGRIB2 ${filnam}${fhr}.${tmmark}.uv${suf} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv ${filnam}${fhr}.${tmmark}.grib2.therest${suf}
      export err=$?;err_chk

      cat ${filnam}${fhr}.${tmmark}.grib2.therest${suf} ${filnam}${fhr}.${tmmark}.grib2.inst${suf} > ${filnam}${fhr}.${tmmark}.grib2${suf}
      rm ${filnam}${fhr}.${tmmark}.grib2.therest${suf} ${filnam}${fhr}.${tmmark}.grib2.inst${suf}
      rm neighbor.txt budget.txt

    done # Loops over suffixes

  fi # grid 218 or 110

done # Loop over grid types

if [ $hswitch -eq 0 ] ; then
#######################################################
# Generate 3-hour precip for on-time runs.
#######################################################
if [ $cyc -eq 00 -o $cyc -eq 12 ] ; then
  if [ $fhr -ne 00 -a $fhr -ne 03 -a $fhr -ne 15 -a $fhr -ne 27 -a \
       $fhr -ne 39 -a $fhr -ne 51 -a $fhr -ne 63 -a $fhr -ne 75 ] ; then
    ${GRB2INDEX} awphys${fhr}.${tmmark}.grib2 awphys${fhr}.${tmmark}.grib2.idxbin
    bashfhr=$(echo $fhr | sed 's/^0*//')
    let fhr3=bashfhr-3
    export fhr3=$(printf "%.2d" "${fhr3#0}")  #two digit formatting in bash
    #
    # Make sure fhr3 prdgen files are available before
    # proceeding.
    #
    ic=0
    while [ ! -r $COMOUT/${RUN}.${cycle}.awphys${fhr3}.${tmmark}.grib2 -o \
            ! -r $COMOUT/${RUN}.${cycle}.awphys${fhr3}.${tmmark}.grib2.idxbin ] ; do
      let ic=ic+1
      if [ $ic -gt 180 ] ; then
        err_exit "F$fhr PRDGEN GIVING UP AFTER 45 MINUTES WAITING FOR F$fhr3 files"
      fi
      sleep 15
    done

# start grid 218 processing

    cp $COMOUT/${RUN}.${cycle}.awphys${fhr3}.${tmmark}.grib2 awphys${fhr3}.${tmmark}.grib2
    cp $COMOUT/${RUN}.${cycle}.awphys${fhr3}.${tmmark}.grib2.idxbin awphys${fhr3}.${tmmark}.grib2.idxbin

    IARW=0
    ISNOW=1
    ILSM=0
    pfhr1=${fhr}
    pfhr2=${fhr3}
    pfhr3=00
    pfhr4=00

    export pgm=nam_makeprecip;. prep_step
    ln -sf awphys${fhr3}.${tmmark}.grib2      fort.13
    ln -sf awphys${fhr3}.${tmmark}.grib2.idxbin  fort.14
    ln -sf awphys${fhr}.${tmmark}.grib2       fort.15
    ln -sf awphys${fhr}.${tmmark}.grib2.idxbin   fort.16
    ln -sf precip218.${fhr}           fort.50
    ln -sf cprecip218.${fhr}          fort.51
    ln -sf snow218.${fhr}             fort.52
$EXECnam/nam_makeprecip << EOF >> $pgmout 2>errfile
$pfhr1 $pfhr2 $pfhr3 $pfhr4 $IARW $ISNOW $ILSM
EOF
    export err=$?;err_chk

    cat precip218.${fhr} >> awphys${fhr}.${tmmark}.grib2
    cat cprecip218.${fhr} >> awphys${fhr}.${tmmark}.grib2
#   cat snow218.${fhr} >> awphys${fhr}.${tmmark}.grib2

  fi # fhr test
fi # end on-time cycle processing
  #end hswitch test
fi

# Transfer data over to COMOUT?

if test $SENDCOM = 'YES'
then
  $WGRIB2 awldas${fhr}.${tmmark}.grib2 -s > awldas${fhr}.${tmmark}.grib2.idx
  mv awldas${fhr}.${tmmark}.grib2 $COMOUT/${RUN}.${cycle}.awldas${fhr}.${tmmark}.grib2
  mv awldas${fhr}.${tmmark}.grib2.idx $COMOUT/${RUN}.${cycle}.awldas${fhr}.${tmmark}.grib2.idx
 
  for suf in ${sufs}; do
    if [ ${suf} == "None" -o $fhr -gt 00 ]; then
      suf=""
    fi
    $WGRIB2 awphys${fhr}.${tmmark}.grib2${suf} -s > awphys${fhr}.${tmmark}.grib2.idx${suf}
    ${GRB2INDEX} awphys${fhr}.${tmmark}.grib2${suf} awphys${fhr}.${tmmark}.grib2.idxbin${suf}
    mv awphys${fhr}.${tmmark}.grib2${suf} $COMOUT/${RUN}.${cycle}.awphys${fhr}.${tmmark}.grib2${suf}
    mv awphys${fhr}.${tmmark}.grib2.idx${suf} $COMOUT/${RUN}.${cycle}.awphys${fhr}.${tmmark}.grib2.idx${suf}
    mv awphys${fhr}.${tmmark}.grib2.idxbin${suf} $COMOUT/${RUN}.${cycle}.awphys${fhr}.${tmmark}.grib2.idxbin${suf}
  done

fi

if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
then
  $DBNROOT/bin/dbn_alert MODEL NAM_AWLD_GB2 $job $COMOUT/${RUN}.${cycle}.awldas${fhr}.${tmmark}.grib2
  $DBNROOT/bin/dbn_alert MODEL NAM_AWLD_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awldas${fhr}.${tmmark}.grib2.idx
  for suf in ${sufs}; do
    if [ ${suf} == "None" -o $fhr -gt 00 ]; then
      suf=""
    fi
    $DBNROOT/bin/dbn_alert MODEL NAM_218_GB2${suf} $job $COMOUT/${RUN}.${cycle}.awphys${fhr}.${tmmark}.grib2${suf}
    $DBNROOT/bin/dbn_alert MODEL NAM_218_GB2_WIDX${suf} $job $COMOUT/${RUN}.${cycle}.awphys${fhr}.${tmmark}.grib2.idx${suf}
  done
fi

if test "$SENDECF" = 'YES'
then
  ecflow_client --event post_5_complete
fi

echo EXITING $0
exit $err
