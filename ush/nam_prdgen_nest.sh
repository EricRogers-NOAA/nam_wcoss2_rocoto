#!/bin/bash
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         nam_prdgen_nest.sh
# Script description:  Run nam product generator jobs for NAM nests
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
# 2010-03-03  Eric Rogers   Version for nested NAM output
# 2015-03-31  Eric Rogers   Convert to GRIB2
#

set -x

export fhr=$(printf "%.2d" "${1#0}")  #two digit formatting in bash
export hswitch=$2
export PS4='PRDGEN${fhr}_T$SECONDS + '

DOMAIN=`echo $domain | tr '[a-z]' '[A-Z]'`

cd $DATA/prdgen_${domain}_${fhr}

if [ $domain = hawaii ] ; then
area=hawaii
gridspecs="mercator:20 198.475:321:2500:206.131 18.073:225:2500:23.088"
compress_type=jpeg
fi
if [ $domain = prico ] ; then
area=prico
gridspecs="mercator:20 284.5:544:2500:297.491 15.0:310:2500:22.005"
compress_type=jpeg
fi
if [ $domain = alaska ] ; then
area=alaska
gridspecs="nps:210:60 181.429:1649:2976 40.530:1105:2976"
compress_type=c3
fi
if [ $domain = conus ] ; then
area=conus
gridspecs="lambert:262.5:38.5:38.5 237.280:1799:3000 21.138:1059:3000"
compress_type=c3
fi

if [ $domain = firewx ] 
then

#set GTYPE=2 for GRIB2
GTYPE=2

compress_type=jpeg

if [ $firewx_location = alaska ]
then
 regtag=ALASKA
else
 regtag=CONUS
fi

cat > itagfw <<EOF
$regtag
$GTYPE
EOF

export pgm=nam_firewx_gridspecs
. prep_step

export FORT11=$COMOUT/${RUN}.t${cyc}z.latlons_corners_firewxnest.txt.f${fhr}
export FORT45=itagfw

startmsg

$EXECnam/nam_firewx_gridspecs >> $pgmout 2>errfile
export err=$?;err_chk

gridspecs=`head copygb_gridnavfw.txt`

if [ $fhr -eq 00 ] ; then

$WGRIB2 $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_nests.hiresf_inst.txt | grep ':anl:' | $WGRIB2 -i -grib inputs.grib${domain}_inst $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark}
$WGRIB2 inputs.grib${domain}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation neighbor \
     -new_grid ${gridspecs} ${domain}nest.hiresf${fhr}.${tmmark}.inst

else

$WGRIB2 $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_nests.hiresf_inst.txt | grep 'hour fcst' | $WGRIB2 -i -grib inputs.grib${domain}_inst $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark}
$WGRIB2 inputs.grib${domain}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation neighbor \
     -new_grid ${gridspecs} ${domain}nest.hiresf${fhr}.${tmmark}.inst

fi

$WGRIB2 $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_nests.hiresf_nn.txt | $WGRIB2 -i -grib inputs.grib${domain} $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark}
$WGRIB2 inputs.grib${domain} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib${domain}.uv
$WGRIB2 $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark} -match ":(APCP|WEASD|SNOD):" -grib inputs.grib${domain}.uv_budget

$WGRIB2 inputs.grib${domain}.uv -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_interpolation neighbor -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -new_grid ${gridspecs} ${domain}nest.hiresf${fhr}.${tmmark}.uv
$WGRIB2 ${domain}nest.hiresf${fhr}.${tmmark}.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv ${domain}nest.hiresf${fhr}.${tmmark}.nn

$WGRIB2 inputs.grib${domain}.uv_budget -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_interpolation budget -new_grid ${gridspecs} ${domain}nest.hiresf${fhr}.${tmmark}.budget

cat ${domain}nest.hiresf${fhr}.${tmmark}.nn ${domain}nest.hiresf${fhr}.${tmmark}.budget ${domain}nest.hiresf${fhr}.${tmmark}.inst > ${domain}nest.hiresf${fhr}.${tmmark}
export err=$?;err_chk

$WGRIB2 ${domain}nest.hiresf${fhr}.${tmmark} -s > ${domain}nest.hiresf${fhr}.${tmmark}.idx

if [ $err -ne 0 -a $fhr -eq "00" ]; then
  if test "$SENDECF" = 'YES'
  echo $PDY `grep ${cyc}z $COM_IN/input/nam_firewx_loc` >> $COM_OUT/input/nam_firewx_badpoint
  then
    ecflow_client --run /prod${cyc}/nam${cyc}/nest_firewx/jnam_firewx_badpoint_alert
  fi
fi

mv copygb_gridnavfw.txt $COMOUT/${RUN}.t${cyc}z.copygb_gridnavfw.txt
mv gridnavfw.ijdims.txt $COMOUT/${RUN}.t${cyc}z.gridnavfw.ijdims.txt

if test $SENDCOM = 'YES'
then
  mv ${domain}nest.hiresf${fhr}.${tmmark} $COMOUT/${RUN}.t${cyc}z.${domain}nest.hiresf${fhr}.${tmmark}.grib2
  mv ${domain}nest.hiresf${fhr}.${tmmark}.idx $COMOUT/${RUN}.t${cyc}z.${domain}nest.hiresf${fhr}.${tmmark}.grib2.idx
