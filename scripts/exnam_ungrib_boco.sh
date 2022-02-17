#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_ungrib_boco.sh.ecf
# Script description:  Runs NPS ungrib code to process GFS 0.25 deg 
#                      GRIB2 files for NAM boco file generation 
#
# Author:        Eric Rogers       Org: NP22         Date: 2016-12-22
#
# Script history log:
# 2016-12-22  Eric Rogers - Based on original NAM NPS job and HIRESW job
# 2019-01-18  Eric Rogers - Changes to parallel script execution on Dell

set -x

msg="JOB $job FOR NMMB HAS BEGUN"
postmsg "$msg"

export DOMNAM=nam

#
# Get needed variables from exndas_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh

mkdir -p $DATA/run_ungrib

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

yy=`echo $PDYtm06 | cut -c1-4`
mm=`echo $PDYtm06 | cut -c5-6`
dd=`echo $PDYtm06 | cut -c7-8`

ystart=`echo $PDYtm06 | cut -c1-4`
mstart=`echo $PDYtm06 | cut -c5-6`
dstart=`echo $PDYtm06 | cut -c7-8`
hstart=`echo $TM06 | cut -c9-10`

int1=`$NDATE +01 $TM06`
yyint1=`echo $int1 | cut -c1-4`
mmint1=`echo $int1 | cut -c5-6`
ddint1=`echo $int1 | cut -c7-8`
hhint1=`echo $int1 | cut -c9-10`

int2=`$NDATE +01 $int1`
yyint2=`echo $int2 | cut -c1-4`
mmint2=`echo $int2 | cut -c5-6`
ddint2=`echo $int2 | cut -c7-8`
hhint2=`echo $int2 | cut -c9-10`

int3=`$NDATE +01 $int2`
yyint3=`echo $int3 | cut -c1-4`
mmint3=`echo $int3 | cut -c5-6`
ddint3=`echo $int3 | cut -c7-8`
hhint3=`echo $int3 | cut -c9-10`

int4=`$NDATE +01 $int3`
yyint4=`echo $int4 | cut -c1-4`
mmint4=`echo $int4 | cut -c5-6`
ddint4=`echo $int4 | cut -c7-8`
hhint4=`echo $int4 | cut -c9-10`

int5=`$NDATE +01 $int4`
yyint5=`echo $int5 | cut -c1-4`
mmint5=`echo $int5 | cut -c5-6`
ddint5=`echo $int5 | cut -c7-8`
hhint5=`echo $int5 | cut -c9-10`

int6=`$NDATE +01 $int5`
yyint6=`echo $int6 | cut -c1-4`
mmint6=`echo $int6 | cut -c5-6`
ddint6=`echo $int6 | cut -c7-8`
hhint6=`echo $int6 | cut -c9-10`

cat $PARMnam/nam_namelist.nps_bocos_catchup | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
 | sed s:DSTART:$dstart: | sed s:HSTART:$hstart: | sed s:YEND:$yyint1: \
 | sed s:MEND:$mmint1:   | sed s:DEND:$ddint1: | sed s:HEND:$hhint1: > $DATA/namelist.nps.tm06

cat $PARMnam/nam_namelist.nps_bocos_catchup | sed s:YSTART:$yyint1: | sed s:MSTART:$mmint1: \
 | sed s:DSTART:$ddint1: | sed s:HSTART:$hhint1: | sed s:YEND:$yyint2: \
 | sed s:MEND:$mmint2:   | sed s:DEND:$ddint2: | sed s:HEND:$hhint2: > $DATA/namelist.nps.tm05

cat $PARMnam/nam_namelist.nps_bocos_catchup | sed s:YSTART:$yyint2: | sed s:MSTART:$mmint2: \
 | sed s:DSTART:$ddint2: | sed s:HSTART:$hhint2: | sed s:YEND:$yyint3: \
 | sed s:MEND:$mmint3:   | sed s:DEND:$ddint3: | sed s:HEND:$hhint3: > $DATA/namelist.nps.tm04

