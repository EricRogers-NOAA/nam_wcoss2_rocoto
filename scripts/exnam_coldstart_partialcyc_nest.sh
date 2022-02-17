#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exndas_coldstart_real.sh.sms 
# Script description:  Runs REAL to get GDAS firs guess file in WRF-NMM input file
#                      format to coldstart WRF-NNM NDAS
#
# Author:        Eric Rogers       Org: NP22         Date: 2004-07-02
#
# Script history log:
# 2006-02-01  Eric Rogers - Based on HIRESW script

set -x

msg="JOB $job FOR NAM HAS BEGUN"
postmsg "$msg"

export DOMNAM=nam

if [ $domain = conus -o $domain = alaska ] ; then
  CYCNEST=true
else
  CYCNEST=false
fi

#
# Get needed variables from exnam_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh

cd $DATA

if [ $CYCNEST = true ] ; then 

  CYCLEgdas=`${NDATE} -12 ${CYCLE}`
  CYCLEtm06=`${NDATE} -6 ${CYCLE}`

  echo DATEXX${CYCLEgdas} > gdasdate
  cycgdas=`cut -c 15-16 gdasdate`
  echo DATEXX${CYCLEtm06} > tm06date
  cyctm06=`cut -c 15-16 tm06date`

  DATE=`cat gdasdate | cut -c7-14`

  ### modify namelist file
  ystart=`cat tm06date | cut -c7-10`
  mstart=`cat tm06date | cut -c11-12`
  dstart=`cat tm06date | cut -c13-14`
  hstart=`cat tm06date | cut -c15-16`
  cycstart=`cat tm06date | cut -c7-16`
  start=$ystart$mstart$dstart

  cpreq $GESDIR/nam.t${cyc}z.input_domain_${domain}nest_nemsio.tm06_precoldstart input_domain_${domain}nest_nemsio

else

  echo DATEXX$CYCLE > nmcdate

  PDY=`cat nmcdate | cut -c7-14`
  yy=`cat nmcdate | cut -c7-10`
  mm=`cat nmcdate | cut -c11-12`
  dd=`cat nmcdate | cut -c13-14`

  ystart=`cat nmcdate | cut -c7-10`
  mstart=`cat nmcdate | cut -c11-12`
  dstart=`cat nmcdate | cut -c13-14`
  hstart=`cat nmcdate | cut -c15-16`
  cycstart=`cat nmcdate | cut -c7-16`
  start=$ystart$mstart$dstart

  cpreq $GESDIR/nam.t${cyc}z.input_nemsio_guess_${domain}nest_precoldstart input_domain_${domain}nest_nemsio

fi

# This block only for cycled nests

if [ $CYCNEST = true ] ; then
    # Real-time run settings for coldstart partial cycle with nest #
    if [ -s ${gespath}/${RUN}.${start}/nam.t${hstart}z.nmm_b_restart_${domain}nest_nemsio.tm01 ]; then
      INPUT_FILE="${gespath}/${RUN}.${start}/nam.t${hstart}z.nmm_b_restart_${domain}nest_nemsio.tm01"
    elif [ -s ${gespath}/${RUN}.hold/nmm_b_restart_${domain}nest_nemsio_hold.${hstart}z ]; then
      INPUT_FILE="${gespath}/${RUN}.hold/nmm_b_restart_${domain}nest_nemsio_hold.${hstart}z"
      msg="JOB ${job}: ${RUN}.${start} restart file not available using ${RUN}.hold restart file for land states in ${domain} NEST."
      postmsg "$msg"
    elif [ -s ${gespath}/${RUN}.${start}/nam.t${hstart}z.nmm_b_restart_nemsio.tm01 ]; then
      msg="JOB ${job}: Using parent ${RUN}.${start} FOR LAND STATES IN ${domain} NEST"
      postmsg "$msg"
      INPUT_FILE="${gespath}/${RUN}.${start}/nam.t${hstart}z.nmm_b_restart_nemsio.tm01"
    else
      #If we just started the NAM - we may not have a nest rst file that can be used.  Grab the one from the parent.
      msg="JOB ${job}: Using parent ${RUN}.hold FOR LAND STATES IN ${domain} NEST"
      postmsg "$msg"
      INPUT_FILE="${gespath}/${RUN}.hold/nmm_b_restart_nemsio_hold.${hstart}z"  
    fi
#end CYCNEST check
fi

if [ $domain = hawaii -o $domain = prico ] ; then
  INPUT_FILE="${gespath}/${RUN}.${start}/nam.t${hstart}z.nmm_b_restart_nemsio.tm01"
fi

if [ $domain = firewx ] ; then
  firewx_location=`cat $COMOUT/nam.t${cyc}z.firewxnest_location | awk '{print $1}'`
  INPUT_FILE="${gespath}/${RUN}.${start}/nam.t${hstart}z.nmm_b_restart_${firewx_location}nest_nemsio.tm01"
fi

INPUT_FILE_TYPE="nems"

# wrf file with the 14 GWD spaces
WRF_BINARY_FILE="input_domain_${domain}nest_nemsio"

