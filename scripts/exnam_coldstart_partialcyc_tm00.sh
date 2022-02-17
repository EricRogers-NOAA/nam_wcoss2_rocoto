#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_coldstart_partialcyc_tm00.sh.ecf
# Script description:  Runs partialcyc code to bring in cycled land states
#                      from the previous catchup cycle run for the NAM parent
#
# Author:        Eric Rogers       Org: NP22         Date: 2004-07-02
#
# Script history log:
# 2006-02-01  Eric Rogers - Based on HIRESW script
# 2015-??-??  Carley/Rogers - Modified for NAMv4
# 2016-07-27  Rogers - Special version for coldstarting NAM off GDAS

set -x

msg="JOB $job FOR NAM HAS BEGUN"
postmsg "$msg"

export DOMNAM=nam

#
# Get needed variables from exndas_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh

cd $DATA

CYCLEgdas=`${NDATE} -6 ${CYCLE}`
CYCLEtm00=`${NDATE} -0 ${CYCLE}`

echo DATEXX${CYCLEgdas} > gdasdate
cycgdas=`cut -c 15-16 gdasdate`
echo DATEXX${CYCLEtm00} > tm00date
cyctm00=`cut -c 15-16 tm00date`

DATE=`cat gdasdate | cut -c7-14`

### modify namelist file
ystart=`cat tm00date | cut -c7-10`
mstart=`cat tm00date | cut -c11-12`
dstart=`cat tm00date | cut -c13-14`
hstart=`cat tm00date | cut -c15-16`
cycstart=`cat tm00date | cut -c7-16`
start=$ystart$mstart$dstart

cp $GESDIR/nam.t${cyc}z.input_domain_01_nemsio.tm00_precoldstart input_domain_01_nemsio

# Run utility to insert valid fields into GWD placeholders in input nemsio file
# This supercedes the partialcyc code

# nmmb file with the land states
# Coldstart of NAM will always use file in hold directory

INPUT_FILE="${gespath}/${RUN}.hold/nmm_b_restart_nemsio_hold.${hstart}z"
INPUT_FILE_TYPE="nems"

# wrf file with the 14 GWD spaces
WRF_BINARY_FILE="input_domain_01_nemsio"

# dont touch this
DYN_CORE="nems"

# your working directory
FIXDIR=$FIXnam

WORK_DIR=$DATA
cd $WORK_DIR

#----------------------------------------------------------------
# don't touch fort.41 namelist settings.
#----------------------------------------------------------------

cat > ${WORK_DIR}/fort.41 << !
 &input_state_fields
  input_file="${INPUT_FILE}"
  input_file_type="${INPUT_FILE_TYPE}"
 /
 &output_grid_specs
  specs_from_output_file=.false.
  lats_output_file="${FIXDIR}/nam_hpnt_latitudes.grb"
  lons_output_file="${FIXDIR}/nam_hpnt_longitudes.grb"
  lsmask_output_file="${FIXDIR}/nam_slmask.grb"
  orog_output_file="${FIXDIR}/nam_elevtiles.grb"
  substrate_temp_output_file="${FIXDIR}/nam_tbot.grb"
 /
 &optional_output_fields
  snow_free_albedo_output_file=""
  greenfrc_output_file=""
  mxsnow_alb_output_file="${FIXDIR}/nam_mxsnoalb.grb"
  slope_type_output_file=""
  soil_type_output_file="${FIXDIR}/nam_soiltiles.grb"
  veg_type_output_file="${FIXDIR}/nam_vegtiles.grb"
  z0_output_file="${FIXDIR}/nam_z0clim.grb"
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

export pgm=emcsfc_coldstart
. prep_step

startmsg
${MPIEXEC} $EXECnam/emcsfc_coldstart >>  $pgmout 2>>errfile
export err=$?;err_chk

cp input_domain_01_nemsio $GESDIR/nam.t${cyc}z.input_domain_01_nemsio.tm00_presfcupdate

exit $err
