#! /bin/sh
#
# Metafile Script : nam_meta_qpf
#
# Log :
# D.W.Plummer/NCEP   2/97   Add log header
# J.W.Carr/NCEP    4/1/97   Changed pmsl to emsl to be consistent
# J.W.Carr/HPC     4/8/97   Added pcpn type amount product
# J.W.Carr/HPC     4/9/97   Added pcpn type amount product
# J.W.Carr/HPC     4/9/97   Changed titles to EMSL from PMSL
# J.W.Carr/HPC    5/13/97   Added sfc dewpoints as a field
# J.W.Carr/HPC   11/05/97   Converted from gdplot to gdplot2
# J.W.Carr/HPC    8/05/98   Changed map to medium resolution
# J.W.Carr/HPC    2/10/99   Changed type c/f to just f for pcpn
# MANOUSOS/HPC    5/27/99   Added Theta e convergence
# MANOUSOS/HPC    5/28/99   Added dqpfmax/dt continuity
# J. Carr/HPC     6/21/99   Added a filter to map
# J. Carr/HPC    10/01/99   Had to comment out changes involving dqpfmax/dt due to 
#                           error in script on 00Z run Oct 1 99. Do not have time to 
#                           solve problem today.
# B. Gordon/NCO   5/01/01   Converted to sh script to be run by production.
# J. Carr/PMB    11/08/04   Added a ? in all title lines to add Day of Week.
#                           Changed main contur value to a 2. Removed all other contur parameter 
#                           entries.
#
#
# Set up Local Variables
#

set -x

export PS4='QPF:$SECONDS + '
mkdir $DATA/QPF
cd $DATA/QPF
cp $FIXgempak/datatype.tbl datatype.tbl

device="nc | nam_qpf.meta"

PDY2=`echo $PDY | cut -c3-`

if [ "$envir" = "para" ] ; then
   export m_title="NAMP"
else
   export m_title="NAM"
fi

#
if [ $fend -eq 12 ] ; then
  gdat="F000-F012-06"
  gdatpcpn06="F006-F012-06"
  gdatpcpn12="F012"
  gdatpcpn24="F024"
  gdatpcpn48="F048"
  gdatpcpn60="F060"
  run24=" "
  run48=" "
  run60=" "
elif [ $fend -eq 24 ] ; then
  gdat="F000-F024-06"
  gdatpcpn06="F006-F024-06"
  gdatpcpn12="F012-F024-06"
  gdatpcpn24="F024"
  gdatpcpn48="F048"
  gdatpcpn60="F060"
  run24="r"
  run48=" "
  run60=" "
elif [ $fend -eq 36 ] ; then
  gdat="F000-F036-06"
  gdatpcpn06="F006-F036-06"
  gdatpcpn12="F012-F036-06"
  gdatpcpn24="F024-F036-06"
  gdatpcpn48="F048"
  gdatpcpn60="F060"
  run24="r"
  run48=" "
  run60=" "
elif [ $fend -eq 48 ] ; then
  gdat="F000-F048-06"
  gdatpcpn06="F006-F048-06"
  gdatpcpn12="F012-F048-06"
  gdatpcpn24="F024-F048-06"
  gdatpcpn48="F048"
  gdatpcpn60="F060"
  run24="r"
  run48="r"
  run60=" "
elif [ $fend -eq 60 ] ; then
  gdat="F000-F060-06"
  gdatpcpn06="F006-F060-06"
  gdatpcpn12="F012-F060-06"
  gdatpcpn24="F024-F060-06"
  gdatpcpn48="F048-F060-06"
  gdatpcpn60="F060"
  run24="r"
  run48="r"
  run60="r"
elif [ $fend -eq 72 ] ; then
  gdat="F000-F072-06"
  gdatpcpn06="F006-F072-06"
  gdatpcpn12="F012-F072-06"
  gdatpcpn24="F024-F072-06"
  gdatpcpn48="F048-F072-06"
  gdatpcpn60="F060-F072-06"
  run24="r"
  run48="r"
  run60="r"
