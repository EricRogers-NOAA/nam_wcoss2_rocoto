#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         nam_getpcp_nam00z.sh
# Script description:  Extract hourly precipitation from 00z NAM
#                      12-36 h forecast for OCONUS soil moisture adjustment 
#                      during NDAS
#
# Author:        Ying Lin/Eric Rogers    Org: NP22         Date: 2007-06-28
#
# Script history log:
# 2007-06-28  Lin/Rogers 
# 2017-02-22  Rogers: Move location of nampcp files from
#             /com/hourly/prod/nam_pcpn_anal.yyyymmdd to COMNAM/nam.YYYYMMDD
#

set -x
cd $DATA 

day=`echo $CYCLE | cut -c 1-8`
PDY=`echo $CYCLE | cut -c 1-8`

HOURDIR=${COM_IN}/${RUN}.${day}
NAMDIR=${COM_IN}/${RUN}.$day
mkdir -p $HOURDIR

fcsthour=13

while [ $fcsthour -le 36 ] ; do

$WGRIB2 $NAMDIR/${RUN}.t${cyc}z.bgrdsf${fcsthour}.tm00 | grep "APCP" | $WGRIB2 -i -grib pcp${fcsthour}.tm00 $NAMDIR/${RUN}.t${cyc}z.bgrdsf${fcsthour}.tm00
$CNVGRIB -g21 pcp${fcsthour}.tm00 pcp${fcsthour}.tm00.grib1

let "fcsthour=fcsthour+1"
typeset -Z2 fhr

done



export pgm=nam_get1236hpcp
. prep_step

ln -sf pcp13.tm00.grib1  fort.13
ln -sf pcp14.tm00.grib1  fort.14
ln -sf pcp15.tm00.grib1  fort.15
ln -sf pcp16.tm00.grib1  fort.16
ln -sf pcp17.tm00.grib1  fort.17
ln -sf pcp18.tm00.grib1  fort.18
ln -sf pcp19.tm00.grib1  fort.19
ln -sf pcp20.tm00.grib1  fort.20
ln -sf pcp21.tm00.grib1  fort.21
ln -sf pcp22.tm00.grib1  fort.22
ln -sf pcp23.tm00.grib1  fort.23
ln -sf pcp24.tm00.grib1  fort.24
ln -sf pcp25.tm00.grib1  fort.25
ln -sf pcp26.tm00.grib1  fort.26
ln -sf pcp27.tm00.grib1  fort.27
ln -sf pcp28.tm00.grib1  fort.28
ln -sf pcp29.tm00.grib1  fort.29
ln -sf pcp30.tm00.grib1  fort.30
ln -sf pcp31.tm00.grib1  fort.31
ln -sf pcp32.tm00.grib1  fort.32
ln -sf pcp33.tm00.grib1  fort.33
ln -sf pcp34.tm00.grib1  fort.34
ln -sf pcp35.tm00.grib1  fort.35
ln -sf pcp36.tm00.grib1  fort.36

startmsg
$EXECnam/nam_get1236hpcp_12hrbuckets >> $pgmout 2>errfile
export err=$?;err_chk

#Files come out of this as nampcp*, so they must be renamed to
#  coincide with nam.

#Rename nampcp files

list=`ls nampcp*`
for mFName in $list;
do
  if [[ -s ${mFName} ]]; then
    y=`echo ${mFName} | awk '{ print (length($0) - 2)}'`
    newname=`echo ${mFName} | tail -c $y`
    mv ${mFName} ${RUN}${newname}
  fi
done


#Move to output directory
mv ${RUN}pcp.* $HOURDIR/.

echo Exiting $0

exit
