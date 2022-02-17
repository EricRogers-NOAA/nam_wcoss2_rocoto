#/bin/ksh

set -x

cd $DATA

fhr=$1

utilfix_nam=${HOMEnam}/util/fix_grib2
NAGRIB=nagrib2
tmmark=tm00

. $GESDIR/${RUN}.t${cyc}z.envir.sh

cp $COMIN/${RUN}.t${cyc}z.gridnavfw.ijdims.txt gridnavfw.ijdims.txt

if [ $firewx_location = conus ]
then
   proj=lcc
   angles="25;-95;0"
else
   proj=stc
   angles="90;-150;0"
fi

NAGRIB_TABLE=${NAMFIXgem}/nagrib.tbl
NAGRIB=nagrib2

kx=`cat gridnavfw.ijdims.txt | awk '{print $1}'`
ky=`cat gridnavfw.ijdims.txt | awk '{print $2}'`

GRIBIN=$COMIN/${RUN}.t${cyc}z.firewxnest.hiresf${fhr}.tm00.grib2
GEMGRD=nam_firewxnest_${PDY}${cyc}f0${fhr}

$WGRIB2 $GRIBIN | grep -F -f $utilfix_nam/nam_firewxnest.parmlist|$WGRIB2 -i -grib temp $GRIBIN
mv temp grib$fhr

#
# Copy model specific GEMPAK tables into working directory
#

cp $NAMFIXgem/hrrr_g2varsncep1.tbl g2varsncep1.tbl
cp $NAMFIXgem/hrrr_g2varswmo2.tbl g2varswmo2.tbl
cp $NAMFIXgem/hrrr_g2vcrdncep1.tbl g2vcrdncep1.tbl
cp $NAMFIXgem/hrrr_g2vcrdwmo2.tbl g2vcrdwmo2.tbl

$NAGRIB << EOF
GBFILE  = grib$fhr
INDXFL  =
GDOUTF  = $GEMGRD
PROJ    = ${proj}/${angles}
GRDAREA = 
KXKY    = ${kx};${ky}
GAREA   = dset
MAXGRD  = 5000
CPYFIL  = gds
OUTPUT  = f/nagrib${fhr}.out
GBTBLS  =
GBDIAG  =
ru

exit
EOF

gpend

export DBN_ALERT_TYPE=NAM_GEMPAK_NEST

cpfs $GEMGRD $COMAWP/.

if [ $SENDDBN = "YES" ] ; then
  $DBNROOT/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job ${COMAWP}/${GEMGRD}
fi

exit
