#!/bin/ksh

set -x

export HPSS_HOSTNAME=`hostname -s`p
export HPSS_PFTPC_PORT_RANGE=ncacn_ip_tcp[38000-38999]
export HPSS_NDCG_SERVERS=10.198.22.5/8001

export GETdumps=NO

#For calculating the day-of-the-year which ised by the RAP/RUC
export datecalc=${UTIL_USHnam}/datecalc.ksh

#
# 10-29-2012 CARLEY - modified with option to grab clean CTL or EXP NAM
#   prepbufr files
#
#  01/11/2013 - Begin modifications for NAMRR
#  01/18/2013 - Continue NAMRR dev


TYPE=$1
tim=$2                #the cycle date
EXPOPT=$3            #Option is no longer used here but keeping the variable in case it is needed for future use
RUNTYPE=$4            #if this is catchup then we have to get tm06-tm00 data.  if not then just tm00



if [ $TYPE = first -a $RUNTYPE != CATCHUP ]; then
  echo "INVALID RUNTYPE OF $RUNTYPE FOR TYPE OPTION first!"
  echo "USE RUNTYPE = CATCHUP FOR TYPE = first!  EXIT!"
  exit 1
fi


HOLDscr=${gespath}/nam.hold
mkdir -p ${HOLDscr}

export PS4='HPSS_T$SECONDS + '


mkdir -p ${INPUT}
cd ${INPUT}

CYC=`echo ${tim} | cut -c 9-10`
CDATE=`echo ${tim} | cut -c 1-10`
YYYYMM=`echo ${tim} | cut -c 1-6`
YYYY=`echo ${tim} | cut -c 1-4`
PDY=`echo ${tim} | cut -c 1-8`


if [ $CYC -eq 00 -o $CYC -eq 06 -o $CYC -eq 12 -o $CYC -eq 18 ]; then
  if [ $RUNTYPE != CATCHUP ]; then
  echo "A CATCHUP CYCLE WAS CHOSEN BUT RUNTYPE WAS NOT SET TO CATCHUP! CYC: $CYC  RUNTYPE:${RUNTYPE}   EXIT!"
  exit 1
  fi
fi


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


ARCH=/NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYYMM}/${PDY}
ARCH2YR=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY}/${YYYYMM}/${PDY}

ARCH2YRM1=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tm01}/${YYYYMM_tm01}/${PDY_tm01}
ARCH2YRM2=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tm02}/${YYYYMM_tm02}/${PDY_tm02}
ARCH2YRM3=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tm03}/${YYYYMM_tm03}/${PDY_tm03}
ARCH2YRM4=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tm04}/${YYYYMM_tm04}/${PDY_tm04}
ARCH2YRM5=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tm05}/${YYYYMM_tm05}/${PDY_tm05}
ARCH2YRM6=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tm06}/${YYYYMM_tm06}/${PDY_tm06}
ARCH2YRM9=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tm09}/${YYYYMM_tm09}/${PDY_tm09}
ARCH2YRM12=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tm12}/${YYYYMM_tm12}/${PDY_tm12}

ARCHM1=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tm01}/${YYYYMM_tm01}/${PDY_tm01}
ARCHM2=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tm02}/${YYYYMM_tm02}/${PDY_tm02}
ARCHM3=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tm03}/${YYYYMM_tm03}/${PDY_tm03}
ARCHM4=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tm04}/${YYYYMM_tm04}/${PDY_tm04}
ARCHM5=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tm05}/${YYYYMM_tm05}/${PDY_tm05}

ARCHM6=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tm06}/${YYYYMM_tm06}/${PDY_tm06}
ARCHM6_GFS=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tm06}/${YYYYMM_tm06}/${PDY_tm06}
ARCHM12=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tm12}/${YYYYMM_tm12}/${PDY_tm12}
ARCHM12_1YR=/NCEPPROD/1year/hpssprod/runhistory/rh${YYYY_tm12}/${YYYYMM_tm12}/${PDY_tm12}
ARCHM12_1YR_save=/NCEPPROD/1year/hpssprod/runhistory/rh${YYYY_tm12}/save

ARCHM18=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tm18}/${YYYYMM_tm18}/${PDY_tm18}
ARCHM18_1YR=/NCEPPROD/1year/hpssprod/runhistory/rh${YYYY_tm18}/${YYYYMM_tm18}/${PDY_tm18}
ARCHM24=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tm24}/${YYYYMM_tm24}/${PDY_tm24}

