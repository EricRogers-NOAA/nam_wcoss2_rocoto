#! /bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         nam_boco_metgrid_gen_catchup.sh
# Script description:  Runs the NPS metgrid executable to interpolate GFS data
#                      for NAM catchup cycle boco file generation
#
# Author:        Eric Rogers       Org: NP22         Date: 2016-12-23
#
# Script history log:
# 2016-12-23  Eric Rogers  - Adapted for NAM from HIRESW script
set -x

INT=1
CYC=$1
STARTHR=$2
ENDHR=$3
ICOUNT=$4
SENDCOM=$5

### figure out start and end times for this segment

ystart=`echo $CYC | cut -c1-4`
mstart=`echo $CYC | cut -c5-6`
dstart=`echo $CYC | cut -c7-8`
hstart=`echo $CYC | cut -c9-10`

orig_start=${CYC}

start=`$NDATE +${STARTHR} ${orig_start}`
ystart=`echo $start | cut -c1-4`
mstart=`echo $start | cut -c5-6`
dstart=`echo $start | cut -c7-8`
hstart=`echo $start | cut -c9-10`

end=`$NDATE +${ENDHR} ${orig_start}`
yend=`echo $end | cut -c1-4`
mend=`echo $end | cut -c5-6`
dend=`echo $end | cut -c7-8`
hend=`echo $end | cut -c9-10`

cd $DATA/run_metgrid_${ICOUNT}
cp $FIXnam/nam_geo_nmb.d01.dio $DATA/run_metgrid_${ICOUNT}/geo_nmb.d01.dio

cp $DATA/run_ungrib_${ICOUNT}/namelist.nps namelist.nps
cp $PARMnam/nam.METGRID.TBL.bocos METGRID.TBL

### pull in needed files from ungrib job

FHR=$STARTHR
while [ $FHR -le $ENDHR ]
do
time=`$NDATE +${FHR} ${orig_start}`
yy=`echo $time | cut -c1-4`
mm=`echo $time | cut -c5-6`
dd=`echo $time | cut -c7-8`
hh=`echo $time | cut -c9-10`

# needs to be made more specific in conjuction with ungrib job

cp $DATA/run_ungrib_${ICOUNT}/FILE:${yy}-${mm}-${dd}_${hh} .

FHR=`expr $FHR + $INT`
done

export pgm=nam_metgrid_boco
. prep_step

startmsg
$EXECnam/nam_metgrid_boco
export err=$?;err_chk

echo "DONE" > metgriddone.${ICOUNT}

files=`ls met*.dio`

if [ $SENDCOM = 1 ] ; then
for fl in $files
do
mv ${fl} $DATA/nam.t${CYC}z.${fl}
done
fi

echo EXITING $0
exit
