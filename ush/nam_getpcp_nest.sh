#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         nam_getpcp_nest.shs
# Script description:  Gets 4 km NCEP stage 2/4 precipitation analysis and
#                      interpolates it to the operational Nam grid
#
# Author:        Rogers/Lin       Org: NP22         Date: 2001-06-11
#
# Abstract: Get hourly NCEP Stage2/4 precipitation analysis and interpolate to
#           the Nam model grid
#
# Script history log:
# 2001-06-11  Eric Rogers / Ying Lin
# 2006-01-17  Ying Lin / Eric Rogers modified to output binary file for WRF-NMM
# 2007-06-28  Ying Lin add use of 12-36h 00Z NAM precip for OCONUS 
# 2009-04-16  Y. Lin devided the old pcpprep.f into merge2n4.f and pcpprep.f. 
# 2009-12-09  E. Rogers modified for NAMRR
# 2013-01-25  J. Carley NAMRR retro
# 2020-01-14  E. Rogers changes for RTMA 2.8: Stage 2 discontinued, Stage 4 now
#             in GRIB2, make Stage 2 lookalike from RTMA precip analysis
#             

set -x
cd $DATA 

delt=`echo $tmmark|cut -c 3-4`
daym1=`${NDATE} -24 $CYCLE | cut -c 1-8`
daym0=`echo $CYCLE | cut -c 1-8`

nampcp_envir=${envir}

# Find out which of ConUS MISBIN mask file (radar effective coverage map) to
# use.  Oct-Apr for 'WINTER', May-Sept for 'SUMMER'.
mm=`echo $CYCLE | cut -c 5-6`
if [[ $mm -ge 05 && $mm -le 09 ]]; then
  cp $FIXnam/SUMMERmisbin_composite.grb misbin_composite.grb
else
  cp $FIXnam/WINTERmisbin_composite.grb misbin_composite.grb
fi

# Specs for B-grid and George Gayno's copygb.  These will need to be changed
# if the B-grid specs change or when the B-grid compatible copygb is 
# operational. 

# These will be used when George's new ip/w3 libs are put into parallel

domain=conus
BGRID="255 205 1827 1467 15947 -125468 136 54000 -106000 032 027 64 45434 -52396"

# Get stage 2/4 data from com

ihrs="1"
for ihr in $ihrs
do
  tinc=`expr -$delt + $ihr`
  time=`${NDATE} $tinc $CYCLE`
  day=`echo $time | cut -c 1-8`
  PDY=`echo $time | cut -c 1-8`
  ST2file[$ihr]=ST2ml${time}.Grb
  ST4file[$ihr]=ST4.${time}.01h
  nestpcpfile[$ihr]=${domain}nest_${RUN}_pcp.${time}

  cp $COMINrtma/pcprtma.${day}/pcprtma2.${time}.grb2 .
  cp $COMINpcpanl/pcpanl.${day}/st4_conus.${time}.01h.grb2 .

  # make stage 4 GRIB1 lookalike
  $CNVGRIB -g21 st4_conus.${time}.01h.grb2 ${ST4file[$ihr]}

  # Make a Stage II look-alike from the pcpRTMA:
  $CNVGRIB -g21 pcprtma2.${time}.grb2 pcprtma2.${time}.grb1
  gridhrap="255 5 1121 881 23117 -119023 8 -105000 4763 4763 0 64"
  $COPYGB -g "$gridhrap" -i3 -x pcprtma2.${time}.grb1 ST2ml${time}.Grb
  gzip ST2ml${time}.Grb
  gzip ST4.${time}.01h

# Fix for 18z NDAS, nampcp files for tm06, tm03 should
# come from the current day's /com/hourly directory!
# For hourly NDAS, catchup cycle starts at tm06

  if [ $cyc -eq 18 ] ; then
    cp ${COM_HRLY_PCP}/${RUN}.${daym0}/${nestpcpfile[$ihr]} .
  else
    cp ${COM_HRLY_PCP}/${RUN}.${daym1}/${nestpcpfile[$ihr]} .
  fi

  cp ${ST2file[$ihr]}.gz $COMOUT/${RUN}.t${cyc}z.${ST2file[$ihr]}.${tmmark}.gz
  cp ${ST4file[$ihr]}.gz $COMOUT/${RUN}.t${cyc}z.${ST4file[$ihr]}.${tmmark}.gz
  cp ${nestpcpfile[$ihr]} $COMOUT/${RUN}.t${cyc}z.${nestpcpfile[$ihr]}.${tmmark}
  # unzip files so merge2n4 will work!
  gunzip ST2ml${time}.Grb.gz
  gunzip ST4.${time}.01h.gz
done

# Interpolate 4 km precipitation analyses to nam grid
# If any input data are missing, the code writes a null
# file so it should never end with a non-zero condition code

cp ${gespath}/${RUN}.hold/pcpbudget_history pcpbudget_history_parent
err=$?
if [ $err -ne 0 ]; then
  # Do not throw an error here, just alert the log file.  This is non-fatal.
  msg="${gespath}/${RUN}.hold/pcpbudget_history file is unavailable"
  postmsg "$msg"
# exit 0
else

#Remap Parent pcp budget file to NEST domain.

