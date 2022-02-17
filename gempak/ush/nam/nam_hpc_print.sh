#! /bin/sh
#
# Metafile Script : nam_hpc_print
#
# NOTE: SCRIPT IS OPERATIONAL FOR THE HPC FORECASTERS.
#
# Log :
# J. Carr/HPC         11/05/2001     New script. Used to generate 4-panel postscript files and
#                                    send them to an HPC printer using dbnet.
# J. Carr/HPC         11/14/2001     Submitted Jif.
# J. Carr/HPC         06/13/2002     Re-submitted Jif.
# J. Carr/PMB         11/09/2004     Added a ? to all title lines. Changed contur parameter to a 2.
#
# Set up Local Variables
set -x
#
# mn is machine name a side or b side ( a or b )
export PS4='HPC_PRINT:$SECONDS + '
mn=`hostname | cut -c1`
mdl=nam
MDL=NAM
#PDY=$1
#cyc=$cyc
# fend=$3
fend=$fhr
export COMIN=${COMROOT:?}/nawips/${envir:?}/${mdl}.${PDY}
export DBN_ALERT_TYPE=PRINT
export DBN_ALERT_SUBTYPE=HPC_PS
export DBN_JOBNAME=SENDPS
export METAOUT=$COMOUT
PDY2=`echo $PDY | cut -c3-`

# MAKE A WORKING DIRECTORY AND CHANGE TO IT.
workdir=$DATA/nam_4pnl_print
mkdir -p ${workdir}
cd ${workdir}
psfile="${mdl}_4pnl_${fend}.plt"

# Copy in datatype table to define gdfile type
set -x

cp /nwprod/gempak/fix/datatype.tbl datatype.tbl

# ONLY RUN AT 12 AND 00 UTC.

if [ ${cyc} -eq "12" ] ; then
    fcsthr=${fend}
elif [ ${cyc} -eq "00" ] ; then
    fcsthr=${fend}
else
    exit 0
fi

if [ ${fend} -eq "006" ] ; then
    exit
elif [ ${fend} -eq "018" ] ; then
    exit 
elif [ ${fend} -eq "030" ] ; then
    exit
elif [ ${fend} -eq "042" ] ; then
    exit
elif [ ${fend} -eq "054" ] ; then
    exit
elif [ ${fend} -eq "066" ] ; then
    exit
elif [ ${fend} -eq "078" ] ; then
    exit
fi

gdplot2 >runlog << EOF
\$MAPFIL = mepowo.gsf
gdfile   = F-${MDL} | ${PDY2}/${cyc}00
GAREA    = 18.0;-128.2;50.3;-40.5
PROJ     = STR/90.0;-105.0;0.0
LATLON   = 5/10/1/1/5;5
map      = 7/1/2/yes
skip     = 0
device   = ps|${psfile}|17;11|g
gdattim  = F${fend}

