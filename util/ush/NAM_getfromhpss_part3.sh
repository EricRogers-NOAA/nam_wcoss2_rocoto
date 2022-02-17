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



# GDAS/GFS files for mkbnd  - NOTE THAT THERE ARE DIFFERENCES IN WHAT IS NEEDED
#   FOR CATCHUP VS. HOURLY

if [ $RUNTYPE = CATCHUP ]; then

  #The files below are renamed and interpolated for the hourly analysis
  #  in the exnam_prelim.sh.sms script
  if [ ! -s gfsbc0.tm06 -a ! -s gfsbc1.tm06 -a ! -s gfsbc0.tm03 -a ! -s gfsbc1.tm03 ]; then
    htar -xvf ${ARCHM6}/com_gfs_prod_gdas.${TM06}.tar ./gdas1.t${CYC_tm06}z.sanl 
    htar -xvf ${ARCHM6}/com_gfs_prod_gdas.${TM06}.tar ./gdas1.t${CYC_tm06}z.sf03 
    htar -xvf ${ARCHM6}/com_gfs_prod_gdas.${TM06}.tar ./gdas1.t${CYC_tm06}z.sf06 

    cp gdas1.t${CYC_tm06}z.sanl gfsbc0.tm06
    cp gdas1.t${CYC_tm06}z.sf03 gfsbc1.tm06
    
    cp gdas1.t${CYC_tm06}z.sf03 gfsbc0.tm03
    cp gdas1.t${CYC_tm06}z.sf06 gfsbc1.tm03
  fi

  # Set up the files for ozone
  cp gfsbc0.tm06 global_ozone.tm06
  cp gfsbc0.tm03 global_ozone.tm03
  cp gfsbc1.tm03 global_ozone.tm00
  
  #Make global_ozone.tm05
  ${UTIL_EXECnam}/global_sigavg -w 0.67,0.33 global_ozone.tm06 global_ozone.tm03 global_ozone.tm05 
  #Make global_ozone.tm04
  ${UTIL_EXECnam}/global_sigavg -w 0.33,0.67 global_ozone.tm06 global_ozone.tm03 global_ozone.tm04
  #Make global_ozone.tm02
  ${UTIL_EXECnam}/global_sigavg -w 0.67,0.33 global_ozone.tm03 global_ozone.tm00 global_ozone.tm02
  #Make global_ozone.tm01
  ${UTIL_EXECnam}/global_sigavg -w 0.33,0.67 global_ozone.tm03 global_ozone.tm00 global_ozone.tm01
 
  rm gdas1*.sf* gdas1*.sanl

  #Now get the files for the tm00 part of the part forecast with the CATCHUP cycle

  gfshour=06
  bccount=0

  while [ $bccount -le 29 ] ; do 
    if [ ! -s gfsbc${bccount}.tm00 ]; then
      htar -xvf ${ARCHM6_GFS}/com_gfs_prod_gfs.${TM06}.sigma.tar ./gfs.t${CYC_tm06}z.sf${gfshour}
      mv gfs.t${CYC_tm06}z.sf${gfshour} gfsbc${bccount}.tm00
    fi
    let "gfshour=gfshour+3"
    typeset -Z2 gfshour
    let "bccount=bccount+1"
  done

