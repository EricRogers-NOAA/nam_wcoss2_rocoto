#! /bin/sh
#
# Metafile Script : nam_meta_mar.sh
#
# Log :
# J. Carr/PMB     12/11/2004      Pushed into production.
#
# Set up Local Variables
#
set -x
#
export PS4='MAR:$SECONDS + '
mkdir $DATA/MAR
cd $DATA/MAR
cp $FIXgempak/datatype.tbl datatype.tbl

mdl=nam
MDL="NAM"
metatype="mar"
metaname="${mdl}_${metatype}_${cyc}.meta"
device="nc | ${metaname}"
PDY2=`echo $PDY | cut -c3-`

export DBN_ALERT_TYPE=NAM_METAFILE

export pgm=gdplot2_nc;. prep_step; startmsg

gdplot2_nc >runlog << EOFplt
\$MAPFIL=mepowo.gsf+mehsuo.ncp+mereuo.ncp+mefbao.ncp
gdfile  = F-${MDL} | ${PDY2}/${cyc}00
GDATTIM = F00-F84-6
GAREA   = 13;-84;50;-38
PROJ    = str/90;-67;1
MAP     = 31 + 6 + 3 + 5
LATLON  = 18/2///5;5
CONTUR  = 1
clear   = y
device  = $device

GLEVEL  = 30:0!0
GVCORD  = pdly!none
PANEL   = 0
SKIP    = 0/1
SCALE   = 0
GDPFUN  = mag(kntv(wnd))!sm5s(pmsl)!kntv(wnd@30:0%pdly)
TYPE    = c/f           !c         !b
CONTUR  =
CINT    = 5/20!4
LINE    = 32/1/2/2!19//2
FINT    = 20;35;50;65
FLINE   = 0;24;25;30;15
HILO    = 0!20/H#;L#
HLSYM   = 0!1.5;1.5//22;22/3;3/hw
CLRBAR  = 1/V/LL!0
WIND    = bk9/0.7/1/112
REFVEC  =
TITLE   = 1/-2/~ ? ${MDL} PMSL, BL WIND (0-30MB AGL;KTS)|~ ATL PMSL & BL WND!0
TEXT    = 1.2/22/2/hw
CLEAR   = YES
l
r

GLEVEL  = 850:1000                  !0
GVCORD  = pres                      !none
PANEL   = 0
SCALE   = -1                        ! 0
SKIP    = 0                         ! 0/1
GDPFUN   = (sub(hght@850,hght@1000)) !sm5s(pmsl) ! kntv(wnd@9823%sgma)
TYPE   = c                           !c          ! b
CINT    = 1                         ! 4
LINE    = 3/5/1/2                   ! 20//2
FINT    =
FLINE   =
HILO    = ! 26;2/H#;L#///30;30/y
HLSYM   = 2;1.5//21//hw
CLRBAR  = 1
WIND    = bk9/0.7/1/112
TITLE   = 5/-2/~ ? ATL MSLP, 1000-850mb THK & BL WIND|~ ATL MSLP,1000-850 THK!0
CLEAR   = yes
l
r

GLEVEL	= 9823!9823!9823:0!9823:0!0
GVCORD	= sgma!sgma!sgma!sgma!none
PANEL	= 0
SCALE	= 7!0
GDPFUN	= sdiv(mixr,obs)!thte(mul(.9823;pres@0%none),tmpc,dwpc)//te!te!te!pmsl!kntv(wnd%sgma@9823)
TYPE	= c/f           !c                                         !c !c !c   !b
CONTUR	= 1
CINT	= 1!4//296!4/300/320!4/324!1;2
LINE	= 32/1/1/2!30/1/1/0!29/1/1/0!7/1/1/1!1
FINT	= -10;-8;-6;-4;-2
FLINE	= 2;15;21;22;23;0
HILO	= !!!!6/H#;L#/
HLSYM	= 1;1/2//4;1.5/0
CLRBAR	= 1
WIND	= bk9/0.7/1/112
REFVEC	=
title	= 1/-2/~ ? ${MDL} BL MOISTURE CONV, WIND and THTAE|~ ATL BL H2O CONV!0
TEXT	= 1
CLEAR	= y
l
r

