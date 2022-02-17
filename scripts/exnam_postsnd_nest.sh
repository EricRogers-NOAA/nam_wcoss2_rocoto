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
# 2010-03-03  Eric Rogers -- Nested output version
# 2015-??-??  Jacob Carley -- Modified for NAMv4

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
    endfhr=${FMAX_HOURLY_NEST}
  else
    endfhr=${FMAX_CATCHUP_NEST}
  fi
fi

rm -rf profilm.c1_${domain}.$tmmark

while [ $fhr -le $endfhr ]
do
  if [ -s $FCSTDIR/post0done${fhr}_${numdomain}.${tmmark} ]; then
    cat $FCSTDIR/profilm.c1_${domain}.${tmmark}.f${fhr} >> profilm.c1_${domain}.$tmmark
    let "fhr=fhr+1"
    typeset -Z2 fhr
  else
     msg="ERROR IN exnam_sndpost_nest.sh.sms AT FHR=${fhr} !!! NOT ALL PROFILE JOBS HAVE FINISHED EXIT!"
     err_exit $msg
  fi
done

##
# Run NAM bufr sounding breakout code
##
$USHnam/nam_sndp_nest.sh
err=$?

echo done > $FCSTDIR/sndpostdone_${numdomain}.${tmmark}

echo EXITING $0 with return code $err
exit $err
