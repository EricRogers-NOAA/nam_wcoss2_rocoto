#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_metgrid_boco.sh.ecf
# Script description:  Runs NPS metgrid code to process GFS 0.25 deg 
#                      GRIB2 files for NAM boco file generation 
#
# Author:        Eric Rogers       Org: NP22         Date: 2016-12-22
#
# Script history log:
# 2016-12-22  Eric Rogers - Based on original NAM NPS job and HIRESW job

set -x

msg="JOB $job FOR NMMB HAS BEGUN"
postmsg "$msg"

export DOMNAM=nam

#
# Get needed variables from exndas_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh

mkdir -p $DATA/run_metgrid

if [ $RUNTYPE = CATCHUP -a $tmmark = tm06 ] ; then

export TM06=`${NDATE} -06 $CYCLE`
PDYtm06=`echo $TM06 | cut -c 1-8`
export TM05=`${NDATE} -05 $CYCLE`
PDYtm05=`echo $TM05 | cut -c 1-8`
export TM04=`${NDATE} -04 $CYCLE`
PDYtm04=`echo $TM04 | cut -c 1-8`
export TM03=`${NDATE} -03 $CYCLE`
PDYtm03=`echo $TM03 | cut -c 1-8`
export TM02=`${NDATE} -02 $CYCLE`
PDYtm02=`echo $TM02 | cut -c 1-8`
export TM01=`${NDATE} -01 $CYCLE`
PDYtm01=`echo $TM01 | cut -c 1-8`

rm -rf poescript

# Rename metgrid files with /com type names
export send=0

echo "$USHnam/nam_boco_metgrid_gen_catchup.sh $TM06 00 01 tm06 $send" > poescript
echo "$USHnam/nam_boco_metgrid_gen_catchup.sh $TM05 00 01 tm05 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen_catchup.sh $TM04 00 01 tm04 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen_catchup.sh $TM03 00 01 tm03 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen_catchup.sh $TM02 00 01 tm02 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen_catchup.sh $TM01 00 01 tm01 $send" >> poescript

chmod 775 $DATA/poescript
export MP_CMDFILE=poescript
export MP_LABELIO=YES
export MP_STDOUTMODE=ordered

export pgm=nam_boco_metgrid_gen_catchup.sh
${MPIEXEC} -cpu-bind core -configfile ${MP_CMDFILE}
export err=$?
err_chk

cat $DATA/run_metgrid_tm06/metgrid.log > metgrid.log
cat $DATA/run_metgrid_tm05/metgrid.log >> metgrid.log
cat $DATA/run_metgrid_tm04/metgrid.log >> metgrid.log
cat $DATA/run_metgrid_tm03/metgrid.log >> metgrid.log
cat $DATA/run_metgrid_tm02/metgrid.log >> metgrid.log
cat $DATA/run_metgrid_tm01/metgrid.log >> metgrid.log

# processing for tm00
else

# Create a script to be poe'd
cd $DATA
rm -rf poescript

# Rename metgrid files with com type names
export send=1

echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 00 03 1 $send" > poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 06 09 2 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 12 15 3 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 18 21 4 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 24 27 5 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 30 33 6 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 36 39 7 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 42 45 8 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 48 51 9 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 54 57 10 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 60 63 11 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 66 69 12 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 72 75 13 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 78 81 14 $send" >> poescript
echo "$USHnam/nam_boco_metgrid_gen.sh $cyc 84 84 15 $send" >> poescript

chmod 775 $DATA/poescript
export MP_CMDFILE=poescript
export MP_LABELIO=YES
export MP_STDOUTMODE=ordered

export pgm=nam_boco_metgrid_gen.sh
${MPIEXEC} -cpu-bind core -configfile $MP_CMDFILE 
export err=$?
err_chk

ic=1
rm metgrid.log

while [ $ic -le 15 ] ; do
  cat $DATA/run_metgrid_${ic}/metgrid.log >> metgrid.log
  let "ic=ic+1"
done

fi

exit $err
