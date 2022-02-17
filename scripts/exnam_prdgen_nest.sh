#!/bin/ksh -l
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_prdgen_nest.sh
# Script description:  Run nam product generator jobs for NAM nests
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract: This script runs the NAM Nest PRDGEN jobs
#
# Script history log:
#
# 2010-??-??  Eric Rogers  Modified 12 km version for NAM nests
# 2015-??-??  Eric Rogers  Convert to GRIB2 : drop PRDGEN code, use wgrib2 for
#                          interpolation
#

set -xa
msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA

#
# Get needed variables from exnam_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh


for fhr in $fcsthrs
do

  mkdir -p $DATA/prdgen_${domain}_${fhr}
  y=`expr $fhr % 3`

  ln -s -f $COMIN/${RUN}.${cycle}.${domain}nest.bgdawp${fhr}.${tmmark} ${domain}.BGDAWP${fhr}.${tmmark}

  $USHnam/nam_prdgen_nest.sh $fhr $y
  err=$?
done

########################################################

echo EXITING $0
exit $err
#
