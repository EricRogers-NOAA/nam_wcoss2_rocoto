#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_prelim.sh.sms
# Script description:  Kickoff job for NAM run
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract: Kickoff job for NAM; gets GDAS/GFS sigma files for 
#           lateral boundary conditions
#
# Script history log:
# 1999-06-23  Eric Rogers
# 1999-07-30  Brent Gordon  - Modified for production.
# 2000-03-03  Eric Rogers modified scripts for 60-h NAM forecast
# 2004-10-14  Julia Zhu	 - NAM/EDAS name changes to NAM/NDAS
# 2006-01-12  Eric Rogers - Extensive changes for WRF-NMM
# 2008-08-14  Eric Rogers - Changed so that coldstart (partial cycling) is 
#                           always invoked
# 2009-12-07  Eric Rogers - Extensive changes for NAM
# 2013-01-24  Jacob Carley - Changes for retro
# 2015-??-??  Rogers/Carley - Modified for NAMv4
# 2016-12-23  Rogers - Modified to get GDAS/GFS 0.25 deg GRIB2 files for
#                      boco file generation
# 2019-01-18  Rogers - Removed RETRO option on Dell, cleaned up unused ecflow triggers
# 2021-09-09  Rogers - Move to WCOSS2, removed HOURLY option checks

set -x

msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA

export DOMAIN=nam
export CYCLE=$PDY$cyc
echo "export CYCLE=$CYCLE" > $GESDIR/nam.t${cyc}z.envir.sh

TM06=`${NDATE} -06 $CYCLE`
TM05=`${NDATE} -05 $CYCLE`
TM04=`${NDATE} -04 $CYCLE`
TM03=`${NDATE} -03 $CYCLE`
TM02=`${NDATE} -02 $CYCLE`
TM01=`${NDATE} -01 $CYCLE`

echo $CYCLE > date
yyyymmdd=`cut -c 1-8 date`
hh=`cut -c 9-10 date`

echo $TM06 > datetm06
yyyymmddm06=`cut -c 1-8 datetm06`
hh06=`cut -c 9-10 datetm06`
SDATE=`cut -c 1-10 datetm06`
yyyymmddm06=`echo $TM06 | cut -c 1-8`

echo $TM03 > datetm03
yyyymmddm03=`cut -c 1-8 datetm03`
hh03=`cut -c 9-10 datetm03`
SDATE=`cut -c 1-10 datetm03`
yyyymmddm03=`echo $TM03 | cut -c 1-8`

y=`expr $cyc % 6`

# Current planned configuration:

if [ $RUNTYPE = CATCHUP -a $tmmark = tm06 ] 
then
  export GUESS=GDAS
  echo "export GUESS=GDAS" >> $GESDIR/nam.t${cyc}z.envir.sh
  echo "export RUNTYPE=CATCHUP" >> $GESDIR/nam.t${cyc}z.envir.sh
fi

if [ $RUNTYPE = CATCHUP -a $tmmark = tm00 ]
then

  export GUESS=NAM
  echo "export GUESS=NAM" >> $GESDIR/nam.t${cyc}z.envir.sh

# Check to see if all NAM nests' first guesses are present; if not
# assume catchup cycle did not finish and coldstart NAM off GDAS

  nestcount=0
  area="alaska conus"
  for reg in $area
  do
    if [ -s $GESDIR/nam.t${cyc}z.nmm_b_restart_${reg}nest_nemsio.tm01 ]
    then
      let "nestcount=nestcount+1"
    fi
  done
  area="hawaii prico firewx"
  for reg in $area
  do
    if [ -s $GESDIR/nam.t${cyc}z.input_domain_${reg}nest_nemsio ]
    then
      let "nestcount=nestcount+1"
    fi
  done
  if [ $nestcount -lt 5 ] ; then
    export GUESStm00=GDAS
    echo "export GUESStm00=GDAS" >> $GESDIR/nam.t${cyc}z.envir.sh
  else
    export GUESStm00=NAM
    echo "export GUESStm00=NAM" >> $GESDIR/nam.t${cyc}z.envir.sh
    echo "export firewx_location=`cat $COMIN/nam.t${cyc}z.firewxnest_location | awk '{print $1}'`" >> $GESDIR/nam.t${cyc}z.envir.sh
    if [ $SENDDBN = YES ]; then
      $DBNROOT/bin/dbn_alert MODEL NAM_FIREWXNEST_TEXT $job $COMOUT/nam.t${cyc}z.firewxnest_center_latlon
    fi
  fi
  echo "export RUNTYPE=CATCHUP" >> $GESDIR/nam.t${cyc}z.envir.sh
fi

# Send message to namlog file w/date and origin of first guess

msg="$CYCLE $tmmark $GUESS $RUNTYPE"
postmsg "$msg"

if [ $tmmark = tm00 -a $RUNTYPE = CATCHUP ] ; then
  msg="$CYCLE $tmmark $GUESStm00 $RUNTYPE"
  postmsg "$msg"
fi

TP01=`${NDATE} 1 $CYCLE`
TP02=`${NDATE} 2 $CYCLE`
TP03=`${NDATE} 3 $CYCLE`
TP06=`${NDATE} 6 $CYCLE`
TP09=`${NDATE} 9 $CYCLE`
TP12=`${NDATE} 12 $CYCLE`
TP15=`${NDATE} 15 $CYCLE`
TP18=`${NDATE} 18 $CYCLE`

if [ $RUNTYPE = CATCHUP -a $tmmark = tm06 ] 
then

# The second argument, 01, refers to the final forecast hour to grab of GFS BC files.
#   Here, we are grabbing 00hr and 01hr forecasts (this scripts assumes a forecast
#   hour interval of 1).