ARCHM30=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tm30}/${YYYYMM_tm30}/${PDY_tm30}
ARCHM36=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tm36}/${YYYYMM_tm36}/${PDY_tm36}
ARCHM42=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tm42}/${YYYYMM_tm42}/${PDY_tm42}

ARCHPLL=/NCEPDEV/hpsspara/runhistory/1year/mmbpll/rh${YYYY}/${YYYYMM}/${PDY}
ARCHPLLM6=/NCEPDEV/hpsspara/runhistory/1year/mmbpll/rh${YYYY_tm06}/${YYYYMM_tm06}/${PDY_tm06}
ARCHPLLM12=/NCEPDEV/hpsspara/runhistory/1year/mmbpll/rh${YYYY_tm12}/${YYYYMM_tm12}/${PDY_tm12}
ARCHPLLM18=/NCEPDEV/hpsspara/runhistory/1year/mmbpll/rh${YYYY_tm18}/${YYYYMM_tm18}/${PDY_tm18}
ARCHPLLM24=/NCEPDEV/hpsspara/runhistory/1year/mmbpll/rh${YYYY_tm24}/${YYYYMM_tm24}/${PDY_tm24}

# --------- Get the TM00-06 reject lists
#    For whatever reason - this step nearly always goes VERY slow.
#    So it gets its own piece

if [ $RUNTYPE = CATCHUP ]; then
  time="tm06 tm05 tm04 tm03 tm02 tm01 tm00"
else
  time="tm00"
fi

for tmmark in $time ; do
  offset=-`echo $tmmark | cut -c 3-4`
  adate=`$NDATE $offset $CDATE`
  apdy=`echo $adate | cut -c1-8`
  acyc=`echo $adate | cut -c9-10`
  ayyyy=`echo $adate | cut -c1-4`
  ayyyymm=`echo $adate | cut -c1-6`
  hpsspath=/NCEPPROD/hpssprod/runhistory/rh${ayyyy}/${ayyyymm}/${apdy}

  field="p t q w"
  for var in $field ; do
    if [ ! -s rtma2p5.t${acyc}z.${var}_rejectlist ]; then
      if [[ $acyc -ge 00 && $acyc -le 05 ]]; then
        htar -xvf ${hpsspath}/com_rtma_prod_rtma2p5.${apdy}00-05.tar ./rtma2p5.t${acyc}z.${var}_rejectlist
        if [ ! -s rtma2p5.t${acyc}z.${var}_rejectlist ]; then
          htar -xvf ${hpsspath}/com2_rtma_prod_rtma2p5.${apdy}00-05.tar ./rtma2p5.t${acyc}z.${var}_rejectlist
        fi        
      fi
 
      if [[ $acyc -ge 06 && $acyc -le 11 ]]; then
        htar -xvf ${hpsspath}/com_rtma_prod_rtma2p5.${apdy}06-11.tar ./rtma2p5.t${acyc}z.${var}_rejectlist
        if [ ! -s rtma2p5.t${acyc}z.${var}_rejectlist ]; then
          htar -xvf ${hpsspath}/com2_rtma_prod_rtma2p5.${apdy}06-11.tar ./rtma2p5.t${acyc}z.${var}_rejectlist
        fi   
      fi

      if [[ $acyc -ge 12 && $acyc -le 17 ]]; then
        htar -xvf ${hpsspath}/com_rtma_prod_rtma2p5.${apdy}12-17.tar ./rtma2p5.t${acyc}z.${var}_rejectlist
        if [ ! -s rtma2p5.t${acyc}z.${var}_rejectlist ]; then
          htar -xvf ${hpsspath}/com2_rtma_prod_rtma2p5.${apdy}12-17.tar ./rtma2p5.t${acyc}z.${var}_rejectlist
        fi   
      fi 
 
      if [[ $acyc -ge 18 && $acyc -le 23 ]]; then
        htar -xvf ${hpsspath}/com_rtma_prod_rtma2p5.${apdy}18-23.tar ./rtma2p5.t${acyc}z.${var}_rejectlist
        if [ ! -s rtma2p5.t${acyc}z.${var}_rejectlist ]; then
          htar -xvf ${hpsspath}/com2_rtma_prod_rtma2p5.${apdy}18-23.tar ./rtma2p5.t${acyc}z.${var}_rejectlist
        fi   
      fi   
    fi
  done
done

exit 0
