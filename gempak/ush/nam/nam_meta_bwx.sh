#! /bin/sh
#
# Metafile Script : nam_meta_bwx_new
#
# Log :
# D.W.Plummer/NCEP   2/97   Add log header
# J.W.Carr/HPC     4/8/97   Added pcpn type amount product
# J.W.Carr/HPC     4/8/97   Removed it and put it in the qpf group
# J.W.Carr/HPC     4/8/97   Added frontogenesis product
# J.W.Carr/HPC   12/11/97   converted to gdplot2
# J.W.Carr/HPC   08/06/98   Changed to medium map resolution
# J.W.Carr/HPC   05/05/99   Added cross totals for Bruce Sullivan
# J. Carr/HPC     6/21/99   Added a filter on map
# J. Carr/HPC     1/27/2000 Removed 250 vort & pw product. Removed pv products. Added a pcpn type product.
#                           Edited the great lakes product.
# J. Carr/HPC     3/31/2000 Edited to add 60 hr time step.
# J. Carr/HPC        5/2001 Added a mn variable for a/b side dbnet root variable.
# J. Carr/HPC        6/2001 Converted to a korn shell prior to delivering script to Production.
# J. Carr/HPC        7/2001 Submitted.
# J. Carr/PMB       11/2004 Added a ? to all title lines. Changed contur parameter to a 2.
#
# Set up Local Variables
#
set -x
#
export PS4='BWX:$SECONDS + '
mkdir $DATA/BWX
cd $DATA/BWX
cp $FIXgempak/datatype.tbl datatype.tbl

PDY2=`echo $PDY | cut -c3-`

if [ "$envir" = "para" ] ; then
   export m_title="NAMP"
else
   export m_title="NAM"
fi

mdl=nam
MDL=NAM
metatype="bwx"
metaname="${mdl}_${metatype}_${cyc}.meta"
device="nc | ${metaname}"
#
# SET VARIABLE BASED ON CYCLE.
#
gdattim="F00-F84-06"
#

export pgm=gdplot2_nc;. prep_step; startmsg

gdplot2_nc >runlog << EOFplt
gdfile   = F-${MDL} | ${PDY2}/${cyc}00
gdattim  = ${gdattim}
CONTUR	 = 2
clear    = y
garea    = bwus
proj     = 
MAP      = 1/1/1/yes 
latlon   = 0
device   = ${device} 
text     = 1/22/2/hw
panel    = 0
skip     = 0

