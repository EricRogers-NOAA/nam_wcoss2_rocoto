#!/bin/ksh
######################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_sndpost.sh
# Script description:  Trigger nam sounding post job
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract: This script triggers the nam sounding post job, which
#           creates a piece of the model sounding profile whose
#           time interval is determined by the input forecast hours.
#
# Script history log:
# 2000-05-16  Eric Rogers
# 2006-01-20  Eric Rogers -- extended to 84-h and modified for WRF-NMM NAM
# 2009-12-09  Eric Rogers -- NAM version
#
set -x

msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA

. $GESDIR/nam.t${cyc}z.envir.sh

fhr=00
typeset -Z2 fhr

if [ $tmmark != tm00 ] 
then
  endfhr=01
fi

if [ $tmmark = tm00 ]
then
  if [ $RUNTYPE = HOURLY ] 
  then
    endfhr=${FMAX_HOURLY_PARENT}
  else
    endfhr=${FMAX_CATCHUP_PARENT}
  fi
fi

rm -rf profilm.c1.$tmmark

# Make Job abort if all sounding files are not present
#   so we can recover later (since the cycle step will not
#   run)

while [ $fhr -le $endfhr ]
do
  if [ -s $FCSTDIR/post0done${fhr}.${tmmark} ]; then
     cat profilm.c1.${tmmark}.f${fhr} >> profilm.c1.$tmmark
     let "fhr=fhr+1"
     typeset -Z2 fhr
  else
     msg="ERROR IN exnam_sndpost.sh.sms AT FHR=${fhr} !!! NOT ALL PROFILE JOBS HAVE FINISHED EXIT!"
     err_exit $msg
  fi
done

##
# Run NAM bufr sounding breakout code
##
$USHnam/nam_sndp.sh
err=$?

echo done > $DATA/sndpostdone.${tmmark}

echo EXITING $0 with return code $err
exit $err