elif [ $RUNTYPE = HOURLY ]; then

  y=`expr $CYC % 3`

  #The various htar expressions grab what they can - anything that is missing
  #  is filled in via linear interpolation by nam_getbestglobal.sh_new

  #Note this step gets as close as 2 hours to the nearest GFS cycle - similar to what was done
  #  in the real-time scripts that grabbed the gfsbc files.

  bccount=0
  case $y in
    
    0) ############ y=0 : cycles 00z,03z,06z,09z,12z,15z,18z,21z
      
      #Find the nearest GFS cycle
      y6=`expr $CYC % 6`
      
      if [ $y6 -eq 0 ]; then
        ARCHM_TMP=${ARCHM6_GFS}
	TM_tmp=$TM06
	CYC_tmp=${CYC_tm06}
	gfshour=06
      else
	tmpcdate=`$NDATE -03 ${CDATE}`
	TM_tmp=$tmpcdate
      	PDY_tmp=`echo $tmpcdate | cut -c 1-8`
	YYYYMM_tmp=`echo $tmpcdate | cut -c 1-6`
	YYYY_tmp=`echo $tmpcdate | cut -c 1-4`
	CYC_tmp=`echo $tmpcdate | cut -c 9-10`
        ARCHM_TMP=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tmp}/${YYYYMM_tmp}/${PDY_tmp}
	gfshour=03
      fi
            
      #Begin extracting
 
      bccount=0
      while [ $bccount -le 19 ] ; do
        if [ ! -s gfsbc${bccount}.tm00_ops ]; then
          htar -xvf ${ARCHM_TMP}/com_gfs_prod_gfs.${TM_tmp}.sigma.tar ./gfs.t${CYC_tmp}z.sf${gfshour}
          mv gfs.t${CYC_tmp}z.sf${gfshour} gfsbc${bccount}.tm00_ops
        fi
        let "gfshour=gfshour+1"
        typeset -Z2 gfshour
        let "bccount=bccount+1"
 	 
        #Note that any "missing" sigma files are filled in later through linear interpolation
	#  by the NAMRR itself.  No worries!
	 
      done
      
      #Grab extra end gfs bc file to use for linear interpolation for the last hour
      #  bc file in the case that there is no final gfs forecast available
      (( gfshour = gfshour + 1 ))  #effectively adds 2 to gfshour after the loop above (the loop ends after having already added 1)
      (( bccount = bccount + 1 ))  #do the same for the bccount
 
      if [ ! -s gfsbc${bccount}.tm00_ops ]; then      
        htar -xvf ${ARCHM_TMP}/com_gfs_prod_gfs.${TM_tmp}.sigma.tar ./gfs.t${CYC_tmp}z.sf${gfshour}
        mv gfs.t${CYC_tmp}z.sf${gfshour} gfsbc${bccount}.tm00_ops
      fi
 
      # Handle the Ozone
      cp gfsbc0.tm00_ops global_ozone.tm00           
    ;;

    1) ############ y=1 : cycles 01z,04z,07z,10z,13z,16z,19z,22z
      
      
      #Find the nearest GFS cycle								    	
      
      (( y7m1 = CYC - 1 ))
      
      y6=`expr $y7m1 % 6`									    	 
      
      if [ $y6 -eq 0 ]; then
	tmpcdate=`$NDATE -07 ${CDATE}`
	TM_tmp=$tmpcdate
      	PDY_tmp=`echo $tmpcdate | cut -c 1-8`
	YYYYMM_tmp=`echo $tmpcdate | cut -c 1-6`
	YYYY_tmp=`echo $tmpcdate | cut -c 1-4`
	CYC_tmp=`echo $tmpcdate | cut -c 9-10`	
        ARCHM_TMP=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tmp}/${YYYYMM_tmp}/${PDY_tmp}			
	gfshour=07
      else
	tmpcdate=`$NDATE -04 ${CDATE}`
	TM_tmp=$tmpcdate
      	PDY_tmp=`echo $tmpcdate | cut -c 1-8`
	YYYYMM_tmp=`echo $tmpcdate | cut -c 1-6`
	YYYY_tmp=`echo $tmpcdate | cut -c 1-4`
	CYC_tmp=`echo $tmpcdate | cut -c 9-10`
        ARCHM_TMP=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tmp}/${YYYYMM_tmp}/${PDY_tmp}
	gfshour=04
      fi
      
      
      #Begin extracting
         
      #Grab known, good possible first bc file to use for linear interpolation to the first hour
      #  bc file in the case that there is no 04hr or 07hr gfs forecast available
      bccount=0
      (( gfshourm1 = gfshour - 1 ))
      typeset -Z2 gfshourm1	 
      if [ ! -s gfsbc${bccount}.tm00_backup_ops ]; then
        htar -xvf ${ARCHM_TMP}/com_gfs_prod_gfs.${TM_tmp}.sigma.tar ./gfs.t${CYC_tmp}z.sf${gfshourm1} 
        mv gfs.t${CYC_tmp}z.sf${gfshourm1} gfsbc${bccount}.tm00_backup_ops
      fi

      #Now reset bccount
      bccount=0
      while [ $bccount -le 20 ] ; do
        if [ ! -s gfsbc${bccount}.tm00_ops ]; then
          htar -xvf ${ARCHM_TMP}/com_gfs_prod_gfs.${TM_tmp}.sigma.tar ./gfs.t${CYC_tmp}z.sf${gfshour} 
          mv gfs.t${CYC_tmp}z.sf${gfshour} gfsbc${bccount}.tm00_ops
        fi
        let "gfshour=gfshour+1"
        typeset -Z2 gfshour
        let "bccount=bccount+1"
	 
	#Note that any "missing" sigma files are filled in later through linear interpolation
        #  by the NAMRR itself.  No worries!
	 
      done 
	
     ##### Handle the Ozone for GSI ########
      if [ -s gfsbc0.tm00_ops ] ; then
        cp gfsbc0.tm00_ops global_ozone.tm00	  	     
      else
	if [ -s gfsbc1.tm00_ops ] ; then	  
          ${UTIL_EXECnam}/global_sigavg -w 0.50,0.50 gfsbc0.tm00_backup_ops gfsbc1.tm00_ops global_ozone.tm00	    
	else
	  ${UTIL_EXECnam}/global_sigavg -w 0.67,0.33 gfsbc0.tm00_backup_ops gfsbc2.tm00_ops global_ozone.tm00
	fi
      fi	
    ;;

    2) ############ y=2 : cycles 02z,05z,08z,11z,14z,17z,20z,23z

      
      #Find the nearest GFS cycle								    	
      
      (( y6m2 = CYC - 2 ))
      
      y6=`expr $y6m2 % 6`									    	 
      
      if [ $y6 -eq 0 ]; then
	tmpcdate=`$NDATE -02 ${CDATE}`
	TM_tmp=$tmpcdate
      	PDY_tmp=`echo $tmpcdate | cut -c 1-8`
	YYYYMM_tmp=`echo $tmpcdate | cut -c 1-6`
	YYYY_tmp=`echo $tmpcdate | cut -c 1-4`
	CYC_tmp=`echo $tmpcdate | cut -c 9-10`	
        ARCHM_TMP=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tmp}/${YYYYMM_tmp}/${PDY_tmp}
	gfshour=02
      else
	tmpcdate=`$NDATE -05 ${CDATE}`
	TM_tmp=$tmpcdate
      	PDY_tmp=`echo $tmpcdate | cut -c 1-8`
	YYYYMM_tmp=`echo $tmpcdate | cut -c 1-6`
	YYYY_tmp=`echo $tmpcdate | cut -c 1-4`
	CYC_tmp=`echo $tmpcdate | cut -c 9-10`
        ARCHM_TMP=/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY_tmp}/${YYYYMM_tmp}/${PDY_tmp}
	gfshour=05
      fi
      
      
      #Begin extracting
         
      #Grab known, good possible first bc file to use for linear interpolation to the first hour
      #  bc file in the case that there is no 02hr or 05hr gfs forecast available
      bccount=0
      (( gfshourm2 = gfshour - 2 ))
      typeset -Z2 gfshourm2	 
      if [ ! -s gfsbc${bccount}.tm00_backup_ops ]; then
        htar -xvf ${ARCHM_TMP}/com_gfs_prod_gfs.${TM_tmp}.sigma.tar ./gfs.t${CYC_tmp}z.sf${gfshourm2} 
        mv gfs.t${CYC_tmp}z.sf${gfshourm2} gfsbc${bccount}.tm00_backup_ops
      fi

      #Now reset bccount
      bccount=0
      while [ $bccount -le 19 ] ; do
        if [ ! -s gfsbc${bccount}.tm00_ops ]; then
          htar -xvf ${ARCHM_TMP}/com_gfs_prod_gfs.${TM_tmp}.sigma.tar ./gfs.t${CYC_tmp}z.sf${gfshour} 
          mv gfs.t${CYC_tmp}z.sf${gfshour} gfsbc${bccount}.tm00_ops
        fi
        let "gfshour=gfshour+1"
        typeset -Z2 gfshour
        let "bccount=bccount+1"
	 
	#Note that any "missing" sigma files are filled in later through linear interpolation
	#  by the NAMRR itself.  No worries!
	 
      done 


      ##### Handle the Ozone for GSI ########     
      if [ -s gfsbc0.tm00_ops ] ; then       
        cp gfsbc0.tm00_ops global_ozone.tm00
      else
        ${UTIL_EXECnam}/global_sigavg -w 0.33,0.67 gfsbc0.tm00_backup_ops gfsbc1.tm00_ops global_ozone.tm00
      fi
    ;;
  esac

