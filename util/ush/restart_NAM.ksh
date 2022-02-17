#!/bin/ksh

#
# Script is used to initialize/prep the NAMRR directories in the event
#  of a production switch - or if the user wants to restart the NAMRR
#  from a particular point in time.
#


# Note that this script is NOT intended to pull down obs, BCs etc.


# Currently only configured to work with a CATCHUP cycle.  Making it work for HOURLY
#  is feasible but would still require pulling down all files related to the most recent
#  CATCHUP cycle (so the next CATCHUP cycle would have everything needed).



# To save
# NAMRR.xml snapshot (not .db, probably better to start fresh from a cycle)
#    - note this will require a fresh start from a CATCHUP cycle
#  satellite bias correction files, stored in the right directories
#  restart files, stored in the right directories
#  precip budget file, right directory
#  hourly precip files, right directory

# *****************************************************************#
# Script assumes that JNAMRR_ENVARS has been run prior to invoking.#
# *****************************************************************#

set -x


nests="conus alaska"

tim=$1                #the cycle date

export PS4='HPSS_T$SECONDS + '

CYC=`echo ${tim} | cut -c 9-10`
CDATE=`echo ${tim} | cut -c 1-10`
YYYYMM=`echo ${tim} | cut -c 1-6`
YYYY=`echo ${tim} | cut -c 1-4`
PDY=`echo ${tim} | cut -c 1-8`


if [ $CYC -eq 00 -o $CYC -eq 06 -o $CYC -eq 12 -o $CYC -eq 18 ]; then
  export RUNTYPE=CATCHUP
else
  echo "PRODSWITCH SCRIPT IS ONLY FUNCTIONAL FOR CATCHUP CYCLES AT THIS TIME. EXIT!"
  exit 1
fi

tarfile_prefix=`echo $COM_OUT/${RUN} | cut -c 2- | tr "/" "_"`
precip_tarfile_prefix=`echo $COM_HRLY_PCP/nam_pcpn_anal | cut -c 2- | tr "/" "_"`


TM48=`$NDATE -48 $CDATE`
CYC_tm48=`echo $TM48 | cut -c 9-10`
CDATE_tm48=`echo $TM48 | cut -c 1-10`
PDY_tm48=`echo $TM48 | cut -c 1-8`
YYYY_tm48=`echo $TM48 | cut -c 1-4`
YYYYMM_tm48=`echo $TM48 | cut -c 1-6`


TM42=`$NDATE -42 $CDATE`
CYC_tm42=`echo $TM42 | cut -c 9-10`
CDATE_tm42=`echo $TM42 | cut -c 1-10`
PDY_tm42=`echo $TM42 | cut -c 1-8`
YYYY_tm42=`echo $TM42 | cut -c 1-4`
YYYYMM_tm42=`echo $TM42 | cut -c 1-6`

TM36=`$NDATE -36 $CDATE`
CYC_tm36=`echo $TM36 | cut -c 9-10`
CDATE_tm36=`echo $TM36 | cut -c 1-10`
PDY_tm36=`echo $TM36 | cut -c 1-8`
YYYY_tm36=`echo $TM36 | cut -c 1-4`
YYYYMM_tm36=`echo $TM36 | cut -c 1-6`

TM30=`$NDATE -30 $CDATE`
CYC_tm30=`echo $TM30 | cut -c 9-10`
CDATE_tm30=`echo $TM30 | cut -c 1-10`
PDY_tm30=`echo $TM30 | cut -c 1-8`
YYYY_tm30=`echo $TM30 | cut -c 1-4`
YYYYMM_tm30=`echo $TM30 | cut -c 1-6`

TM24=`$NDATE -24 $CDATE`
CYC_tm24=`echo $TM24 | cut -c 9-10`
CDATE_tm24=`echo $TM24 | cut -c 1-10`
PDY_tm24=`echo $TM24 | cut -c 1-8`
YYYY_tm24=`echo $TM24 | cut -c 1-4`
YYYYMM_tm24=`echo $TM24 | cut -c 1-6`

TM18=`$NDATE -18 $CDATE`
CYC_tm18=`echo $TM18 | cut -c 9-10`
CDATE_tm18=`echo $TM18 | cut -c 1-10`
PDY_tm18=`echo $TM18 | cut -c 1-8`
YYYY_tm18=`echo $TM18 | cut -c 1-4`
YYYYMM_tm18=`echo $TM18 | cut -c 1-6`

