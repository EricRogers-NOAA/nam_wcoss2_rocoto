#! /bin/sh
#
# Metafile Script : nam20_meta_qpf.sh
#
# Log :
# J. Carr/HPC    02/28/2001    New script for the 20 km NAM.
# J. Carr/HPC        5/2001    Added a mn variable for a/b side dbnet root variable.
# J. Carr/HPC        6/2001    Expanded times until f084
# J. Carr/HPC        6/2001    Converted to a korn shell prior to delivering script to Production.
# J. Carr/HPC        7/2001    Submitted.
# J. Carr/PMB       11/2004    Added a ? in all title lines.
#
# Set up Local Variables
#
set -x
#
export PS4='nam20:$SECONDS + '
mkdir $DATA/nam20
cd $DATA/nam20
cp $FIXgempak/datatype.tbl datatype.tbl

mdl=nam20
MDL=NAM20
metatype="qpf"
metaname="${mdl}_${metatype}_${cyc}.meta"
device="nc | ${metaname}"
PDY2=`echo $PDY | cut -c3-`
#
    gdat="F000-F084-06"
    gdatpcpn06="F006-F084-06"
    gdatpcpn12="F012-F084-06"
    gdatpcpn24="F024-F084-06"
    gdatpcpn48="F048-F084-06"
    gdatpcpn60="F060-F084-06"
    gdatpcpn72="F072-F084-06"
    gdatpcpn84="F084"
    run="r"

export pgm=gdplot2_nc;. prep_step; startmsg

gdplot2_nc >runlog << EOFplt
gdfile   = F-${MDL} | ${PDY2}/${cyc}00
GAREA    = us
proj     = 
map      = 1/1/2/yes
latlon   = 0
skip     = 0/1
device   = ${device}
gdattim  = ${gdat}
text     = m/22/2/hw
clear    = y
filter   = y
panel    = 0
contur   = 2

gdattim  = ${gdatpcpn06}
glevel   = 0   !0
gvcord   = none!none
scale    = 0   !0
gdpfun   = p06i!sm5s(sm5s(pmsl)
type     = f   !c
cint     =     !4
line     =     !17/1/3
fint     = .01;.1;.25;.5;.75;1;1.25;1.5;1.75;2;2.5;3;4;5;6;7;8;9
fline    = 0;21-30;14-20;5
hilo     = 31;0/x#2/.15-20/100;100/7!17/H#;L#/1020-1070;900-1012/7
hlsym    = 1.5!1.5;1.5//22;22/2;2/hw
clrbar   = 1
wind     = bk0
refvec   =
title    = 1/0/~ ? ${MDL} 6-HOUR TOTAL PCPN, PMSL |~6-HR TOTAL PCPN!0
r

gdpfun   = c06i!sm5s(sm5s(pmsl)
title    = 1/0/~ ? ${MDL} 6-HOUR CONV PCPN, PMSL |~6-HR CONV PCPN!0
${run}

gdattim  = ${gdatpcpn12}
gdpfun   = p12i
title    = 1/0/~ ? ${MDL} 12-HOUR TOTAL PCPN|~12-HR TOTAL PCPN!0
${run}

gdattim  = ${gdatpcpn24}
gdpfun   = p24i
title    = 1/0/~ ? ${MDL} 24-HOUR TOTAL PCPN|~24-HR TOTAL PCPN!0
${run}

gdattim  = ${gdatpcpn48}
gdpfun   = p48i
title    = 1/0/~ ? ${MDL} 48-HOUR TOTAL PCPN|~48-HR TOTAL PCPN!0
${run}

gdattim  = ${gdatpcpn60}
gdpfun   = p60i
title    = 1/0/~ ? ${MDL} 60-HOUR TOTAL PCPN|~60-HR TOTAL PCPN!0
${run}

gdattim  = ${gdatpcpn72}
gdpfun   = p72i
title    = 1/0/~ ? ${MDL} 72-HOUR TOTAL PCPN|~72-HR TOTAL PCPN!0
${run}

gdattim  = ${gdatpcpn84}
gdpfun   = p84i
title    = 1/0/~ ? ${MDL} 84-HOUR TOTAL PCPN|~84-HR TOTAL PCPN!0
${run}

exit
EOFplt
export err=$?;err_chk
cat runlog

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
      ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
      ${COMOUT}/${mdl}_${PDY}_${cyc}_${metatype}
      if [ $DBN_ALERT_TYPE = "NAM_METAFILE_LAST" ] ; then
        DBN_ALERT_TYPE=NAM_METAFILE
        ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
        ${COMOUT}/${mdl}_${PDY}_${cyc}_${metatype}
      fi
   fi
fi

exit