GLEVEL	= 850!850!2:850!2:850!0
GVCORD	= pres!pres!hght!hght!none
PANEL	= 0
SCALE	= 0
GDPFUN	= mag(kntv(wnd))!sm9s(sub(tmpc@2%hght,tmpc))//stb!stb!stb!emsl!kntv(wnd@850%pres)
TYPE	= c/f           !c                               !c  !c  !c   !b
CONTUR	=
CINT	= 5/20!1/10!5;6;7;8;9!1//4!4//1000
LINE	= 32/1/2/2!7/1/2!14/10/3!6/10/3!19//2
FINT	= 20;35;50;65
FLINE	= 0;24;25;30;15
HILO	= 0!7/X#;/10-20;!0!0!20/H#;L#
HLSYM	= 0!1.5;1.5//22;22/3;3/hw!0!0!1.5;1.5//22;22/3;3/hw
CLRBAR	= 1/V/LL!0
WIND	= bk9/0.7/1/112
REFVEC	=
TITLE	= 1/-2/~ ? ${MDL} PMSL,T850-Tsfc,850 WIND(kts)|~ ATL T850-Tsfc & @ WIND!0
TEXT	= 1.2/22/2/hw
CLEAR	= YES

GLEVEL	= 850!850!850:0!0
GVCORD	= pres!pres!pres!none
PANEL	= 0
SCALE	= 0
SKIP	= 0/1
GDPFUN	= mag(kntv(wnd))!sm9s(sub(thta,thta@0%none))//stb!stb!emsl!kntv(wnd@850%pres)
TYPE	= c/f           !c                               !c  !c   !b
CONTUR	= 1
CINT	= 5/20!1//0!1/1!4//1012
LINE	= 32/1/2/2!7/1/2!6/10/3!19//2
FINT	= 20;35;50;65
FLINE	= 0;24;25;30;15
HILO	= 0!7/;N#/10-20;!0!20/H#;L#/1018-1070;900-1014
HLSYM	= 0!1.2;1.2//21;21/2;2/hw!0!1.2;1.2//21;21/2;2/hw
CLRBAR	= 1/V/LL!0
WIND	= bk9/0.7/1/112
REFVEC	=
TITLE	= 1/-2/~ ? ${MDL} EMSL, THETA (850-sfc), 850 WND (kts)|~ WATL 850 STBLTY!0
TEXT	= 1/22/2/hw
CLEAR	= YES
l
r

GLEVEL  = 900!900!900:0!0
GDPFUN  = mag(kntv(wnd))!sm9s(sub(thta,thta@0%none))//stb!stb!emsl!kntv(wnd@900%pres)
TITLE   = 1/-2/~ ? ${MDL} EMSL, THETA (900-sfc), 900 WND (kts)|~ WATL 900 STBLTY!0
l
r

GLEVEL  = 925!925!925:0!0
GDPFUN  = mag(kntv(wnd))!sm9s(sub(thta,thta@0%none))//stb!stb!emsl!kntv(wnd@925%pres)
TITLE   = 1/-2/~ ? ${MDL} EMSL, THETA (925-sfc), 925 WND (kts)|~ WATL 925 STBLTY!0
l
r

GLEVEL  = 950!950!950:0!0
GDPFUN  = mag(kntv(wnd))!sm9s(sub(thta,thta@0%none))//stb!stb!emsl!kntv(wnd@950%pres)
TITLE   = 1/-2/~ ? ${MDL} EMSL, THETA (950-sfc), 950 WND (kts)|~ WATL 950 STBLTY!0
l
r

GLEVEL  = 500
restore /nwprod/gempak/ush/restore/500mb_hght_absv.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
TITLE	= 1/-2/~ ? ${MDL} @ HEIGHTS AND VORTICITY|~ ATL @ HGHT AND VORTICITY!0
CLEAR   = yes
l
ru