elif [ $fend -eq 84 ] ; then
  gdat="F000-F084-06"
  gdatpcpn06="F006-F084-06"
  gdatpcpn12="F012-F084-06"
  gdatpcpn24="F024-F084-06"
  gdatpcpn48="F048-F084-06"
  gdatpcpn60="F060-F084-06"
  run24="r"
  run48="r"
  run60="r"
else
  err_exit "Varibale fend incorrectly set."
fi

export pgm=gdplot2_nc; . prep_step; startmsg

$GEMEXE/gdplot2_nc >runlog << EOFplt
gdfile   = F-${RUN} | ${PDY2}/${cyc}00
GAREA    = us
proj     = 
map      = 1/1/2/yes
latlon   = 0
skip     = 0/1
device   = ${device}
gdattim  = ${gdat}
text     = 1/22/2/hw
clear    = y
filter   = y
panel    = 0
contur   = 2

glevel   = 180:0
gvcord   = pdly
scale    = 0
gdpfun   = sm5s(lft4)  !sm5s(lft4) !sm5s(lft4)!kntv(wnd@30:0%pdly)
type     = c/f         !c          !c         !b
cint     = 2/2         !-10000;0.05!2/-100/-2
line     = 20/1/2/1    !5/1/4/1    !32/1/2/1
fint     = -8;-6;-4;-2;0.05;10
fline    = 2;15;21;22;23;0;24
hilo     = 0
hlsym    = 0
clrbar   = 1/V/LL!0
wind     = !!!bk10/0.9/2/112!bk0
refvec   =
title    = 1/-2/~ ? ${m_title} BEST LI(0-180MB AGL) & BL (0-30MB AGL)WND|~BEST LI!0
r

gdpfun	 = sm5s(cape)  !sm5s(cins)!sm5s(cins)!sm5s(cins)
type	 = f           !c
cint	 = 250/250/1000!30/-60/-30!30/-210/-90!-2000;-250
line	 = 22/1/2      !6/10/2    !6/1/1      !2/1/3
fint	 = 500;1000;1500;2000;3000;4000
fline	 = 0;25;24;23;22;21;20
hlsym	 = 1;1//22;22/2;2/hw
wind	 = bk0
refvec	 =
title	 = 1/-2/~ ? ${m_title} BEST CAPE (jkg-1) & CIN (cyan)|~BEST CAPE & CIN!0
r

GLEVEL   = 30:0!30:0!30:0!0
GVCORD   = pdly!pdly!pdly!none
SCALE    = 0
GDPFUN   = sm5s(dwpf)!sm5s(dwpf)!sm5s(dwpf)!sm5s(pmsl)!kntv(wnd@30:0%pdly)
TYPE     = c/f!c!c!c!b
CINT     = 4/52!4/32/48!4/0/28!4
LINE     = 32/1/2/1!3/1/2!22/1/1!5//3
FINT     = 50;56;62;68;74
FLINE    = 0;23;22;30;14;2
HILO     = 0!0!0!5/H#;L#/1020-1060;900-1012
HLSYM    = !!!1.3;1.3//22/3/hw
CLRBAR   = 1/V/LL!0
WIND     = !!!!bk9/0.8/2/112
REFVEC   =
TITLE    = 1/-2/~ ? ${m_title} BL DWPT, WND(30MB AGL), PMSL|~SFC DEWPOINT!0
r

