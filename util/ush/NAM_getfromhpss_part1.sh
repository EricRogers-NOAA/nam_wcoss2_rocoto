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
EXPOPT=$3             #Option is no longer used here but keeping the variable in case it is needed for future use
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



#Get files that are only needed for the catchup cycle (e.g. precip assimilation is only done for the catchup cycle)
if [ $RUNTYPE = CATCHUP ] ; then

  # First get all files needed for each tmmark during the catchup

  tmmarks="tm06 tm05 tm04 tm03 tm02 tm01"


  for tmmark in $tmmarks ; do

    delt=`echo $tmmark|cut -c 3-4`

    #Get the rap/ruc cycle based upon the tmmark for the NAMRR

    case $tmmark in   
      tm06)myARCH=${ARCHM6}
           rapcyc=${CYC_tm06}
           rappdy=${PDY_tm06};;   
      tm05)myARCH=${ARCHM5}
           rapcyc=${CYC_tm05}
           rappdy=${PDY_tm05};;   
      tm04)myARCH=${ARCHM4}
           rapcyc=${CYC_tm04}
           rappdy=${PDY_tm04};; 
      tm03)myARCH=${ARCHM3}
           rapcyc=${CYC_tm03}
           rappdy=${PDY_tm03};; 
      tm02)myARCH=${ARCHM2}
           rapcyc=${CYC_tm02}
           rappdy=${PDY_tm02};; 
      tm01)myARCH=${ARCHM1}
           rapcyc=${CYC_tm01}
           rappdy=${PDY_tm01};;
      *)   echo "BAD TMMARK! EXIT!"
           exit 1
    esac
 
    if [ ${rapcyc} -ge 0 -a ${rapcyc} -le 5 ]; then
      myrange=00-05
    elif [ ${rapcyc} -ge 6 -a ${rapcyc} -le 11 ]; then
      myrange=06-11
    elif [ ${rapcyc} -ge 12 -a ${rapcyc} -le 17 ]; then
      myrange=12-17
    elif [ ${rapcyc} -ge 18 -a ${rapcyc} -le 23 ]; then
      myrange=18-23
    else
      echo "WHOA!  Bad rapcyc=${rapcyc}!  UNABLE TO OBTAIN ANY RAP PREPBUFR or BUFR_D DATA. EXIT!"
      exit 1
    fi

    if [ ! -s rap.t${rapcyc}z.prepbufr.tm00 ]; then
      htar -xvf ${myARCH}/com_rap_prod_rap.${rappdy}${myrange}.bufr.tar ./rap.t${rapcyc}z.prepbufr.tm00
    fi

    if [ ${myrange} = 12-17 -a ! -s rap.t${rapcyc}z.prepbufr.tm00 ]; then
      # Originial implementation of RAP had botched archive step (Manikin, personal comm.)
      # So try again looking backward one day.

      rapcdate_tm24=`$NDATE -24 ${rappdy}${rapcyc}`
      rappdy_tm24=`echo $rapcdate_tm24 | cut -c 1-8`
      rapyyyy_tm24=`echo $rapcdate_tm24 | cut -c 1-4`
      rapyyyymm_tm24=`echo $rapcdate_tm24 | cut -c 1-6`
      ARCH_rapcdate_tm24=/NCEPPROD/hpssprod/runhistory/rh${rapyyyy_tm24}/${rapyyyymm_tm24}/${rappdy_tm24}

      # This is correct - the directory is back one day but the filename + contents correspond to
      # ACTUAL rappdy and rapcyc, NOT rappdy_tm24
   
      htar -xvf ${ARCH_rapcdate_tm24}/com_rap_prod_rap.${rappdy}${myrange}.bufr.tar ./rap.t${rapcyc}z.prepbufr.tm00
    fi

    #tag as restricted
    chmod 640 rap.t${rapcyc}z.prepbufr.tm00
    chgrp rstprod rap.t${rapcyc}z.prepbufr.tm00 

    if [ ! -s rap.t${rapcyc}z.prepbufr.tm00 ]; then
      echo "Unable to retrieve rap.t${rapcyc}z.prepbufr.tm00.  EXIT!"
      exit 1
    fi

    ####  Now grab the radiances as well if the CDATE >= July 01 2012 - otherwise
    # this is handled elsewhere in the script by grabbing the files from GSD's archive.
  
    if [ ${rappdy} -ge 20120701 ]; then
      echo "USE RUNHISTORY FOR ${tmmark} RADIANCES!"   
      data="esamua 1bhrs3 1bamub 1bamua 1bmhs 1bhrs4 radwnd goesfv airsev l2suob gpsro mtiasi satwnd nexrad lghtng lgycld atms cris sevcsr ssmisu" 
      for type in $data ; do
        outfile=rap.t${rapcyc}z.${type}.tm00.bufr_d
        if [ ! -s ${outfile} ]; then     
          htar -xvf ${myARCH}/com_rap_prod_rap.${rappdy}${myrange}.bufr.tar ./${outfile}  
        fi
  
        if [ ${myrange} = 12-17 -a ! -s ${outfile} ]; then

          # Originial implementation of RAP had botched archive step (Manikin, personal comm.)
          # So try again looking backward one day.

          rapcdate_tm24=`$NDATE -24 ${rappdy}${rapcyc}`
          rappdy_tm24=`echo $rapcdate_tm24 | cut -c 1-8`
          rapyyyy_tm24=`echo $rapcdate_tm24 | cut -c 1-4`
          rapyyyymm_tm24=`echo $rapcdate_tm24 | cut -c 1-6`
          ARCH_rapcdate_tm24=/NCEPPROD/hpssprod/runhistory/rh${rapyyyy_tm24}/${rapyyyymm_tm24}/${rappdy_tm24}

          # This is correct - the directory is back one day but the filename + contents correspond to
          # ACTUAL rappdy and rapcyc, NOT rappdy_tm24
   
          htar -xvf ${ARCH_rapcdate_tm24}/com_rap_prod_rap.${rappdy}${myrange}.bufr.tar ./${outfile}
        fi        
      done   
    fi

    ### Files for precip assimilation in CATCHUP

    # Use Stage II/IV files if running NDAS cycle with a domain other than the ops NAM
    #   12-km b-grid; in this situation, the nampcp files must be remapped from the 12-km NAM b-grid
    #   to the launcher domain
    # Use ndas.t${CYC}z.pcp.${tmmark}.hr*.${CDATE}.bin and nampcp files if running cycle w/ops NAM 12km b-grid 

    ihrs="1"
    for ihr in $ihrs ; do
      tinc=`expr -$delt + $ihr`
      time=`$NDATE $tinc $CDATE`
      ST2file[$ihr]=ST2ml${time}.Grb
      ST4file[$ihr]=ST4.${time}.01h
      namprecip[$ihr]=nampcp.${time}
      namprecip[$ihr]=nampcp.${time}

      if [ ! -s nam.t${CYC}z.${ST2file[$ihr]}.${tmmark}.gz ]; then
        htar -xvf ${ARCH}/com_nam_prod_ndas.${CDATE}.input.tar ./ndas.t${CYC}z.${ST2file[$ihr]}.${tmmark}.gz
        mv ndas.t${CYC}z.${ST2file[$ihr]}.${tmmark}.gz nam.t${CYC}z.${ST2file[$ihr]}.${tmmark}.gz
      fi
      if [ ! -s nam.t${CYC}z.${ST4file[$ihr]}.${tmmark}.gz ]; then
        htar -xvf ${ARCH}/com_nam_prod_ndas.${CDATE}.input.tar ./ndas.t${CYC}z.${ST4file[$ihr]}.${tmmark}.gz
        mv ndas.t${CYC}z.${ST4file[$ihr]}.${tmmark}.gz nam.t${CYC}z.${ST4file[$ihr]}.${tmmark}.gz
      fi

      #Archived nampcp files are only available every 3 hours, avoid unnecessary htars
 
      if [ $tmmark = tm06 -o $tmmark = tm03 ]; then
        if [ ! -s nam.t${CYC}z.${namprecip[$ihr]}.${tmmark} ]; then 
          if [ $PDY -ge 20111018 ]; then    
            htar -xvf ${ARCH}/com_nam_prod_ndas.${CDATE}.input.tar ./ndas.t${CYC}z.${namprecip[$ihr]}.${tmmark}
            if [ -s ndas.t${CYC}z.${namprecip[$ihr]}.${tmmark} ] ; then
              echo found file
              mv ndas.t${CYC}z.${namprecip[$ihr]}.${tmmark} nam.t${CYC}z.${namprecip[$ihr]}.${tmmark}
            else
              htar -xvf ${ARCHPLL}/ndasx.${CDATE}.input.tar ./ndas.t${CYC}z.${namprecip[$ihr]}.${tmmark}
              mv ndas.t${CYC}z.${namprecip[$ihr]}.${tmmark} nam.t${CYC}z.${namprecip[$ihr]}.${tmmark}
            fi
          fi

          if [ $PDY -ge 20110323 -a $PDY -le 20111017 ]; then
            htar -xvf ${ARCHPLL}/ndasx.${CDATE}.input.tar ./ndas.t${CYC}z.${namprecip[$ihr]}.${tmmark}
            if [ -s ndas.t${CYC}z.${namprecip[$ihr]}.${tmmark} ] ; then
              echo found file
              mv ndas.t${CYC}z.${namprecip[$ihr]}.${tmmark} nam.t${CYC}z.${namprecip[$ihr]}.${tmmark}
            fi
          fi
        fi
      fi


      ls -l nam.t${CYC}z.${ST2file[$ihr]}.${tmmark}.gz
      err1=$?
  
      if [ $err1 -ne 0 ] ; then
        daypcp=`echo $time | cut -c 1-8`
        PDYpcp=`echo $time | cut -c 1-8`
        YYYYpcp=`echo $time | cut -c 1-4`
        YYYYMMpcp=`echo $time | cut -c 1-6`
        ARCHpcp=/NCEPPROD/hpssprod/runhistory/rh${YYYYpcp}/${YYYYMMpcp}/${PDYpcp}
        htar -xvf $ARCHpcp/com_hourly_prod_nam_pcpn_anal.${PDYpcp}.tar ./ST2ml${time}.Grb.gz
        htar -xvf $ARCHpcp/com_hourly_prod_nam_pcpn_anal.${PDYpcp}.tar ./ST4.${time}.01h.gz
        mv ST2ml${time}.Grb.gz nam.t${CYC}z.${ST2file[$ihr]}.${tmmark}.gz
        mv ST4.${time}.01h.gz nam.t${CYC}z.${ST4file[$ihr]}.${tmmark}.gz
      fi

      #Archived nampcp files are only available every 3 hours, avoid unnecessary htars
 
      if [ $tmmark = tm06 -o $tmmark = tm03 ]; then
        ls -l nam.t${CYC}z.${namprecip[$ihr]}.${tmmark}
        err1=$?
        if [ $err1 -ne 0 ] ; then
          daypcp=`echo $time | cut -c 1-8`
          PDYpcp=`echo $time | cut -c 1-8`
          YYYYpcp=`echo $time | cut -c 1-4`
          YYYYMMpcp=`echo $time | cut -c 1-6`
          ARCHpcp=/NCEPPROD/hpssprod/runhistory/rh${YYYYpcp}/${YYYYMMpcp}/${PDYpcp}
          htar -xvf $ARCHpcp/com_hourly_prod_nam_pcpn_anal.${PDYpcp}.tar ./nampcp.${time}
          mv nampcp.${time} nam.t${CYC}z.${nampcp[$ihr]}.${tmmark}
        fi
      fi
    done #end loop over ihrs
  #end BIG tmmark loop
  done


  #Get the radar reflectivity files for cloud analysis (only tm01-tm06 here, get tm00 a little later since all steps need that one)
  htar -xvf ${ARCHM1}/com_hourly_prod_radar.${PDY_tm01}.save.tar ./refd3d.t${CYC_tm01}z.grb2f00
  htar -xvf ${ARCHM2}/com_hourly_prod_radar.${PDY_tm02}.save.tar ./refd3d.t${CYC_tm02}z.grb2f00
  htar -xvf ${ARCHM3}/com_hourly_prod_radar.${PDY_tm03}.save.tar ./refd3d.t${CYC_tm03}z.grb2f00
  htar -xvf ${ARCHM4}/com_hourly_prod_radar.${PDY_tm04}.save.tar ./refd3d.t${CYC_tm04}z.grb2f00
  htar -xvf ${ARCHM5}/com_hourly_prod_radar.${PDY_tm05}.save.tar ./refd3d.t${CYC_tm05}z.grb2f00
  htar -xvf ${ARCHM6}/com_hourly_prod_radar.${PDY_tm06}.save.tar ./refd3d.t${CYC_tm06}z.grb2f00



  #Separate tmmark loop to get the the GDAS EnKF members - which may not always be available
  #  There's logic in the GSI scripts to account for this - so no worry if missing!
  #  Also, as far as I know, only the fhr=06 member has been archived.
  time="tm06 tm05 tm04 tm03 tm02 tm01 tm00"
  for tmmark in $time ; do
    offset=-`echo $tmmark | cut -c 3-4`
    adate=`$NDATE $offset $CDATE`

    # LINK UP WITH GDAS EnKF for CATCHUP IF FILES ARE AVAILABLE
    # Forecast files must be >= fhr3

    case $tmmark in
      tm00) dateadj=06;; 
      tm01) dateadj=05;;
      tm02) dateadj=04;;               
      tm03) dateadj=09;;
      tm04) dateadj=08;;                     
      tm05) dateadj=07;;               
      tm06) dateadj=06;;
    esac

    typeset -Z2 dateadj
    gdate=`$NDATE -${dateadj} $adate`
    pdyg=`echo $gdate | cut -c1-8`
    yyyyg=`echo $gdate | cut -c1-4`
    yyyymmg=`echo $gdate | cut -c1-6`
    cycg=`echo $gdate | cut -c9-10`
    n=0
    typeset -Z3 n
    while [ $n -le 80 ]; do   
      if [ ! -s sfg_${gdate}_fhr${dateadj}s_mem${n} ]; then               
        htar -xvf /NCEPPROD/hpssprod/runhistory/rh${yyyyg}/${yyyymmg}/${pdyg}/com_gfs_prod_enkf.${pdyg}_${cycg}.fcs.tar ./sfg_${gdate}_fhr${dateadj}s_mem${n}
      fi
      (( n = n + 1 ))     
    done

    #Get the ens mean
    if [ ! -s sfg_${gdate}_fhr${dateadj}_ensmean ]; then
      htar -xvf /NCEPPROD/hpssprod/runhistory/rh${yyyyg}/${yyyymmg}/${pdyg}/com_gfs_prod_enkf.${pdyg}_${cycg}.fcs.tar ./sfg_${gdate}_fhr${dateadj}_ensmean
    fi
    
  #end the GDAS EnKF tmmark loop for CATCHUP
  done

