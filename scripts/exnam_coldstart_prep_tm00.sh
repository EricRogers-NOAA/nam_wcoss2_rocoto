#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_coldstart_prep_tm00.sh.ecf
# Script description:  Runs NPS off GDAS first guess input for NAM parent        
#                      to coldstart NAM 84-h forecast off global
#                      if catchup cycle did not finish
#
# Author:        Eric Rogers       Org: NP22         Date: 2004-07-02
#
# Script history log:
# 2006-02-01  Eric Rogers - Based on HIRESW script
# 2008-08-14  Eric Rogers - Converted to use WPS
# 2009-05-22  Eric Rogers - Converted to use NPS
# 2013-01-25  Jacob Carley - NAM retro
# 2016-07-27  Eric Rogers - Modified for coldstart of NAM off GDAS
# 2016-12-29  Eric Rogers - Modified for GFS 2017Q3 implementation
# 2020-05-25  Eric Rogers - Convert to use GDAS 0.25 deg GRIB2 data for GFS v16

set -x

msg="JOB $job FOR NMMB HAS BEGUN"
postmsg "$msg"

export DOMNAM=nam

#
# Get needed variables from exndas_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh

mkdir -p $DATA/ungrib
mkdir -p $DATA/metgrid
mkdir -p $DATA/nemsinterp

