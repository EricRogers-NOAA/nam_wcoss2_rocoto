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
# 2019-11-05  Eric Rogers -- Dell version of nam_post0 doesn't run as an MPI code
#
set -x

msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA

offset=-`echo $tmmark | cut -c 3-4`
SDATE=`${NDATE} $offset ${PDY}${cyc}`
echo $SDATE > startdate.${tmmark}

ystart=`cat startdate.${tmmark} | cut -c1-4`
mstart=`cat startdate.${tmmark} | cut -c5-6`
dstart=`cat startdate.${tmmark} | cut -c7-8`
hstart=`cat startdate.${tmmark} | cut -c9-10`

. $GESDIR/nam.t${cyc}z.envir.sh

cp $FIXnam/nam_profdat_${domain}nest $DATA/nam_profdat_${domain}

typeset -Z2 -x fhr

OUTTYP=nemsio
model=NMMB
# increment is now in minutes
INCR=60

let NFILE=1

startd=$ystart$mstart$dstart

######
STARTDATE=${ystart}-${mstart}-${dstart}_${hstart}:00:00
######

timeform=$STARTDATE

curtime=`${NDATE} +${fhr} $ystart$mstart$dstart$hstart`
ycur=`echo $curtime | cut -c1-4`
mcur=`echo $curtime | cut -c5-6`
dcur=`echo $curtime | cut -c7-8`
hrcur=`echo $curtime | cut -c9-10`
 
timeform=${ycur}-${mcur}-${dcur}_${hrcur}:00:00
OUTFIL=$FCSTDIR/nmmb_hst_${numdomain}_nio_00${fhr}h_00m_00.00s


min=`expr ${fhr} \* 60`

cat > itag <<EOF
$OUTFIL
$model
$OUTTYP
$STARTDATE
$NFILE
$INCR
$min
EOF
 
export pgm=nam_post0
. prep_step
ln -sf $DATA/nam_profdat_${domain} fort.19
ln -sf $DATA/profilm.c1_${domain}.${tmmark} fort.79
ln -sf $DATA/itag fort.666

startmsg
$EXECnam/nam_post0 < itag >> $pgmout 2>errfile
export err=$?;err_chk

mv $DATA/profilm.c1_${domain}.${tmmark} $FCSTDIR/profilm.c1_${domain}.${tmmark}.f${fhr}
echo done > $FCSTDIR/post0done${fhr}_${numdomain}.${tmmark}

echo EXITING $0 with return code $err
exit $err