GLEVEL   = 500:1000      !500:1000      !0
GVCORD   = pres          !pres          !none
SKIP     = 0
SCALE    = -1            !-1            !0
GDPFUN   = sm5s(ldf(hght)!sm5s(ldf(hght)!sm5s(pmsl)
TYPE     = c
CONTUR   = 2
CINT     = 6//540        !6/546         !4
LINE     = 1/2/5/1/2/.05 !1/2/2/1/2/.05 !1/1/5/1/2/.05
FINT     =
FLINE    =
HILO     = 0             !0             !1;1/H#;L#/1020-1090;900-1016/5/30;30/y
HLSYM    = 0             !0             !1.1;1.1//22/8/hw
CLRBAR   = 0
WIND     = bk0
REFVEC   =
TEXT     = t/22/////hw   !t/22/////hw   !s/22/////hw
STNPLT   =
PANEL    = 3
TITLE    = 0!0!1/-2/~ ? ${MDL} PMSL/1000-500 THICK (${cyc}Z)!0
clear    = yes
r

GLEVEL   = 500
GVCORD   = pres 
panel    = 1
SCALE    = 5                  !-1
GDPFUN   = avor(wnd)          !sm5s(hght)
TYPE     = c/f                !c
CINT     = 2/6/14             !6
LINE     = 1/12/2/2/2/.05     !1/1/5/1/2/.05
FINT     = 14;18;22;26;30     !
FLINE    =  0;18;16;14;12;10  !
HILO     = 1;1/X;N/10-99;10-99!0
HLSYM    = .7//21/2/hw        !
CLRBAR   = 1/v/ll/.10;.05
WIND     = 0
clear    = no
TEXT     = t/22/////hw        !m/22/////hw
TITLE    = 0!1/-2/~ ? ${MDL} 500 MB HGT AND ABS VORT (${cyc}Z)!0
r

GAREA    = 21.27;-120.35;48.21;-50.57
PROJ     = STR/90.0;-105.0;0.0
PANEL    = 2
GLEVEL	 = 4700:10000   !700           !700:500       !700:500
GVCORD	 = SGMA         !PRES          !PRES          !PRES
SCALE	 = 0            !-1            !3             !3
GDPFUN   = sm5s(relh)   !sm5s(hght)    !sm5s(lav(omeg)!sm5s(lav(omeg)
TYPE	 = f            !c
CINT	 = 0            !3             !3;5;7;9;11    !-3;-5;-7;-9;-11;-13;-15
LINE	 = 0            !1/1/5/1/2/.05 !8/10/4/1/2/.05!1/2/4/1/2/.05
FINT	 = 50;70;90
FLINE	 = 0;18;16;14
title    = 0!1/-2/~ ? ${MDL} 1000-470 MB RH,700 HGT,700-500 VV (${cyc}Z)!0!0
HILO     = 0            !1;1/H;L//5!0
HLSYM    = 0            !1.2//22/2/hw!0
TEXT     = s/22/////hw  !s/22/////hw   !t/22/////hw   !t/22/////hw
LATLON   = 0
r

glevel   = 0     !850       !30:0 
gvcord   = none  !pres      !pdly
scale    = 0     !0  
gdpfun   = p12i  !sm5s(tmpc)!sm5s(tmpc)
type     = c/f   !c
skip     = 0     !0
cint     = .01;.10;.25; .5; 1;1.5; 2;2.5; 3;4!0;200!0;200
line     = 10/1/1/1!1/1/5/1/2/.05!1/2/5/1/2/.05
fint     = .01;.10;.25; .5; 1;1.5; 2;2.5; 3;4
fline    =   0; 19; 18; 17;15; 13;11;  9; 7;5;4 
hilo     = 1;0/x#2/.15-7.0///y!0
hlsym    = 1//22/2/hw!0
wind     = bk0
TEXT     = t/22/////hw!s/22/////hw!m/22/////hw
refvec   =
title    = 0!0!1/-2/~ ? ${MDL} 12-HR PCPN,850 MB TMP(SOLID),BL TMP(DASH)!0
filter   = yes
panel    = 4
CLRBAR   = 0
r

ex
EOF
cat runlog

gpend

if [ $SENDCOM = "YES" ] ; then
   mv ${psfile} ${COMOUT}/${psfile}
   if [ $SENDDBN = "YES" ] ; then
      ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} ${DBN_JOBNAME} ${COMOUT}/${psfile}
   fi
fi

fend=$fhr


if [ fend -eq 048 ] ; then
    echo " "
    echo "Forecast hour 48"
    echo " "

#
# Set up Local Variables
#
# mn is machine name a side or b side ( a or b )
mn=`hostname | cut -c1`
mdl=nam
MDL=NAM
export COMIN=${COMROOT:?}/nawips/${envir:?}/${mdl}.$PDY
export DBN_ALERT_TYPE=PRINT

export DBN_ALERT_SUBTYPE=HPC_PS
export DBN_JOBNAME=SENDVGF
export METOUT=$COMOUT
PDY2=`echo $PDY | cut -c3-`
#
# MAKE A WORKING DIRECTORY
workdir=$DATA/nam_print_250
mkdir -p ${workdir}
cd ${workdir}
#
# Copy in datatype table to define gdfile type
#

cp /nwprod/gempak/fix/datatype.tbl datatype.tbl
#
# SET THE DEFAULT PRINTER UP FOR THE HPC
#
psfile="${mdl}_250.plt"

gdplot2 >runlog << EOF
\$MAPFIL = mepowo.gsf
gdfile   = F-${MDL} | ${PDY2}/${cyc}00
GAREA    = 23.14;-121.39;46.71;-57.54
PROJ     = STR/90.0;-105.0;0.0
skip     = 0
device   = ps|${psfile}|17;11|g
gdattim  = F12
map      = 7/1/2/yes
!latlon   = 5/10/1/1/5;5
latlon   = 0

GLEVEL   = 250
GVCORD   = pres
SCALE    = 0                      !0            ! -1
skip     = 0                      !0            !0         !0/4;4
GDPFUN   = knts(mag(wnd)          !knts(mag(wnd)!sm5s(hght)!kntv(wnd)
TYPE     = c/f                    !c            !c         !b
CINT     = 10/70                  !10;30;50;70  !12
LINE     = 1/2/4/1/2/.05          !1/2/4/1/2/.05!1/1/6/1/2/.05
FINT     = 70;90;110;130;150;170;190;210
FLINE    =  0;20; 18; 16; 14; 12; 10;  8;6
HILO     = 0                      !0            !1/H#;L#//5
HLSYM    = 0                      !0            !1;1//22;22/2;2/hw
CLRBAR   = 1
WIND     = bk0                    !bk0          !bk0        !bk10/.5/1/112
REFVEC   =
TITLE    = 0!0!1/-2/~ ? ${MDL} @ HEIGHTS, ISOTACHS AND WIND (KTS)!0
PANEL    = 1
clear    = yes
filter   = no
TEXT     = t/22/////hw!t/22/////hw!m/22/////hw!t/22/////hw
r

clear    = no
panel    = 2
gdattim  = f24
TITLE    = 0!0!1/-2/~ ? ${MDL} @ HEIGHTS, ISOTACHS AND WIND (KTS)!0
r

panel    = 3
gdattim  = f36
TITLE    = 0!0!1/-2/~ ? ${MDL} @ HEIGHTS, ISOTACHS AND WIND (KTS)!0
r

panel    = 4
gdattim  = f48
title    = 0!0!1/-2/~ ? ${MDL} 250 MB HGT,ISOTACHS & WIND (${cyc}Z RUN)!0
r

ex
EOF
cat >runlog

gpend

if [ $SENDCOM = "YES" ] ; then
   mv ${psfile} ${COMOUT}/${psfile}
   if [ $SENDDBN = "YES" ] ; then
      ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} ${DBN_JOBNAME} ${COMOUT}/${psfile}
   fi
fi

# mn is machine name a side or b side ( a or b )
mn=`hostname | cut -c1`
mdl=nam
MDL=NAM
export COMIN=${COMROOT:?}/nawips/${envir:?}/${mdl}.${PDY}
export DBN_ALERT_TYPE=PRINT
export DBN_ALERT_SUBTYPE=HPC_PS
export DBN_JOBNAME=SENDVGF
export METAOUT=$COMOUT
PDY2=`echo $PDY | cut -c3-`

psfile="${mdl}_850.plt"

# MAKE A WORKING DIRECTORY
workdir=$DATA/nam_print_850
mkdir -p ${workdir}
cd ${workdir}
#
# Copy in datatype table to define gdfile type
#
cp /nwprod/gempak/fix/datatype.tbl datatype.tbl

#
gdplot2 >runlog << EOF10
\$MAPFIL = mepowo.gsf
gdfile   = F-${MDL} | ${PDY2}/${cyc}00
!GAREA    = 21.27;-120.35;48.21;-50.57
PROJ     = STR/90.0;-105.0;0.0
GAREA    = 23.14;-121.39;46.71;-57.54
skip     = 0
device   = ps|${psfile}|17;11|g
gdattim  = F12
map      = 7/1/2/yes
latlon   = 0
TEXT     = m/22/////hw

GLEVEL   = 850
GVCORD   = pres
SCALE    = 0            !0             !0             !-1
GDPFUN   = sm5s(tmpc)   !sm5s(tmpc)    !sm5s(tmpc)    !sm5s(hght)
TYPE     = c            !c             !c             !c
CINT     = 3/-99/0      !3/3/18        !3/21/99       !3
LINE     = 1/2/7/1/2/.05!14/2/3/1/2/.05!10/8/5/1/2/.05!1/1/6/1/2/.05
FINT     = 0!
FLINE    = 0!
HILO     = 0            !0             !0             !1/H#;L#//5
HLSYM    = 0            !0             !0             !1;1//22;22/2;2/hw
CLRBAR   = 1
WIND     = bk0
REFVEC   =
TITLE    = 1/-2/~ ? ${MDL} @ HGT & TEMP!0
PANEL    = 1
clear    = yes
r

clear    = no
panel    = 2
gdattim  = f24
TITLE    = 1/-2/~ ? ${MDL} @ HGT & TEMP!0
r

panel    = 3
gdattim  = f36
TITLE    = 1/-2/~ ? ${MDL} @ HGT & TEMP!0
r

panel    = 4
gdattim  = f48
title    = 1/-2/~ ? ${MDL} (${cyc} RUN)!0
r

ex

EOF10
cat runlog

gpend

if [ $SENDCOM = "YES" ] ; then
   mv ${psfile} ${COMOUT}/${psfile}
   if [ $SENDDBN = "YES" ] ; then
      ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} ${DBN_JOBNAME} ${COMOUT}/${psfile}
   fi
fi


else
    echo 'done this fcst hr'
fi

exit