#Remove any potential pre-existing files in these subdirectories
rm -f $DATA/ungrib/*
rm -f $DATA/metgrid/*
rm -f $DATA/nemsinterp/*

cd $DATA/ungrib
sh 

datetm00=`${NDATE} -0 $CYCLE`

echo DATEXX${datetm00} > ncepdate.npstm00
cp ncepdate.npstm00 $DATA/metgrid/.

### modify namelist file
PDYstart=`cat ncepdate.npstm00 | cut -c7-14`
ystart=`cat ncepdate.npstm00 | cut -c7-10`
mstart=`cat ncepdate.npstm00 | cut -c11-12`
dstart=`cat ncepdate.npstm00 | cut -c13-14`
hstart=`cat ncepdate.npstm00 | cut -c15-16`

start=$ystart$mstart$dstart$hstart

CYCer=`cat ncepdate.npstm00 | cut -c 7-16`
CYCstart=`${NDATE} -0 $CYCer`
CYCgdas=`${NDATE} -6 $CYCer`

echo DATEXX${CYCgdas} > nmcdate.gdas

PDYgds=`cat nmcdate.gdas | cut -c7-14`
yygds=`cat nmcdate.gdas | cut -c7-10`
mmgds=`cat nmcdate.gdas | cut -c11-12`
ddgds=`cat nmcdate.gdas | cut -c13-14`
cycgds=`cat nmcdate.gdas | cut -c15-16`

end=`${NDATE} +00 $start`

yend=`echo $end | cut -c1-4`
mend=`echo $end | cut -c5-6`
dend=`echo $end | cut -c7-8`
hend=`echo $end | cut -c9-10`

ignore_gridgen_sfc=".false."

cat $PARMnam/nam_namelist.nps | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
 | sed s:DSTART:$dstart: | sed s:HSTART:$hstart: | sed s:YEND:$yend: \
 | sed s:MEND:$mend:     | sed s:DEND:$dend: | sed s:HEND:$hend: \
 | sed s:IGNORE_GRIDGEN:${ignore_gridgen_sfc}: > namelist.nps

DATE=`echo $start | cut -c1-8`

rm Vtable

#####

cp $PARMnam/nam_Vtable.GFS.bocos Vtable

hrs="06"
 
for hr in $hrs
do

vldgdas=`${NDATE} $hr ${PDYgds}${cycgds}`

$UTIL_USHnam/getges_linkges_pgrb.sh -t pg2ges -v $vldgdas -e ${envir_getges} gdas.pgb2f${hr}

done

ln -sf gdas.pgb2f06 GRIBFILE.AAA

#Save a copy of the GDAS pgbf file in COMOUT
cp gdas.pgb2f06 $COMOUT/${RUN}.t${cyc}z.gdas.pgb2f${hr}

####

export pgm=nam_ungrib
. prep_step

startmsg
${MPIEXEC} $EXECnam/nam_ungrib >> $pgmout 2>errfile
export err=$?;err_chk

mv errfile $DATA/errfile.ungrib

### run metgrid

cd $DATA/metgrid
sh 

mv $DATA/ungrib/$pgmout .

STARTHR=00
ENDHR=00
INCRHR=03

ystart=`cat ncepdate.npstm00 | cut -c7-10`
echo ystart $ystart
mstart=`cat ncepdate.npstm00 | cut -c11-12`
echo mstart $mstart
dstart=`cat ncepdate.npstm00 | cut -c13-14`
echo dstart $dstart
hstart=`cat ncepdate.npstm00 | cut -c15-16`

orig_start=$ystart$mstart$dstart${hstart}

start=`${NDATE} 0 ${orig_start}`
ystart=`echo $start | cut -c1-4`
mstart=`echo $start | cut -c5-6`
dstart=`echo $start | cut -c7-8`
hstart=`echo $start | cut -c9-10`

end=`${NDATE} 0 ${orig_start}`

echo $start
echo $end

yend=`echo $end | cut -c1-4`
mend=`echo $end | cut -c5-6`
dend=`echo $end | cut -c7-8`
hend=`echo $end | cut -c9-10`

ignore_gridgen_sfc=".false."

cat $PARMnam/nam_namelist.nps | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
 | sed s:DSTART:$dstart: | sed s:HSTART:${hstart}: | sed s:YEND:$yend: \
 | sed s:MEND:$mend:     | sed s:DEND:$dend: | sed s:HEND:$hend: \
 | sed s:IGNORE_GRIDGEN:${ignore_gridgen_sfc}: > namelist.nps

cp $PARMnam/nam_METGRID.TBL.NMM_gfsgrib2 METGRID.TBL
cp $FIXnam/nam_geo_nmb.d01.dio geo_nmb.d01.dio

FHR=$STARTHR

while [ $FHR -le $ENDHR ]
do

time=`${NDATE} +${FHR} ${orig_start}`
yy=`echo $time | cut -c1-4`
mm=`echo $time | cut -c5-6`
dd=`echo $time | cut -c7-8`
hh=`echo $time | cut -c9-10`
 
cp $DATA/ungrib/FILE:${yy}-${mm}-${dd}_${hh} .
echo GRABBED $FHR
 
FHR=`expr $FHR + $INCRHR`
 
echo $FHR
done

export pgm=nam_metgrid
. prep_step

startmsg
${MPIEXEC} $EXECnam/nam_metgrid >> $pgmout 2>errfile
export err=$?;err_chk

mv errfile $DATA/errfile.metgrid

### run nemsinterp

cd $DATA/nemsinterp
sh 

cp $DATA/metgrid/$pgmout .
ln -sf $DATA/metgrid/met_nmb*dio . 
cp $DATA/metgrid/namelist.nps .

export pgm=nam_nemsinterp
. prep_step

startmsg
${MPIEXEC} $EXECnam/nam_nemsinterp >> $pgmout 2>errfile
export err=$?;err_chk

mv errfile $DATA/errfile.nemsinterp

# move files back to GESDIR
mv input_domain_01_nemsio $GESDIR/nam.t${cyc}z.input_domain_01_nemsio.tm00_precoldstart
rm input_domain_01
cp $GESDIR/nam.t${cyc}z.input_domain_01_nemsio.tm00_precoldstart  $GESDIR/nam.t${cyc}z.input_domain_01_nemsio.tm00
export err=$?;err_chk

rm boco*
mv $pgmout $DATA/.

cd $DATA

cat errfile.ungrib errfile.metgrid errfile.nemsinterp > errfile

exit $err
