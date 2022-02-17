#! /bin/ksh
#
# Metafile Script : nam_meta_svr_new
#
# Log :
# D.W.Plummer/NCEP     2/97   Add log header
# J. Carr/HPC       5/14/97   Added severe wx product
# J. Carr/HPC      10/31/97   Changed name and removed all avn products
# J. Carr/HPC      12/05/97   Changed gdplot to gdplot2
# J. Carr/HPC      12/09/97   Added 500 mb hght, tmp and wind product
# J. Carr/HPC       3/13/97   Added 4-panel and soundings
# J. Carr/HPC       8/06/98   Changed map to medium resolution
# J. Carr/HPC       6/21/99   Added a filter to map
# J. Carr/HPC        5/2001   Added a mn variable for a/b side dbnet root variable.
# J. Carr/HPC        6/2001   Converted to a korn shell prior to delivering script to Production.
# J. Carr/HPC        7/2001   Submitted.
# J. Carr/PMB       11/2004   Added ? to all title/TITLE lines.
#
# Set up Local Variables
#
set -x
#
export PS4='snd:$SECONDS + '
mkdir $DATA/snd
cd $DATA/snd
cp $FIXgempak/datatype.tbl datatype.tbl

mdl=nam
MDL=NAM
metatype="snd"
metaname="${mdl}_${metatype}_${cyc}.meta"
PDY2=`echo $PDY | cut -c3-`
device="nc | ${metaname}"
#
gdattim="F00-F84-06"
gdattim2="F06-F84-06"

export pgm=gdplot2_nc;. prep_step; startmsg
gdplot2_nc >runlog <<EOFplt
gdattim = ${gdattim}
gdfile  = F-${MDL} | ${PDY2}/${cyc}00
garea   = us
proj    = 
device  = ${device}
TEXT    = 1/22/2/hw
map     = 1/1/1/yes
panel   = 0
refvec  =
clear   = y
skip    = 0
filter  = y
contur  = 2

glevel  = 8400:9800!8400:9800!90:60!0
gvcord  = sgma!sgma!pdly!none
scale   = 0!0!3!0
gdpfun  = sm9s(relh)!sm9s(relh)!sm9s(omeg)!sm9s(emsl)!kntv(wnd@30:0%pdly)
type    = c/f       !c         !c         !c         !b
cint    = 80;90;95!10;20;30;40;50;60;70!-9;-7;-5;-3;-1!0;1
line    = 32//1!25//1!6//3!20
fint    = 70;80;90;95
fline   = 0;24;23;22;14
HILO    = 0!0!0!20/H#;L#/1020-1070;900-1012
HLSYM   = 0!0!0!1;1//22;22/3;3/hw
clrbar  = 1/V/LL!0
wind    = bk0!bk0!bk0!bk0!bk9/0.8/2/112
title   = 1/-2/~ ? 20-160MB AGL RH,60-90MB AGL OMG,0-30MB AGL WND|~20-160MB AGL RH!0
 
 
glevel  = 30:0!30:0!90:60!0
gvcord  = pdly!pdly!pdly!none
scale   = 0!0!3!0
gdpfun  = sm9s(relh)!sm9s(relh)!sm9s(omeg)!sm9s(emsl)!kntv(wnd@30:0%pdly)
type    = c/f       !c         !c         !c         !b
cint    = 80;90;95!10;20;30;40;50;60;70!-9;-7;-5;-3;-1!0;1
line    = 32//1!25//1!6//3!20
fint    = 70;80;90;95
fline   = 0;24;23;22;14
HILO    = 0!0!0!20/H#;L#/1020-1070;900-1012
HLSYM   = 0!0!0!1;1//22;22/3;3/hw
clrbar  = 1/V/LL!0
wind    = bk0!bk0!bk0!bk0!bk9/0.8/2/112
title   = 1/-2/~ ? 0-30MB AGL RH,60-90MB AGL OMG,BL WND|~0-30MB AGL RH!0

glevel  = 90:60!90:60!90:60!0
gvcord  = pdly!pdly!pdly!none
scale   = 0!0!3!0
gdpfun  = sm9s(relh)!sm9s(relh)!sm9s(omeg)!sm9s(emsl)!kntv(wnd@30:0%pdly)
type    = c/f       !c         !c         !c         !b
cint    = 80;90;95!10;20;30;40;50;60;70!-9;-7;-5;-3;-1!0;1
line    = 32//1!25//1!6//3!20
fint    = 70;80;90;95
fline   = 0;24;23;22;14
HILO    = 0!0!0!20/H#;L#/1020-1070;900-1012
HLSYM   = 0!0!0!1;1//22;22/3;3/hw
clrbar  = 1/V/LL!0
wind    = bk0!bk0!bk0!bk0!bk9/0.8/2/112
title   = 1/-2/~ ? 60-90MB AGL RH,60-90MB AGL OMG,BL WND|~60-90MB AGL RH!0