########################################
else  #END check on RUNTYPE = CATCHUP  #
########################################

  ########################################
  #          RUNTYPE=HOURLY              #
  ########################################

  #Link up with the GDAS ENKF members for RUNTYPE=HOURLY IF THEY ARE AVAILABLE!
  
  cya=$CYC
  adate=$CDATE
  if [ $cya -eq 00 -o $cya -eq 18 -o $cya -eq 12 -o $cya -eq 06 ]; then
    dateadj=06
  elif [ $cya -eq 01 -o $cya -eq 19 -o $cya -eq 13 -o $cya -eq 07 ]; then
    dateadj=07 
  elif [ $cya -eq 02 -o $cya -eq 20 -o $cya -eq 14 -o $cya -eq 08 ]; then
    dateadj=08
  elif [ $cya -eq 03 -o $cya -eq 21 -o $cya -eq 15 -o $cya -eq 09 ]; then
    dateadj=09
  elif [ $cya -eq 04 -o $cya -eq 22 -o $cya -eq 16 -o $cya -eq 10 ]; then  
    dateadj=04
  elif [ $cya -eq 05 -o $cya -eq 23 -o $cya -eq 17 -o $cya -eq 11 ]; then
    dateadj=05
  fi  
  typeset -Z2 dateadj
  # Now link up with the GDAS EnkF members
  gdate=`$NDATE -${dateadj} $adate`
  pdyg=`echo $gdate | cut -c1-8`
  yyyyg=`echo $gdate | cut -c1-4`
  yyyymmg=`echo $gdate | cut -c1-6`
  cycg=`echo $gdate | cut -c9-10`
  n=0
  typeset -Z3 n
  while [ $n -le 80 ]; do
    if [ ! -s sfg_${gdate}_fhr${dateadj}s_mem${n} ]; then
      htar -xvf /NCEPPROD/hpssprod/runhistory/rh${yyyyg}/${yyyymmg}/${pdyg}/com_gfs_prod_enkf.${pdyg}_${cycg}.fcs.tar ./sfg_${gdate}_fhr${dateadj}s_mem${n}
    fi
    (( n = n + 1 ))     
  done

    #Get the ens mean
    if [ ! -s sfg_${gdate}_fh${dateadj}_ensmean ]; then
      htar -xvf /NCEPPROD/hpssprod/runhistory/rh${yyyyg}/${yyyymmg}/${pdyg}/com_gfs_prod_enkf.${pdyg}_${cycg}.fcs.tar ./sfg_${gdate}_fh${dateadj}_ensmean 
    fi

