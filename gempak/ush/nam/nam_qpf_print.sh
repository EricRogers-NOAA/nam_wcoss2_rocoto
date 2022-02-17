#! /bin/sh
#
# Metafile Script : nam_qpf_print
#
# Log :
# J. Carr/HPC        11/05/2001     New script to print nam qpf for HPC.
# J. Carr/HPC        11/14/2001     Submitted Jif.
# J. Carr/PMB        11/10/2004     Added a ? in all title/TITLE lines.
# M. Klein/HPC       07/25/2007     Stop printing of 06Z and 18Z QPF plots.
#
# Set up Local Variables
#
set -x
echo "============================"
echo " start with nam_qpf_print.sh"
# If this is a non-production run, specify in graphic title.
if [ $envir = "para" ]
then
   MDL=NAMP
else
   MDL=NAM
fi
echo "Running in the ${envir} environment."
mdl=nam
# PDY=$1
# cyc=$2
fhrend=$fhr
# export COMIN=/com/nawips/prod/${mdl}.${PDY}
export DBN_ALERT_TYPE=PRINT
export DBN_ALERT_SUBTYPE=HPC_PS
export DBN_JOBNAME=SENDPS
# export METAOUT=/nfsuser/hpcops/meta/${mdl}
export METAOUT=$COMOUT
PDY2=`echo $PDY | cut -c3-`

# CREATE A WORKING DIRECTORY AND SWITCH TO IT
# workdir="/nfsuser/hpcops/tmp/${mdl}/${mdl}_psqpf_day1"
workdir=$DATA/nam_qpf_print
mkdir -p ${workdir}
cd ${workdir}
#
# Copy in datatype table to define gdfile type
#
cp /nwprod/gempak/fix/datatype.tbl datatype.tbl

if [ ${cyc} -eq "00" -o ${cyc} -eq "12" ] ; then
   if [ ${fhrend} -eq "036" ] ; then
      fcsthr="036"
   elif [ ${fhrend} -eq "060" ] ; then
      fcsthr="060"
   elif [ ${fhrend} -eq "084" ] ; then
      fcsthr="084"
   else
      exit
   fi
else
   echo "Do not print the off-hour QPFs"
   exit 0 
fi  

# TEST FOR EXISTENCE OF THE GRID
dhour=`date -u "+%H"`
dmin=`date -u "+%M"`
exist="no"
psfile="${mdl}qpf_${fcsthr}.plt"
device="ps|${psfile}"

$GEMEXE/gdplot2 >runlog << EOF
gdfile   = F-${MDL} | ${PDY2}/${cyc}00
MAP      = 1/1/5/yes
GAREA    = us
PROJ     =
latlon   = 0
skip     = 0
device   = ${device}
gdattim  = f${fcsthr}

GLEVEL   = 0
GVCORD   = none
PANEL    = 0
SCALE    = 0
GDPFUN   = p24i!p24i
TYPE     = f   !c
CONTUR   = 2
CINT     = 0   !.01;.1;.25;.5; 1;1.5;2;2.5;3; 4; 5
LINE     = 0   !1/1/1
FINT     = .01;.1;.25;.5; 1;1.5; 2;2.5; 3; 4; 5; 6; 7; 8;9!0
FLINE    =   0;19; 16;13;10;  7; 4; 19;16;13;10; 7; 4;19;16;13!0
HILO     = 0   !1;0/x#2/.10-10/2/100;100/y
HLSYM    = 0   !l//22/3/hw
CLRBAR   = 1   !0
WIND     =
REFVEC   =
TITLE    = 1/-2/~ ? ${MDL} 24-HOUR TOTAL PCPN |~ 24-HOUR TOTAL PCPN!0
TEXT     = h/22/1/hw!s/2/1/hw
CLEAR    = YES
STNPLT   =
SATFIL   =
RADFIL   =
LUTFIL   =
STREAM   =
POSN     = 0
COLORS   = 0
MARKER   = 0
GRDLBL   = 0
run

exit
EOF
cat runlog
gpend

if [ $SENDCOM = "YES" ] ; then
   mv ${psfile} ${COMOUT}/${psfile}
   if [ $SENDDBN = "YES" ] ; then
      ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} ${DBN_JOBNAME} ${COMOUT}/${psfile}
   fi
fi
exit