glevel   = 9823!9823!9823
gvcord   = sgma!sgma!sgma
scale    = 0
gdpfun   = sm5s(thte(pres;tmpc;dwpc)!sm5s(thte(pres;tmpc;dwpc)!sm5s(thte(pres;tmpc;dwpc)!kntv(wnd)
type     = c/f                      !c         !c!b
cint     = 4/200/308                !4/312/324 !4/328
line     = 16/1/1                   !2/1/3     !32/1/2/1
fint     = 328;336;344;352;360;368
fline    = 0;24;30;29;15;18;20
hilo     = 
hlsym    = 
clrbar   = 1/V/LL!0
wind     = !!!bk9/0.7/2/112
refvec   = 
title    = 1/0/~ ? ${MDL} BL(18MB AGL) THTE & WIND (KTS)|~BL THTE & WIND!0
filter   = y
r

glevel   = 9823!9823!9823!0!9823
gvcord   = sgma!sgma!sgma!none!sgma
gdpfun   = sm5s(tmpc)!sm5s(tmpc)!sm5s(tmpc)!sm5s(pmsl)!kntv(wnd)
type     = c/f!c!c!c!b
cint     = 3/-99/0!3/3/18!3/21/99!4
line     = 27/1/2!2/1/2!16/1/2!19//3
fint     = -24;-12;0 !
fline    = 29;30;24;0 !
hilo     = 0!0!0!20/H#;L#/1020-1070;900-1014
hlsym    = 0!0!0!1.3;1.3//22;22/3;3/hw
clrbar   = 1/V/LL!0
wind     = bk0!bk0!bk0!bk0!bk9/0.7/2/112
title    = 1/-1/~ ? ${MDL} PMSL,BL TMP,WND (KTS)(18MB AGL)|~PMSL,BL TMP,WND!0
r

GLEVEL   = 1000!1000!0!1000
GVCORD   = pres!pres!none!pres
SKIP     = 0/1
SCALE    = 1                        !0           !0
GDPFUN   = sm5s(frnt(tmpf,wnd))//fr !sm5s(tmpf)  !sm5s(pmsl)!kntv(wnd)
TYPE     = c/f                      !c           !c         !b
CINT     = 10                       !4           !4
LINE     = 32/1/2/1                 !2/1/2       !6/1/2/1
FINT     = -50;-35;-20;-5;5;20;35;50
FLINE    = 29;30;25;24;0;23;22;14;20
HILO     = !!6/H#;L#/1020-1070;900-1012
HLSYM    = !!1.5;1.5//22;22/3;3/hw
CLRBAR   = 1
WIND     = !!!bk9/0.6/2/121/.6
REFVEC   =
TITLE    = 1/-1/~ ? ${MDL} PMSL, 1000 MB TMP (F), FRONTOGENESIS (F)|~@ FRONTOGENESIS!0
r
 
glevel	 = 700     !700       !0
gdpfun   = kinx    !sm5s(tmpc)!sm5s(pmsl)
gvcord	 = pres    !pres      !none
scale	 = 0
type	 = c/f     !c
cint	 = 3/15/60 !2/6       !4
line	 = 32/1/2/2!5/10/3    !6/1/2
fint	 = 15;24;33;42
fline	 = 0;24;30;14;2
hilo	 = 0       !0         !6/H#;L#/1020-1070;900-1012
hlsym	 = 0       !0         !1.5;1.5//22;22/3;3/hw
clrbar	 = 1/V/LL  !0
wind	 =
refvec	 =
title	 = 1/-1/~ ? ${MDL} K INDEX, 700 MB TMP, PMSL|~K INDEX!0
r

GLEVEL   = 0         !700       !0
GVCORD   = none      !pres      !none
PANEL    = 0
SKIP     = 0
SCALE    = 0
GDPFUN   = sm5s(ctot)!sm5s(tmpc)!sm5s(pmsl)
TYPE     = f         !c
CINT     = 2/16/36   !2/6       !4
LINE     = 0         !5/10/3    !6/1/2
FINT     = 16;20;24;28
FLINE    = 0;24;30;14;2
HILO     = 0         !0         !6/H#;L#
HLSYM    = 0         !0         !1.5;1.5//22;22/3;3/hw
CLRBAR   = 1/V/LL    !0
WIND     = bk0
REFVEC   = 
TITLE    = 1/0/~ ? ${MDL} CT INDEX, 700 MB TEMP (>6 C), MSLP|~CT INDEX!0
r

glevel   = 0   !500:1000       !500:1000       !0
gvcord   = none!pres           !pres           !none 
scale    = 0   !-1             !-1             !0 
gdpfun   = p06i!sm5s(ldf(hght))!sm5s(ldf(hght))!sm5s(pmsl)
type     = f   !c              !c
cint     =     !3/0/540        !3/543/1000     !4
line     =     !4/5/2          !2/5/2          !19//3  
fint     = .01;.1;.25;.5;.75;1;1.25;1.5;1.75;2;2.5;3;4;5;6;7;8;9
fline    = 0;21-30;14-20;5
hilo     = 0   !0              !0!19/H#;L#/1020-1070;900-1012
hlsym    = 0   !0              !0!1.3;1.3//22;22/3;3/hw
clrbar   = 1
wind     = 
refvec   = 
title    = 1/-1/~ ? ${MDL} 6-H PCPN, PMSL, 1000-500 MB THK|~6-H PCPN & 1000-500 THK!0
r

GLEVEL	 = 700 !700 !700 !850 !850 !30:0!30:0
GVCORD	 = PRES!PRES!PRES!PRES!PRES!pdly!pdly
SCALE	 = 0 
GDPFUN	 = sm5s(relh) !sm5s(tmpc)!sm5s(tmpc)!sm5s(tmpc)!sm5s(tmpc)!sm5s(tmpc)!sm5s(tmpc)
TYPE	 = c/f        ! c
CINT	 = 50;70;90;95!2;-2 !200;0 !2;-2 !200;0 !2;-2 !-100;0;100    
LINE	 = 32//1/0    !6/3/2!6/1/2 !2/3/2!2/1/2 !20/3/2!20/1/2  
FINT	 = 50;70;90
FLINE	 = 0;24;23;22
HILO	 = 
HLSYM	 = 
CLRBAR	 = 1
WIND	 = 
REFVEC	 =
TITLE    = 1/-1/~ ? ${MDL} @ RH, TEMP (BL yel,850 red,700 cyan)|~@ RH, R/S TEMP!0
r

GLEVEL	 = 4700:10000!700:500  !700:500  !850 !850 !30:0!30:0
GVCORD	 = SGMA      !PRES     !PRES     !PRES!PRES!pdly!pdly
SCALE	 = 0         !3        !3        !0  
GDPFUN   = sm5s(relh)!sm5s(lav(omeg))!sm5s(lav(omeg))!sm5s(tmpc)!sm5s(tmpc)!sm5s(tmpc)!sm5s(tmpc)
TYPE	 = c/f       !c
CINT	 = 50;70;90;95!1/1!-1;-3;-5;-7;-9;-11;-13;-15;-17;-19;-21!2;-2!200;0!2;-2!200;0    
LINE	 = 32//2/0    !30/10/3!6/1/2 !2/3/2!2/1/2 !20/3/2!20/1/2  
FINT	 = 50;70;90
FLINE	 = 0;24;23;22
title    = 1/-1/~ ? ${MDL} @ RH,T(BL yel,850 red),700-500 VV|~@ RH, R/S T,VV!0
r

glevel	 = 0!0!0!0!700:500!4700:10000
gvcord	 = none!none!none!none!PRES!sgma
scale	 = 2!2!2!2!3!0
gdpfun   = sm5s(WXTr)!sm5s(WXTs)!sm5s(WXTp)!sm5s(WXTz)!sm5s(lav(omeg))!sm5s(relh)
refvec	 =
type	 = c/f!c/f!c/f!c/f!c!c
cint	 = 50;200!50;200!50;200!50;200!-1;-3;-5;-7;-9;-11;-13;-15;-17;-19;-21!5/70
line	 = 22/1/2/0!4/1/2/0!7/1/2/0!2/1/2/0!6/1/3!21/1/3
fint	 = 50;200!50;200!50;200!50;200
fline	 = 0;23;23!0;25;25!0;30;30!0;15;15
clrbar	 =
title	 = 1/-1/~ ? ${MDL} PCPN TYPE, 1000-500 RH & 7-500 VV|~PCPN TYPE & VV!0
r

glevel	 = 0         !0         !0         !0
gvcord	 = none      !none      !none      !none
scale	 = 2         !2         !2         !2
gdpfun   = sm5s(WXTr)!sm5s(WXTs)!sm5s(WXTp)!sm5s(WXTz)
refvec	 =
type	 = c/f       !c/f       !c/f       !c/f
cint	 = 50;200    !50;200    !50;200    !50;200
line	 = 22/1/2/0  !4/1/2/0   !7/1/2/0   !2/1/2/0
fint	 = 50;200    !50;200    !50;200    !50;200
fline	 = 0;23;23   !0;25;25   !0;30;30   !0;15;15
clrbar	 =
title	 = 1/-1/~ ? ${MDL} PCPN TYPE|~PCPN TYPE!0
r

GLEVEL   = 500
GVCORD   = pres
SKIP     = 0!0!0!0/2;2
SCALE    = 0!0!-1!0
GDPFUN   = mag(kntv(wnd)!sm5s(tmpc)!sm5s(hght)!kntv(wnd)
TYPE     = f!c!c!a
CINT     = !2!6!!
LINE     = !2/12/3/2!6/1/2!
FINT     = 60;65;70;75;80;85;90;95;100;105;110;115;120;125;130
FLINE    = 0;24-1
HILO     =
HLSYM    =
CLRBAR   = 1
WIND     = !!!am1/.15/1/121/.3
REFVEC   = 10
TITLE    = 1/-1/~ ? ${MDL} @ HGHT, TEMP & WIND|~500 HGHT,TMP,WIND!0
TEXT     = 1/21//hw
MAP      = 11/1/2/yes
STNPLT   =
SATFIL   =
RADFIL   =
LUTFIL   =
STREAM   =
POSN     = 0
COLORS   = 0
MARKER   = 0
GRDLBL   = 0
FILTER   = n
r

GAREA   = us
PROJ    =
MAP     = 1/1/2/yes
GLEVEL  = 0                   !30:0
GVCORD  = FRZL                !pdly
PANEL   = 0
SKIP    =  0/1
SCALE   = -2                  !0
GDPFUN  = sm5s(sub(mul(3.28,hght)),(mul(hght@0%none,3.28))!sm5s(tmpc)
TYPE    = c/f                 !c
CINT    = 20/20/160           !0;100
LINE    = 32/1/2/1            !15/1/2
FINT    = 20;40;60;80;100;120;140;160;180;200
FLINE   =  0;30;29;4;25;6;23;22;19;5;17;18
HILO    = 0
HLSYM   = 0
CLRBAR  = 1
WIND    = 0
REFVEC  =
TITLE   = 1/-1/~ ? (FRZNG LVL HGT - SFC HGT),0-30MB AGL 0C TEMP|~FRZG LVL!0
TEXT    = m/22/2/hw
r

MAP      = 4/1/2/yes 
garea    = 38.5;-91.3;51.4;-71.4
proj     = nps//3;3;0;1
glevel	 = 150:120  !150:120    !850                !850     !825
gvcord	 = pdly     !pdly       !pres                 !pres      !pres
scale	 = 0        !0          !0                    !0         !3
gdpfun	 = avg(relh,relh@120:90%pdly)//rh!rh!sub(tmpc@2%hght,tmpc)!sm5s(tmpc)!omeg!kntv(wnd@30:0%pdly)
type	 = c/f                           !c !c                    !c!c!b
cint	 = 85;90;95 !60;70;80 !1/10                 !1//0      !1//-1
line	 = 32//2    !3//2     !20/1/1               !2/3/3     !6/1/2
fint     = 80;90
fline    = 0;23;22
hilo	 = 0
hlsym	 = 0
clrbar	 = 1/V/LL!0
wind	 = bk0!bk0!bk0!bk0!bk0!bk9/0.9/2/112
refvec	 =
title	 = 1/-1/~ ? 90-150MB AGL RH,BL1 WND,825MB OMG,850-2m dT,850 T|~GR LAKE!0
FILTER   = y

MAP      = 4/1/2/yes 
garea    = 38.5;-91.3;51.4;-71.4
proj     = nps//3;3;0;1
glevel	 = 8400:9800 !850                  !850       !850
gvcord	 = sgma      !pres                 !pres      !pres
scale	 = 0         !0                    !0         !3
gdpfun	 = sm5s(relh)!sub(tmpc@2%hght,tmpc)!sm5s(tmpc)!sm5s(omeg)!kntv(wnd@30:0%pdly)
type	 = f         !c                    !c         !c         !b
cint	 =           !1/10                 !1//0      !1//-1
line	 =           !20/1/1               !2/3/3     !6/1/2
fint     = 70;80;90;95
fline    = 0 ;24;23;22;21
hilo	 = 0
hlsym	 = 0
clrbar	 = 1/V/LL!0
wind	 = bk0       !bk0                  !bk0       !bk0       !bk9/0.9/2/112
refvec	 =
title	 = 1/-1/~ ? 840-980 MB RH,BL1 WND,850 MB OMG,850-2m dT,850 T|~GR LAKE!0
FILTER   = y
r

GAREA	 = 105
PROJ	 = str/90;-105;0
LATLON	 = 0
MAP      = 1/1/2/yes 

GDATTIM  = f12
GLEVEL   = 500
GVCORD   = pres
PANEL    = 0
SKIP     = 0
SCALE    = -1        !0                       !0                       !-1
GDPFUN   = sm5s(hght)!(sub(hght^f12,hght^f00))!(sub(hght^f12,hght^f00))!sm5s(hght)
TYPE     = c         !f                       !f                       !c
CINT     = 6         !                        !                        !6
LINE     = 5/1/3     !                        !                        !5/1/3
FINT     = 0         !30;60;90;120;150;180    !-180;-150;-120;-90;-60;-30
FLINE    = 0         !0;24;25;30;29;28;27     !11;12;2;10;15;14;0
HILO     = 0         !0                       !0                       !5/H#;L#
HLSYM    = 0         !                        !1.0//21//hw             !1.5
CLRBAR   = 0         !0                       !1                       !0
WIND     = 
REFVEC   = 
TITLE    = 1/-1/~ ? ${MDL} @ MB HGT|~500 HGT CHG!1/-2/~ ${MDL} @ MB 12-HR HGT FALLS!0
TEXT     = 1/21////hw
CLEAR    = YES
l
run

GDATTIM  = f24
GDPFUN   = sm5s(hght)!(sub(hght^f24,hght^f12))!(sub(hght^f24,hght^f12))!sm5s(hght)
TITLE    = 1/-1/~ ? ${MDL} @ MB HGT|~500 HGT CHG!1/-2/~ ${MDL} @ MB 12-HR HGT FALLS!0
l
run 

GDATTIM  = f36
GDPFUN   = sm5s(hght)!(sub(hght^f36,hght^f24))!(sub(hght^f36,hght^f24))!sm5s(hght)
TITLE    = 1/-1/~ ? ${MDL} @ MB HGT|~500 HGT CHG!1/-2/~ ${MDL} @ MB 12-HR HGT FALLS!0
l
run

GDATTIM  = f48
GDPFUN   = sm5s(hght)!(sub(hght^f48,hght^f36))!(sub(hght^f48,hght^f36))!sm5s(hght)
TITLE    = 1/-1/~ ? ${MDL} @ MB HGT|~500 HGT CHG!1/-2/~ ${MDL} @ MB 12-HR HGT FALLS!0
l
run

GDATTIM  = f60
GDPFUN   = sm5s(hght)!(sub(hght^f60,hght^f48))!(sub(hght^f60,hght^f48))!sm5s(hght)
TITLE    = 1/-1/~ ? ${MDL} @ MB HGT|~500 HGT CHG!1/-2/~ ${MDL} @ MB 12-HR HGT FALLS!0
l
run

GDATTIM  = f72
GDPFUN   = sm5s(hght)!(sub(hght^f72,hght^f60))!(sub(hght^f72,hght^f60))!sm5s(hght)
TITLE    = 1/-1/~ ? ${MDL} @ MB HGT|~500 HGT CHG!1/-2/~ ${MDL} @ MB 12-HR HGT FALLS!0
l
run

GDATTIM  = f84
GDPFUN   = sm5s(hght)!(sub(hght^f84,hght^f72))!(sub(hght^f84,hght^f72))!sm5s(hght)
TITLE    = 1/-1/~ ? ${MDL} @ MB HGT|~500 HGT CHG!1/-2/~ ${MDL} @ MB 12-HR HGT FALLS!0
l
run

garea   = 8.9;-109;47.5;-51.6
proj    = mer
gdattim = ${gdattim}
glevel  = 400:850!0
gvcord  = pres!none
scale   = 0
gdpfun  = squo(2,vadd(vlav(wnd@850:700%pres,vlav(wnd@500:400%pres)!sm5s(pmsl)
type    = b                                                       !c
cint    = 0!4
line    = 0!20//3
SKIP    = 0/2;2
fint    =
fline   =
hilo    = 0!26;2/H#;L#/1020-1070;900-1012//30;30/y
hlsym   = 0!2;1.5//21//hw
clrbar  = 0
wind    = bk10/0.9/1.4/112!bk0
refvec  =
title   = 1/-1/~ ? ${MDL} 850-400mb MLW AND MSLP|~850-400mb MLW & MSLP!0
r
 
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

