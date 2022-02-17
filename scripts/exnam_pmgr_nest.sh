#! /bin/ksh
#
# Script name:         exnam_pmgr_nest.sh.sms
#
#  This script monitors the progress of the nam_fcst job for submission
#  of NAM nest post jobs
#
#  2015-??-??  Carley modified script so it could be used for the 6-h catchup cycle
#              in NAMv4

set -x

msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA 

export tmmark_post=$tmmark

hour=00
typeset -Z2 hour

if [ $tmmark = tm00 ]
then
  if [ $RUNTYPE = CATCHUP ]
  then
    TEND=${FMAX_CATCHUP_NEST}
    (( TCP = FMAX_CATCHUP_NEST + 1 ))
  else
    TEND=${FMAX_HOURLY_NEST}
    (( TCP = FMAX_HOURLY_NEST + 1 ))
  fi
else
   TEND=01
   TCP=02
fi

if [ $domain = firewx ]
then
  TEND=36
  TCP=37
fi

rm $FCSTDIR/post_manager_running_${domain}
echo "post_manager_running" > $FCSTDIR/post_manager_running_${domain}

if [ -e posthours_${numdomain} ]; then
   rm -f posthours_${numdomain}
fi

while [ $hour -lt $TCP ];
do
  echo $hour >>posthours_${numdomain}
  let "hour=hour+1"
done

postjobs=`cat posthours_${numdomain}`

#
# Wait for all fcst hours to finish 
#
icnt=1
while [ $icnt -lt 1500 ]
do
  for fhr in $postjobs
  do
    if [ -s $FCSTDIR/fcstdone.${numdomain}.00${fhr}h_00m_00.00s ]
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
    msg="ABORTING after 2.0 hours of waiting for Nam ${domain}nest FCST hours $postjobs."
    err_exit $msg
  fi

done

echo Exiting $0

exit 