glevel  = 120:90!120:90!90:60!0
gvcord  = pdly!pdly!pdly!none
scale   = 0!0!3!0
gdpfun  = sm9s(relh)!sm9s(relh)!sm9s(omeg)!sm9s(emsl)!kntv(wnd@30:0%pdly)
type    = c/f       !c         !c         !c         !b
cint    = 80;90;95!10;20;30;40;50;60;70!-9;-7;-5;-3;-1!0;1
line    = 32//1!25//1!6//3!20
fint    = 70;80;90;95
fline   = 0;24;23;22;14
HILO    = 0!0!0!20/H#;L#/1020-1070;900-1012
HLSYM   = 0!0!0!1;1//22;22/3;3/hw
clrbar  = 1/V/LL!0
wind    = bk0!bk0!bk0!bk0!bk9/0.8/2/112
title   = 1/-2/~ ? 90-120MB AGL RH,40-70MB AGL OMG,BL WND|~90-120MB AGL RH!0

glevel  = 150:120!150:120!90:60!0
gvcord  = pdly!pdly!pdly!none
scale   = 0!0!3!0
gdpfun  = sm9s(relh)!sm9s(relh)!sm9s(omeg)!sm9s(emsl)!kntv(wnd@30:0%pdly)
type    = c/f       !c         !c         !c         !b
cint    = 80;90;95!10;20;30;40;50;60;70!-9;-7;-5;-3;-1!0;1
line    = 32//1!25//1!6//3!20
fint    = 70;80;90;95
fline   = 0;24;23;22;14
HILO    = 0!0!0!20/H#;L#/1020-1070;900-1012
HLSYM   = 0!0!0!1;1//22;22/3;3/hw
wind    = bk0!bk0!bk0!bk0!bk9/0.8/2/112
title   = 1/-2/~ ? 120-150MB AGL RH,40-70MB AGL OMG,BL WND|~120-150MB AGL RH!0

GLEVEL	= 0!0!0!0!9823
GVCORD	= FRZL!FRZL!FRZL!FRZL!sgma
PANEL	= 0
SCALE	= 0!-3!-2!0!0
GDPFUN	= (relh)   !mul(3.28,hght) !mul(3.28,hght) !sub(hght,hght@0%none) !tmpc
TYPE	= c/f      ! c             !c              !c/f                   !c
CINT	= 70;90;95!1;2;3;5;6;7;9;10;11;13;14;15 !40;80;120;160 !-100;25 !0;100
LINE	= 32//1/0  !6/1/2/0                        !29/1/4    !8/1/5   !15/1/4
FINT	= 70;90;95    !!!-100;25!
FLINE	= 0;24;23;22  !!!8;8;0!
HILO	=
HLSYM	=
WIND	=
TITLE	= 1/-2/~ ? ${MDL} FRZNG LVL HGHT, RH, 18MB AGL 0C TMP|~FRZG LVL HGHT & RH!0

GLEVEL  = 850!30:0!0
GVCORD  = pres!pdly!none
SCALE   = 4!0!0
GDPFUN  = adv(tmpc,wnd)!mag(kntv(wnd))!sm5s(pmsl)!kntv(wnd@30:0%pdly)
TYPE    = c/f          !c             !c         !b
CINT    = 1!5;10;15;20;25;30;35;40;45;50;55;60;65;70!4
LINE    = 32/1/2/1!23;23;23;22;22;22;22;21;21;21;21;7;7;7/1/2!1//2
FINT    = -7;-5;-3;-1;1;3;5;7
FLINE   = 7;29;30;24;0;14;15;18;5
HILO    = 0!0!1/H#;L#/1020-1070;900-1012
HLSYM   = 0!0!1.5;1.5//22;22/3;3/hw
WIND    = bk0!bk0!bk0!bk9/0.8/2/112
TITLE   = 1/-2/~ ? ${MDL} MSLP, BL1 (0-30MB AGL) WND & 850 MB T ADV|~LL TURB!0