!
! 1000-850 thk & precip fields
!
CLEAR	= y
GLEVEL  = 0!0!850:1000!0!0
GVCORD  = none !none!pres!none!none
SCALE   = 0!0!-1!0!0
SKIP	= 0/1
GDPFUN  = p06i!p06i!(sub(hght@850,hght@1000))!sm5s(pmsl)! 
TYPE    = c/f !c   !c                        !c         !
CINT    = 0.1;0.25 !0.25/0.5!1!4! 
LINE    = 32//1/0!32//1/0!16/15/2/1!20//2! 
FINT    = .1;.25;.5;.75;1;1.25;1.5;1.75;2;2.25;2.5;2.75;3;3.25;3.5;3.75;4
FLINE   = 0;22-30;14-20;5
HILO    = 31;0/x#2/.01-10///y !31;0/x#2/.01-10///y !0!26;2/H#;L#///30;30/y !0
HLSYM   = 0!0!2;1.5//21//hw!0!0
WIND    = 
clrbar  = 1/V/LL
TITLE	= 5/-2/~ ? ${MDL} MSLP,1000-850 THK, 6HR PCP|~ ATL PCPN, MSLP & THK!0
TEXT	= 1.2/22/2/hw
li
run

GDPFUN   = c06i!c06i!(sub(hght@850,hght@1000))!sm5s(pmsl)!
TITLE   = 5/-2/~ ? ${MDL} MSLP,1000-850 THK, 6HR CONV. PCP|~ ATL CONV PCP,MSLP,THK!0
li
run

! RH & Omega (vv) - maybe swap 700mb hght for 9950 TMPF??

GLEVEL	= 700
GVCORD	= PRES
GDATTIM = F00-F84-6
SKIP	= 0! 1! 0! 0
SCALE	= 0!-1! 3! 3
GDPFUN	= (relh) !(hght)!(omeg)!(omeg)
TYPE	= c/f ! c
CONTUR	= 1
CINT	= 50;70;90 !3 !-9;-7;-5;-3 !3;5;7;9
LINE	= 21//2/0 !20/1/2/1 !6/1/1/1 !16/5/1/1
FINT	= 70;90
FLINE	= 0;22;23
HILO	=
HLSYM	=
WIND	= ! ! Bk9/0.7/1/112
REFVEC	=
TITLE	= 1/-2/~ ? ${MDL} @ HEIGHTS, RH and OMEGA |~ ATL @ HGHT, RH & OMEGA!0
li
run

\$MAPFIL=mepowo.gsf+mehsuo.ncp+mereuo.ncp+himouo.nws
GDATTIM    = F00-F84-6
GAREA      = 11;-135;75;-98
PROJ       = str/90;-100;1
LATLON     = 18/2///5;5
CONTUR     = 1
clear      = y
device     = $device

GLEVEL  = 30:0!0
GVCORD  = pdly!none
PANEL   = 0
SKIP    = 0/1
SCALE   = 0
GDPFUN  = mag(kntv(wnd))!sm5s(pmsl)!kntv(wnd@30:0%pdly)
TYPE    = c/f           !c         !b
CONTUR  =
CINT    = 5/20!4
LINE    = 32/1/2/2!19//2
FINT    = 20;35;50;65
FLINE   = 0;24;25;30;15
HILO    = 0!20/H#;L#
HLSYM   = 0!1.5;1.5//22;22/3;3/hw
CLRBAR  = 1/V/LL!0
WIND    = bk9/0.7/1/112
REFVEC  =
TITLE   = 1/-2/~ ? ${MDL} PMSL, BL WIND (0-30MB AGL;KTS)|~ PAC PMSL & BL WIND!0
TEXT    = 1.2/22/2/hw
CLEAR   = YES
l
r

