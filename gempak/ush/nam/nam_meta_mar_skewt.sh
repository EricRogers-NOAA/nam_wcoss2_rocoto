#! /bin/sh
#
# Metafile Script : nam_meta_mar_skewt.sh
#
# Log :
# J. Carr/PMB     12/12/2004     Pushed into production.
#
# Set up Local Variables
#
set -x
#
export PS4='MAR_SKEWT:$SECONDS + '
mkdir $DATA/MAR_SKEWT
cd $DATA/MAR_SKEWT
cp $FIXgempak/datatype.tbl datatype.tbl
mdl=nam
MDL="NAM"
metatype="mar_skewt"
metaname="${mdl}_${metatype}_${cyc}.meta"
device="nc | ${metaname}"
PDY2=`echo $PDY | cut -c3-`

export DBN_ALERT_TYPE=NAM_METAFILE

for fhr in 000 006 012 018 024 030 036 042 048 054 060 066 072
do
    export pgm=gdprof;. prep_step; startmsg

gdprof >runlog << EOFplt
GDATTIM  = F${fhr}
GVCORD   = PRES
GDFILE   = F-${MDL}
GVECT    = wnd
LINE     = 2/1/2
MARKER   = 5/5/1
BORDER   = 1/1/1
PTYPE    = SKEW
SCALE    = 0
XAXIS    = -40/50/10/1;1;1
YAXIS    = 1050/100//1;1;1
WIND     = bk31/.8/1
REFVEC   = 
WINPOS   = 1
FILTER   = 0.8
PANEL    = 0
TEXT     = 1.2/22/2/hw
DEVICE   = $device
OUTPUT   = T
THTALN   = 18/1/1
THTELN   = 23/2/1
MIXRLN   = 23/9/1

! Buoy 44005
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 44005 (Gulf of Maine 42.9N 68.9W) SNDG|^ Buoy 44005 SNDG
GPOINT  = 42.9;-68.9
CLEAR   = yes
ru

GFUNC   = dwpc
LINE    = 4/1/2
CLEAR   = no
ru

! Buoy 44011
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 44011 (George's Bank 41.1N 66.6W) SNDG|^ Buoy 44011 SNDG
GPOINT  = 41.1;-66.6
CLEAR   = yes
ru

GFUNC   = dwpc
LINE	= 4/1/2
CLEAR   = no
ru

! Buoy 44008
GFUNC   = tmpc
LINE    = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 44008 (Nantucket Shoals 40.5N 69.4W) SNDG|^ Buoy 44008 SNDG
GPOINT  = 40.5;-69.4
CLEAR   = yes
ru

GFUNC   = dwpc
LINE	= 4/1/2
CLEAR   = no
ru

!Buoy 44004
GFUNC   = tmpc
LINE    = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 44004 (Hotel 38.5N 70.7W) SNDG|^ Buoy 44004 SNDG
GPOINT  = 38.5;-70.7
CLEAR   = yes
ru

GFUNC   = dwpc
LINE	= 4/1/2
CLEAR   = no
ru

! Buoy 44009
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 44009 (Delaware Bay 38.5N 74.7W) SNDG|^ Buoy 44009 SNDG
GPOINT  = 38.5;-74.7
CLEAR   = yes
ru

GFUNC   = dwpc
LINE	= 4/1/2
CLEAR   = no
ru

!Buoy 44014
GFUNC   = tmpc
LINE    = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 44014 (VA Beach 36.6N 74.8W) SNDG|^ Buoy 44014 SNDG
GPOINT  = 36.6;-74.8
CLEAR   = yes
ru

GFUNC   = dwpc
LINE    = 4/1/2
CLEAR   = no
ru

! Buoy 41001
GFUNC   = tmpc
LINE	= 2/1/2
TITLE   = 5//~ ? ${MDL} @ 41001 (E.Hatteras 34.7N 72.6W) SNDG|^ Buoy 41001 SNDG
GPOINT  = 34.7;-72.6
CLEAR   = yes
ru

GFUNC   = dwpc
LINE	= 4/1/2
CLEAR   = no
ru

! C-man FPSN7
GFUNC   = tmpc
LINE    = 2/1/2
TITLE   = 5//~ ? ${MDL} @ FPSN7 (Frying Pan Shoals 33.5N 77.5W) SNDG|^ C-man FPSN7 SNDG
GPOINT  = 33.5;-77.5
CLEAR   = yes
ru

GFUNC   = dwpc
LINE    = 4/1/2
CLEAR   = no
ru

! Buoy 41002
GFUNC   = tmpc
LINE	= 2/1/2
TITLE   = 5//~ ? ${MDL}  @ 41002 (S.Hatteras 32.3N 75.2W) SNDG|^ Buoy 41002 SNDG
GPOINT  = 32.3;-75.2
CLEAR   = yes
ru

GFUNC   = dwpc
LINE	= 4/1/2
CLEAR   = no
ru

! Buoy 41008
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 41008 (NE Georgia 31.4N 80.9W) SNDG|^ Buoy 41008 SNDG
GPOINT  = 31.4;-80.9
CLEAR   = yes
ru

GFUNC   = dwpc
LINE	= 4/1/2
CLEAR   = no
ru

! TXKF - Bermuda
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL} @ Bermuda SNDG|^ Bermuda SNDG
GPOINT  = TXKF
CLEAR   = yes
ru

