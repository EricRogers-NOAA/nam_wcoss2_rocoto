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

export domain=$1

day=`echo $CYCLE | cut -c 1-8`
PDY=`echo $CYCLE | cut -c 1-8`

HOURDIR=${COM_IN}/${RUN}.${day}
NAMDIR=${COM_IN}/${RUN}.$day
mkdir -p $HOURDIR

fcsthour=13

while [ $fcsthour -le 36 ] ; do

$WGRIB2 $NAMDIR/${RUN}.t${cyc}z.${domain}nest.bgdawp${fcsthour}.tm00 | grep "APCP" | $WGRIB2 -i -grib ${domain}nest_pcp${fcsthour}.tm00 $NAMDIR/${RUN}.t${cyc}z.${domain}nest.bgdawp${fcsthour}.tm00
$CNVGRIB -g21 ${domain}nest_pcp${fcsthour}.tm00 ${domain}nest_pcp${fcsthour}.tm00.grib1

let "fcsthour=fcsthour+1"
typeset -Z2 fhr

done


export pgm=nam_get1236hpcp
. prep_step

#Run for CONUS nest
rm -f fort.*

ln -sf ${domain}nest_pcp13.tm00.grib1  fort.13
ln -sf ${domain}nest_pcp14.tm00.grib1  fort.14
ln -sf ${domain}nest_pcp15.tm00.grib1  fort.15
ln -sf ${domain}nest_pcp16.tm00.grib1  fort.16
ln -sf ${domain}nest_pcp17.tm00.grib1  fort.17
ln -sf ${domain}nest_pcp18.tm00.grib1  fort.18
ln -sf ${domain}nest_pcp19.tm00.grib1  fort.19
ln -sf ${domain}nest_pcp20.tm00.grib1  fort.20
ln -sf ${domain}nest_pcp21.tm00.grib1  fort.21
ln -sf ${domain}nest_pcp22.tm00.grib1  fort.22
ln -sf ${domain}nest_pcp23.tm00.grib1  fort.23
ln -sf ${domain}nest_pcp24.tm00.grib1  fort.24
ln -sf ${domain}nest_pcp25.tm00.grib1  fort.25
ln -sf ${domain}nest_pcp26.tm00.grib1  fort.26
ln -sf ${domain}nest_pcp27.tm00.grib1  fort.27
ln -sf ${domain}nest_pcp28.tm00.grib1  fort.28
ln -sf ${domain}nest_pcp29.tm00.grib1  fort.29
ln -sf ${domain}nest_pcp30.tm00.grib1  fort.30
ln -sf ${domain}nest_pcp31.tm00.grib1  fort.31
ln -sf ${domain}nest_pcp32.tm00.grib1  fort.32
ln -sf ${domain}nest_pcp33.tm00.grib1  fort.33
ln -sf ${domain}nest_pcp34.tm00.grib1  fort.34
ln -sf ${domain}nest_pcp35.tm00.grib1  fort.35
ln -sf ${domain}nest_pcp36.tm00.grib1  fort.36

startmsg
$EXECnam/nam_get1236hpcp_3hrbuckets >> $pgmout 2>errfile
export err=$?;err_chk


#Files come out of this as nampcp*, so they must be renamed for conusnest
hrmax=36
h=13
while [ $h -le $hrmax ]; do
c=`${NDATE} +${h} $CYCLE`
mv nampcp.${c} ${domain}nest_${RUN}_pcp.${c}
(( h = h + 1 ))
done


mv ${domain}nest_${RUN}_pcp* $HOURDIR/.

echo Exiting $0

exit