fi

if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
then
 $DBNROOT/bin/dbn_alert MODEL NAM_${DOMAIN}NEST_GB2 $job $COMOUT/${RUN}.t${cyc}z.${domain}nest.hiresf${fhr}.${tmmark}.grib2
 $DBNROOT/bin/dbn_alert MODEL NAM_${DOMAIN}NEST_GB2_WIDX $job $COMOUT/${RUN}.t${cyc}z.${domain}nest.hiresf${fhr}.${tmmark}.grib2.idx
fi

$USHnam/nam_nawips_firewx.sh ${fhr}
export err=$?;err_chk

else

if [ $fhr -eq 00 ] ; then

$WGRIB2 $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_nests.hiresf_inst.txt | grep ':anl:' | $WGRIB2 -i -grib inputs.grib${domain}_inst $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark}
$WGRIB2 inputs.grib${domain}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation neighbor \
     -new_grid ${gridspecs} ${domain}nest.hiresf${fhr}.${tmmark}.inst

else

$WGRIB2 $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_nests.hiresf_inst.txt | grep 'hour fcst' | $WGRIB2 -i -grib inputs.grib${domain}_inst $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark}
$WGRIB2 inputs.grib${domain}_inst -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation neighbor \
     -new_grid ${gridspecs} ${domain}nest.hiresf${fhr}.${tmmark}.inst

fi

$WGRIB2 $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_nests.hiresf_nn.txt | $WGRIB2 -i -grib inputs.grib${domain} $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark}
$WGRIB2 inputs.grib${domain} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib${domain}.uv
$WGRIB2 $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark} -match ":(APCP|WEASD|SNOD):" -grib inputs.grib${domain}.uv_budget

$WGRIB2 inputs.grib${domain}.uv -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_interpolation neighbor -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -new_grid ${gridspecs} ${domain}nest.hiresf${fhr}.${tmmark}.uv
$WGRIB2 ${domain}nest.hiresf${fhr}.${tmmark}.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv ${domain}nest.hiresf${fhr}.${tmmark}.nn

$WGRIB2 inputs.grib${domain}.uv_budget -set_bitmap 1 -set_grib_type ${compress_type} -new_grid_winds grid -new_grid_interpolation budget -new_grid ${gridspecs} ${domain}nest.hiresf${fhr}.${tmmark}.budget
cat ${domain}nest.hiresf${fhr}.${tmmark}.nn ${domain}nest.hiresf${fhr}.${tmmark}.budget ${domain}nest.hiresf${fhr}.${tmmark}.inst > ${domain}nest.hiresf${fhr}.${tmmark}
export err=$?;err_chk

$WGRIB2 ${domain}nest.hiresf${fhr}.${tmmark} -s > ${domain}nest.hiresf${fhr}.${tmmark}.idx

if test $SENDCOM = 'YES'
then
  mv ${domain}nest.hiresf${fhr}.${tmmark} $COMOUT/${RUN}.t${cyc}z.${domain}nest.hiresf${fhr}.${tmmark}.grib2
  mv ${domain}nest.hiresf${fhr}.${tmmark}.idx $COMOUT/${RUN}.t${cyc}z.${domain}nest.hiresf${fhr}.${tmmark}.grib2.idx
fi

if [ $domain = conus -o $domain = alaska ] ; then

  # Special grid for NOS

  INPUTnos=$COMOUT/${RUN}.t${cyc}z.${domain}nest.hiresf${fhr}.${tmmark}.grib2

  $WGRIB2 $INPUTnos | grep -F -f $PARMnam/wgrib2.txtlists/nam_conusnest.parmlist_nos | $WGRIB2 -i -grib ${domain}nest.hiresf${fhr}.${tmmark}.nos $INPUTnos

  if test $SENDCOM = 'YES'
  then
    mv ${domain}nest.hiresf${fhr}.${tmmark}.nos $COMOUT/${RUN}.t${cyc}z.${domain}nest.hiresf${fhr}.${tmmark}.grib2_nos
    export err=$?;err_chk
  fi

  #end conus/alaska test
fi

if [ $domain = conus ] ; then