${UTIL_USHnam}/getgfsbc_nam_hourlypgrb.sh $TM06 01 $envir_getges tm06
${UTIL_USHnam}/getgfsbc_nam_hourlypgrb.sh $TM05 01 $envir_getges tm05
${UTIL_USHnam}/getgfsbc_nam_hourlypgrb.sh $TM04 01 $envir_getges tm04
${UTIL_USHnam}/getgfsbc_nam_hourlypgrb.sh $TM03 01 $envir_getges tm03
${UTIL_USHnam}/getgfsbc_nam_hourlypgrb.sh $TM02 01 $envir_getges tm02
${UTIL_USHnam}/getgfsbc_nam_hourlypgrb.sh $TM01 01 $envir_getges tm01

# save file with list of Global forecasts used for LBC's 

cat $DATA/filelist.ges*.tm06 > $COMOUT/nam.t${cyc}z.lbcfilelist.tm06
cat $DATA/filelist.ges*.tm05 > $COMOUT/nam.t${cyc}z.lbcfilelist.tm05
cat $DATA/filelist.ges*.tm04 > $COMOUT/nam.t${cyc}z.lbcfilelist.tm04
cat $DATA/filelist.ges*.tm03 > $COMOUT/nam.t${cyc}z.lbcfilelist.tm03
cat $DATA/filelist.ges*.tm02 > $COMOUT/nam.t${cyc}z.lbcfilelist.tm02
cat $DATA/filelist.ges*.tm01 > $COMOUT/nam.t${cyc}z.lbcfilelist.tm01

mkdir -p $DATA/run_ungrib_tm06
mkdir -p $DATA/run_ungrib_tm05
mkdir -p $DATA/run_ungrib_tm04
mkdir -p $DATA/run_ungrib_tm03
mkdir -p $DATA/run_ungrib_tm02
mkdir -p $DATA/run_ungrib_tm01

mkdir -p $DATA/run_metgrid_tm06
mkdir -p $DATA/run_metgrid_tm05
mkdir -p $DATA/run_metgrid_tm04
mkdir -p $DATA/run_metgrid_tm03
mkdir -p $DATA/run_metgrid_tm02
mkdir -p $DATA/run_metgrid_tm01

mkdir -p $DATA/run_nemsinterp_tm06
mkdir -p $DATA/run_nemsinterp_tm05
mkdir -p $DATA/run_nemsinterp_tm04
mkdir -p $DATA/run_nemsinterp_tm03
mkdir -p $DATA/run_nemsinterp_tm02
mkdir -p $DATA/run_nemsinterp_tm01

# release ungrib BC jobs on ECF
  if test "$SENDECF" = 'YES'
  then
    ecflow_client --event release_ungrib
  fi

fi

# Use utility script to get global files for 
# 84-h forecasts from tm00

if [ $tmmark = tm00 ] 
then
  #  Get the GDAS/GFS 0.25 deg GRIB2 files for the NAM boundary conditions
  ${UTIL_USHnam}/getgfsbc_nam_pgrb.sh $CYCLE 87 $envir_getges tm00
  # save file with list of Global forecasts used for LBC's 
  cat $DATA/filelist.ges*.tm00 > $COMOUT/nam.t${cyc}z.lbcfilelist.tm00

  mkdir -p $DATA/run_ungrib_1
  mkdir -p $DATA/run_ungrib_2
  mkdir -p $DATA/run_ungrib_3
  mkdir -p $DATA/run_ungrib_4
  mkdir -p $DATA/run_ungrib_5
  mkdir -p $DATA/run_ungrib_6
  mkdir -p $DATA/run_ungrib_7
  mkdir -p $DATA/run_ungrib

  mkdir -p $DATA/run_metgrid_1
  mkdir -p $DATA/run_metgrid_2
  mkdir -p $DATA/run_metgrid_3
  mkdir -p $DATA/run_metgrid_4
  mkdir -p $DATA/run_metgrid_5
  mkdir -p $DATA/run_metgrid_6
  mkdir -p $DATA/run_metgrid_7
  mkdir -p $DATA/run_metgrid_8
  mkdir -p $DATA/run_metgrid_9
  mkdir -p $DATA/run_metgrid_10
  mkdir -p $DATA/run_metgrid_11
  mkdir -p $DATA/run_metgrid_12
  mkdir -p $DATA/run_metgrid_13
  mkdir -p $DATA/run_metgrid_14
  mkdir -p $DATA/run_metgrid_15
  mkdir -p $DATA/run_metgrid

  mkdir -p $DATA/run_nemsinterp_1
  mkdir -p $DATA/run_nemsinterp_2
  mkdir -p $DATA/run_nemsinterp_3
  mkdir -p $DATA/run_nemsinterp_4
  mkdir -p $DATA/run_nemsinterp_5
  mkdir -p $DATA/run_nemsinterp_6
  mkdir -p $DATA/run_nemsinterp_7
  mkdir -p $DATA/run_nemsinterp

# release ungrib job on ECF
  # Added SENDECF test so I couls run this scripot in dev testing
  if test "$SENDECF" = 'YES'
  then
    ecflow_client --event release_ungrib
  fi

# if catchup cycle did not run release NAM coldstart off GDAS
  if [ $GUESStm00 = GDAS ] ; then
    NETNAME=`echo ${ECF_NAME}| awk -F"/prelim" '{print $1}'`
    if test "$SENDECF" = "YES"
    then
      ecflow_client --force queued recursive $NETNAME/coldstart
    fi
    ecflow_client --event release_nam_coldstart
  fi
fi

exit 0

msg="JOB $job HAS COMPLETED NORMALLY."
postmsg "$msg"