# dont touch this
DYN_CORE="nems"

# your working directory
if [ $domain = firewx ]; then
  FIXDIR=$COMIN
else
  FIXDIR=$FIXnam
fi

WORK_DIR=$DATA
cd $WORK_DIR

if [ $domain = firewx ] ; then

cat > ${WORK_DIR}/fort.41 << !
 &input_state_fields
  input_file="${INPUT_FILE}"
  input_file_type="${INPUT_FILE_TYPE}"
 /
 &output_grid_specs
  specs_from_output_file=.true.
  lats_output_file=""
  lons_output_file=""
  lsmask_output_file=""
  orog_output_file=""
  substrate_temp_output_file=""
 /
 &optional_output_fields
  snow_free_albedo_output_file=""
  greenfrc_output_file=""
  mxsnow_alb_output_file=""
  slope_type_output_file=""
  soil_type_output_file=""
  veg_type_output_file="${FIXDIR}/${RUN}.t${cyc}z.firewx_vegtiles.grb"
  z0_output_file="${FIXDIR}/${RUN}.t${cyc}z.firewx_z0clim.grb"
 /
 &soil_parameters
  soil_src_input = "statsgo"
  smclow_input  = 0.5
  smchigh_input = 3.0
  smcmax_input= 0.395, 0.421, 0.434, 0.476, 0.476, 0.439,
                0.404, 0.464, 0.465, 0.406, 0.468, 0.457,
                0.464, -9.99,  0.20, 0.421
  beta_input =  4.05,  4.26,  4.74,  5.33,  5.33,  5.25,
                6.77,  8.72,  8.17, 10.73, 10.39, 11.55,
                5.25, -9.99,  4.05,  4.26
  psis_input =  0.0350, 0.0363, 0.1413, 0.7586, 0.7586, 0.3548,
                0.1349, 0.6166, 0.2630, 0.0977, 0.3236, 0.4677,
                0.3548,  -9.99, 0.0350, 0.0363
  satdk_input = 1.7600e-4, 1.4078e-5, 5.2304e-6, 2.8089e-6, 2.8089e-6,
                3.3770e-6, 4.4518e-6, 2.0348e-6, 2.4464e-6, 7.2199e-6,
                1.3444e-6, 9.7394e-7, 3.3770e-6,     -9.99, 1.4078e-5,
                1.4078e-5
  soil_src_output = "statsgo"
  smclow_output  = 0.5
  smchigh_output = 3.0
  smcmax_output= 0.395, 0.421, 0.434, 0.476, 0.476, 0.439,
                 0.404, 0.464, 0.465, 0.406, 0.468, 0.457,
                 0.464, -9.99,  0.20, 0.421
  beta_output =  4.05,  4.26,  4.74,  5.33,  5.33,  5.25,
                 6.77,  8.72,  8.17, 10.73, 10.39, 11.55,
                 5.25, -9.99,  4.05,  4.26
  psis_output =  0.0350, 0.0363, 0.1413, 0.7586, 0.7586, 0.3548,
                 0.1349, 0.6166, 0.2630, 0.0977, 0.3236, 0.4677,
                 0.3548, -9.99,  0.0350, 0.0363
  satdk_output = 1.7600e-4, 1.4078e-5, 5.2304e-6, 2.8089e-6, 2.8089e-6,
                3.3770e-6, 4.4518e-6, 2.0348e-6, 2.4464e-6, 7.2199e-6,
                1.3444e-6, 9.7394e-7, 3.3770e-6,     -9.99, 1.4078e-5,
                1.4078e-5
 /
 &veg_parameters
  veg_src_input = "igbp"
  veg_src_output = "igbp"
  salp_output = 4.0
  snup_output = 0.080, 0.080, 0.080, 0.080, 0.080, 0.020,
                0.020, 0.060, 0.040, 0.020, 0.010, 0.020,
                0.020, 0.020, 0.013, 0.013, 0.010, 0.020,
                0.020, 0.020
 /
 &final_output
  output_file_type="${DYN_CORE}"
  output_file="${WRF_BINARY_FILE}"
 /
 &options
  landice_opt=3
 /
 &nam_options
  merge=.false.
 /
!

else