else
  echo "INVALID RUNTYPE: $RUNTYPE     EXIT!"
  exit 1
fi


# Get files only needed for the 1st hrly NDAS - ONLY VALID FOR CATCHUP CYCLE

if [ $TYPE = first -a $RUNTYPE = CATCHUP ] ; then

  if [ $PDY -ge 20111018 ]; then
    hsi "cd $ARCHM6 ; get nam.t${CYC_tm06}z.nmm_b_restart_nemsio_anl.tm00"
    mv nam.t${CYC_tm06}z.nmm_b_restart_nemsio_anl.tm00 nmm_b_restart_nemsio_hold.${CYC_tm06}z
    # add restart file to hold directory for cycling land states at first step
    cp nmm_b_restart_nemsio_hold.${CYC_tm06}z $HOLDscr/nmm_b_restart_nemsio_hold.${CYC_tm06}z
  fi

  if [ $PDY -ge 20110323 -a $PDY -le 20111017 ]; then
    hsi "cd $ARCHPLL ; get namx.t${CYC_tm06}z.nmm_b_restart_nemsio_anl.tm00"
    mv namx.t${CYC_tm06}z.nmm_b_restart_nemsio_anl.tm00 nmm_b_restart_nemsio_hold.${CYC_tm06}z
    # add restart file to hold directory for cycling land states at first step
    cp nmm_b_restart_nemsio_hold.${CYC_tm06}z $HOLDscr/nmm_b_restart_nemsio_hold.${CYC_tm06}z
  fi


  # New GSI can use ops bias corrections!!

  #These bias correction files are output from the TM06 NDAS at tm03.  So they *should* be valid
  #   for the NAMRR tm06 analysis time  (before this used TM06 at tm09 - since the ndas window shrunk
  #   from 12 to 6 hours then we just subtract 6 hour from the outermost tm-time.  So tm09-6=tm03.

  if [ $PDY -le 20131106 ] ; then
    # Date when new bias correction algorithm was implemented in NAMX
    htar -xvf /NCEPDEV/hpsspara/runhistory/1year/mmbpll/rh2013/201311/20131106/ndasx.2013110600.input.tar ./ndas.t00z.satbiasc.tm03
    htar -xvf /NCEPDEV/hpsspara/runhistory/1year/mmbpll/rh2013/201311/20131106/ndasx.2013110600.input.tar ./ndas.t00z.satbiaspc.tm03
    htar -xvf /NCEPDEV/hpsspara/runhistory/1year/mmbpll/rh2013/201311/20131106/ndasx.2013110600.bufr.tar ./ndas.t00z.radstat.tm03
    mv ndas.t00z.satbiaspc.tm03  nam.t${CYC_tm06}z.satbias_pc.tm03
    mv ndas.t00z.satbiasc.tm03 nam.t${CYC_tm06}z.satbias.tm03	
    mv ndas.t00z.radstat.tm03   nam.t${CYC_tm06}z.radstat.tm03	
  elif [ $CDATE -ge 2014081212 ]; then
    # Date when new bias correction algorithm was implemented in Ops NAM
    htar -xvf ${ARCHM6}/com_nam_prod_ndas.${TM06}.input.tar ./ndas.t${CYC_tm06}z.satbiasc.tm03
    htar -xvf ${ARCHM6}/com_nam_prod_ndas.${TM06}.input.tar ./ndas.t${CYC_tm06}z.satbiaspc.tm03
    htar -xvf ${ARCHM6}/com_nam_prod_ndas.${TM06}.bufr.tar ./ndas.t${CYC_tm06}z.radstat.tm03
    mv ndas.t${CYC_tm06}z.satbiaspc.tm03 nam.t${CYC_tm06}z.satbias_pc.tm03
    mv ndas.t${CYC_tm06}z.satbiasc.tm03  nam.t${CYC_tm06}z.satbias.tm03   
    mv ndas.t${CYC_tm06}z.radstat.tm03   nam.t${CYC_tm06}z.radstat.tm03
  else
    htar -xvf ${ARCHPLLM6}/ndasx.${TM06}.input.tar ./ndas.t${CYC_tm06}z.satbiasc.tm03
    htar -xvf ${ARCHPLLM6}/ndasx.${TM06}.input.tar ./ndas.t${CYC_tm06}z.satbiaspc.tm03
    htar -xvf ${ARCHPLLM6}/ndasx.${TM06}.bufr.tar ./ndas.t${CYC_tm06}z.radstat.tm03
    mv ndas.t${CYC_tm06}z.satbiaspc.tm03 nam.t${CYC_tm06}z.satbias_pc.tm03
    mv ndas.t${CYC_tm06}z.satbiasc.tm03  nam.t${CYC_tm06}z.satbias.tm03   
    mv ndas.t${CYC_tm06}z.radstat.tm03   nam.t${CYC_tm06}z.radstat.tm03
  fi

  #   Strongly suggest only updating biascr in parent so make the appropriate file in the 
  #   COMOUT directory so that both the parent and nest pick up the same file - this way
  #   the parent will NOT grab an already updated file from $HOLD
  # To get to this point in the retrieval script the RUNTYPE must be CATCHUP

  NET=nam
  RUN=nam
  
  case $CYC in
    00) f1=${COM_IN}/${RUN}.${PDY_tm06}/nam.t18z.satbias.tm01
        f2=${COM_IN}/${RUN}.${PDY_tm06}/nam.t18z.satbias_pc.tm01
        f3=${COM_IN}/${RUN}.${PDY_tm06}/nam.t18z.radstat.tm01;;

    06) f1=${COM_IN}/${RUN}.${PDY_tm06}/nam.t00z.satbias.tm01
        f2=${COM_IN}/${RUN}.${PDY_tm06}/nam.t00z.satbias_pc.tm01
        f3=${COM_IN}/${RUN}.${PDY_tm06}/nam.t00z.radstat.tm01;;

    12) f1=${COM_IN}/${RUN}.${PDY_tm06}/nam.t06z.satbias.tm01
        f2=${COM_IN}/${RUN}.${PDY_tm06}/nam.t06z.satbias_pc.tm01
        f3=${COM_IN}/${RUN}.${PDY_tm06}/nam.t06z.radstat.tm01;; 

    18) f1=${COM_IN}/${RUN}.${PDY_tm06}/nam.t12z.satbias.tm01
        f2=${COM_IN}/${RUN}.${PDY_tm06}/nam.t12z.satbias_pc.tm01
        f3=${COM_IN}/${RUN}.${PDY_tm06}/nam.t12z.radstat.tm01;;
  esac

  mkdir -p ${COM_IN}/${RUN}.${PDY_tm06} 
  cp nam.t${CYC_tm06}z.satbias.tm03 $f1
  cp nam.t${CYC_tm06}z.satbias_pc.tm03 $f2
  cp nam.t${CYC_tm06}z.radstat.tm03 $f3


  # get ops pcpbudget file; it will be remapped to expanded domain (if needed) in special version of
  # pcpbudget script 

  # Leave budget history stuff un-changed for NAMRR? Yes - want the most recent budget update, which is
  #  ALWAYS done at 12z

  if [ $PDY -ge 20111018 ] ; then
    if [ $CYC -eq 00 ] ; then
      htar -xvf ${ARCHM12}/com_nam_prod_ndas.${CDATE_tm12}.input.tar ./ndas.t${CYC_tm12}z.pcpbudget_history
      mv ndas.t${CYC_tm12}z.pcpbudget_history pcpbudget_history
      if [ -s pcpbudget_history ] ; then
        echo found file
      else
        htar -xvf ${ARCHPLLM12}/ndasx.${TM12}.input.tar ./ndas.t${CYC_tm12}z.pcpbudget_history
        mv ndas.t${CYC_tm12}z.pcpbudget_history pcpbudget_history
      fi
    fi

    if [ $CYC -eq 06 ] ; then
      htar -xvf ${ARCHM18}/com_nam_prod_ndas.${CDATE_tm18}.input.tar ./ndas.t${CYC_tm18}z.pcpbudget_history
      mv ndas.t${CYC_tm18}z.pcpbudget_history pcpbudget_history
      if [ -s pcpbudget_history ] ; then
        echo found file
      else
        htar -xvf ${ARCHPLLM18}/ndasx.${TM18}.input.tar ./ndas.t${CYC_tm18}z.pcpbudget_history
        mv ndas.t${CYC_tm18}z.pcpbudget_history pcpbudget_history
      fi
    fi
 
    if [ $CYC -eq 12 ] ; then
      htar -xvf ${ARCH}/com_nam_prod_ndas.${CDATE}.input.tar ./ndas.t${CYC}z.pcpbudget_history
      mv ndas.t${CYC}z.pcpbudget_history pcpbudget_history
      if [ -s pcpbudget_history ] ; then
        echo found file
      else
        htar -xvf ${ARCHPLL}/ndasx.${CYC}z.input.tar ./ndas.t${CYC}z.pcpbudget_history
        mv ndas.t${CYC}z.pcpbudget_history pcpbudget_history
      fi
    fi
    if [ $CYC -eq 18 ] ; then
      htar -xvf ${ARCHM6}/com_nam_prod_ndas.${TM06}.input.tar ./ndas.t${CYC_tm06}z.pcpbudget_history
      mv ndas.t${CYC_tm06}z.pcpbudget_history pcpbudget_history
      if [ -s pcpbudget_history ] ; then
        echo found file
      else
        htar -xvf ${ARCHPLLM6}/ndasx.${TM06}.input.tar ./ndas.t${CYC_tm06}z.pcpbudget_history
        mv ndas.t${CYC_tm06}z.pcpbudget_history pcpbudget_history
      fi
    fi
  #end first date check (not if TYPE=first)
  fi

  if [ $PDY -ge 20110323 -a $PDY -le 20111017 ]; then
    if [ $CYC -eq 00 ] ; then
      htar -xvf ${ARCHPLLM12}/ndasx.${TM12}.input.tar ./ndas.t${CYC_tm12}z.pcpbudget_history
      mv ndas.t${CYC_tm12}z.pcpbudget_history pcpbudget_history
    fi
    if [ $CYC -eq 06 ] ; then
      htar -xvf ${ARCHPLLM18}/ndasx.${TM18}.input.tar ./ndas.t${CYC_tm18}z.pcpbudget_history
      mv ndas.t${CYC_tm18}z.pcpbudget_history pcpbudget_history
    fi
    if [ $CYC -eq 12 ] ; then
      htar -xvf ${ARCHPLL}/ndasx.${CDATE}.input.tar ./ndas.t${CYC}z.pcpbudget_history
      mv ndas.t${CYC}z.pcpbudget_history pcpbudget_history
    fi
    if [ $CYC -eq 18 ] ; then
      htar -xvf ${ARCHPLLM6}/ndasx.${TM06}.input.tar ./ndas.t${CYC_tm06}z_pcpbudget_history
      mv ndas.t${CYC_tm06}z.pcpbudget_history pcpbudget_history
    fi
    #end second date check
  fi


  # Last check here - if the date is -ge 20120102 then use that date's budget file
  # this is because in operations the precip analysis which were used stopped being available
  # and thus the budget was no longer updated - so use the last know available budget.

  if [ $PDY -ge 20120102 ]; then
    if [ ! -s pcpbudget_history ]; then
        #---Grab the last known pcp budget file           
      htar -xvf /NCEPPROD/hpssprod/runhistory/rh2012/201201/20120102/com_nam_prod_ndas.2012010212.input.tar ./ndas.t12z.pcpbudget_history
      mv ndas.t12z.pcpbudget_history pcpbudget_history
      if [ ! -s pcpbudget_history ]; then
         echo "UNABLE TO LOCATE PCP BUDGET HISTORY FILE!    EXIT!"
         exit 1
      else
         echo "USING OLD PCP BUDGET HISTORY FILE (FROM 20120102 12Z) - MOST RECENT ONE IS UNAVAILABLE FROM HPSS!"
      fi
    fi
  fi


  #Copy pcpbudget_history file to correct ndas.hold directory
  cp pcpbudget_history $HOLDscr/pcpbudget_history

