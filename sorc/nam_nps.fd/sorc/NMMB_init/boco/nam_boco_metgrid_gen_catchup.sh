#! /bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         hiresw_wps_metgrid_gen.sh
# Script description:  Runs the WPS metgrid executable to interpolate data
#
# Author:        Eric Rogers       Org: NP22         Date: 2004-07-07
#
# Abstract: Runs the WPS program metgrid, which horizontally interpolates 
#           fields onto the target WRF domain.  For better parallel
#           performance, this script  is run in simultaneous threads
#           to process all 48-h of NAM input.  Input variables "ICOUNT", 
#           "STARTHR", and "ENDHR" set in the Loadleveler argument
#           card,  tells this script which NAM forecast GRIB files to process
#
# Script history log:
# 2003-11-01  Matt Pyle    - Original script for parallel
# 2004-07-07  Eric Rogers  - Preliminary modifications for production.
# 2007-04-19  Matthew Pyle - Completely renamed and revamped script 
#                            to run WPS metgrid.  Sufficiently flexible to run
#                            with a user-defined number of streams if the proper
#                            items are passed into the script.
                                                                                                                                   
set -x

INT=1
CYC=$1
STARTHR=$2
ENDHR=$3
ICOUNT=$4
SENDCOM=$5

### figure out start and end times for this segment

export DATA=/stmpp2/Eric.Rogers/testnps_origcode_catchup/run_metgrid
mkdir -p /stmpp2/Eric.Rogers/testnps_origcode_catchup/run_metgrid

NDATE=/nwprod/util/exec/ndate

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

cd $DATAROOT/run_metgrid_${ICOUNT}
cp $FIXnam/nam_geo_nmb.d01.dio $DATAROOT/run_metgrid_${ICOUNT}/geo_nmb.d01.dio

cp $DATAROOT/run_ungrib_${ICOUNT}/namelist.nps .

EXECmet=/meso/save/Eric.Rogers/nam_gfs2017q3/sorc/nam_nps_bocos.fd/NMMB_init/NPS/metgrid/src
cp $PARMnps/nam.METGRID.TBL.bocos METGRID.TBL
mv namelist.nps.${ICOUNT} namelist.nps

### pull in needed files from ungrib job

FHR=$STARTHR
while [ $FHR -le $ENDHR ]
do
time=`$NDATE +${FHR} ${orig_start}`
yy=`echo $time | cut -c1-4`
mm=`echo $time | cut -c5-6`
dd=`echo $time | cut -c7-8`
hh=`echo $time | cut -c9-10`

. /usrx/local/Modules/default/init/ksh
###module switch ics ics/15.0.3
module load NetCDF/4.2/serial

# needs to be made more specific in conjuction with ungrib job

cp $DATAROOT/run_ungrib_${ICOUNT}/FILE:${yy}-${mm}-${dd}_${hh} .

FHR=`expr $FHR + $INT`
done

$EXECmet/metgrid.exe
export err=$?
###err_chk

echo "DONE" > wpsdone.${ICOUNT}

files=`ls met*.dio`

if [ $SENDCOM = 1 ] ; then
for fl in $files
do
mv ${fl} $DATA/nam.t${CYC}z.${fl}
done
fi

if [ $ICOUNT == "1" ]
then
for fl in $files
do
cp ${fl} ../
done
fi

mv wpsdone.${ICOUNT} ../

cp metgrid.log $DATA/metgrid.log.0000_${ICOUNT}

echo EXITING $0
exit
