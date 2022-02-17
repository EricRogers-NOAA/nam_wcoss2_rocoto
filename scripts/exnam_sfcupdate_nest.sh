#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exndas_coldstart_sfcupdate.sh.sms
# Script description:  Update sst/snow/sea ice for NDAS run
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract: Update WRF-NMM coldstart (wrfinput) file with best
#           available SST, snow, sea-ice analyses
#
# Script history log:
# 1999-06-23  Eric Rogers
# 1999-07-30  Brent Gordon  - Modified for production.
# 2000-03-03  Eric Rogers modified scripts for 60-h NAM forecast
# 2004-10-14  Julia Zhu	 - NAM/EDAS name changes to NAM/NDAS
# 2006-01-12  Eric Rogers - Extensive changes for WRF-NMM
# 2008-08-14  Eric Rogers - Since NDAS "partial cycling" coldstart is
#                           done every cycle, change script so sfc
#                           fields are only updated at start of 06z NDAS
# 2009-06-22  Eric Rogers - Converted to work in the NEMS NDAS
# 2019-05-20  Eric Rogers - Changes for run on Dell

set -x

msg="JOB $job HAS BEGUN"
postmsg "$msg"

mkdir -p $DATA
cd $DATA

if [ $domain = conus -o $domain = alaska ] ; then
  CYCNEST=true
else
  CYCNEST=false
fi

#
# Get needed variables from exndas_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh

export DOMAIN=${domain}

export CYCLE=$PDY$cyc

if [ $CYCNEST = true ] ; then

TM06=`${NDATE} -06 $CYCLE`
echo $CYCLE > date
echo $TM06 > datetm06

if [ $RUNTYPE = CATCHUP ]; then
  CYCLE_TIME=`cat datetm06 | cut -c1-10`
  cpreq $GESDIR/nam.t${cyc}z.input_nemsio_guess_${domain}nest_presfcupdate input_nemsio_${DOMAIN}
fi

CYCLE_YEAR=`echo $CYCLE_TIME | cut -c1-4`
CYCLE_MON=`echo $CYCLE_TIME | cut -c5-6`
CYCLE_DAY=`echo $CYCLE_TIME | cut -c7-8`
CYCLE_HOUR=`echo $CYCLE_TIME | cut -c9-10`

# Set valid time to update snow. sea ice, and sst

CYCSICE_UPDATE=00
CYCSST_UPDATE=00
#For canned data tests
#CYCSICE_UPDATE=06
#CYCSST_UPDATE=06

else

echo DATEXX${CYCLE} > nmcdate.tm00

cpreq $GESDIR/nam.t${cyc}z.input_nemsio_guess_${domain}nest_presfcupdate input_nemsio_${DOMAIN}

CYCLE_TIME=`cat nmcdate.tm00 | cut -c7-16`
CYCLE_YEAR=`echo $CYCLE_TIME | cut -c1-4`
CYCLE_MON=`echo $CYCLE_TIME | cut -c5-6`
CYCLE_DAY=`echo $CYCLE_TIME | cut -c7-8`
CYCLE_HOUR=`echo $CYCLE_TIME | cut -c9-10`

# Set valid time to update snow. sea ice, and sst
# Update SST every cycle for non-cycled nests
# Update Snow/sea ice at 06z for non-cycled nests

CYCSICE_UPDATE=06
CYCSST_UPDATE=$CYCLE_HOUR

fi

# How old can the NESDIS snow/ice data and SST data be?  Set the age
# in hours below.  if older, the snow/ice/sst programs will not run
# and the sfcupdate code will cycle these fields.  

typeset integer SICE_AGE_IN_HOURS=36    # always a positive number
typeset integer SICE_AGE_IN_HOURS_2=96   # always a positive number
typeset integer SST_AGE_IN_HOURS=72    # always a positive number

if [ $domain = conus -o $domain = alaska ] ; then
  typeset integer AFWA_AGE_IN_HOURS=18
else
  typeset integer AFWA_AGE_IN_HOURS=24
fi