#end TYPE test
fi

# Get tm18 GDAS sigma files to coldstart NDAS

#To get the right sf06 file for NAMRR from the ops NDAS
# step 6 hours forward, and then 12 back to correspond to correct
# NAM/NDAS file used in partial cycle

#For the GDAS, instead of TM18 and using 6 hour forecasts
# we now use TM12 but keep the 6 hour forecasts

TP06=`$NDATE +06 $CDATE`
CYC_tp06=`echo $TP06 | cut -c 9-10`
CDATE_tp06=`echo $TP06 | cut -c 1-10`
PDY_tp06=`echo $TP06 | cut -c 1-8`
YYYY_tp06=`echo $TP06 | cut -c 1-4`
YYYYMM_tp06=`echo $TP06 | cut -c 1-6`

if [ $RUNTYPE = CATCHUP ]; then

  if [ $TYPE = first -o $TYPE = partial ] ; then

    htar -xvf ${ARCH}/com_nam_prod_ndas.${CDATE_tp06}.bufr.tar ./ndas.t${CYC_tp06}z.sgesprep.tm12 
    if [ -s ndas.t${CYC_tp06}z.sgesprep.tm12 ] ; then
      mv ndas.t${CYC_tp06}z.sgesprep.tm12 sf06
    else
      htar -xvf ${ARCHM12}/com_gfs_prod_gdas.${TM12}.tar ./gdas1.t${CYC_tm12}z.sf06
      mv gdas1.t${CYC_tm12}z.sf06 sf06
    fi

    htar -xvf ${ARCHM12}/com_gfs_prod_gdas.${TM12}.tar ./gdas1.t${CYC_tm12}z.sf09
    mv gdas1.t${CYC_tm12}z.sf09 sf09


    # If the requested retro run is less than a year old, grab gfs file from primary spot
    #   otherwise get it from the save space
    #

    curyear=`date +%Y`
    (( lastyear = curyear - 1 ))
    mmdd=`date +%m%d`
    oneyearago_PDY=${lastyear}${mmdd}

    if [ ${TM12} -ge 2015011400 ]; then

      if [ $PDY -ge ${oneyearago_PDY} ]; then 
        htar -xvf ${ARCHM12_1YR}/com_gfs_prod_gfs.${TM12}.pgrb2_0p50.tar ./gfs.t${CYC_tm12}z.pgrb2.0p50.f006
        mv gfs.t${CYC_tm12}z.pgrb2.0p50.f006 pgrb2f06
        htar -xvf ${ARCHM12_1YR}/com_gfs_prod_gfs.${TM12}.pgrb2_0p50.tar ./gfs.t${CYC_tm12}z.pgrb2.0p50.f009
        mv gfs.t${CYC_tm12}z.pgrb2.0p50.f009 pgrb2f09
  
      else

        htar -xvf ${ARCHM12_1YR_save}/com_gfs_prod_gfs.${TM12}.pgrb2_0p50.tar ./gfs.t${CYC_tm12}z.pgrb2.0p50.f006
        mv gfs.t${CYC_tm12}z.pgrb2.0p50.f006 pgrb2f06
        htar -xvf ${ARCHM12_1YR_save}/com_gfs_prod_gfs.${TM12}.pgrb2_0p50.tar ./gfs.t${CYC_tm12}z.pgrb2.0p50.f009
        mv gfs.t${CYC_tm12}z.pgrb2.0p50.f009 pgrb2f09
        if [ ! -s pgrb2f06 -o ! -s pgrb2f09 ]; then
          #maybe they haven't moved to save yet, try the ARCHM12_1YR path
          htar -xvf ${ARCHM12_1YR}/com_gfs_prod_gfs.${TM12}.pgrb2_0p50.tar ./gfs.t${CYC_tm12}z.pgrb2.0p50.f006
          mv gfs.t${CYC_tm12}z.pgrb2.0p50.f006 pgrb2f06
          htar -xvf ${ARCHM12_1YR}/com_gfs_prod_gfs.${TM12}.pgrb2_0p50.tar ./gfs.t${CYC_tm12}z.pgrb2.0p50.f009
          mv gfs.t${CYC_tm12}z.pgrb2.0p50.f009 pgrb2f09
        fi
      # end test for 1 year old retro
      fi

    else  #Else before the early, 2015 GFS implementation, use older file names

      if [ $PDY -ge ${oneyearago_PDY} ]; then 

        htar -xvf ${ARCHM12_1YR}/com_gfs_prod_gfs.${TM12}.pgrb0p5.tar ./gfs.t${CYC_tm12}z.pgrb2f06
        mv gfs.t${CYC_tm12}z.pgrb2f06 pgrb2f06
        htar -xvf ${ARCHM12_1YR}/com_gfs_prod_gfs.${TM12}.pgrb0p5.tar ./gfs.t${CYC_tm12}z.pgrb2f09
        mv gfs.t${CYC_tm12}z.pgrb2f09 pgrb2f09
  
      else

        htar -xvf ${ARCHM12_1YR_save}/com_gfs_prod_gfs.${TM12}.pgrb0p5.tar ./gfs.t${CYC_tm12}z.pgrb2f06
        mv gfs.t${CYC_tm12}z.pgrb2f06 pgrb2f06
        htar -xvf ${ARCHM12_1YR_save}/com_gfs_prod_gfs.${TM12}.pgrb0p5.tar ./gfs.t${CYC_tm12}z.pgrb2f09
        mv gfs.t${CYC_tm12}z.pgrb2f09 pgrb2f09
        if [ ! -s pgrb2f06 -o ! -s pgrb2f09 ]; then
          #maybe they haven't moved to save yet, try the ARCHM12_1YR path
          htar -xvf ${ARCHM12_1YR}/com_gfs_prod_gfs.${TM12}.pgrb0p5.tar ./gfs.t${CYC_tm12}z.pgrb2f06
          mv gfs.t${CYC_tm12}z.pgrb2f06 pgrb2f06
          htar -xvf ${ARCHM12_1YR}/com_gfs_prod_gfs.${TM12}.pgrb0p5.tar ./gfs.t${CYC_tm12}z.pgrb2f09
          mv gfs.t${CYC_tm12}z.pgrb2f09 pgrb2f09
        fi
      # end test for 1 year old retro
      fi
    # end if for date check relating to early 2015 global implementation when file names changed
    fi
  
    if [ ! -s pgrb2f06 -o ! -s pgrb2f09 -o ! -s sf06 -o ! -s sf09 ]; then
      echo "Error! Unable downloaded needed GFS input files for use in partial cycling. Exit!"
      exit 1
    fi

  #end TYPE or PARTIAL test
  fi