GLEVEL  = 850:1000                  !0
GVCORD  = pres                      !none
PANEL   = 0
SCALE   = -1                        ! 0
SKIP    = 0                         ! 0/1
GDPFUN  = (sub(hght@850,hght@1000)) !sm5s(pmsl) ! kntv(wnd@30:0%pdly)
TYPE    = c                         ! c         ! b
CINT    = 1                         ! 4
LINE    = 3/5/1/2                   ! 20//2
FINT    =
FLINE   =
HILO    = ! 26;2/H#;L#///30;30/y
HLSYM   = 2;1.5//21//hw
CLRBAR  = 1
WIND    = bk9/0.7/1/112
TITLE   = 5/-2/~ ? ${MDL} PAC MSLP, 1000-850mb THK & BL WIND|~ PAC MSLP,1000-850 THK!0
CLEAR   = yes
l
r


GLEVEL	= 9823!9823!9823:0!9823:0!0
GVCORD	= sgma!sgma!sgma  !sgma  !none
PANEL	= 0
SCALE	= 7!0
GDPFUN	= sdiv(mixr,obs)!thte(mul(.9823;pres@0%none),tmpc,dwpc)//te!te!te!pmsl!kntv(wnd%sgma@9823)
TYPE	= c/f           !c                                         !c !c !c   !b
CONTUR	= 1
CINT	= 1!4//296!4/300/320!4/324!1;2
LINE	= 32/1/1/2!30/1/1/0!29/1/1/0!7/1/1/1!1
FINT	= -10;-8;-6;-4;-2
FLINE	= 2;15;21;22;23;0
HILO	= !!!!6/H#;L#/
HLSYM	= 1;1/2//4;1.5/0
CLRBAR	= 1
WIND	= bk9/0.7/1/112
REFVEC	=
title	= 1/-2/~ ? ${MDL} BL(18MB AGL) MST CONV, WND & THTAE|~ PAC BL H2O CONV!0
TEXT	= 1
CLEAR	= y
l
r

GLEVEL	= 850!850!2:850!2:850!0
GVCORD	= pres!pres!hght!hght!none
PANEL	= 0
SCALE	= 0
GDPFUN	= mag(kntv(wnd))!sm9s(sub(tmpc@2%hght,tmpc))//stb!stb!stb!emsl!kntv(wnd@850%pres)
TYPE	= c/f           !c                               !c  !c  !c   !b
CONTUR	=
CINT	= 5/20!1/10!5;6;7;8;9!1//4!4//1000
LINE	= 32/1/2/2!7/1/2!14/10/3!6/10/3!19//2
FINT	= 20;35;50;65
FLINE	= 0;24;25;30;15
HILO	= 0!7/X#;/10-20;!0!0!20/H#;L#
HLSYM	= 0!1.5;1.5//22;22/3;3/hw!0!0!1.5;1.5//22;22/3;3/hw
CLRBAR	= 1/V/LL!0
WIND	= bk9/0.7/1/112
REFVEC	=
TITLE	= 1/-2/~ ? ${MDL} PMSL,T850-Tsfc,850 WIND(kts)|~ PAC T850-Tsfc & @ WIND!0
TEXT	= 1.2/22/2/hw
CLEAR	= YES

GLEVEL	= 850!850!850:0!0
GVCORD	= pres!pres!pres!none
PANEL	= 0
SCALE	= 0
SKIP	= 0/1
GDPFUN	= mag(kntv(wnd))!sm9s(sub(thta,thta@0%none))//stb!stb!emsl!kntv(wnd@850%pres)
TYPE	= c/f           !c                               !c  !c   !b
CONTUR	= 1
CINT	= 5/20!1//0!1/1!4//1012
LINE	= 32/1/2/2!7/1/2!6/10/3!19//2
FINT	= 20;35;50;65
FLINE	= 0;24;25;30;15
HILO	= 0!7/;N#/10-20;!0!20/H#;L#/1018-1070;900-1014
HLSYM	= 0!1.2;1.2//21;21/2;2/hw!0!1.2;1.2//21;21/2;2/hw
CLRBAR	= 1/V/LL!0
WIND	= bk9/0.7/1/112
REFVEC	=
TITLE	= 1/-2/~ ? ${MDL} EMSL, THETA (850-sfc), 850 WND (kts)|~ EPAC 850 STBLTY!0
TEXT	= 1/22/2/hw
CLEAR	= YES
l
r

