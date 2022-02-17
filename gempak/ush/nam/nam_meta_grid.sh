#! /bin/sh

#
# Metafile Script : nam_meta_grid
#
# Log :
# D.W.Plummer/NCEP   2/97   Add log header
# D.W.Plummer/NCEP  12/97   Added NGM v. NAM plot comparison if NGM precedes NAM
# J. Carr/HPC        8/98   Changed map to medium resolution
# J. Carr/HPC        1/99   Changed contur from 1 to 2 per OM request
# J. Carr/HPC        2/99   Changed skip to 0 per OM request
# B. Gordon/NCO      5/00   Ported to IBM-SP, Standardized for production,
#                           changed gdplot_nc -> gdplot2_nc
# D. Michaud/NCO     4/01   Added logic to display different titles for
#                           parallel runs.
# J. Carr/PMB       11/04   Changed contur parameter from 1 to a 2. 
#                           Added a ? to all title/TITLE lines.
#

cd $DATA

set -xa

device="nc | nam.meta"

PDY2=`echo $PDY | cut -c3-`

if [ "$envir" = "para" ] ; then
   export m_title="NAMP"
else
   export m_title="NAM"
fi


if [ $cyc -eq 00 -o $cyc -eq 12 ] ; then
  gdattim=F00-F${fend}-6
else
  gdattim=F00-F${fend}-3
fi

export pgm=gdplot2_nc;. prep_step; startmsg

$GEMEXE/gdplot2_nc > runlog << EOF
GDFILE	= F-NAM | ${PDY2}/${cyc}00
GDATTIM	= $gdattim
DEVICE	= $device
PANEL	= 0
TEXT	= 1/21//hw
CONTUR	= 2
MAP	= 1
CLEAR	= yes
CLRBAR  = 1

GAREA	= 105
PROJ	= str/90;-105;0
LATLON	= 0

restore ${USHgempak}/restore/pmsl_thkn.2.nts
CLRBAR  = 1
HLSYM   = 2;1.5//21//hw
TEXT    = 1/21//hw
TITLE	= 5/-2/~ ? $m_title PMSL, 1000-500 MB THICKNESS|~MSLP, 1000-500 THKN!0
l
ru

restore ${USHgempak}/restore/850mb_hght_tmpc.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
TITLE	= 5/-2/~ ? $m_title @ HGT, TEMP AND WIND (KTS)|~@ HGT, TMP, WIND!0!0!0
l
ru

restore ${USHgempak}/restore/700mb_hght_relh_omeg.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
TITLE	= 5/-2/~ ? $m_title @ HGT, REL HUMIDITY AND OMEGA|~@ HGT, RH AND OMEGA!0
l
ru

restore ${USHgempak}/restore/500mb_hght_absv.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
TITLE	= 5/-2/~ ? $m_title @ HGT AND VORTICITY|~@ HGT AND VORTICITY!0
l
ru

restore ${USHgempak}/restore/250mb_hght_wnd.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
TITLE	= 5/-2/~ ? $m_title HGT, ISOTACHS AND WIND (KTS)|~@ HGT AND WIND!0
l
ru

restore ${USHgempak}/restore/p06m_pmsl.2.nts
CLRBAR  = 1
HLSYM   = 2;1.5//21//hw
TEXT    = 1/21//hw
GDATTIM	= F06-F84-6
TITLE	= 5/-2/~ ? $m_title 6-HR TOTAL PCPN, MSLP|~6-HR TOTAL PCPN, MSLP!0
l
ru

restore ${USHgempak}/restore/precip.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
GDATTIM	= F12-F84-6
HILO    = 31;0/x#2////y
HLSYM   = 1.5
GDPFUN	= p12i 
TITLE	= 5/-2/~ ? $m_title 12-HR TOTAL PRECIPITATION (IN)|~12-HR TOTAL PCPN!0
l
ru

restore ${USHgempak}/restore/precip.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
GDATTIM	= F24-F84-6
HILO    = 31;0/x#2////y
HLSYM   = 1.5
GDPFUN	= p24i 
TITLE	= 5/-2/~ ? $m_title 24-HR TOTAL PRECIPITATION (IN)|~24-HR TOTAL PCPN!0
l
ru

restore ${USHgempak}/restore/precip.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
GDATTIM	= F48-F84-6
HILO    = 31;0/x#2////y
HLSYM   = 1.5
GDPFUN	= p48i 
TITLE	= 5/-2/~ ? $m_title 48-HR TOTAL PRECIPITATION (IN)|~48-HR TOTAL PCPN!0
l
ru