typeset -L8 OLD_DATE_8
typeset -L8 CHKDATE

#---------------------------------------------------------------------
#  FIXED_DIR holds the land/sea mask file and other fixed files for the domain.
#---------------------------------------------------------------------

if [ $domain = firewx ]; then
  export FIXED_DIR=$COMIN
else
  export FIXED_DIR=$FIXnam
fi

WORK_DIR=$DATA

SST_GLOBAL_FILE_NAME="rtgssthr_grb_0.083"
NESDIS_FILE_NAME="imssnow96.grb"
AFWA_NH_FILE_NAME="NPR.SNWN.SP.S1200.MESH16"
SST_REG_FILE_NAME=""

# For nests:

# Run snow2mdl, ice2mdl and sst2mdl for Firewx, Alaska, CONUS 
# Run snow2mdl and sst2mdl only for Hawaii
# Run sst2mdl only for Puerto Rico

# Fire weather needs separate if test block because domain
# is not fixed and surface grib files are made for each
# cycle and put into /com

#---------------------------------------------------------------------
# RUN SNOW AND SEA ICE PROGRAMS
#---------------------------------------------------------------------

if [ $domain != prico ] ; then

if [[ $CYCLE_HOUR = $CYCSICE_UPDATE ]]
then

  CHKDATE=${CYCLE_TIME}
  OLD_DATE_AFWA=`$NDATE -${AFWA_AGE_IN_HOURS} $CYCLE_TIME`
  OLD_DATE_8=$OLD_DATE_AFWA
  AFWA_NH_FILE=""
  