GLEVEL  = 914:10!914:2!914:2!0!914:10
gvcord  = hght!hght!hght!none!hght
scale   = 0
gfunc   = mag(kntv(vldf(wnd))!stab(tmpc)//s!s!sm5s(pmsl)!kntv(vldf(wnd))
ctype   = c/f!c
cint    = 5/15!2/0!1//-4!4
line    = 32/1/2!29/1/3!7/1/5!19
fint    = 15;30;45;60
fline   = 0;24;25;30;15
hilo    = 0!0!0!20/H#;L#!
HLSYM   = 0!0!0!1.5;1.5//22;22/3;3/hw!
wind    = bk0!bk0!bk0!bk0!bk9/0.6/2/112
title   = 1/-2/~ ? ${MDL} 10-914m WND SHR (KTS), MSLP, STAB|~VWS, STAB!0

GLEVEL  = 700!30:0!700!700!0!700
GVCORD  = pres!pdly!pres!pres!none!pres
SKIP    = 0/2;1
SCALE   = 0
GDPFUN  = sm9s(relh)!sm9s(dwpf)!sm9s(relh)!sm9s(tmpc)!pmsl!sm9s(relh)!kntv(wnd@30:0%pdly)!kntv(wnd@700%pres)
TYPE    = c/f       !c/f       !c         !c         !c   !c         !b                  !a
CINT    = 10;20;30;40!50;53;56;59;62;65;68;71;74!-5;50!3!4//1016!10;20;30;40
LINE    = 10/1/2!32/1/2/1!8/1/5!4/5/3!5//3!10/1/2
FINT    = 0;50!50;56;62;68;74
FLINE   = 0;8;0!0;23;22;30;14;2
HILO    = 0!0!0!0!5/H#;L#/1080-2000;900-1012!0
HLSYM   = !!!!1.5;1.5//22/3/hw!
CLRBAR  = 0!1/V/LL!0
WIND    = bk0!bk0!bk0!bk0!bk0!bk0!bk9/0.8/2/112!ak6/.3/2/221/.4
TITLE   = 1/-2/~ ? ${MDL} BL DWPT, WIND, 700mb TEMP, RH & WND & MSLP|~SVR WX!0
TEXT    = 1/22/2/hw
GAREA   = 25.5;-108.4;41.8;-65.1
PROJ    = STR/90.0;-105.0;0.0
filter  = n
r

ex

EOFplt
export err=$?;err_chk
cat runlog
 
times="000 006 012 018 024 030 036 042 048 054 060 066 072 078 084"

for fhr in ${times}
do
typeset -Z3 fhr
export pgm=gdprof;. prep_step; startmsg
gdprof >runlog << EOFplt
GDATTIM  = F${fhr}
GDFILE   = $COMIN/${mdl}_${PDY}${cyc}f${fhr}
SCALE    = 0
GVECT    = wind
XAXIS    = -39/35/10/1;1;1
PTYPE    = skew/0/4;6;4;4
YAXIS    =
REFVEC   = 
WIND     = bk6/.8/2
WINPOS   = 1
PANEL    = 0
FILTER   = no
BORDER   = 1
MARKER   = 0
OUTPUT   = T
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = iad
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} IAD SOUNDING|~IAD SNDG
CLEAR    = YES
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = dca
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} DCA SOUNDING|~DCA SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = ric
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} RICHMOND SOUNDING|~RIC SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE    = 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = rdu
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} RALEIGH SOUNDING|~RDU SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE    = 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = alb
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} ALB SOUNDING|~ALB SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = atl
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} ATL SOUNDING|~ATL SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = sil
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} SIL SOUNDING|~SIL SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = stl
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} STL SOUNDING|~STL SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = mkc
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} MKC SOUNDING|~MKC SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = okc
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} OKC SOUNDING|~OKC SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = ftw
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} FTW SOUNDING|~FTW SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = msp
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} MSP SOUNDING|~MSP SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = slc
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} SLC SOUNDING|~SLC SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = den
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} DEN SOUNDING|~DEN SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = pdx
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} PDX SOUNDING|~PDX SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = sea
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} SEA SOUNDING|~SEA SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = boi
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} BOI SOUNDING|~BOI SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = sac
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} SAC SOUNDING|~SAC SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

GVCORD   = pres
GFUNC    = tmpc
GPOINT   = lax
LINE     = 2/1/3
TITLE    = 1/-2/~ ? ${MDL} LAX SOUNDING|~LAX SNDG
CLEAR    = YES
THTALN   = 12/3/1
THTELN   = 15/1/1
MIXRLN   = 5/10/2
ru

GFUNC   = dwpc
LINE	= 3/5/3
CLEAR   = no
THTALN  = 0
THTELN  = 0
MIXRLN  = 0
TITLE   = 0
ru

ex
EOFplt
export err=$?;err_chk
cat runlog

done
gpend

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
