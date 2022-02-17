#! /bin/ksh
#
# Script name:         exnam_pmgr.sh.sms
#
#  This script monitors the progress of the nam_fcst job for submission of
#  NAM parent domain post jobs
#
#  2015-??-??  Carley modified script so it could be used for the 6-h catchup cycle
#              in NAMv4

set -x

msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA 

echo $tmmark > time
tmmark_post=`cut -c 1-4 timemark`
export tmmark
export tmmark_post=$tmmark

hour=00
typeset -Z2 hour

if [ $tmmark = tm00 ]
then
  if [ $RUNTYPE = CATCHUP ]
  then
    TEND=${FMAX_CATCHUP_PARENT}
    (( TCP = FMAX_CATCHUP_PARENT + 1 ))
  else
    TEND=${FMAX_HOURLY_PARENT}
    (( TCP = FMAX_HOURLY_PARENT + 1 ))
  fi
else
   TEND=01
   TCP=02
fi

if [ -e posthours ]; then
   rm -f posthours
fi

while [ $hour -lt $TCP ]; 
do
  echo $hour >>posthours  
  let "hour=hour+1"
done
postjobs=`cat posthours`

#
# Wait for all fcst hours to finish 
#
icnt=1
while [ $icnt -lt 1500 ]
do
  for fhr in $postjobs
  do
    if [ -s $DATA/fcstdone.01.00${fhr}h_00m_00.00s ]
    then
     ecflow_client --event release_post${fhr}
     # Remove current fhr from list
     postjobs=`echo $postjobs | sed s/${fhr}//g`
    fi
  done

  result_check=`echo $postjobs | wc -w`
  if [ $result_check -eq 0 ]
  then
     break
  fi

  sleep 10
  icnt=$((icnt + 1))
  if [ $icnt -ge 720 ]
  then
    msg="ABORTING after 1.5 hours of waiting for Nam FCST hours $postjobs."
    err_exit $msg
  fi

done

echo Exiting $0

exit