TM12=`$NDATE -12 $CDATE`
CYC_tm12=`echo $TM12 | cut -c 9-10`
CDATE_tm12=`echo $TM12 | cut -c 1-10`
PDY_tm12=`echo $TM12 | cut -c 1-8`
YYYY_tm12=`echo $TM12 | cut -c 1-4`
YYYYMM_tm12=`echo $TM12 | cut -c 1-6`

TM09=`$NDATE -09 $CDATE`
CYC_tm09=`echo $TM09 | cut -c 9-10`
CDATE_tm09=`echo $TM09 | cut -c 1-10`
PDY_tm09=`echo $TM09 | cut -c 1-8`
YYYY_tm09=`echo $TM09 | cut -c 1-4`
YYYYMM_tm09=`echo $TM09 | cut -c 1-6`

TM06=`$NDATE -06 $CDATE`
CYC_tm06=`echo $TM06 | cut -c 9-10`
CDATE_tm06=`echo $TM06 | cut -c 1-10`
PDY_tm06=`echo $TM06 | cut -c 1-8`
YYYY_tm06=`echo $TM06 | cut -c 1-4`
YYYYMM_tm06=`echo $TM06 | cut -c 1-6`

TM05=`$NDATE -05 $CDATE`
CYC_tm05=`echo $TM05 | cut -c 9-10`
CDATE_tm05=`echo $TM05 | cut -c 1-10`
PDY_tm05=`echo $TM05 | cut -c 1-8`
YYYY_tm05=`echo $TM05 | cut -c 1-4`
YYYYMM_tm05=`echo $TM05 | cut -c 1-6`

TM04=`$NDATE -04 $CDATE`
CYC_tm04=`echo $TM04 | cut -c 9-10`
CDATE_tm04=`echo $TM04 | cut -c 1-10`
PDY_tm04=`echo $TM04 | cut -c 1-8`
YYYY_tm04=`echo $TM04 | cut -c 1-4`
YYYYMM_tm04=`echo $TM04 | cut -c 1-6`

TM03=`$NDATE -03 $CDATE`
CYC_tm03=`echo $TM03 | cut -c 9-10`
CDATE_tm03=`echo $TM03 | cut -c 1-10`
PDY_tm03=`echo $TM03 | cut -c 1-8`
YYYY_tm03=`echo $TM03 | cut -c 1-4`
YYYYMM_tm03=`echo $TM03 | cut -c 1-6`

TM02=`$NDATE -02 $CDATE`
CYC_tm02=`echo $TM02 | cut -c 9-10`
CDATE_tm02=`echo $TM02 | cut -c 1-10`
PDY_tm02=`echo $TM02 | cut -c 1-8`
YYYY_tm02=`echo $TM02 | cut -c 1-4`
YYYYMM_tm02=`echo $TM02 | cut -c 1-6`

TM01=`$NDATE -01 $CDATE`
CYC_tm01=`echo $TM01 | cut -c 9-10`
CDATE_tm01=`echo $TM01 | cut -c 1-10`
PDY_tm01=`echo $TM01 | cut -c 1-8`
YYYY_tm01=`echo $TM01 | cut -c 1-4`
YYYYMM_tm01=`echo $TM01 | cut -c 1-6`

export HPSSOUT=/${HPSS_RETENTION_PERIOD}/NCEPDEV/${HPSS_GROUP}/${HPSS_USER}/nw${envir}
ARCH=${HPSSOUT}/rh${YYYY}/${YYYYMM}/$PDY

ARCHM1=${HPSSOUT}/rh${YYYY_tm01}/${YYYYMM_tm01}/${PDY_tm01}
ARCHM2=${HPSSOUT}/rh${YYYY_tm02}/${YYYYMM_tm02}/${PDY_tm02}
ARCHM3=${HPSSOUT}/rh${YYYY_tm03}/${YYYYMM_tm03}/${PDY_tm03}
ARCHM4=${HPSSOUT}/rh${YYYY_tm04}/${YYYYMM_tm04}/${PDY_tm04}
ARCHM5=${HPSSOUT}/rh${YYYY_tm05}/${YYYYMM_tm05}/${PDY_tm05}
ARCHM6=${HPSSOUT}/rh${YYYY_tm06}/${YYYYMM_tm06}/${PDY_tm06}

