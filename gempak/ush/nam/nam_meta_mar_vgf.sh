#! /bin/sh
#
# Metafile Script : eta_meta_mar_vgf.sh
#
# Log :
# J. Carr/PMB    12/10/2004    Pushed into operations.
#
#
# Set up Local Variables
#
set -x
#
export PS4='OPC_MAR_VGF:$SECONDS + '
workdir="${DATA}/OPC_MAR_VGF"
mkdir ${workdir}
cd ${workdir}

cp $FIXgempak/datatype.tbl datatype.tbl

mdl=nam
MDL="NAM"
PDY2=`echo $PDY | cut -c3-`

export DBN_ALERT_TYPE=VGF
export DBN_ALERT_SUBTYPE=OPC

atlfilename="${mdl}_${PDY2}_${cyc}_4swatl.vgf"
pacfilename="${mdl}_${PDY2}_${cyc}_4swpac.vgf"

device1="vg|${atlfilename}"
device2="vg|${pacfilename}"

gdplot2_vg >runlog << EOFplt
GDFILE    = F-${MDL} | ${PDY2}/${cyc}00
GDATTIM   = f24
GAREA     = 25;-84;46;-38
PROJ      = str/90;-67;1
LATLON    = 
MAP       = 0
CLEAR     = y
DEVICE    = ${device1}
GLEVEL    = 0
GVCORD    = none
PANEL     = 0
SKIP      = 0
SCALE     = 0
GDPFUN    = sm5s(pmsl)
TYPE      = c
CONTUR    = 0
CINT      = 4
LINE      = 5/1/3/-5/2/.13
FINT      = 
FLINE     = 
HILO      =
HLSYM     =
CLRBAR    = 0
WIND      = 
REFVEC    =
TITLE     =
TEXT      = 1.3/21/2/hw
li
ru

GAREA	= 13.16;-134.88;77.09;166.47
PROJ    = str/90;-100;1
DEVICE  = ${device2}
CLEAR   = Y
l
run

exit
EOFplt
cat runlog

if [ $SENDCOM = "YES" ] ; then
    mv *.vgf ${COMOUT}
    if [ $SENDDBN = "YES" ] ; then
        ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} $job ${COMOUT}/${mdl}_${PDY2}_${cyc}_4swatl.vgf
        ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} $job ${COMOUT}/${mdl}_${PDY2}_${cyc}_4swpac.vgf
    fi
fi
exit