###############################      
fi # End check on RUNTYPES    #
###############################



##########################################################
#    Get the non-conventional obs from GSD's RAP ARCHIVE #
#    IF THE DATE IS OLDER THAN 20120701                  #
##########################################################

#These obs are stored on a different archive on HPSS and are different to access
#  To accomplish this task I have adopted a script kindly provided by Joe Olson.

if [ $RUNTYPE = CATCHUP ]; then
  marks="tm00 tm01 tm02 tm03 tm04 tm05 tm06"
elif [ $RUNTYPE = HOURLY ]; then
  marks="tm00"
else
  echo "INVALID RUNTYPE:${RUNTYPE}  EXIT!"
  exit 1
fi

#Temporary location to store RAP files
export DEST=${INPUT}/tmpdest
for tmmark in ${marks}; do
  #Make DEST
  mkdir -p ${DEST}
  cd ${DEST}
  myoffset=`echo $tmmark | cut -c 3-4`

  tmpcdate=`$NDATE -${myoffset} ${PDY}${CYC}`
  tmppdy=`echo $tmpcdate | cut -c 1-8`
  tmpcyc=`echo $tmpcdate | cut -c 9-10`
  tmpyyyy=`echo $tmpcdate | cut -c 1-4`
  tmpmm=`echo $tmpcdate | cut -c 5-6`
  tmpday=`echo $tmpcdate | cut -c 7-8`

  if [ ${tmppdy} -lt 20120701 ]; then
    echo "USE GSD ARCHIVE FOR ${tmmark} RADIANCES!"
    #Set cycle to use to grab archive radiance and radwnd file (radwnd file is in the radiance directory)
    if [ $tmpcyc -lt 12 ]; then
      grabcyc_r=00
    elif [ $tmpcyc -ge 12 ]; then
      grabcyc_r=12
    else
      echo "INVALID tmpcyc: ${tmpcyc}    EXIT!"
      exit 1
    fi

    # Set RAP/RUC archive directories
   
    #Base directory
    export BASE_DIR=/BMC/fdr/${tmpyyyy}/${tmpmm}/${tmpday}
   
    #Data directories
    if [ $tmpcdate -lt 2013060500 ]; then
      export RADIANCE_DIR=${BASE_DIR}/data/grids/rr/radiance
      export RADWIND_DIR=${BASE_DIR}/data/grids/ruc/ncep_radwnd
      export NEXRAD_DIR=${BASE_DIR}/data/grids/ruc/ncep_nexrad
    else
      export RADIANCE_DIR=${BASE_DIR}/data/grids/rap/radiance
      export RADWIND_DIR=${BASE_DIR}/data/grids/rap/radwnd
      export NEXRAD_DIR=${BASE_DIR}/data/grids/rap/nexrad
    fi

    echo "Copying over RAP ARCHIVE RADIANCE AND LEVEL 2.5 RADWND files for "$tmpmm"/"$tmpday"/"$tmpyyyy

    hsi get "${RADIANCE_DIR}/*${tmppdy}${grabcyc_r}00*"
    for f in `ls *${tmppdy}${grabcyc_r}00*` ; do    
      #Try to get file again if file is empty
      if [[ ! -s $f ]] then
        rm -f ${f}
        hsi get ${RADIANCE_DIR}/${f}
        if [[ ! -s $f ]] then
          rm -f ${f}
          echo "WARNING: ${RADIANCE_DIR}/${f} appears corrupted and has been skipped"
        fi
      fi
      if [ -s ${f} ]; then
        tar -zxvf ${f}  
      fi               
    done

    #Set cycle to use to grab archive nexrad level 2 radial wind file (level 2.5 radwnd file is in the radiance directory)
    case $tmpcyc in
      00)grabcyc=00;;
      01)grabcyc=00;;
      02)grabcyc=00;;
      03)grabcyc=03;;
      04)grabcyc=03;;
      05)grabcyc=03;;
      06)grabcyc=06;;
      07)grabcyc=06;;
      08)grabcyc=06;;
      09)grabcyc=09;;
      10)grabcyc=09;;
      11)grabcyc=09;;
      12)grabcyc=12;;
      13)grabcyc=12;;
      14)grabcyc=12;;
      15)grabcyc=15;;
      16)grabcyc=15;;
      17)grabcyc=15;;
      18)grabcyc=18;;
      19)grabcyc=18;;
      20)grabcyc=18;;
      21)grabcyc=21;;
      22)grabcyc=21;;
      23)grabcyc=21;;
    esac   

    echo "Copying over RAP ARCHIVE LEVEL 2 RADIAL WIND files for "$tmpmm"/"$tmpday"/"$tmpyyyy

    hsi get "${NEXRAD_DIR}/*${tmppdy}${grabcyc}00*"
    for f in `ls *${tmppdy}${grabcyc}00*`; do
      #Try to get file again if file is empty
      if [[ ! -s $f ]] then
        rm -f ${f}
        hsi get ${NEXRAD_DIR}/${f}
        if [[ ! -s $f ]] then
          rm -f ${f}
          echo "WARNING: ${NEXRAD_DIR}/${f} appears corrupted and has been skipped"
        fi
      fi
      if [ -s ${f} ]; then
        tar -zxvf ${f}  
      fi     
    done  
  
    #Find the day-of-the-year by subtracting the Julian date of Jan. 1 from the
    # Julian date of the analysis cycle and then adding 1
    j1=`$datecalc -a $tmpyyyy $tmpmm $tmpday - $tmpyyyy 01 01`
    (( doy = j1 + 1 ))

    # Rename appropriately
    data="esamua 1bhrs3 1bamub 1bamua 1bmhs 1bhrs4 radwnd goesfv airsev l2suob gpsro mtiasi satwnd nexrad lghtng lgycld atms cris sevcsr ssmisu" 
    for type in $data ; do 
      outfile=rap.t${tmpcyc}z.${type}.tm00.bufr_d  
      if [ $CDATE -ge 2012050112 ]; then  #RAP implementation date so file names changed       
        if [ $type = nexrad ]; then
          cpfile=${tmpyyyy}${doy}${tmpcyc}00.${tmppdy}_rap.t${tmpcyc}z.tm00.bufr_d  #archive does not have the "nexrad" label with it
        else
          cpfile=${tmpyyyy}${doy}${tmpcyc}00.rap.t${tmpcyc}z.${type}.tm00.bufr_d.${tmppdy}	 
        fi      
      else       
        if [ $type = nexrad ]; then
          cpfile=${tmpyyyy}${doy}${tmpcyc}00.${tmppdy}_ruc2a.t${tmpcyc}z.tm00.bufr_d  #archive does not have the "nexrad" label with it
        else
          cpfile=${tmpyyyy}${doy}${tmpcyc}00.ruc2a.t${tmpcyc}z.${type}.tm00.bufr_d.${tmppdy}
        fi
      fi
          
      if [ -s ${DEST}/${cpfile} ]; then      
        mv  ${DEST}/${cpfile} ${INPUT}/${outfile}
      else
        echo "Unable to locate RAP file: ${cpfile}"              
      fi
    done
   
    #clean up temp directory
    rm -rf ${DEST}
   
  fi #If check on date for using GSD's RAP archive for obs   