cat $PARMnam/nam_namelist.nps_bocos_catchup | sed s:YSTART:$yyint3: | sed s:MSTART:$mmint3: \
 | sed s:DSTART:$ddint3: | sed s:HSTART:$hhint3: | sed s:YEND:$yyint4: \
 | sed s:MEND:$mmint4:   | sed s:DEND:$ddint4: | sed s:HEND:$hhint4: > $DATA/namelist.nps.tm03

cat $PARMnam/nam_namelist.nps_bocos_catchup | sed s:YSTART:$yyint4: | sed s:MSTART:$mmint4: \
 | sed s:DSTART:$ddint4: | sed s:HSTART:$hhint4: | sed s:YEND:$yyint5: \
 | sed s:MEND:$mmint5:   | sed s:DEND:$ddint5: | sed s:HEND:$hhint5: > $DATA/namelist.nps.tm02

cat $PARMnam/nam_namelist.nps_bocos_catchup | sed s:YSTART:$yyint5: | sed s:MSTART:$mmint5: \
 | sed s:DSTART:$ddint5: | sed s:HSTART:$hhint5: | sed s:YEND:$yyint6: \
 | sed s:MEND:$mmint6:   | sed s:DEND:$ddint6: | sed s:HEND:$hhint6: > $DATA/namelist.nps.tm01

cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_tm06/Vtable
cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_tm05/Vtable
cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_tm04/Vtable
cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_tm03/Vtable
cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_tm02/Vtable
cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_tm01/Vtable

export GRIBSRC=GFS

### Get the needed GRIB files into each of the six run_ungrib subdirectories

cp gfspgrb0.tm06 ./run_ungrib_tm06/GRIBFILE.AAA
cp gfspgrb1.tm06 ./run_ungrib_tm06/GRIBFILE.AAB
cp gfspgrb0.tm05 ./run_ungrib_tm05/GRIBFILE.AAA
cp gfspgrb1.tm05 ./run_ungrib_tm05/GRIBFILE.AAB
cp gfspgrb0.tm04 ./run_ungrib_tm04/GRIBFILE.AAA
cp gfspgrb1.tm04 ./run_ungrib_tm04/GRIBFILE.AAB
cp gfspgrb0.tm03 ./run_ungrib_tm03/GRIBFILE.AAA
cp gfspgrb1.tm03 ./run_ungrib_tm03/GRIBFILE.AAB
cp gfspgrb0.tm02 ./run_ungrib_tm02/GRIBFILE.AAA
cp gfspgrb1.tm02 ./run_ungrib_tm02/GRIBFILE.AAB
cp gfspgrb0.tm01 ./run_ungrib_tm01/GRIBFILE.AAA
cp gfspgrb1.tm01 ./run_ungrib_tm01/GRIBFILE.AAB

rm -rf poescript

echo "$USHnam/nam_boco_ungrib_gen_catchup.sh $cyc tm06" >> poescript
echo "$USHnam/nam_boco_ungrib_gen_catchup.sh $cyc tm05" >> poescript
echo "$USHnam/nam_boco_ungrib_gen_catchup.sh $cyc tm04" >> poescript
echo "$USHnam/nam_boco_ungrib_gen_catchup.sh $cyc tm03" >> poescript
echo "$USHnam/nam_boco_ungrib_gen_catchup.sh $cyc tm02" >> poescript
echo "$USHnam/nam_boco_ungrib_gen_catchup.sh $cyc tm01" >> poescript

chmod 775 $DATA/poescript
export MP_CMDFILE=$DATA/poescript

export pgm=nam_boco_ungrib_gen_catchup.sh
${MPIEXEC} -cpu-bind core -configfile $MP_CMDFILE
export err=$?; err_chk

cp $DATA/run_ungrib_tm06/ungrib.log errfile.tm06
cp $DATA/run_ungrib_tm05/ungrib.log errfile.tm05
cp $DATA/run_ungrib_tm04/ungrib.log errfile.tm04
cp $DATA/run_ungrib_tm03/ungrib.log errfile.tm03
cp $DATA/run_ungrib_tm02/ungrib.log errfile.tm02
cp $DATA/run_ungrib_tm01/ungrib.log errfile.tm01