GFUNC   = dwpc
LINE	= 4/1/2
CLEAR   = no
ru

! Buoy 46001
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL}  @ 46001 (Gulf of Alaska 56.3N 148.2W) SNDG|^ Buoy 46001 SNDG
GPOINT  = 56.3;-148.2
CLEAR   = yes
ru

GFUNC   = dwpc
LINE	= 4/1/2
CLEAR   = no
ru

! Buoy 46036
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 46036 (NW OFSHR 48.4N 133.9W) SNDG|^ Buoy 46036 SNDG
GPOINT  = 48.4;-133.9
CLEAR   = yes
ru

GFUNC   = dwpc
LINE    = 4/1/2
CLEAR   = no
ru

! Buoy 46005
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 46005 (Washington 46.0N 131.0W) SNDG|^ Buoy 46005 SNDG
GPOINT  = 46.0;-131.0
CLEAR   = yes
ru

GFUNC   = dwpc
LINE    = 4/1/2
CLEAR   = no
ru

! Buoy 46002
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 46002 (Oregon 42.5N 130.3W) SNDG|^ Buoy 46002 SNDG
GPOINT  = 42.5;-130.3
CLEAR   = yes
ru

GFUNC   = dwpc
LINE	= 4/1/2
CLEAR   = no
ru

! Buoy 46006
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 46006 (N Cal - West 41N 138W) SNDG|^ Buoy 46006 SNDG
GPOINT  = 41.0;-138.0
CLEAR   = yes
ru

GFUNC   = dwpc
LINE    = 4/1/2
CLEAR   = no
ru

! Buoy 46059
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 46059 (Pt. Arena 38N 130W) SNDG|^ Buoy 46059 SNDG
GPOINT  = 38.0;-130
CLEAR   = yes
ru

GFUNC   = dwpc
LINE	= 4/1/2
CLEAR   = no
ru

! Buoy 46023
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL} @ 46023 (Pt Conception 34.3N 120.7W) SNDG|^ Buoy 46023 SNDG
GPOINT  = 34.3;-120.7
CLEAR   = yes
ru

GFUNC   = dwpc
LINE	= 4/1/2
CLEAR   = no
ru

! S Cal - West
GFUNC   = tmpc
LINE     = 2/1/2
TITLE   = 5//~ ? ${MDL} @ (S Cal - West 32N 122W) SNDG|^ S. Cal. SNDG
GPOINT  = 32.0;-122.0
CLEAR   = yes
ru

GFUNC   = dwpc
LINE    = 4/1/2
CLEAR   = no
ru
exit
EOFplt
cat runlog
done
gpend

export err=$?;err_chk
#####################################################
# GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
# WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
# FOR THIS CASE HERE.
#####################################################
ls -l $metaname
export err=$?;export pgm="GEMPAK CHECK FILE";err_chk

if [ $SENDCOM = "YES" ] ; then
   mv ${metaname} ${COMOUT}/${mdl}_${PDY}_${cyc}_${metatype}
   if [ $SENDDBN = "YES" ] ; then
      ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job ${COMOUT}/${mdl}_${PDY}_${cyc}_${metatype}
   fi
fi



exit