done

cd ${INPUT}

################################################################
# DONE Getting the non-convetional obs from GSD's RAP ARCHIVE  #
# FOR DATES OLDER THAN 20120701                                #
################################################################

# Get the tm00 prepbufr

tmmark=tm00
if [ ${CYC} -ge 0 -a ${CYC} -le 5 ]; then
  myrange=00-05
elif [ ${CYC} -ge 6 -a ${CYC} -le 11 ]; then
  myrange=06-11
elif [ ${CYC} -ge 12 -a ${CYC} -le 17 ]; then
  myrange=12-17
elif [ ${CYC} -ge 18 -a ${CYC} -le 23 ]; then
  myrange=18-23
else
  echo "WHOA!  Bad CYC=${CYC}!  UNABLE TO OBTAIN RAP PREPBFUR DATA. EXIT!"
  exit 1  
fi

if [ ! -s rap.t${CYC}z.prepbufr.tm00 ]; then
  htar -xvf ${ARCH}/com_rap_prod_rap.${PDY}${myrange}.bufr.tar ./rap.t${CYC}z.prepbufr.tm00
fi

if [ ${myrange} = 12-17 -a ! -s rap.t${CYC}z.prepbufr.tm00 ]; then
  # Originial implementation of RAP had botched archive step (Manikin, personal comm.)
  # So try again looking backward one day.
  # This is correct - the directory is back one day but the filename + contents correspond to
  # ACTUAL rappdy and rapcyc, NOT rappdy_tm24   
  htar -xvf ${ARCHM24}/com_rap_prod_rap.${PDY}${myrange}.bufr.tar ./rap.t${CYC}z.prepbufr.tm00