ARCHM12=${HPSSOUT}/rh${YYYY_tm12}/${YYYYMM_tm12}/${PDY_tm12}
ARCHM18=${HPSSOUT}/rh${YYYY_tm18}/${YYYYMM_tm18}/${PDY_tm18}
ARCHM24=${HPSSOUT}/rh${YYYY_tm24}/${YYYYMM_tm24}/${PDY_tm24}
ARCHM30=${HPSSOUT}/rh${YYYY_tm30}/${YYYYMM_tm30}/${PDY_tm30}
ARCHM36=${HPSSOUT}/rh${YYYY_tm36}/${YYYYMM_tm36}/${PDY_tm36}
ARCHM42=${HPSSOUT}/rh${YYYY_tm42}/${YYYYMM_tm42}/${PDY_tm42}

# Get restart files for parent and then any nests

mkdir -p ${gespath}/${RUN}.hold

# -- Parent
if [ ! -s ${gespath}/${RUN}.hold/nam_hpss_restart.done ]; then
  hsi "cd $ARCHM6 ; get nam.t${CYC_tm06}z.nmm_b_restart_nemsio_anl.tm00"
  mv nam.t${CYC_tm06}z.nmm_b_restart_nemsio_anl.tm00 ${gespath}/${RUN}.hold/nmm_b_restart_nemsio_hold.${CYC_tm06}z
  echo 'done' > ${gespath}/${RUN}.hold/nam_hpss_restart.done
fi
# -- Nests
for domain in ${nests}; do
  if [ ! -s ${gespath}/${RUN}.hold/${domain}nest_hpss_restart.done ]; then
    hsi "cd $ARCHM6 ; get nam.t${CYC_tm06}z.nmm_b_restart_${domain}nest_nemsio_anl.tm00"
    mv nam.t${CYC_tm06}z.nmm_b_restart_${domain}nest_nemsio_anl.tm00 ${gespath}/${RUN}.hold/nmm_b_restart_${domain}nest_nemsio_hold.${CYC_tm06}z
    echo 'done' > ${gespath}/${RUN}.hold/${domain}nest_hpss_restart.done
  fi
done

# -- Get the satellite bias correction files
htar -xvf ${ARCHM6}/${tarfile_prefix}.${TM06}.bufr.tar ./nam.t${CYC_tm06}z.satbias.tm01
htar -xvf ${ARCHM6}/${tarfile_prefix}.${TM06}.bufr.tar ./nam.t${CYC_tm06}z.satbias_pc.tm01
htar -xvf ${ARCHM6}/${tarfile_prefix}.${TM06}.bufr.tar ./nam.t${CYC_tm06}z.radstat.tm01

# --  Strongly suggest only updating biascr in parent so make the appropriate file in the 
# --  COMOUT directory so that both the parent and nest pick up the same file - this way
# --  the parent will NOT grab an already updated file from $HOLD

mkdir -p ${COM_IN}/${RUN}.${PDY_tm06} 
mv nam.t${CYC_tm06}z.satbias.tm01 ${COM_IN}/${RUN}.${PDY_tm06}/
mv nam.t${CYC_tm06}z.satbias_pc.tm01 ${COM_IN}/${RUN}.${PDY_tm06}/
mv nam.t${CYC_tm06}z.radstat.tm01 ${COM_IN}/${RUN}.${PDY_tm06}/


# -- Get pcpbudget file, there is only one and it is for the parent
# -- Note that the pcpbudget file is only updated at tm06 on the 12Z
# -- cycle.  So we have to find the nearest completed 12z cycle and grab
# -- that one.

if [ $CYC -eq 00 ] ; then
  htar -xvf ${ARCHM12}/${tarfile_prefix}.${CDATE_tm12}.input.tar ./nam.t${CYC_tm12}z.pcpbudget_history
  mkdir -p ${COM_OUT}/${RUN}.${PDY_tm12}
  cp nam.t${CYC_tm12}z.pcpbudget_history ${COM_OUT}/${RUN}.${PDY_tm12}
  mv nam.t${CYC_tm12}z.pcpbudget_history pcpbudget_history
fi
if [ $CYC -eq 06 ] ; then
  htar -xvf ${ARCHM18}/${tarfile_prefix}.${CDATE_tm18}.input.tar ./nam.t${CYC_tm18}z.pcpbudget_history
  mkdir -p ${COM_OUT}/${RUN}.${PDY_tm18}
  cp nam.t${CYC_tm18}z.pcpbudget_history ${COM_OUT}/${RUN}.${PDY_tm18}
  mv nam.t${CYC_tm18}z.pcpbudget_history pcpbudget_history
