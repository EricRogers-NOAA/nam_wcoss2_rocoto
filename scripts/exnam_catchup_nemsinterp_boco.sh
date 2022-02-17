#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_catchup_nemsinterp_boco.sh.ecf
# Script description:  Runs NPS nemsinterp code to process GFS 0.25 deg 
#                      GRIB2 files for NAM catchup cycle boco file generation 
#
# Author:        Eric Rogers       Org: NP22         Date: 2016-12-22
#
# Script history log:
# 2016-12-22  Eric Rogers - Based on original NAM NPS job and HIRESW job

set -x

export tmmark=$1

msg="JOB $job FOR NMMB HAS BEGUN"
postmsg "$msg"

export DOMNAM=nam

LENGTH=1

#
# Get needed variables from exndas_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh

INPUT_DATA=$DATA/run_metgrid_${tmmark}

offset=`echo $tmmark | cut -c 3-4`
export npsstart=`${NDATE} -${offset} $CYCLE`

yy1=`echo $npsstart | cut -c1-4`
mm1=`echo $npsstart | cut -c5-6`
dd1=`echo $npsstart | cut -c7-8`
hh1=`echo $npsstart | cut -c9-10`

cp $INPUT_DATA/met_nmb.d01.${yy1}-${mm1}-${dd1}_${hh1}:00:00.dio .

t2=`$NDATE +1 $npsstart`
yy2=`echo $t2 | cut -c1-4`
mm2=`echo $t2 | cut -c5-6`
dd2=`echo $t2 | cut -c7-8`
hh2=`echo $t2 | cut -c9-10`

cp $INPUT_DATA/met_nmb.d01.${yy2}-${mm2}-${dd2}_${hh2}:00:00.dio .
cp $INPUT_DATA/namelist.nps .

export pgm=nam_nemsinterp
. prep_step

startmsg
${MPIEXEC} $EXECnam/nam_nemsinterp > $pgmout 2> errfile
export err=$?;err_chk

cp boco.0000 $COMOUT/nam.t${cyc}z.boco.01.000.${tmmark}

exit $err