restore ${USHgempak}/restore/precip.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
GAREA   = 26.52;-119.70;50.21;-90.42
PROJ    = str/90;-105;0/3;3;0;1
MAP     = 1//2
GDATTIM	= F24-F84-6
HILO    = 31;0/x#2////y
HLSYM   = 1.5
GDPFUN	= p24i 
TITLE	= 5/-2/~ ? $m_title 24-HR TOTAL PRECIPITATION (IN)|~WEST: 24-HR PCPN
l
ru

restore ${USHgempak}/restore/precip.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
GAREA   = 24.57;-100.55;47.20;-65.42
PROJ    = str/90;-90;0/3;3;0;1
MAP     = 1//2
GDATTIM	= F24-F84-6
HILO    = 31;0/x#2////y
HLSYM   = 1.5
GDPFUN	= p24i 
TITLE	= 5/-2/~ ? $m_title 24-HR TOTAL PRECIPITATION (IN)|~EAST: 24-HR PCPN
l
ru

exit
EOF
export err=$?;err_chk
cat runlog

for fhr in f000 f006 f012 f018 f024 f030 f036 f042 f048
do
  grid1=$COMIN/nam_${PDY}${cyc}${fhr}
  grid2=${COMROOT:?}/nawips/${envir}/ngm.${PDY}/ngm_${PDY}${cyc}${fhr}

  if [ -f $grid2 ] ; then

    export pgm=gdplot2_nc;. prep_step; startmsg

    $GEMEXE/gdplot2_nc >runlog << EOF
    GDATTIM = $fhr
    DEVICE  = ${device}
    PANEL   = 0
    TEXT    = 1/21//hw
    CONTUR  = 2
    MAP     = 1
    CLEAR   = yes
    CLRBAR  = 1

    GAREA   = 105
    PROJ    = str/90;-105;0
    LATLON  = 0

    restore ${USHgempak}/restore/pmsl_thkn.nts
    GLEVEL  = 0
    GVCORD  = none
    PANEL   = 0                                                                       
    SKIP    = 0                                           
    SCALE   = 0
    GDPFUN  = sm5s(pmsl)
    TYPE    = c                                                                       
    CINT    = 4                                           
    FINT    =                                                                       
    FLINE   =                                                                       
    HLSYM   = 2;1.5//21//hw                                                           
    WIND    = 
    REFVEC  =                                                                       

    GDFILE  = $grid2
    LINE    = 5//3                                       
    HILO    = 5/H#;L#/1018-1070;900-1012//30;30/y
    TITLE   = 5/-2/~ ? NGM PMSL|~NGM & $m_title MSLP
    l
    ru

    clear   = no
    GDFILE  = $grid1
    LINE    = 6//3                                       
    HILO    = 6/H#;L#/1018-1070;900-1012//30;30/y
    TITLE   = 6/-1/~ ? $m_title PMSL 
    l
    ru

    GLEVEL  = 500                                                                     
    GVCORD  = PRES                                                                    
    PANEL   = 0                                                                       
    SKIP    = 0            
    SCALE   = -1           
    GDPFUN  = sm9s(hght)         
    TYPE    = c            
    CONTUR  = 2                                                                       
    CINT    = 6            
    FINT    = 
    FLINE   = 
    HLSYM   =                                                                         
    CLRBAR  = 1                                                                       
    WIND    =              
    REFVEC  =                                                                        
    TEXT    = 1/21//hw                                                                

    CLEAR   = yes
    GDFILE  = $grid2
    LINE    = 5//3
    HILO    = 5/H#;L#/588-700;300-586//30;30/y
    TITLE   = 5/-2/~ ? NGM @ HGT|~NGM & $m_title @ HGHT
    l
    ru

    CLEAR   = no
    GDFILE  = $grid1
    LINE    = 6//3
    HILO    = 6/H#;L#/588-700;300-586//30;30/y
    TITLE   = 6/-1/~ ? $m_title @ HGT
    l
    ru

EOF
  export err=$?;err_chk
  cat runlog
  fi
done

#####################################################
# GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
# WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
# FOR THIS CASE HERE.
#####################################################
ls -l nam.meta
export err=$?;export pgm="GEMPAK CHECK FILE";err_chk

if [ $SENDCOM = "YES" ] ; then
  mv nam.meta ${COMOUT}/nam_${PDY}_${cyc}
  if [ $SENDDBN = "YES" ] ; then
    $DBNROOT/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
     $COMOUT/nam_${PDY}_${cyc}
      if [ $DBN_ALERT_TYPE = "NAM_METAFILE_LAST" ] ; then
        DBN_ALERT_TYPE=NAM_METAFILE
        ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
        ${COMOUT}/nam_${PDY}_${cyc}
      fi
  fi
fi

#
