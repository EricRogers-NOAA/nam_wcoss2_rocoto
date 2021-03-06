#!/bin/ksh

set -x

msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA

GEMGRD1=${RUN}_${PDY}${cyc}f
GEMGRD2=${RUN}20_${PDY}${cyc}f
GEMGRD3=${RUN}32_${PDY}${cyc}f
#find out what fcst hr to start processing
#in case of a rerun only the needed files will be created
fhr=$fhend

while [ $fhr -ge $fhbeg ] ; do
   typeset -Z3 fhr
   ls -l $COMIN/$GEMGRD1${fhr}
   err1=$?
   ls -l $COMIN/$GEMGRD2${fhr}
   err2=$?
   ls -l $COMIN/$GEMGRD3${fhr}
   err3=$?
   if [ $err1 -eq 0 -a $err2 -eq 0 -a $err3 -eq 0 -o $fhr -eq $fhbeg ] ; then
      break
   fi
   fhr=`expr $fhr - $fhinc`
done

maxtries=180

#loop through and process needed forecast hours
while [ $fhr -le $fhend ]
do
   icnt=1

   while [ $icnt -lt 1000 ]
   do
      typeset -Z3 fhr
      ls -l $COMIN/$GEMGRD1${fhr}
      err1=$?
      ls -l $COMIN/$GEMGRD2${fhr}
      err2=$?
      ls -l $COMIN/$GEMGRD3${fhr}
      err3=$?
      if [ $err1 -eq 0 -a $err2 -eq 0 -a $err3 -eq 0 ] ; then
         break
      else
         let "icnt= icnt + 1"
         sleep 20
      fi
      if [ $icnt -ge $maxtries ]
      then
         msg="ABORTING after 1 hour of waiting for gempak grid F$fhr to end."
         err_exit $msg
      fi
   done

   export fhr

   ########################################################
   # Create a script to be poe'd
   #
   #  Note:  The number of scripts to be run MUST match the number
   #  of total_tasks set in the ecf script, or the job will fail.
   #
   rm $DATA/poescript
   typeset -Z2 fhr

   grep $fhr $FIXgempak/nam_meta |awk '{print $1}' > $DATA/tmpscript
   for script in `cat $DATA/tmpscript`
   do
     eval "echo $script" >> $DATA/poescript
   done

   num=`cat $DATA/poescript |wc -l` 

   while [ $num -lt $numproc ] ; do
      echo "hostname" >>poescript
      num=`expr $num + 1`
   done

   chmod 775 $DATA/poescript
   export CMDFILE=$DATA/poescript
#
#  If this is the final fcst hour, alert the
#  file to all centers.
#
   if [ $fhr -ge $fhend ] ; then
      export DBN_ALERT_TYPE=NAM_METAFILE_LAST
   fi

   #
   # Execute the script.

   export fend=$fhr
   ${MPIEXEC} -cpu-bind core -configfile ${CMDFILE}
   export err=$?; err_chk


      fhr=`expr $fhr + $fhinc`
done

#####################################################################
# GOOD RUN
set +x
echo "**************JOB NAM_META COMPLETED NORMALLY on the IBM-SP"
echo "**************JOB NAM_META COMPLETED NORMALLY on the IBM-SP"
echo "**************JOB NAM_META COMPLETED NORMALLY on the IBM-SP"
set -x
#####################################################################

echo EXITING $0
exit
#