# End if RUNTYPE = CATCHUP
fi 


# Get burn areas for FireWx nest

cd ${INPUT_FIRE_DIR}
thisCDATE=`$NDATE -720 $thisCDATE`
thisPDY=`echo $thisCDATE | cut -c 1-8`  
while [ $thisPDY -le $PDY ]; do
  this_YYYY=`echo $thisCDATE | cut -c 1-4` 
  this_YYYYMM=`echo $thisCDATE | cut -c 1-6` 
  ARCH_TMP=/NCEPPROD/hpssprod/runhistory/rh${this_YYYY}/${this_YYYYMM}/${thisPDY}
  if [ ! -s ${INPUT_FIRE_DIR}/burned_area_${thisPDY}_00_05_12km.grib2 ]; then
    htar -xvf ${ARCH_TMP}/dcom_us007003_${thisPDY}.tar ./burned_area/burned_area_${thisPDY}_00_05_12km.grib2
  fi
  if [ ! -s ${INPUT_FIRE_DIR}/burned_area_${thisPDY}_06_11_12km.grib2 ]; then
    htar -xvf ${ARCH_TMP}/dcom_us007003_${thisPDY}.tar ./burned_area/burned_area_${thisPDY}_06_11_12km.grib2
  fi
  if [ ! -s ${INPUT_FIRE_DIR}/burned_area_${thisPDY}_12_17_12km.grib2 ]; then
    htar -xvf ${ARCH_TMP}/dcom_us007003_${thisPDY}.tar ./burned_area/burned_area_${thisPDY}_12_17_12km.grib2
  fi
  if [ ! -s ${INPUT_FIRE_DIR}/burned_area_${thisPDY}_18_23_12km.grib2 ]; then
    htar -xvf ${ARCH_TMP}/dcom_us007003_${thisPDY}.tar ./burned_area/burned_area_${thisPDY}_18_23_12km.grib2
  fi
  if [ ! -s ${INPUT_FIRE_DIR}/burned_area_${thisPDY}_00_11_1km.grib2 ]; then
    htar -xvf ${ARCH_TMP}/dcom_us007003_${thisPDY}.tar ./burned_area/burned_area_${thisPDY}_00_11_1km.grib2
  fi
  if [ ! -s ${INPUT_FIRE_DIR}/burned_area_${thisPDY}_12_23_1km.grib2 ]; then
   htar -xvf ${ARCH_TMP}/dcom_us007003_${thisPDY}.tar ./burned_area/burned_area_${thisPDY}_12_23_1km.grib2
  fi
  thisCDATE=`$NDATE +12 $thisCDATE`
  thisPDY=`echo $thisCDATE | cut -c 1-8`  
