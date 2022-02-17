#!/bin/ksh

set -x

ACCUM_LENGTH=$1
CYCLE_TIME=$2

cd $DATA

####  UNIX Script Documentation Block ###################################
#                      .                                             .
# Script name:  emcsfc_fire2mdl.sh
# RFC Contact:  George Gayno
# Abstract:  This script calls the emcsfc_fire2mdl program to map
#    fire (burned area) data to a model grid.
#
# Script History Log:
#    02/2015  Gayno   Initial version
#
# Usage:
#    emcsfc_fire2mdl.sh $ACCUM_LENGTH $CYCLE_TIME
#
# Input argument
#        $ACCUM_LENGTH - 2 (for two days) or 45 (for 45 days)
#        $CYCLE_TIME - NAM cycle
#
# Script Parameters:
# Modules and Files references:
#    fix:   ${MODEL_LSMASK_FILE} (model landmask, grib 1 or 2)
#           ${MODEL_LATITUDE_FILE} (model latitude, grib 1 or 2)
#           ${MODEL_LONGITUDE_FILE} (model longitude, grib 1 or 2)
#
#    input files (may choose one or both:
#           ${NESDIS_1KM_FIRE_FILE}   (1km burned area data, grib 2)
#           ${NESDIS_12KM_FIRE_FILE} (12km burned area data, grib 2)
#
#    output file:
#           ${MODEL_FIRE_FILE} (burned area data on model grid, grib 2)
#
#    executables: /nwprod/emcsfc.vX.Y.Z/exec/emcsfc_fire2mdl -
#                 ${FIRE2MDLEXEC}
#
# Condition codes:
#  0    - normal termination
#  3    - no input burned area data specified
#  $rc  - non-zero status indicates a problem in emcsfc_fire2mdl execution.
#         see source code for details - /nwprod/emcsfc.vX.Y.Z/sorc/emcsfc_fire2mdl.fd
#
# If a non-zero status occurs, no model fire analysis will be created.
# This is not fatal to the model executation.  But any problems should
# be investigated.
#
# Attributes:
#     Language:  RedHat Linux
#     Machine:   NCEP WCOSS
#
#########################################################################

FIXED_DIR=$COMIN

#------------------------------------------------------------------------
# The program executable.
#------------------------------------------------------------------------

#------------------------------------------------------------------------
# Input fire (burned area) data.  May choose 1km, 12km or both.
# Exit with error if no data chosen.
#------------------------------------------------------------------------

NESDIS_1KM_FIRE_FILE=accum_fire.1km.${ACCUM_LENGTH}day.grib2
NESDIS_12KM_FIRE_FILE=accum_fire.12km.${ACCUM_LENGTH}day.grib2

size1km=${#NESDIS_1KM_FIRE_FILE}
size12km=${#NESDIS_12KM_FIRE_FILE}

if ((size1km == 0 && size12km == 0)); then
  msg="WARNING: ${pgm} detects no input fire data. Can not run."
  if [ -f postmsg ]; then
    postmsg "$msg"
  fi
  exit 3
fi

#------------------------------------------------------------------------
# Create program namelist file and run program.
#------------------------------------------------------------------------

rm -f ./fort.41
cat > ./fort.41 << !
 &source_data
  nesdis_1km_fire_file="${NESDIS_1KM_FIRE_FILE}"
  nesdis_12km_fire_file="${NESDIS_12KM_FIRE_FILE}"
 /
 &model_specs
  model_lat_file="${FIXED_DIR}/nam.t${cyc}z.${domain}_hpnt_latitudes.grb"
  model_lon_file="${FIXED_DIR}/nam.t${cyc}z.${domain}_hpnt_longitudes.grb"
  model_lsmask_file="${FIXED_DIR}/nam.t${cyc}z.${domain}_slmask.grb"
 /
 &output_data
  model_fire_file="${WORK_DIR}/fire.${CYCLE_TIME}.${ACCUM_LENGTH}day.firewx.grb"
 /
!

export pgm=emcsfc_fire2mdl
. prep_step

startmsg
$EXECnam/emcsfc_fire2mdl >> $pgmout 2>errfile
export err=$?

if [ $err -ne 0 ]
then
  msg=" ABNORMAL TERMINATION IN $pgm : run without new burn data accum"
  rm ${WORK_DIR}/fire.${CYCLE_TIME}.${ACCUM_LENGTH}day.firewx.grb
else
  msg="$pgm completed normally"
fi

postmsg "$msg"