fi

#tag as restricted
chmod 640 rap.t${rapcyc}z.prepbufr.tm00
chgrp rstprod rap.t${rapcyc}z.prepbufr.tm00

if [ ! -s rap.t${CYC}z.prepbufr.tm00 ]; then
  echo "Unable to retrieve rap.t${CYC}z.prepbufr.tm00.  EXIT!"
  exit 1
fi

  ####  Now grab the radiances as well if the CDATE >= July 01 2012 - otherwise
  # this is handled elsewhere (just above) in the script by grabbing the files from GSD's archive.
  
  if [ ${PDY} -ge 20120701 ]; then
   echo "USE RUNHISTORY FOR tm00 RADIANCES!"
   data="esamua 1bhrs3 1bamub 1bamua 1bmhs 1bhrs4 radwnd goesfv airsev l2suob gpsro mtiasi satwnd nexrad lghtng lgycld atms cris sevcsr ssmisu" 
   for type in $data
   do
     outfile=rap.t${CYC}z.${type}.tm00.bufr_d
     if [ ! -s $outfile ]; then 
       htar -xvf ${ARCH}/com_rap_prod_rap.${PDY}${myrange}.bufr.tar ./${outfile}  
     fi
 
     if [ ${myrange} = 12-17 -a ! -s ${outfile} ]; then

       # Originial implementation of RAP had botched archive step (Manikin, personal comm.)
       # So try again looking backward one day.

       # This is correct - the directory is back one day but the filename + contents correspond to
       # ACTUAL rappdy and rapcyc, NOT rappdy_tm24
   
       htar -xvf ${ARCHM24}/com_rap_prod_rap.${PDY}${myrange}.bufr.tar  ./${outfile}

     fi        
   done   
  fi

#Get the tm00 radar reflectivity files for cloud analysis
if [ ! -s refd3d.t${CYC}z.grb2f00 ]; then
  htar -xvf ${ARCH}/com_hourly_prod_radar.${PDY}.save.tar ./refd3d.t${CYC}z.grb2f00
fi


exit 0