#    20120925  J. Carley     Copied Ying's script to interpolate the parent grid pcp_budget file
#                              to the CONUS nest (all B-grid)
#
# Mapping /com/nam/prod/ndas.$day/ndas.t12z.pcpbudget_history from E-grid
# to B-grid.  
#
#
#   NOTE that the budget updates on the 12z NDAS at tm12.  From the budget update
#     script (nam_h2obudget.sh):
#                      Update the long-term precipitation budget array
#                      by comparing the hourly precipitation input for
#                      the time period of ${TM48}-${TM24}
#        So if the cycle day is 20111127 at 12z, then TM12 is 20111126 - 00z.
#        So then the re-mapped budget file corresponds to ending time on 
#        20111125 AT 00z ( ${TM48}-${TM24} ).
#
# 1. Read in the budget history file.  Convert the budget array to a GRIB
#    file (parameter: 255)
# 2. Use Gayno copygb to map it to B-grid
# 3. Read in the B-grid file (in GRIB).  Output the original E-grid header,
#    followed by the B-grid budget history in simple binary.

# Step 1
    export pgm=grid_to_grb
    . prep_step
    ln -s pcpbudget_history_parent   fort.11
    ln -s budget.parent.grb          fort.51
    startmsg
    ${UTIL_EXECnam}/grid_to_grb.x >> $pgmout 2>errfile
    export err=$?;err_chk

# Step 2
$COPYGB -g "${BGRID}" -i3 -x budget.parent.grb budget.${domain}nest.grb

# Step 3
    rm fort.*
    export pgm=grb_to_bin
    . prep_step
    ln -s pcpbudget_history_parent        fort.11
    ln -s budget.${domain}nest.grb        fort.12
    ln -s pcpbudget_history.${domain}nest fort.51
    startmsg
    ${UTIL_EXECnam}/grb_to_bin.x >> $pgmout 2>errfile
    export err=$?;err_chk

#########################################################################
############ Done with re-mapping budget to CONUS NEST ##################
#########################################################################

fi

ihrs="1"
for ihr in $ihrs
do
  tinc=`expr -$delt + $ihr`
  time=`${NDATE} $tinc $CYCLE`
  day=`echo $time | cut -c 1-8`
  PDY=`echo $time | cut -c 1-8`
  ST2file[$ihr]=ST2ml${time}.Grb
  ST4file[$ihr]=ST4.${time}.01h
  nestpcpfile[$ihr]=${domain}nest_${RUN}_pcp.${time}

# Merge Stage 2 and 4 files:

  if [[ -s ${ST2file[$ihr]} || -s ${ST4file[$ihr]} ]]; then
    rm fort.*
    export pgm=nam_mergest2n4
    . prep_step
    ln -sf ${ST2file[$ihr]}         fort.11
    ln -sf ${ST4file[$ihr]}         fort.12
    ln -sf $FIXnam/stage3_mask.grb  fort.13
    ln -sf misbin_composite.grb     fort.14
    ln -sf st2n4.$time              fort.51
    
    startmsg
    $EXECnam/nam_merge2n4 >> $pgmout 2>errfile
    export err=$?;err_chk

# Map to B-grid:
    $COPYGB -g "${BGRID}" -i3 -x st2n4.$time st2n4.$time.bgrid

  fi

  rm fort.*

# Run the nam_pcpprep regardless of whether any of the three files exists: 
#   in pcpprep.f, if pcpbudget_history does not exist, we assume that no
#   adjustment to the hourly input is needed (i.e. no long term surplus/deficit
#   anywhere).  If st2n4 file does not exist, use nampcpfile only; if nampcpfile
#   does not exist, use st2n4 file only; if neither exists, the entire hourly
#   input file is set to the value of '999.', which, when read in later as input
#   for the soil, tells ndas that there is no valid input at the given grid 
#   point (in this case, everywhere), and the precip naturally generated by
#   the model at that time step should be used.  
#  if [ -s st2n4.$time.bgrid -a -s ${nestpcpfile[$ihr]} -a -s pcpbudget_history.${domain}nest ]; then
    export pgm=nam_pcpprep
    . prep_step
    ln -sf st2n4.$time.bgrid         fort.11
    ln -sf ${nestpcpfile[$ihr]}      fort.12
    ln -sf pcpbudget_history.${domain}nest    fort.13
    ln -sf pcp.${domain}nest.$tmmark.hr${ihr}.bin  fort.51
    ln -sf pcp.${domain}nest.$tmmark.hr${ihr}.grb  fort.52

    startmsg
    $EXECnam/nam_pcpprep >> $pgmout 2>errfile
    export err=$?;err_chk
  
    ${WGRIB} -V pcp.${domain}nest.$tmmark.hr${ihr}.grb 
    cp pcp.${domain}nest.$tmmark.hr${ihr}.bin $COMOUT/${RUN}.t${cyc}z.pcp.${domain}nest.$tmmark.hr${ihr}.${CDATE}.bin
    cp pcp.${domain}nest.$tmmark.hr${ihr}.grb $COMOUT/${RUN}.t${cyc}z.pcp.${domain}nest.$tmmark.hr${ihr}.${CDATE}.grb
#  fi
  
done

# Clean up!
  rm -f fort*
  rm -f pcpbudget_history
  rm -f ST2ml*
  rm -f ST4*
  rm -f st2n4.*

echo Exiting $0

exit $err