glevel   = 0!0!0!500:1000!500:1000!850:700
gvcord   = none!none!NONE!PRES!PRES!PRES
skip     = 0!0!0!0!0!0/3;3
SCALE    = 0!0!0!-1
gdpfun   = quo(pwtr;25.4)!quo(pwtr;25.4)!pmsl!ldf(hght)!ldf(hght)!kntv(vsub(squo(2,vadd(vlav(wnd),vlav(wnd@500:300))),(wnd@850))
type     = c!c/f!c!c!c!b
cint     = 0.25/0.25/0.5!0.25/0.75/6.0!4!3/0/540!3/543/1000
line     = 22///2!32//2/2!6//3!4/5/2!5/5/2
fint     = !0.5;1.0;1.5;2.0
fline    = !0;23;22;30;14
hilo     = 0!0!6/H#;L#/1020-1070;900-1012!0
HLSYM    = 0!0!1.3;1.3//22;22/3;3/hw!0
clrbar   = 0!1/V/LL!0!0
wind     = am0!am0!am0!am0!am0!bk9/0.8/2/112
refvec   =
title    = 1/-2/~ ? ${m_title} PW, PMSL, THICKNESS, C-VEC|~PW, PMSL, C-VEC!0
r

glevel   = 0!0
gvcord   = none!none
skip     = 0/1;1
scale    = 0!0
gdpfun   = quo(pwtr;25.4)!quo(pwtr;25.4)!kntv(wnd@850%PRES)
type     = c!c/f!b
cint     = 0.25/0.25/0.5!0.25/0.75/6.0
line     = 22///2!32//2/2
fint     = !0.5;1.0;1.5;2.0
fline    = !0;23;22;21;2
hilo     = 0
HLSYM    = 0
clrbar   = 0!1/V/LL
wind     = bk0!bk0!bk9/0.8/2/112
refvec   =
title    = 1/-2/~ ? ${m_title} 850 MB WIND AND PRECIP WATER|~850 MB WIND & PW!0
filter   = no
r

glevel   = 9823          !9823!9823
gvcord   = sgma          !sgma!sgma
skip     = 0/1;2
scale    = 7             !0   !0
gdpfun   = sdiv(mixr;wnd)!dwpc!dwpc!dwpc!kntv(wnd)
type     = f             !c   !c   !c   !b
cint     = 0             !2   !2/12!2/20
line     = 0             !19  !5//2!6//2
fint     = -11;-9;-7;-5;-3;-1
fline    =   2;25;24;23;22; 3;0
hilo     = 0
hlsym    = 0             !1;1//22;22/2;2/hw
clrbar   = 1/V/LL        !0
wind     = bk0           !bk0 !bk0 !bk0!bk9/0.8/2/112
refvec   =
title    = 1/-2/~ ? ${m_title} BL (18MB AGL) MOIST CONV, WND, DEWPT|~BL MOIST CONV!0
filter   = yes
r

glevel   = 850!850!9823
gvcord   = pres!pres!sgma
SKIP     = 0/2;1
scale    = 2!-1/2!0!-1/2
gdpfun   = mag(smul(mixr;wnd))!hght!thte(pres;tmpc;dwpc)!smul(mixr;wnd)
type     = c/f!c!c!a
cint     = 3!3!5
line     = 3!1//2!25/10/2
fint     = 6;12;18;24;30;36
fline    = 0;23;22;21;14;15;2
hilo     = 0!1;1/H#;L#!0
hlsym    = 0!1;1//22;22/2;2/hw!0
clrbar   = 1/V/LL!0
wind     = bk0!bk0!bk0!am16/0.8/2/211/0.5
refvec   = 10
title    = 1/-2/~ ? ${m_title} @ MOISTURE TRNSPT, HGHT, BL THTAE|~@ H2O TRANSPORT!0
r

glevel	 = 850
gvcord	 = pres!pres!pres
SKIP     = 0/2;1
scale	 = 4!-1!0
gdpfun	 = adv(thte(pres;tmpc;dwpc),wind)!hght!thte(pres;tmpc;dwpc)//te!te!te!kntv(wnd)
type	 = c/f!c!c!c!c!b
cint	 = 2!3/90/96!4//304!4/308/324!4/328
line	 = 32/1/2!1//2!23/10/3!22/10/3!21/1/2
fint	 = -14;-10;-6;-2;2;6;10;14
fline	 = 7;29;30;24;0;14;15;18;5
hilo	 = 0!
hlsym	 = 0!
clrbar	 = 1/V/LL!0
wind	 = bk0!bk0!bk0!bk0!bk0!bk9/0.7/2/112
refvec   = 10
title	 = 1/-2/~ ? ${m_title} @ THTAE ADV, THTAE & WIND|~@ THTAE ADVECTION!0
r

glevel   = 700
gvcord   = pres!pres!pres
SKIP     = 0/2;1
scale    = 4!-1!0
gdpfun   = adv(thte(pres;tmpc;dwpc),wind)!hght!thte(pres;tmpc;dwpc)//te!te!te!kntv(wnd)
type     = c/f!c!c!c!c!b
cint     = 2!3/90/96!4//304!4/308/324!4/328
line     = 32/1/2!1//2!23/10/3!22/10/3!21/1/2
fint     = -14;-10;-6;-2;2;6;10;14
fline    = 7;29;30;24;0;14;15;18;5
hilo     = 0!
hlsym    = 0!
clrbar   = 1/V/LL!0
wind     = bk0!bk0!bk0!bk0!bk0!bk9/0.7/2/112
refvec   = 10
title    = 1/-2/~ ? ${m_title} @ THTAE ADV, THTAE & WIND|~@ THTAE ADVECTION!0
r

glevel	 = 850!!!!!!1000:700
gvcord	 = pres!pres!pres!pres
SKIP     = 0/2;1
scale	 = 4!-1!0!!!!4
gdpfun	 = adv(thte(pres;tmpc;dwpc),wind)!hght!thte(pres;tmpc;dwpc)//te!te!te!kntv(wnd)!sm5s(msdv(thte,wind))
type	 = c/f!c!c!c!c!b!c
cint	 = 2!3/90/96!4//304!4/308/324!4/328!!3//-3!
line	 = 32/1/2!1//2!23/10/3!22/10/3!21/1/2!6/1/2
fint	 = -14;-10;-6;-2;2;6;10;14
fline	 = 7;29;30;24;0;14;15;18;5
hilo	 = 0!
hlsym	 = 0!
clrbar	 = 1/V/LL!0
wind	 = bk0!bk0!bk0!bk0!bk0!bk9/0.7/2/112!bk0
refvec   = 10
title	 = 1/-2/~ ? ${m_title} @ THTAE ADV & WIND/(CNVRG-AQUA)|~@ THTAE ADVCN/CNVRG!0
r

glevel   = 750                           !    !                        !  !  !         !850:700
gvcord   = pres
SKIP     = 0/2;1
scale    = 4                             !-1  !0                       !  !  !         !4
gdpfun   = adv(thte(pres;tmpc;dwpc),wind)!hght!thte(pres;tmpc;dwpc)//te!te!te!kntv(wnd)!sm5s(msdv(thte,wind))
type     = c/f                           !c   !c                       !c !c !b        !c
cint     = 2                             !3/90/96!4//304               !4/308/324!4/328!!3//-3!
line     = 32/1/2                        !1//2   !23/10/3              !22/10/3  !21/1/2!6/1/2
fint     = -14;-10;-6;-2;2;6;10;14
fline    = 7;29;30;24;0;14;15;18;5
hilo     = 0!
hlsym    = 0!
clrbar   = 1/V/LL!0
wind     = bk0!bk0!bk0!bk0!bk0!bk9/0.7/2/112!bk0
refvec   = 10
title    = 1/-2/~ ? ${m_title} @ THTAE ADV,WIND,850-700 MST-FLUX CNVG(AQUA)|~@ THTE ADV/CNV!0
r

glevel   = 850!850!850
gvcord   = pres!pres!pres
skip     = 0/2;1
scale    = 0!0!-1
gdpfun   = dwpc!dwpc!sm5s(hght)!kntv(wnd)
type     = c/f!c!c!b
cint     = -4;-2;0;2;4!2/6/28!3
line     = 3//1!32//1!6//3
fint     = 4;8;12;16;20
fline    = 0;23;22;30;14;2
hilo     = 0!0!6/H#;L#
hlsym    = 0!0!1.3;1.3//22;22/2;2/hw
clrbar   = 1/V/LL!0
wind     = bk0!bk0!bk0!bk9/0.8/2/212
refvec   =
title    = 1/-2/~ ? ${m_title} @ DEWPOINT, WIND, AND HGHT|~850 MB DEWPOINT!0
r

glevel   = 700!700!700
gvcord   = pres!pres!pres
scale    = 0!0!-1
gdpfun   = dwpc!dwpc!sm5s(hght)!kntv(wnd)
type     = c/f!c!c!b
cint     = -8;-6;-4;-2!1/0/28!3
line     = 3//1!32//1!6//3
fint     = 0;4;8;12;16
fline    = 0;23;22;30;14;2
hilo     = 0!0!6/H#;L#
hlsym    = 0!0!1.5;1.5//22;22/2;2/hw
clrbar   = 1/V/LL!0
wind     = bk0!bk0!bk0!bk9/0.8/2/212
refvec   =
title    = 1/-2/~ ? ${m_title} @ DEWPOINT, WIND, AND HGHT|~@ DEWPOINT!0
r

GLEVEL   = 700!700!0
GVCORD   = pres!pres!none
SKIP     = 0/2;2
SCALE    = 0
GDPFUN   = sub(add(add(dwpc@850,dwpc),sub(tmpc@850,tmpc@500)),tmpc)!tmpc!pmsl
TYPE     = c/f!c
CINT     = 3/15/60!2/6!4
LINE     = 32/1/2/2!20/3/2!6//3
FINT     = 15;24;33;42
FLINE    = 0;24;30;14;2
HILO     = 0!0!6/H#;L#/1020-1070;900-1012
HLSYM    = 0!0!1.3;1.3//22;22/3;3/hw
CLRBAR   = 1/V/LL!0
WIND     =
REFVEC   =
TITLE    = 1/-2/~ ? ${m_title} K INDEX, 700mb TEMP (>6 C) & PMSL|~K INDEX!0
r

glevel   = 300
gvcord   = pres
SKIP     = 0/3;3
scale    = 0                       !5/0               !5/0    !-1        !5/0
gdpfun   = sm5s(mag(kntv(wnd))//jet!sm5s(div(wnd)//dvg!dvg    !sm5s(hght)!age(hght)
type     = c/f                     !c                 !c      !c         !a
cint     = 70;90;110;130;150;170   !-11;-9;-7;-5;-3;-1!2/2/100!12
line     = 32/1                    !20/-2/2           !3/1/2  !1//2
fint     = 70;90;110;130;150;170;190!
fline    = 0;24;25;30;28;14;2;1    !
hilo     = 0                       !0                 !0      !1/H#;L#/3
hlsym    = 0                       !0                 !0      !1.3//22/2/hw
clrbar   = 1/V/LL                  !0
wind     = bk0                     !bk0               !bk0    !bk0       !am16/0.4//211/0.4
refvec   = 10
title    = 1/-1/~ ? ${m_title} @ DIV(GREEN),ISOTACHS & AGEO WND|~@ AGEO & DIVERG!0
filter   = no
r

GLEVEL   = 250
GDPFUN   = sm5s(mag(kntv(wnd))//jet!sm5s(div(wnd)//dvg!dvg    !sm5s(hght)!age(hght)
r

glevel   = 200
gdpfun   = sm5s(mag(kntv(wnd))//jet!sm5s(div(wnd)//dvg!dvg    !sm5s(hght)!age(hght)
r
 
filter   = yes
gdattim  = ${gdatpcpn06}
glevel   = 0   !0
gvcord   = none!none
scale    = 0   !0
gdpfun   = p06i!sm5s(pmsl)
type     = f   !c
cint     =     !4
line     =     !17/1/3
fint     = .01;.1;.25;.5;.75;1;1.25;1.5;1.75;2;2.5;3;4;5;6;7;8;9
fline    = 0;21-30;14-20;5
hilo     = 31;0/x#2/.03-20/50;50//y!17/H#;L#/1020-1070;900-1012
hlsym    = 1.3!1;1//22;22/2;2/hw
clrbar   = 1
wind     = bk0
refvec   =
title    = 1/-2/~ ? ${m_title} 6-HOUR TOTAL PCPN, PMSL |~6-HR TOTAL PCPN!0
r

gdpfun   = c06i!sm5s(pmsl)
title    = 1/-2/~ ? ${m_title} 6-HOUR CONV PCPN, PMSL |~6-HR CONV PCPN!0
r

gdattim  = ${gdatpcpn12}
gdpfun   = p12i
title    = 1/-2/~ ? ${m_title} 12-HOUR TOTAL PCPN|~12-HR TOTAL PCPN!0
r

gdattim  = ${gdatpcpn24}
gdpfun   = p24i
title    = 1/-2/~ ? ${m_title} 24-HOUR TOTAL PCPN|~24-HR TOTAL PCPN!0
${run24}

gdattim  = ${gdatpcpn48}
gdpfun   = p48i
title    = 1/-2/~ ? ${m_title} 48-HOUR TOTAL PCPN|~48-HR TOTAL PCPN!0
${run48}

gdattim  = ${gdatpcpn60}
gdpfun   = p60i
title    = 1/-2/~ ? ${m_title} 60-HOUR TOTAL PCPN|~60-HR TOTAL PCPN!0
${run60}

GDATTIM  = ${gdat}
GLEVEL   = 1000
GVCORD   = pres
SKIP     = 0
SCALE    = 0!0
GDPFUN   = mag(kntv(wnd))!kntv(wnd)
TYPE     = c/f!s
CINT     = 5/15
LINE     = 32/1/2/2! 6/1/2
FINT     = 20;35;50;65
FLINE    = 0;18;17;16;15
HILO     = 
HLSYM    = 
CLRBAR   = 1
WIND     = bk0
REFVEC   = 
TITLE    = 1/-2/~ ? ${m_title} 1000 MB STREAMLINES & WIND|~1000 MB STMLNS!0
STREAM   = 1
POSN     = 4
COLORS   = 2
MARKER   = 2
GRDLBL   = 5
FILTER   = yes
run

GLEVEL   = 850
GDPFUN   = mag(kntv(wnd))!kntv(wnd)
TITLE    = 1/-2/~ ? ${m_title} 850 MB STREAMLINES & WIND|~850 MB STMLNS!0
run

gdattim  = ${gdat}
GAREA    = 24.57;-100.55;47.20;-65.42
PROJ     = str/90;-90;0/3;3;0;1
glevel   = 9823!9823!0!9823
gvcord   = SGMA!SGMA!none!SGMA
SKIP     = 0/0;1
scale    = 5/2!5/2!0!5/2
gdpfun   = mul(mixr,(ADV(pres@0%none,wnd))!mul(mixr,(ADV(pres@0%none,wnd))!hght!smul(mixr;wnd)))
type     = c/f!c!c!a
CINT     = 1/1/99!1/-99/-1!200/200
LINE     = 21/1/1!24/1/2/2!18/1/1/3
FINT     = 1;3;5;7;9
FLINE    = 0;23;22;28;15;2
hilo     = 0
hlsym    = 0
clrbar   = 1/V/LL!0
wind     = am0!am0!am0!am6/0.6/2/222/0.4
refvec   = 10
title    = 1/-2/~ ? ${m_title} BL H2O TRNSP,OROG OMG*MIXR,SFC HT|~E BL H2O TRNSP, OMG*Q!0
r

garea    = 25;-125;55;-90
proj     = str/90;-105;0/3;3;0;1
glevel   = 9823!9823!0!9823
gvcord   = SGMA!SGMA!none!SGMA
scale    = 5/2!5/2!0!5/2
gdpfun   = mul(mixr,(ADV(pres@0%none,wnd)!mul(mixr,(ADV(pres@0%none,wnd))!hght!smul(mixr;wnd)
type     = c/f!c!c!a
CINT     = 1/1/99!1/-99/-1!200/200
LINE     = 21/1/1!24/1/2/2!18/1/1/3
FINT     = 1;3;5;7;9
FLINE    = 0;23;22;28;15;2
gvect    = smul(mixr;wnd)
wind     = am0!am0!am0!am6/0.6/2/222/0.4
title    = 1/-2/~ ? ${m_title} BL H2O TRNSP,OROG OMG*MIXR,SFC HT|~W BL H2O TRNSP, OMG*Q!0
r

exit
EOFplt
cat runlog

#####################################################
# GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
# WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
# FOR THIS CASE HERE.
#####################################################
ls -l nam_qpf.meta
export err=$?; export pgm="GEMPAK CHECK FILE"; err_chk

if [ $SENDCOM = "YES" ] ; then
  mv nam_qpf.meta ${COMOUT}/nam_${PDY}_${cyc}_qpf
  if [ $SENDDBN = "YES" ] ; then
    $DBNROOT/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
     $COMOUT/nam_${PDY}_${cyc}_qpf
      if [ $DBN_ALERT_TYPE = "NAM_METAFILE_LAST" ] ; then
        DBN_ALERT_TYPE=NAM_METAFILE
        ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
        ${COMOUT}/nam_${PDY}_${cyc}_qpf
      fi
  fi
fi

exit