GLEVEL  = 900!900!900:0!0
GDPFUN  = mag(kntv(wnd))!sm9s(sub(thta,thta@0%none))//stb!stb!emsl!kntv(wnd@900%pres)
TITLE   = 1/-2/~ ? ${MDL} EMSL, THETA (900-sfc), 900 WND (kts)|~ EPAC 900 STBLTY!0
l
r

GLEVEL  = 925!925!925:0!0
GDPFUN  = mag(kntv(wnd))!sm9s(sub(thta,thta@0%none))//stb!stb!emsl!kntv(wnd@925%pres)
TITLE   = 1/-2/~ ? ${MDL} EMSL, THETA (925-sfc), 925 WND (kts)|~ EPAC 925 STBLTY!0
l
r

GLEVEL  = 950!950!950:0!0
GDPFUN  = mag(kntv(wnd))!sm9s(sub(thta,thta@0%none))//stb!stb!emsl!kntv(wnd@950%pres)
TITLE   = 1/-2/~ ? ${MDL} EMSL, THETA (950-sfc), 950 WND (kts)|~ EPAC 950 STBLTY!0
l
r

GLEVEL  = 500
restore /nwprod/gempak/ush/restore/500mb_hght_absv.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
TITLE	= 1/-2/~ ? ${MDL} @ HEIGHTS AND VORTICITY|~ PAC @ HGHT AND VORTICITY!0
CLEAR   = yes
l
ru

GDATTIM = f06-f48-06
CLEAR	= y
GLEVEL  = 0!0!850:1000!0!0
GVCORD  = none !none!pres!none!none
SCALE   = 0!0!-1!0!0
SKIP	= 0/1
GDPFUN  = p06i!p06i!(sub(hght@850,hght@1000))!sm5s(pmsl)! 
TYPE   = c/f!c!c!c!
CINT    = 0.1;0.25 !0.25/0.5!1!4! 
LINE    = 32//1/0!32//1/0!16/15/2/1!20//2! 
FINT    = .1;.25;.5;.75;1;1.25;1.5;1.75;2;2.25;2.5;2.75;3;3.25;3.5;3.75;4
FLINE   = 0;22-30;14-20;5
HILO    = 31;0/x#2/.01-10///y !31;0/x#2/.01-10///y !0!26;2/H#;L#///30;30/y !0
HLSYM   = 0!0!2;1.5//21//hw!0!0
WIND    = 
clrbar  = 1/V/LL
TITLE	= 5/-2/~ ? ${MDL} MSLP,1000-850 THK,6HR PCP|~ PAC PCPN, MSLP & THK!0
TEXT	= 1.2/22/2/hw
li
run

GDPFUN  = c06i!c06i!(sub(hght@850,hght@1000))!sm5s(pmsl)!
TITLE   = 5/-2/~ ? ${MDL} MSLP,1000-850 THK, 6HR CONV. PCP|~ PAC CONV PCP,MSLP,THK!0
li
run

! RH and Omega (vv) - maybe swap 700mb hght for 9950 TMPF??

GLEVEL	= 700
GVCORD	= PRES
SKIP	= 0! 1! 0! 0
GDATTIM = f00-f48-06
SCALE	= 0!-1! 3! 3
GDPFUN	= (relh) !(hght)!(omeg)!(omeg)
TYPE	= c/f ! c
CONTUR	= 1
CINT	= 50;70;90 !3 !-9;-7;-5;-3 !3;5;7;9
LINE	= 21//2/0 !20/1/2/1 !6/1/1/1 !16/5/1/1
FINT	= 70;90
FLINE	= 0;22;23
HILO	=
HLSYM	=
WIND	= Bk9/0.7/1/112
REFVEC	=
TITLE	= 1/-2/~ ? ${MDL} @ HEIGHTS, RH and OMEGA |~ PAC @ HGHT, RH & OMEGA!0
li
run
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
   mv ${metaname} ${COMOUT}/${mdl}_${PDY}_${cyc}_mar
   if [ $SENDDBN = "YES" ] ; then
      ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job ${COMOUT}/${mdl}_${PDY}_${cyc}_mar
   fi
fi

exit
