#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_nemsinterp_boco7.sh.ecf
# Script description:  Runs NPS nemsinterp code to process GFS 0.25 deg 
#                      GRIB2 files for NAM 84-h forecast boco file generation 
#
# Author:        Eric Rogers       Org: NP22         Date: 2016-12-22
#
# Script history log:
# 2016-12-22  Eric Rogers - Based on original NAM NPS job and HIRESW job

set -x

cd $DATA/run_nemsinterp_7

export tmmark=tm00

msg="JOB $job FOR NMMB HAS BEGUN"
postmsg "$msg"

export DOMNAM=nam
LENGTH=84

#
# Get needed variables from exndas_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh

INPUT_DATA=$DATA/run_metgrid

yy=`echo $PDY | cut -c1-4`
mm=`echo $PDY | cut -c5-6`
dd=`echo $PDY | cut -c7-8`

ystart=`echo $PDY | cut -c1-4`
mstart=`echo $PDY | cut -c5-6`
dstart=`echo $PDY | cut -c7-8`

start=$ystart$mstart$dstart$cyc

int1=`$NDATE +12 $start`
yyint1=`echo $int1 | cut -c1-4`
mmint1=`echo $int1 | cut -c5-6`
ddint1=`echo $int1 | cut -c7-8`
hhint1=`echo $int1 | cut -c9-10`

int2=`$NDATE +12 $int1`
yyint2=`echo $int2 | cut -c1-4`
mmint2=`echo $int2 | cut -c5-6`
ddint2=`echo $int2 | cut -c7-8`
hhint2=`echo $int2 | cut -c9-10`

int3=`$NDATE +12 $int2`
yyint3=`echo $int3 | cut -c1-4`
mmint3=`echo $int3 | cut -c5-6`
ddint3=`echo $int3 | cut -c7-8`
hhint3=`echo $int3 | cut -c9-10`

int4=`$NDATE +12 $int3`
yyint4=`echo $int4 | cut -c1-4`
mmint4=`echo $int4 | cut -c5-6`
ddint4=`echo $int4 | cut -c7-8`
hhint4=`echo $int4 | cut -c9-10`

int5=`$NDATE +12 $int4`
yyint5=`echo $int5 | cut -c1-4`
mmint5=`echo $int5 | cut -c5-6`
ddint5=`echo $int5 | cut -c7-8`
hhint5=`echo $int5 | cut -c9-10`

int6=`$NDATE +12 $int5`
yyint6=`echo $int6 | cut -c1-4`
mmint6=`echo $int6 | cut -c5-6`
ddint6=`echo $int6 | cut -c7-8`
hhint6=`echo $int6 | cut -c9-10`

int7=`$NDATE +12 $int6`
yyint7=`echo $int7 | cut -c1-4`
mmint7=`echo $int7 | cut -c5-6`
ddint7=`echo $int7 | cut -c7-8`
hhint7=`echo $int7 | cut -c9-10`

end=`$NDATE $LENGTH $start`

yend=`echo $end | cut -c1-4`
mend=`echo $end | cut -c5-6`
dend=`echo $end | cut -c7-8`

cycstart=`echo ${PDY}${cyc}`

start=$ystart$mstart$dstart

end=`$NDATE $LENGTH $cycstart`

yend=`echo $end | cut -c1-4`
mend=`echo $end | cut -c5-6`
dend=`echo $end | cut -c7-8`
hend=`echo $end | cut -c9-10`

cat $PARMnam/nam_namelist.nps_bocos | sed s:YSTART:$yyint6: | sed s:MSTART:$mmint6: \
 | sed s:DSTART:$ddint6: | sed s:HSTART:$hhint6: | sed s:YEND:$yend: \
 | sed s:MEND:$mend:   | sed s:DEND:$dend: | sed s:HEND:$hend:g > namelist.nps

yy1=`echo $int6 | cut -c1-4`
mm1=`echo $int6 | cut -c5-6`
dd1=`echo $int6 | cut -c7-8`
hh1=`echo $int6 | cut -c9-10`

cp $INPUT_DATA/nam.t${cyc}z.met_nmb.d01.${yy1}-${mm1}-${dd1}_${hh1}:00:00.dio met_nmb.d01.${yy1}-${mm1}-${dd1}_${hh1}:00:00.dio

t2=`$NDATE +3 $int6`

yy2=`echo $t2 | cut -c1-4`
mm2=`echo $t2 | cut -c5-6`
dd2=`echo $t2 | cut -c7-8`
hh2=`echo $t2 | cut -c9-10`

cp $INPUT_DATA/nam.t${cyc}z.met_nmb.d01.${yy2}-${mm2}-${dd2}_${hh2}:00:00.dio met_nmb.d01.${yy2}-${mm2}-${dd2}_${hh2}:00:00.dio

t3=`$NDATE +3 $t2`

yy3=`echo $t3 | cut -c1-4`
mm3=`echo $t3 | cut -c5-6`
dd3=`echo $t3 | cut -c7-8`
hh3=`echo $t3 | cut -c9-10`

cp $INPUT_DATA/nam.t${cyc}z.met_nmb.d01.${yy3}-${mm3}-${dd3}_${hh3}:00:00.dio met_nmb.d01.${yy3}-${mm3}-${dd3}_${hh3}:00:00.dio

t4=`$NDATE +3 $t3`

yy4=`echo $t4 | cut -c1-4`
mm4=`echo $t4 | cut -c5-6`
dd4=`echo $t4 | cut -c7-8`
hh4=`echo $t4 | cut -c9-10`

cp $INPUT_DATA/nam.t${cyc}z.met_nmb.d01.${yy4}-${mm4}-${dd4}_${hh4}:00:00.dio met_nmb.d01.${yy4}-${mm4}-${dd4}_${hh4}:00:00.dio

t5=`$NDATE +3 $t4`

yy5=`echo $t5 | cut -c1-4`
mm5=`echo $t5 | cut -c5-6`
dd5=`echo $t5 | cut -c7-8`
hh5=`echo $t5 | cut -c9-10`

cp $INPUT_DATA/nam.t${cyc}z.met_nmb.d01.${yy5}-${mm5}-${dd5}_${hh5}:00:00.dio met_nmb.d01.${yy5}-${mm5}-${dd5}_${hh5}:00:00.dio

t6=`$NDATE +3 $t5`

yy6=`echo $t6 | cut -c1-4`
mm6=`echo $t6 | cut -c5-6`
dd6=`echo $t6 | cut -c7-8`
hh6=`echo $t6 | cut -c9-10`

cp $INPUT_DATA/nam.t${cyc}z.met_nmb.d01.${yy6}-${mm6}-${dd6}_${hh6}:00:00.dio met_nmb.d01.${yy6}-${mm6}-${dd6}_${hh6}:00:00.dio

export pgm=nam_nemsinterp
. prep_step

startmsg
${MPIEXEC} -n ${procs} -ppn ${procspernode} $EXECnam/nam_nemsinterp > $pgmout 2> errfile
export err=$?; err_chk

cp boco.0000 $COMOUT/nam.t${cyc}z.boco.01.072.${tmmark}
cp boco.0003 $COMOUT/nam.t${cyc}z.boco.01.075.${tmmark}
cp boco.0006 $COMOUT/nam.t${cyc}z.boco.01.078.${tmmark}
cp boco.0009 $COMOUT/nam.t${cyc}z.boco.01.081.${tmmark}

exit $err