cat errfile.tm06 errfile.tm05 errfile.tm04 errfile.tm03 errfile.tm02 errfile.tm01 > errfile

# processing for tm00
else

LENGTH=87

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

cat $PARMnam/nam_namelist.nps_bocos | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
 | sed s:DSTART:$dstart: | sed s:HSTART:$cyc: | sed s:YEND:$yyint1: \
 | sed s:MEND:$mmint1:   | sed s:DEND:$ddint1: | sed s:HEND:$hhint1: > $DATA/namelist.nps.1

cat $PARMnam/nam_namelist.nps_bocos | sed s:YSTART:$yyint1: | sed s:MSTART:$mmint1: \
 | sed s:DSTART:$ddint1: | sed s:HSTART:$hhint1: | sed s:YEND:$yyint2: \
 | sed s:MEND:$mmint2:   | sed s:DEND:$ddint2: | sed s:HEND:$hhint2: > $DATA/namelist.nps.2

cat $PARMnam/nam_namelist.nps_bocos | sed s:YSTART:$yyint2: | sed s:MSTART:$mmint2: \
 | sed s:DSTART:$ddint2: | sed s:HSTART:$hhint2: | sed s:YEND:$yyint3: \
 | sed s:MEND:$mmint3:   | sed s:DEND:$ddint3: | sed s:HEND:$hhint3: > $DATA/namelist.nps.3

cat $PARMnam/nam_namelist.nps_bocos | sed s:YSTART:$yyint3: | sed s:MSTART:$mmint3: \
 | sed s:DSTART:$ddint3: | sed s:HSTART:$hhint3: | sed s:YEND:$yyint4: \
 | sed s:MEND:$mmint4:   | sed s:DEND:$ddint4: | sed s:HEND:$hhint4: > $DATA/namelist.nps.4

cat $PARMnam/nam_namelist.nps_bocos | sed s:YSTART:$yyint4: | sed s:MSTART:$mmint4: \
 | sed s:DSTART:$ddint4: | sed s:HSTART:$hhint4: | sed s:YEND:$yyint5: \
 | sed s:MEND:$mmint5:   | sed s:DEND:$ddint5: | sed s:HEND:$hhint5: > $DATA/namelist.nps.5

cat $PARMnam/nam_namelist.nps_bocos | sed s:YSTART:$yyint5: | sed s:MSTART:$mmint5: \
 | sed s:DSTART:$ddint5: | sed s:HSTART:$hhint5: | sed s:YEND:$yyint6: \
 | sed s:MEND:$mmint6:   | sed s:DEND:$ddint6: | sed s:HEND:$hhint6: > $DATA/namelist.nps.6

cat $PARMnam/nam_namelist.nps_bocos | sed s:YSTART:$yyint6: | sed s:MSTART:$mmint6: \
 | sed s:DSTART:$ddint6: | sed s:HSTART:$hhint6: | sed s:YEND:$yyint7: \
 | sed s:MEND:$mmint7:   | sed s:DEND:$ddint7: | sed s:HEND:$hhint7: > $DATA/namelist.nps.7

cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_1/Vtable
cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_2/Vtable
cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_3/Vtable
cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_4/Vtable
cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_5/Vtable
cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_6/Vtable
cp $PARMnam/nam_Vtable.GFS.bocos  $DATA/run_ungrib_7/Vtable

GRIBSRC=GFS

### Get the needed GRIB files into each of the six run_ungrib subdirectories

cp gfspgrb0.tm00 ./run_ungrib_1/GRIBFILE.AAA
cp gfspgrb1.tm00 ./run_ungrib_1/GRIBFILE.AAB
cp gfspgrb2.tm00 ./run_ungrib_1/GRIBFILE.AAC
cp gfspgrb3.tm00 ./run_ungrib_1/GRIBFILE.AAD
cp gfspgrb4.tm00 ./run_ungrib_1/GRIBFILE.AAE