# GRID w/CAM fields

  $WGRIB2 $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark} | grep -F -f $PARMnam/wgrib2.txtlists/nam_conusnest_camlist.txt | $WGRIB2 -i -grib inputs.cam${domain} $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark}
  $WGRIB2 inputs.cam${domain} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.cam${domain}.uv
  $WGRIB2 $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark} -match ":(APCP|WEASD|SNOD):" -grib inputs.cam${domain}.uv_budget

  $WGRIB2 inputs.cam${domain}.uv -set_bitmap 1 -set_grib_type c3 -new_grid_winds grid -new_grid_interpolation neighbor -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -new_grid ${gridspecs} ${domain}nest.camfld${fhr}.${tmmark}.uv
  $WGRIB2 ${domain}nest.camfld${fhr}.${tmmark}.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv ${domain}nest.camfld${fhr}.${tmmark}.nn

  $WGRIB2 inputs.cam${domain}.uv_budget -set_bitmap 1 -set_grib_type c3 -new_grid_winds grid -new_grid_interpolation budget -new_grid ${gridspecs} ${domain}nest.camfld${fhr}.${tmmark}.budget
  cat ${domain}nest.camfld${fhr}.${tmmark}.nn ${domain}nest.camfld${fhr}.${tmmark}.budget > ${domain}nest.camfld${fhr}.${tmmark}
  export err=$?;err_chk
  $WGRIB2 ${domain}nest.camfld${fhr}.${tmmark} -s >  ${domain}nest.camfld${fhr}.${tmmark}.idx

  if test $SENDCOM = 'YES'
  then
    mv ${domain}nest.camfld${fhr}.${tmmark} $COMOUT/${RUN}.t${cyc}z.${domain}nest.camfld${fhr}.${tmmark}.grib2
    mv ${domain}nest.camfld${fhr}.${tmmark}.idx $COMOUT/${RUN}.t${cyc}z.${domain}nest.camfld${fhr}.${tmmark}.grib2.idx
  fi

  #end conus test
fi

if [ $SENDDBN = 'YES' -a $tmmark = tm00 ]
then
 $DBNROOT/bin/dbn_alert MODEL NAM_${DOMAIN}NEST_GB2 $job $COMOUT/${RUN}.t${cyc}z.${domain}nest.hiresf${fhr}.${tmmark}.grib2
 $DBNROOT/bin/dbn_alert MODEL NAM_${DOMAIN}NEST_GB2_WIDX $job $COMOUT/${RUN}.t${cyc}z.${domain}nest.hiresf${fhr}.${tmmark}.grib2.idx
 [ $domain = "conus" ] && $DBNROOT/bin/dbn_alert MODEL NAM_CONUSNEST_SUBSET_GB2 $job $COMOUT/${RUN}.t${cyc}z.${domain}nest.camfld${fhr}.${tmmark}.grib2
fi

fi

if [ $fhr -eq 00 -a $tmmark != tm00 ]; then
  if [ $domain = conus -o $domain = alaska ]; then
   #Must run the prdgen again to process the analysis restart file (the history file is not the analysis but
   # the filtered state

    if [ $tmmark = tm06 ]; then
      sufs="anl ges"  #have to do a little extra work at tm06 to get the ges included here
    else
      sufs="anl"
    fi

    for suf in ${sufs}; do

      $WGRIB2 $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark}.${suf} | grep -F -f $PARMnam/wgrib2.txtlists/nam_nests.hiresf_nn.txt | $WGRIB2 -i -grib inputs.grib${domain}.${suf} $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark}.${suf}
      $WGRIB2 inputs.grib${domain}.${suf} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib${domain}.uv.${suf}
      $WGRIB2 $COMOUT/${RUN}.t${cyc}z.${domain}nest.bgdawp${fhr}.${tmmark}.${suf} -match ":(WEASD|SNOD):" -grib inputs.grib${domain}.uv_budget.${suf}

      $WGRIB2 inputs.grib${domain}.uv.${suf} -set_bitmap 1 -set_grib_type c3 -new_grid_winds grid -new_grid_interpolation neighbor -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -new_grid ${gridspecs} ${domain}nest.hiresf${fhr}.${tmmark}.uv.${suf}
      $WGRIB2 ${domain}nest.hiresf${fhr}.${tmmark}.uv.${suf} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv ${domain}nest.hiresf${fhr}.${tmmark}.nn.${suf}

      $WGRIB2 inputs.grib${domain}.uv_budget.${suf} -set_bitmap 1 -set_grib_type c3 -new_grid_winds grid -new_grid_interpolation budget -new_grid ${gridspecs} ${domain}nest.hiresf${fhr}.${tmmark}.budget.${suf}
      cat ${domain}nest.hiresf${fhr}.${tmmark}.nn.${suf} ${domain}nest.hiresf${fhr}.${tmmark}.budget.${suf} > ${domain}nest.hiresf${fhr}.${tmmark}.${suf}
      $WGRIB2 ${domain}nest.hiresf${fhr}.${tmmark}.${suf} -s > ${domain}nest.hiresf${fhr}.${tmmark}.idx.${suf}
      export err=$?;err_chk

      if test $SENDCOM = 'YES'
      then
        mv ${domain}nest.hiresf${fhr}.${tmmark}.${suf} $COMOUT/${RUN}.t${cyc}z.${domain}nest.hiresf${fhr}.${tmmark}.grib2.${suf}
        mv ${domain}nest.hiresf${fhr}.${tmmark}.idx.${suf} $COMOUT/${RUN}.t${cyc}z.${domain}nest.hiresf${fhr}.${tmmark}.grib2.idx.${suf}
      fi
    done #end loop over ges/an suffixes for tm06 
  fi #if domain is conus or alaska
fi # if fhr = 00

if test "$SENDECF" = 'YES'
then
  ecflow_client --event post_${domain}_complete
fi

echo EXITING $0
exit $err