fi 
if [ $CYC -eq 12 ] ; then # Use the 24 hour old pcpbudget file since we will be updating on this cycle
  htar -xvf ${ARCHM24}/${tarfile_prefix}.${CDATE_tm24}.input.tar ./nam.t${CYC_tm24}z.pcpbudget_history
  mkdir -p ${COM_OUT}/${RUN}.${PDY_tm24}
  cp nam.t${CYC_tm24}z.pcpbudget_history ${COM_OUT}/${RUN}.${PDY_tm24}
  mv nam.t${CYC_tm24}z.pcpbudget_history pcpbudget_history
fi
if [ $CYC -eq 18 ] ; then
  htar -xvf ${ARCHM6}/${tarfile_prefix}.${TM06}.input.tar ./nam.t${CYC_tm06}z.pcpbudget_history
  mkdir -p ${COM_OUT}/${RUN}.${PDY_tm06}
  cp nam.t${CYC_tm06}z.pcpbudget_history ${COM_OUT}/${RUN}.${PDY_tm06}
  mv nam.t${CYC_tm06}z.pcpbudget_history pcpbudget_history
fi

# -- If we can't find the budget file on disk then abort
if [ ! -s pcpbudget_history ]; then
  echo "UNABLE TO LOCATE PCP BUDGET HISTORY FILE! Attempting to grab a file from ${RTRUN_SRC_GESDIR}/ndas.hold"
  cp ${RTRUN_SRC_GESDIR}/ndas.hold/pcpbudget_history pcpbudget_history
  err=$?
  if [ $err -ne 0 ]; then
    echo "UNABLE TO LOCATE PCP BUDGET HISTORY FILE!    EXIT!"
    exit 1    
  fi
fi
# -- Move pcpbudget_history file to correct nam.hold directory
mv pcpbudget_history ${gespath}/${RUN}.hold/pcpbudget_history


# Get the COM HRLY precip files
#  We probably need to get at LEAST the two most recent sets of hourly precip files so future
#  cycles are also covered. Get the most recent 00Z and the previous 48hrs of 00Z cycles.

htar -xvf ${ARCH}/${precip_tarfile_prefix}.${PDY}00.hourly.tar
err=$?

if [ $err -eq 0 ]; then
  mkdir -p ${COM_HRLY_PCP}/nam_pcpn_anal.${PDY}
  mv nampcp.* ${COM_HRLY_PCP}/nam_pcpn_anal.${PDY}/
  for domain in ${nests}; do
    mv ${domain}nest_nam_pcp.* ${COM_HRLY_PCP}/nam_pcpn_anal.${PDY}/
  done
else
  #Get these from the bgrdsf files and run getpcp scripts
  OUTDIR=${COM_OUT}/${RUN}.${PDY}
  mkdir -p ${OUTDIR}
  tmmark=tm00
  fhr=13
  while [ ${fhr} -le 36 ]; do
    htar -xvf ${ARCH}/${tarfile_prefix}.${PDY}00.bgrid.tar ./nam.t00z.bgrdsf${fhr}.${tmmark}
    mv nam.t00z.bgrdsf${fhr}.${tmmark} ${OUTDIR}/nam.t00z.bgrdsf${fhr}.${tmmark}  
    for domain in ${nests}; do
      htar -xvf ${ARCH}/${tarfile_prefix}.${PDY}00.bgrid.tar ./nam.t00z.${domain}nest.bgrdsf${fhr}.${tmmark}
      mv nam.t00z.${domain}nest.bgrdsf${fhr}.${tmmark} ${OUTDIR}/nam.t00z.${domain}nest.bgrdsf${fhr}.${tmmark}
    done
    (( fhr = fhr + 1 ))
  done
  export CYCLE=${PDY}00
  export cyc=00
  ${USHnam}/nam_getpcp_nam00z.sh
  ${USHnam}/nam_getpcp_nam00z_nest.sh
fi

htar -xvf ${ARCHM24}/${precip_tarfile_prefix}.${PDY_tm24}00.hourly.tar
err=$?
if [ $err -eq 0 ]; then
  mkdir -p ${COM_HRLY_PCP}/nam_pcpn_anal.${PDY_tm24}
  mv nampcp.* ${COM_HRLY_PCP}/nam_pcpn_anal.${PDY_tm24}/
  for domain in ${nests}; do
    mv ${domain}nest_nam_pcp.* ${COM_HRLY_PCP}/nam_pcpn_anal.${PDY_tm24}/
  done