cp gfspgrb4.tm00 ./run_ungrib_2/GRIBFILE.AAA
cp gfspgrb5.tm00 ./run_ungrib_2/GRIBFILE.AAB
cp gfspgrb6.tm00 ./run_ungrib_2/GRIBFILE.AAC
cp gfspgrb7.tm00 ./run_ungrib_2/GRIBFILE.AAD
cp gfspgrb8.tm00 ./run_ungrib_2/GRIBFILE.AAE

cp gfspgrb8.tm00 ./run_ungrib_3/GRIBFILE.AAA
cp gfspgrb9.tm00 ./run_ungrib_3/GRIBFILE.AAB
cp gfspgrb10.tm00 ./run_ungrib_3/GRIBFILE.AAC
cp gfspgrb11.tm00 ./run_ungrib_3/GRIBFILE.AAD
cp gfspgrb12.tm00 ./run_ungrib_3/GRIBFILE.AAE

cp gfspgrb12.tm00 ./run_ungrib_4/GRIBFILE.AAA
cp gfspgrb13.tm00 ./run_ungrib_4/GRIBFILE.AAB
cp gfspgrb14.tm00 ./run_ungrib_4/GRIBFILE.AAC
cp gfspgrb15.tm00 ./run_ungrib_4/GRIBFILE.AAD
cp gfspgrb16.tm00 ./run_ungrib_4/GRIBFILE.AAE

cp gfspgrb16.tm00 ./run_ungrib_5/GRIBFILE.AAA
cp gfspgrb17.tm00 ./run_ungrib_5/GRIBFILE.AAB
cp gfspgrb18.tm00 ./run_ungrib_5/GRIBFILE.AAC
cp gfspgrb19.tm00 ./run_ungrib_5/GRIBFILE.AAD
cp gfspgrb20.tm00 ./run_ungrib_5/GRIBFILE.AAE

cp gfspgrb20.tm00 ./run_ungrib_6/GRIBFILE.AAA
cp gfspgrb21.tm00 ./run_ungrib_6/GRIBFILE.AAB
cp gfspgrb22.tm00 ./run_ungrib_6/GRIBFILE.AAC
cp gfspgrb23.tm00 ./run_ungrib_6/GRIBFILE.AAD
cp gfspgrb24.tm00 ./run_ungrib_6/GRIBFILE.AAE

cp gfspgrb24.tm00 ./run_ungrib_7/GRIBFILE.AAA
cp gfspgrb25.tm00 ./run_ungrib_7/GRIBFILE.AAB
cp gfspgrb26.tm00 ./run_ungrib_7/GRIBFILE.AAC
cp gfspgrb27.tm00 ./run_ungrib_7/GRIBFILE.AAD
cp gfspgrb28.tm00 ./run_ungrib_7/GRIBFILE.AAE

### run_ungrib
cd $DATA

rm -rf poescript

echo "$USHnam/nam_boco_ungrib_gen.sh $cyc 2" >> poescript
echo "$USHnam/nam_boco_ungrib_gen.sh $cyc 1" >> poescript
echo "$USHnam/nam_boco_ungrib_gen.sh $cyc 3" >> poescript
echo "$USHnam/nam_boco_ungrib_gen.sh $cyc 4" >> poescript
echo "$USHnam/nam_boco_ungrib_gen.sh $cyc 5" >> poescript
echo "$USHnam/nam_boco_ungrib_gen.sh $cyc 6" >> poescript
echo "$USHnam/nam_boco_ungrib_gen.sh $cyc 7" >> poescript

chmod 775 $DATA/poescript
export MP_CMDFILE=$DATA/poescript

export pgm=nam_boco_ungrib_gen.sh
${MPIEXEC} -cpu-bind core -configfile $MP_CMDFILE
export err=$?; err_chk

cat $DATA/run_ungrib_1/ungrib.log > errfile
cat $DATA/run_ungrib_2/ungrib.log >> errfile
cat $DATA/run_ungrib_3/ungrib.log >> errfile
cat $DATA/run_ungrib_4/ungrib.log >> errfile
cat $DATA/run_ungrib_5/ungrib.log >> errfile
cat $DATA/run_ungrib_6/ungrib.log >> errfile
cat $DATA/run_ungrib_7/ungrib.log >> errfile

fi

exit $err