# look for afwa data.  if file exists, check the internal
# date stamp.  if too old, set AFWA_NH_FILE as empty
# string.  this tells snow2mdl program to not use afwa data.
 
  while ((CHKDATE >= OLD_DATE_8)) ; do
    # this is phase 3 dcom
    AFWA_DIR="${DCOMROOT}/${CHKDATE}/wgrbbul/"
    if [[ (-s ${AFWA_DIR}/${AFWA_NH_FILE_NAME}) ]]
    then
      TEMP_DATE=`$WGRIB -4yr ${AFWA_DIR}/${AFWA_NH_FILE_NAME} | head -1`
      typeset -L10 AFWA_GRIB_DATE
      AFWA_GRIB_DATE=${TEMP_DATE#*:d=}
      if ((AFWA_GRIB_DATE > OLD_DATE_AFWA))
      then
        AFWA_NH_FILE=${AFWA_DIR}/${AFWA_NH_FILE_NAME}
      fi
      break
    fi
    CHKDATE=`$NDATE -24 ${CHKDATE}00`
  done

  if [[ -z ${AFWA_NH_FILE} ]]
  then
    echo NO CURRENT AFWA DATA AVAILABLE.
  else
    echo AFWA DATA AVAILABLE
    echo AFWA NH DATA $AFWA_NH_FILE
  fi

# NESDIS DATA

  OLD_DATE_SICE=`$NDATE -$SICE_AGE_IN_HOURS $CYCLE_TIME`
  OLD_DATE_SICE_2=`$NDATE -$SICE_AGE_IN_HOURS_2 $CYCLE_TIME`

  OLD_DATE_8=$OLD_DATE_SICE
  CHKDATE=$CYCLE_TIME

# look for nesdis cover data.  if file exists, check the internal
# date stamp.  if old, don't run snow2mdl even if afwa is current
# as afwa snow coverage can't be trusted.  if snow2mdl does not
# run, then snow will be cycled by surface update program.
# exception! if nesdis data is very old (as defined by
# OLD_DATE_SICE_2), then there are big problems at the
# national ice center.  in that case, run snow2mdl with
# just afwa data if it is current.
 
  NESDIS_FILE=""
  while ((CHKDATE >= OLD_DATE_8)) ; do
   # this is phase 3 dcom
   NESDIS_DIR="${DCOMROOT}/${CHKDATE}/wgrbbul"
   if [[ -s ${NESDIS_DIR}/${NESDIS_FILE_NAME} ]]
   then
     TEMP_DATE=`$WGRIB -4yr ${NESDIS_DIR}/${NESDIS_FILE_NAME} | head -1`
     typeset -L10 NESDIS_GRIB_DATE
     NESDIS_GRIB_DATE=${TEMP_DATE#*:d=}
     if ((NESDIS_GRIB_DATE >= OLD_DATE_SICE))   # current data exists.
     then                                       # run program.
       echo CURRENT DATA EXISTS
       NESDIS_FILE=${NESDIS_DIR}/${NESDIS_FILE_NAME}
     elif ((NESDIS_GRIB_DATE < OLD_DATE_SICE_2))
     then  # nesdis is very old, run program if afwa is current.
           # expect this to happen if a catastropic outage.
       echo NESDIS DATA VERY OLD.
       NESDIS_FILE=""
     else  # if nesdis is old, but not too old, then don't use afwa
           # data by itself even if it is current.
       NESDIS_FILE=""
       AFWA_NH_FILE=""
     fi
     break
   fi
   CHKDATE=`$NDATE -24 ${CHKDATE}00`
 done

 if [[ -z $NESDIS_FILE && -z $AFWA_NH_FILE ]]
 then
   echo NO DATA AVAILABLE. DONT RUN SNOW PROGRAM.
 else

 if [ $domain = firewx ] ; then

   cat > ${WORK_DIR}/fort.41 << !
      &source_data
       autosnow_file=""
       nesdis_snow_file="${NESDIS_FILE}"
       nesdis_lsmask_file=""
       afwa_snow_global_file=""
       afwa_snow_nh_file="${AFWA_NH_FILE}"
       afwa_snow_sh_file=""
       afwa_lsmask_nh_file=""
       afwa_lsmask_sh_file=""
      /
      &qc
       climo_qc_file="$FIXnam/emcsfc_snow_cover_climo.grib2"
      /
      &model_specs
       model_lat_file="$COMIN/nam.t${cyc}z.${domain}_hpnt_latitudes.grb"
       model_lon_file="$COMIN/nam.t${cyc}z.${domain}_hpnt_longitudes.grb"
       model_lsmask_file="$COMIN/nam.t${cyc}z.${domain}_slmask.grb"
      /
      &output_data
       model_snow_file="${WORK_DIR}/snow.${CYCLE_TIME}.${DOMAIN}.grb"
       output_grib2=.false.
      /
      &output_grib_time
       grib_year=$CYCLE_YEAR
       grib_month=$CYCLE_MON
       grib_day=$CYCLE_DAY
       grib_hour=$CYCLE_HOUR
      /
      &parameters
       lat_threshold=55.0
       min_snow_depth=0.08
       snow_cvr_threshold=50.0
      /
!

 else

   cat > ${WORK_DIR}/fort.41 << !
      &source_data
       autosnow_file=""
       nesdis_snow_file="${NESDIS_FILE}"
       nesdis_lsmask_file=""
       afwa_snow_global_file=""
       afwa_snow_nh_file="${AFWA_NH_FILE}"
       afwa_snow_sh_file=""
       afwa_lsmask_nh_file=""
       afwa_lsmask_sh_file=""
      /
      &qc
       climo_qc_file="${FIXED_DIR}/emcsfc_snow_cover_climo.grib2"
      /
      &model_specs
       model_lat_file="${FIXED_DIR}/nam_${domain}nest_hpnt_latitudes.grb"
       model_lon_file="${FIXED_DIR}/nam_${domain}nest_hpnt_longitudes.grb"
       model_lsmask_file="${FIXED_DIR}/nam_${domain}nest_slmask.grb"
      /
      &output_data
       model_snow_file="${WORK_DIR}/snow.${CYCLE_TIME}.${DOMAIN}.grb"
       output_grib2=.false.
      /
      &output_grib_time
       grib_year=$CYCLE_YEAR
       grib_month=$CYCLE_MON
       grib_day=$CYCLE_DAY
       grib_hour=$CYCLE_HOUR
      /
      &parameters
       lat_threshold=55.0
       min_snow_depth=0.08
       snow_cvr_threshold=50.0
      /
!

#end firewx check
  fi
      export pgm=emcsfc_snow2mdl
      . prep_step
#
      startmsg
      $EXECnam/emcsfc_snow2mdl >> $pgmout 2>errfile
      export err=$?
#---------------------------------------------------------------------
#     if there is a problem in the program, don't need to abort.
#     the sfcupdate program will run with no new snow analysis,
#     but we want the logs to know about it!
#---------------------------------------------------------------------
      if [ $err -ne 0 ]
      then
        msg=" ABNORMAL TERMINATION IN $pgm : run without new snow analysis"
        rm -f ${WORK_DIR}/snow.${CYCLE_TIME}.${DOMAIN}.grb
      else
        msg="$pgm completed normally"
        cp ${WORK_DIR}/snow.${CYCLE_TIME}.${DOMAIN}.grb $COMOUT/nam.t${cyc}z.${domain}nest_snowanl.grb
      fi
      postmsg "$msg"

      rm ${WORK_DIR}/fort.41

   fi  # is there afwa or nesdis data available?

#---------------------------------------------------------------------
#     now run ice program
#---------------------------------------------------------------------
 
   if [[ -z $NESDIS_FILE ]]
   then
     echo NO DATA AVAILABLE. DONT RUN ICE PROGRAM.
   else

 if [ $domain = firewx ] ; then

      cat > ${WORK_DIR}/fort.41 << !
       &global_src
        input_global_src_file=""
        input_global_src_lsmask_file=""
       /
       &ims_src
        input_ims_src_file="${NESDIS_FILE}"
        input_ims_src_lsmask_file=""
       /
       &model_specs
        model_lat_file="$COMIN/nam.t${cyc}z.${domain}_hpnt_latitudes.grb"
        model_lon_file="$COMIN/nam.t${cyc}z.${domain}_hpnt_longitudes.grb"
        model_lsmask_file="$COMIN/nam.t${cyc}z.${domain}_slmask.grb"
       /
       &output
        output_file="${WORK_DIR}/seaice.${CYCLE_TIME}.${DOMAIN}.grb"
        output_grib2=.false.
       /
       &output_grib_time
        grib_year=$CYCLE_YEAR
        grib_month=$CYCLE_MON
        grib_day=$CYCLE_DAY
        grib_hour=$CYCLE_HOUR
       /
!

 else

      cat > ${WORK_DIR}/fort.41 << !
       &global_src
        input_global_src_file=""
        input_global_src_lsmask_file=""
       /
       &ims_src
        input_ims_src_file="${NESDIS_FILE}"
        input_ims_src_lsmask_file=""
       /
       &model_specs
        model_lat_file="${FIXED_DIR}/nam_${domain}nest_hpnt_latitudes.grb"
        model_lon_file="${FIXED_DIR}/nam_${domain}nest_hpnt_longitudes.grb"
        model_lsmask_file="${FIXED_DIR}/nam_${domain}nest_slmask.grb"
       /
       &output
        output_file="${WORK_DIR}/seaice.${CYCLE_TIME}.${DOMAIN}.grb"
        output_grib2=.false.
       /
       &output_grib_time
        grib_year=$CYCLE_YEAR
        grib_month=$CYCLE_MON
        grib_day=$CYCLE_DAY
        grib_hour=$CYCLE_HOUR
       /
!

#end firewx nest check
 fi
      export pgm=emcsfc_ice2mdl
      . prep_step
#
      startmsg
      $EXECnam/emcsfc_ice2mdl >> $pgmout 2>errfile
      export err=$?
#---------------------------------------------------------------------
#     if there is a problem in the program, don't need to abort.
#     the sfcupdate program will run with no new sea ice analysis,
#     but we want the logs to know about it!
#---------------------------------------------------------------------
      if [ $err -ne 0 ]
      then
        msg=" ABNORMAL TERMINATION IN $pgm : run without new sea-ice analysis"
      else
        msg="$pgm completed normally"
        cp ${WORK_DIR}/seaice.${CYCLE_TIME}.${DOMAIN}.grb $COMOUT/nam.t${cyc}z.${domain}nest_seaiceanl.grb
      fi
      postmsg "$msg"
                                                                                                  
      rm ${WORK_DIR}/fort.41

  fi # nesdis file exists
fi # is cycle hour

#end not priconest check
fi

#---------------------------------------------------------------------
# RUN SST PROGRAM.  data are usually available by 22:30z.
#---------------------------------------------------------------------

if [[ $CYCLE_HOUR = $CYCSST_UPDATE ]]
then

  OLD_DATE_SST=`$NDATE -${SST_AGE_IN_HOURS} $CYCLE_TIME`
  OLD_DATE_8=$OLD_DATE_SST
  CHKDATE=$CYCLE_TIME

  while ((CHKDATE >= OLD_DATE_8)) ; do
     SST_DIR="$COMINsst/nsst.${CHKDATE}"
     SST_GLOBAL_FILE=${SST_DIR}/${SST_GLOBAL_FILE_NAME}
     if [[ -s $SST_GLOBAL_FILE ]]
     then
       echo FOUND GLOBAL SST FILE
       break
     fi
     CHKDATE=`$NDATE -24 ${CHKDATE}00`
  done

  if [[ -s $SST_GLOBAL_FILE ]]
  then

#   check date stamp in grib header

    TEMP_DATE=`$WGRIB -4yr $SST_GLOBAL_FILE | head -1`
    typeset -L10 SST_GRIB_DATE
    SST_GRIB_DATE=${TEMP_DATE#*:d=}

    if ((SST_GRIB_DATE >= OLD_DATE_SST))   # current data exists.
    then                                   # run program.

       echo GLOBAL SST DATA CURRENT

       SST_REG_FILE=""   # hi-res regional data is optional
                         # set to zero length string to not use

       CHKDATE=$CYCLE_TIME
       while ((CHKDATE >= OLD_DATE_8)) ; do
          SST_DIR="$COMINsst/nsst.${CHKDATE}"
          if [[ -s ${SST_DIR}/${SST_REG_FILE_NAME} ]]
          then
            SST_REG_FILE=${SST_DIR}/${SST_REG_FILE_NAME}
            break
          fi
          CHKDATE=`$NDATE -24 ${CHKDATE}00`
       done

       if [[ ! -n $SST_REG_FILE ]]
       then
         echo NO REGIONAL SST DATA AVAILABLE. RUN PROGRAM ANYWAY.
       else
         echo REGIONAL SST DATA AVAILABLE.
       fi

   if [ $domain = firewx ] ; then

      cat > ${WORK_DIR}/fort.41 << !
      &source_data
       input_src_file="${SST_GLOBAL_FILE}"
       input_src_bitmap_file="$FIXnam/emcsfc_gland5min.grib2"
       input_src14km_file=""
       input_flake_file="$FIXnam/emcsfc_flake_sst_climo.grib2"
      /
      &model_specs
       model_lat_file="$COMIN/nam.t${cyc}z.${domain}_hpnt_latitudes.grb"
       model_lon_file="$COMIN/nam.t${cyc}z.${domain}_hpnt_longitudes.grb"
       model_lsmask_file="$COMIN/nam.t${cyc}z.${domain}_slmask.grb"
      /
      &output_data
       output_file="${WORK_DIR}/sst.${CYCLE_TIME}.${DOMAIN}.grb"
       output_grib2=.false.
      /
      &parameters
       climo_4_lakes=.true.
      /
!

   else

      cat > ${WORK_DIR}/fort.41 << !
      &source_data
       input_src_file="${SST_GLOBAL_FILE}"
       input_src_bitmap_file="${FIXED_DIR}/emcsfc_gland5min.grib2"
       input_src14km_file=""
       input_flake_file="${FIXED_DIR}/emcsfc_flake_sst_climo.grib2"
      /
      &model_specs
       model_lat_file="${FIXED_DIR}/nam_${domain}nest_hpnt_latitudes.grb"
       model_lon_file="${FIXED_DIR}/nam_${domain}nest_hpnt_longitudes.grb"
       model_lsmask_file="${FIXED_DIR}/nam_${domain}nest_slmask.grb"
      /
      &output_data
       output_file="${WORK_DIR}/sst.${CYCLE_TIME}.${DOMAIN}.grb"
       output_grib2=.false.
      /
      &parameters
       climo_4_lakes=.true.
      /
!

#end firewx nest check
  fi

      export pgm=emcsfc_sst2mdl
      . prep_step
#
      startmsg
      $EXECnam/emcsfc_sst2mdl >> $pgmout 2>errfile
      export err=$?

#---------------------------------------------------------------------
#     if there is a problem in the program, don't need to abort.
#     the sfcupdate program will run with no new sst analysis,
#     but we want the logs to know about it!
#---------------------------------------------------------------------
      if [ $err -ne 0 ]
      then
        msg=" ABNORMAL TERMINATION IN $pgm : run without new sst analysis"
      else
        msg="$pgm completed normally"
        cp ${WORK_DIR}/sst.${CYCLE_TIME}.${DOMAIN}.grb $COMOUT/nam.t${cyc}z.${domain}nest_sstanl.grb
      fi
      postmsg "$msg"
                                                                                                  
      rm ${WORK_DIR}/fort.41

   fi # grib header date in global sst file is current
  fi # sst file exists
fi # is cycle hour

# Still need to run sfcupdate every cycle to update veg fraction and snowfree albedo

#---------------------------------------------------------------------
# run surface update program,  will automatically check for the
# the existance of current sst, seaice and snow data in the rform:.  
#
#  $type.$CYCLE_TIME.$DOMAIN.grb
#
#  where type=sst, snow, seaice
#        CYCLE_TIME=tm06 valid time
#        DOMAIN=nam
#
# If these files exist, the code will use them, otherwise, it will cycle first guess
# values.
#
# "first_guess_file" is the input wrf binary file
# "output_file" is the output wrf binary file (may be the same
#  as first_guess_file).
#
# sst/seaice/snow_depth_anal_dir should be set to the directory
# where the data from the previous three programs resides.
#---------------------------------------------------------------------

if [ $domain = firewx ] ; then

# Burn data info

# 1) Run emcsfc_accum_firedata.sh to get 2-day and 30-day accumulated burn data
#    for 1 km and 12 km grid. 1 km grid is the primary; 12 km is used if area
#    is not covered by 1 km data

export ENDFIRE=$CYCLE

STARTFIRE_2day=`${NDATE} -48 $ENDFIRE`
STARTFIRE_30day=`${NDATE} -720 $ENDFIRE`

. $USHnam/emcsfc_accum_firedata.sh $STARTFIRE_2day $ENDFIRE 12 2
. $USHnam/emcsfc_accum_firedata.sh $STARTFIRE_30day $ENDFIRE 12 30

. $USHnam/emcsfc_accum_firedata.sh $STARTFIRE_2day $ENDFIRE 1 2
. $USHnam/emcsfc_accum_firedata.sh $STARTFIRE_30day $ENDFIRE 1 30

# 2) emcsfc_fire2mdl.sh : maps burn data to fire wx nest domain

. $USHnam/emcsfc_fire2mdl.sh 2 ${CYCLE_TIME}
. $USHnam/emcsfc_fire2mdl.sh 30 ${CYCLE_TIME}

# change name to that expected by sfcupdate

mv fire.${CYCLE_TIME}.2day.firewx.grb fire.${CYCLE_TIME}.daily.firewx.grib2
mv fire.${CYCLE_TIME}.30day.firewx.grb fire.${CYCLE_TIME}.monthly.firewx.grib2

cp fire.${CYCLE_TIME}.daily.firewx.grib2 $COMOUT/nam.t${cyc}z.${domain}nest_fire.daily.grib2
cp fire.${CYCLE_TIME}.monthly.firewx.grib2 $COMOUT/nam.t${cyc}z.${domain}nest_fire.monthly.grib2

cp accum_fire.1km.2day.grib2  $COMOUT/nam.t${cyc}z.${domain}nest.accum_fire_1km_2day.grib2
cp accum_fire.12km.2day.grib2 $COMOUT/nam.t${cyc}z.${domain}nest.accum_fire_12km_2day.grib2
cp accum_fire.1km.30day.grib2  $COMOUT/nam.t${cyc}z.${domain}nest.accum_fire_1km_30day.grib2
cp accum_fire.12km.30day.grib2 $COMOUT/nam.t${cyc}z.${domain}nest.accum_fire_12km_30day.grib2

cat > ${WORK_DIR}/fort.41 << !
 &grid_info
  domain_name="${DOMAIN}"
 /
 &cycle
  cycle_year=$CYCLE_YEAR
  cycle_month=$CYCLE_MON
  cycle_day=$CYCLE_DAY
  cycle_hour=$CYCLE_HOUR
  fcst_hour=0.0
 /
 &model_flds
  first_guess_file="${WORK_DIR}/input_nemsio_${DOMAIN}"
  first_guess_file_type="nems"
 /
 &fixed_flds
  lsmask_file="${FIXED_DIR}/${RUN}.t${cyc}z.${domain}_slmask.grb"
 /
 &time_varying_analysis_flds
  snowfree_albedo_climo_file="${FIXED_DIR}/${RUN}.t${cyc}z.${domain}_snowfree_albedo.grb"
  greenfrc_climo_file="${FIXED_DIR}/${RUN}.t${cyc}z.${domain}_vegfrac.grb"
  z0_climo_file=""
  seaice_anal_dir="${WORK_DIR}/"
  seaice_climo_file=""
  sst_anal_dir="${WORK_DIR}/"
  sst_climo_file=""
  merge_coeff_sst=0.
  sst_anlcyc_update=.false.
  soilm_climo_file=""
  merge_coeff_soilm=99999.
  snow_depth_anal_dir="${WORK_DIR}/"
  snow_depth_climo_file=""
  merge_coeff_snow_depth=-2.
  fire_anal_dir="${WORK_DIR}/"
 /
 &output
  output_file="${WORK_DIR}/input_nemsio_${DOMAIN}"
  output_file_type="nems"
 /
 &settings
  thinned=.false.
  nsoil=4
 /
 &soil_parameters
  soil_type_src="statsgo"
  smclow = 0.5
  smchigh = 3.0
  smcmax = 0.395, 0.421, 0.434, 0.476, 0.476, 0.439,
           0.404, 0.464, 0.465, 0.406, 0.468, 0.457,
           0.464, -9.99,  0.20, 0.421
  beta =  4.05,  4.26,  4.74,  5.33,  5.33,  5.25,
          6.77,  8.72,  8.17, 10.73, 10.39, 11.55,
          5.25, -9.99,  4.05,  4.26
  psis =  0.0350, 0.0363, 0.1413, 0.7586, 0.7586, 0.3548,
          0.1349, 0.6166, 0.2630, 0.0977, 0.3236, 0.4677,
          0.3548,  -9.99, 0.0350, 0.0363
  satdk = 1.7600e-4, 1.4078e-5, 5.2304e-6, 2.8089e-6, 2.8089e-6,
          3.3770e-6, 4.4518e-6, 2.0348e-6, 2.4464e-6, 7.2199e-6,
          1.3444e-6, 9.7394e-7, 3.3770e-6,     -9.99, 1.4078e-5,
          1.4078e-5
 /
 &veg_parameters
  veg_type_src="igbp"
  salp = 4.0
  snup = 0.080, 0.080, 0.080, 0.080, 0.080, 0.020,
         0.020, 0.060, 0.040, 0.020, 0.010, 0.020,
         0.020, 0.020, 0.013, 0.013, 0.010, 0.020,
         0.020, 0.020
 /
!

else

cat > ${WORK_DIR}/fort.41 << !
 &grid_info
  domain_name="${DOMAIN}"
 /
 &cycle
  cycle_year=$CYCLE_YEAR
  cycle_month=$CYCLE_MON
  cycle_day=$CYCLE_DAY
  cycle_hour=$CYCLE_HOUR
  fcst_hour=0.0
 /
 &model_flds
  first_guess_file="${WORK_DIR}/input_nemsio_${DOMAIN}"
  first_guess_file_type="nems"
 /
 &fixed_flds
  lsmask_file="${FIXED_DIR}/nam_${domain}nest_slmask.grb"
 /
 &time_varying_analysis_flds
  snowfree_albedo_climo_file="${FIXED_DIR}/nam_${domain}nest_snowfree_albedo.grb"
  greenfrc_climo_file="${FIXED_DIR}/nam_${domain}nest_vegfrac.grb"
  z0_climo_file=""
  seaice_anal_dir="${WORK_DIR}/"
  seaice_climo_file=""
  sst_anal_dir="${WORK_DIR}/"
  sst_climo_file=""
  merge_coeff_sst=0.
  sst_anlcyc_update=.false.
  soilm_climo_file=""
  merge_coeff_soilm=99999.
  snow_depth_anal_dir="${WORK_DIR}/"
  snow_depth_climo_file=""
  merge_coeff_snow_depth=-2.
  fire_anal_dir=""
 /
 &output
  output_file="${WORK_DIR}/input_nemsio_${DOMAIN}"
  output_file_type="nems"
 /
 &settings
  thinned=.false.
  nsoil=4
 /
 &soil_parameters
  soil_type_src="statsgo"
  smclow = 0.5
  smchigh = 3.0
  smcmax = 0.395, 0.421, 0.434, 0.476, 0.476, 0.439,
           0.404, 0.464, 0.465, 0.406, 0.468, 0.457,
           0.464, -9.99,  0.20, 0.421
  beta =  4.05,  4.26,  4.74,  5.33,  5.33,  5.25,
          6.77,  8.72,  8.17, 10.73, 10.39, 11.55,
          5.25, -9.99,  4.05,  4.26
  psis =  0.0350, 0.0363, 0.1413, 0.7586, 0.7586, 0.3548,
          0.1349, 0.6166, 0.2630, 0.0977, 0.3236, 0.4677,
          0.3548,  -9.99, 0.0350, 0.0363
  satdk = 1.7600e-4, 1.4078e-5, 5.2304e-6, 2.8089e-6, 2.8089e-6,
          3.3770e-6, 4.4518e-6, 2.0348e-6, 2.4464e-6, 7.2199e-6,
          1.3444e-6, 9.7394e-7, 3.3770e-6,     -9.99, 1.4078e-5,
          1.4078e-5
 /
 &veg_parameters
  veg_type_src="igbp"
  salp = 4.0
  snup = 0.080, 0.080, 0.080, 0.080, 0.080, 0.020,
         0.020, 0.060, 0.040, 0.020, 0.010, 0.020,
         0.020, 0.020, 0.013, 0.013, 0.010, 0.020,
         0.020, 0.020
 /
!

fi
  
export pgm=emcsfc_sfcupdate
. prep_step
#
startmsg
${MPIEXEC} $EXECnam/emcsfc_sfcupdate >> $pgmout 2>errfile
export err=$?;err_chk

rm -f ${WORK_DIR}/fort.41

if [ $CYCNEST = true ] ; then

if [ ${RUNTYPE} = CATCHUP ]; then
  mv input_nemsio_${DOMAIN} $GESDIR/nam.t${cyc}z.input_domain_${domain}nest_nemsio.tm06
  export err=$?;err_chk
else
  mv input_nemsio_${DOMAIN} $GESDIR/nam.t${cyc}z.nmm_b_restart_${domain}nest_nemsio.ges
  export err=$?;err_chk
fi

else

  mv input_nemsio_${DOMAIN} $GESDIR/nam.t${cyc}z.input_domain_${domain}nest_nemsio
  export err=$?;err_chk

fi

echo "DONE" >$DATA/sfcupdate_${DOMAIN}.done

mv $pgmout $DATA/.
cd $DATA
exit $err