done 

mv ./burned_area/*grib2 ${INPUT_FIRE_DIR}/
rmdir burned_area
cd ${INPUT}

# Get snow/sst/sea ice files for sfcupdate 

#NAMRR change - snow is now updated with the 00z cycle since that corresponds to 18z at tm06
#  With NDAS it was 06z cycle which correpsonds to 18z at tm12 - the start of the NDAS.
if [ $CYC -eq 00 -o $TYPE = first -o $TYPE = partial ] ; then

  htar -xvf ${ARCHM24}/dcom_us007003_${PDY_tm24}.tar ./wgrbbul/imssnow96.grb
  htar -xvf ${ARCHM24}/dcom_us007003_${PDY_tm24}.tar ./wgrbbul/NPR.SNWN.SP.S1200.MESH16
  htar -xvf ${ARCHM24}/dcom_us007003_${PDY_tm24}.tar ./wgrbbul/NPR.SNWS.SP.S1200.MESH16

  mv wgrbbul/imssnow96.grb .
  mv wgrbbul/NPR.SNWN.SP.S1200.MESH16 .
  mv wgrbbul/NPR.SNWS.SP.S1200.MESH16 .

  rmdir wgrbbul

# Grab the SST files that are closest to 12z!

  case $CYC in
    00)m=12;;
    01)m=13;;
    02)m=14;;
    03)m=15;;
    04)m=16;;
    05)m=17;;
    06)m=18;;
    07)m=19;;
    08)m=20;;
    09)m=21;;
    10)m=22;;
    11)m=23;;
    12)m=24;;
    13)m=01;;
    14)m=02;;
    15)m=03;;
    16)m=04;;
    17)m=05;;
    18)m=06;;
    19)m=07;;
    20)m=08;;
    21)m=09;;
    22)m=10;;
    23)m=11;;
  esac
  
  tmpcdate=`$NDATE -${m} ${CDATE}`
  PDY_tmp=`echo $tmpcdate | cut -c 1-8`
  YYYYMM_tmp=`echo $tmpcdate | cut -c 1-6`
  YYYY_tmp=`echo $tmpcdate | cut -c 1-4`
  tmpmm=`echo $tmpcdate | cut -c 5-6`
  tmpday=`echo $tmpcdate | cut -c 7-8` 

  ARCHM_TMP=/NCEPPROD/hpssprod/runhistory/rh${YYYY_tmp}/${YYYYMM_tmp}/${PDY_tmp}
  htar -xvf ${ARCHM_TMP}/com_gfs_prod_sst.${PDY_tmp}.tar ./rtgssthr_grb_0.083
  htar -xvf ${ARCHM_TMP}/com_gfs_prod_sst.${PDY_tmp}.tar ./sst2dvar.t12z.nam_grid

fi  #END IF TYPE = first, 00z, or partial


#Get CCPA for h2o budget update  - NO CHANGE NEEDED HERE FOR NAMRR
if [ $CYC -eq 12 ] ; then

  #18Z two days ago  
  htar -xvf ${ARCHM42}/com2_ccpa_prod_ccpa.${PDY_tm42}.tar ./18/ccpa.t18z.06h.hrap.conus
  if [ ! -s ./18/ccpa.t18z.06h.hrap.conus ]; then
    htar -xvf ${ARCHM42}/com_gens_prod_gefs.${PDY_tm42}_${CYC_tm42}.ccpa.tar ./ccpa/ccpa_conus_hrap_t18z_06h
    mv ./ccpa/ccpa_conus_hrap_t18z_06h .
    rmdir ccpa
  else
    mv ./18/ccpa.t18z.06h.hrap.conus .
    rmdir 18
  fi

  #00Z prev day
  htar -xvf ${ARCHM36}/com2_ccpa_prod_ccpa.${PDY_tm36}.tar ./00/ccpa.t00z.06h.hrap.conus
  if [ ! -s ./00/ccpa.t00z.06h.hrap.conus ]; then
    htar -xvf ${ARCHM36}/com_gens_prod_gefs.${PDY_tm36}_${CYC_tm36}.ccpa.tar ./ccpa/ccpa_conus_hrap_t00z_06h
    mv ./ccpa/ccpa_conus_hrap_t00z_06h .
    rmdir ccpa
  else
    mv ./00/ccpa.t00z.06h.hrap.conus .
    rmdir 00
  fi

  #06Z prev day
  htar -xvf ${ARCHM30}/com2_ccpa_prod_ccpa.${PDY_tm30}.tar ./06/ccpa.t06z.06h.hrap.conus
  if [ ! -s ./06/ccpa.t06z.06h.hrap.conus ]; then
    htar -xvf ${ARCHM30}/com_gens_prod_gefs.${PDY_tm30}_${CYC_tm30}.ccpa.tar ./ccpa/ccpa_conus_hrap_t06z_06h
    mv ./ccpa/ccpa_conus_hrap_t06z_06h .
    rmdir ccpa
  else
    mv ./06/ccpa.t06z.06h.hrap.conus .
    rmdir 06
  fi

  #12z prev day
  htar -xvf ${ARCHM24}/com2_ccpa_prod_ccpa.${PDY_tm24}.tar ./12/ccpa.t12z.06h.hrap.conus
  if [ ! -s ./12/ccpa.t12z.06h.hrap.conus ]; then
    htar -xvf ${ARCHM24}/com_gens_prod_gefs.${PDY_tm24}_${CYC_tm24}.ccpa.tar ./ccpa/ccpa_conus_hrap_t12z_06h
    mv ./ccpa/ccpa_conus_hrap_t12z_06h .
    rmdir ccpa
  else
    mv ./12/ccpa.t12z.06h.hrap.conus .
    rmdir 12
  fi

fi

exit 0