else
  #Get these from the bgrdsf files and run getpcp scripts
  OUTDIR=${COM_OUT}/${RUN}.${PDY_tm24}
  mkdir -p ${OUTDIR}
  tmmark=tm00
  fhr=13
  while [ ${fhr} -le 36 ]; do
    htar -xvf ${ARCHM24}/${tarfile_prefix}.${PDY_tm24}00.bgrid.tar ./nam.t00z.bgrdsf${fhr}.${tmmark}
    mv nam.t00z.bgrdsf${fhr}.${tmmark} ${OUTDIR}/nam.t00z.bgrdsf${fhr}.${tmmark}  
    for domain in ${nests}; do
      htar -xvf ${ARCHM24}/${tarfile_prefix}.${PDY_tm24}00.bgrid.tar ./nam.t00z.${domain}nest.bgrdsf${fhr}.${tmmark}
      mv nam.t00z.${domain}nest.bgrdsf${fhr}.${tmmark} ${OUTDIR}/nam.t00z.${domain}nest.bgrdsf${fhr}.${tmmark}
    done
    (( fhr = fhr + 1 ))
  done
  export CYCLE=${PDY_tm24}00
  export cyc=00
  ${USHnam}/nam_getpcp_nam00z.sh
  ${USHnam}/nam_getpcp_nam00z_nest.sh 
fi

htar -xvf ${ARCHM48}/${precip_tarfile_prefix}.${PDY_tm48}00.hourly.tar
err=$?
if [ $err -eq 0 ]; then
  mkdir -p ${COM_HRLY_PCP}/nam_pcpn_anal.${PDY_tm48}
  mv nampcp.* ${COM_HRLY_PCP}/nam_pcpn_anal.${PDY_tm48}/
  for domain in ${nests}; do
    mv ${domain}nest_nam_pcp.* ${COM_HRLY_PCP}/nam_pcpn_anal.${PDY_tm48}/
  done
else
  #Get these from the bgrdsf files and run getpcp scripts
  OUTDIR=${COM_OUT}/${RUN}.${PDY_tm48}
  mkdir -p ${OUTDIR}
  tmmark=tm00
  fhr=13
  while [ ${fhr} -le 36 ]; do
    htar -xvf ${ARCHM48}/${tarfile_prefix}.${PDY_tm48}00.bgrid.tar ./nam.t00z.bgrdsf${fhr}.${tmmark}
    mv nam.t00z.bgrdsf${fhr}.${tmmark} ${OUTDIR}/nam.t00z.bgrdsf${fhr}.${tmmark}  
    for domain in ${nests}; do
      htar -xvf ${ARCHM48}/${tarfile_prefix}.${PDY_tm48}00.bgrid.tar ./nam.t00z.${domain}nest.bgrdsf${fhr}.${tmmark}
      mv nam.t00z.${domain}nest.bgrdsf${fhr}.${tmmark} ${OUTDIR}/nam.t00z.${domain}nest.bgrdsf${fhr}.${tmmark}
    done
    (( fhr = fhr + 1 ))
  done
  export CYCLE=${PDY_tm48}00
  export cyc=00
  ${USHnam}/nam_getpcp_nam00z.sh
  ${USHnam}/nam_getpcp_nam00z_nest.sh 
fi

#cyc may have been reset when getting the bgrdsf files so reset here to be on the safe side
export cyc=`echo ${tim} | cut -c 9-10`

#
#  Below needs to be done for the precip budget update step that happens at 12z.
#  But note that we'll need to pull down as much of this as possible
#  to support any subsequent 12Z cycles.
#
#  This step is ONLY performed for the parent domain. No budget files is maintained
#  for the nest.

# Pull down the most recent 2 days of these
tmmarks="tm06 tm05 tm04 tm03 tm02 tm01"
prevcycs="-06 -12 -18 -24 -36 -42 -48"
for delt in ${prevcycs}; do
  newCDATE=`$NDATE $delt $CDATE`
  newCYC=`echo $newCDATE | cut -c 9-10`
  newPDY=`echo $newCDATE | cut -c 1-8`
  newYYYY=`echo $newCDATE | cut -c 1-4`
  newYYYYMM=`echo $newCDATE | cut -c 1-6`
  OUTDIR=${COM_IN}/${RUN}.${newPDY}
  mkdir -p $OUTDIR
  newARCH=${HPSSOUT}/rh${newYYYY}/${newYYYYMM}/$newPDY
  for tmmark in ${tmmarks}; do
    htar -xvf ${newARCH}/${tarfile_prefix}.${newCDATE}.bgrid.tar ./nam.t${newCYC}z.bgrdsf01.${tmmark}
    mv nam.t${newCYC}z.bgrdsf01.${tmmark} ${OUTDIR}/nam.t${newCYC}z.bgrdsf01.${tmmark}  
  done  
done




exit 0