cat > ${WORK_DIR}/fort.41 << !
 &input_state_fields
  input_file="${INPUT_FILE}"
  input_file_type="${INPUT_FILE_TYPE}"
 /
 &output_grid_specs
  specs_from_output_file=.false.
  lats_output_file="${FIXDIR}/nam_${domain}nest_hpnt_latitudes.grb"
  lons_output_file="${FIXDIR}/nam_${domain}nest_hpnt_longitudes.grb"
  lsmask_output_file="${FIXDIR}/nam_${domain}nest_slmask.grb"
  orog_output_file="${FIXDIR}/nam_${domain}nest_elevtiles.grb"
  substrate_temp_output_file="${FIXDIR}/nam_${domain}nest_tbot.grb"
 /
 &optional_output_fields
  snow_free_albedo_output_file=""
  greenfrc_output_file=""
  mxsnow_alb_output_file="${FIXDIR}/nam_${domain}nest_mxsnoalb.grb"
  slope_type_output_file=""
  soil_type_output_file="${FIXDIR}/nam_${domain}nest_soiltiles.grb"
  veg_type_output_file="${FIXDIR}/nam_${domain}nest_vegtiles.grb"
  z0_output_file="${FIXDIR}/nam_${domain}nest_z0clim.grb"
 /
 &soil_parameters
  soil_src_input = "statsgo"
  smclow_input  = 0.5
  smchigh_input = 3.0
  smcmax_input= 0.395, 0.421, 0.434, 0.476, 0.476, 0.439,
                0.404, 0.464, 0.465, 0.406, 0.468, 0.457,
                0.464, -9.99,  0.20, 0.421
  beta_input =  4.05,  4.26,  4.74,  5.33,  5.33,  5.25,
                6.77,  8.72,  8.17, 10.73, 10.39, 11.55,
                5.25, -9.99,  4.05,  4.26
  psis_input =  0.0350, 0.0363, 0.1413, 0.7586, 0.7586, 0.3548,
                0.1349, 0.6166, 0.2630, 0.0977, 0.3236, 0.4677,
                0.3548,  -9.99, 0.0350, 0.0363
  satdk_input = 1.7600e-4, 1.4078e-5, 5.2304e-6, 2.8089e-6, 2.8089e-6,
                3.3770e-6, 4.4518e-6, 2.0348e-6, 2.4464e-6, 7.2199e-6,
                1.3444e-6, 9.7394e-7, 3.3770e-6,     -9.99, 1.4078e-5,
                1.4078e-5
  soil_src_output = "statsgo"
  smclow_output  = 0.5
  smchigh_output = 3.0
  smcmax_output= 0.395, 0.421, 0.434, 0.476, 0.476, 0.439,
                 0.404, 0.464, 0.465, 0.406, 0.468, 0.457,
                 0.464, -9.99,  0.20, 0.421
  beta_output =  4.05,  4.26,  4.74,  5.33,  5.33,  5.25,
                 6.77,  8.72,  8.17, 10.73, 10.39, 11.55,
                 5.25, -9.99,  4.05,  4.26
  psis_output =  0.0350, 0.0363, 0.1413, 0.7586, 0.7586, 0.3548,
                 0.1349, 0.6166, 0.2630, 0.0977, 0.3236, 0.4677,
                 0.3548, -9.99,  0.0350, 0.0363
  satdk_output = 1.7600e-4, 1.4078e-5, 5.2304e-6, 2.8089e-6, 2.8089e-6,
                3.3770e-6, 4.4518e-6, 2.0348e-6, 2.4464e-6, 7.2199e-6,
                1.3444e-6, 9.7394e-7, 3.3770e-6,     -9.99, 1.4078e-5,
                1.4078e-5
 /
 &veg_parameters
  veg_src_input = "igbp"
  veg_src_output = "igbp"
  salp_output = 4.0
  snup_output = 0.080, 0.080, 0.080, 0.080, 0.080, 0.020,
                0.020, 0.060, 0.040, 0.020, 0.010, 0.020,
                0.020, 0.020, 0.013, 0.013, 0.010, 0.020,
                0.020, 0.020
 /
 &final_output
  output_file_type="${DYN_CORE}"
  output_file="${WRF_BINARY_FILE}"
 /
 &options
  landice_opt=3
 /
 &nam_options
  merge=.false.
 /
!

#end firewx nest check
fi

# Before running coldstart for fire weather nest, check to see if the fire weather nest has all water points
# by running wwgrib.pl to see if the max value of the land/sea mask is 0 or 1.
# If it is zero, skip coldstart execution

if [ $domain = firewx ]; then

#wwgrib.pl expects to have had $WGRIB envar set and pointing to wgrib

${UTIL_USHnam}/wwgrib.pl ${FIXDIR}/nam.t${cyc}z.firewx_slmask.grb > landcheck.txt
landcheck=`cat landcheck.txt | awk '{print $11}'`

  if [ $landcheck -eq 1 ]; then

    export pgm=emcsfc_coldstart
    . prep_step

    startmsg
    ${MPIEXEC} $EXECnam/emcsfc_coldstart >> $pgmout 2>errfile
    export err=$?;err_chk

    mv input_domain_${domain}nest_nemsio $GESDIR/nam.t${cyc}z.input_nemsio_guess_${domain}nest_presfcupdate

  else

    mv input_domain_${domain}nest_nemsio $GESDIR/nam.t${cyc}z.input_nemsio_guess_${domain}nest_presfcupdate

  #end landcheck test
  fi

else

  export pgm=emcsfc_coldstart
  . prep_step

  startmsg
  ${MPIEXEC} $EXECnam/emcsfc_coldstart >>  $pgmout 2>>errfile
  export err=$?;err_chk

  mv input_domain_${domain}nest_nemsio $GESDIR/nam.t${cyc}z.input_nemsio_guess_${domain}nest_presfcupdate

#end firewx nest check
fi

exit $err

