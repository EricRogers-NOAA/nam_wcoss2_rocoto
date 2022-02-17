#! /bin/sh
#
# Metafile Script : nam_meta_hur_new
#
# Log :
# D.W.Plummer/NCEP     2/97   Add log header
# J.W.Carr/HPC         3/97   Adjusted HILO parameters
# J.W.Carr/HPC     12/12/97   Converted gdplot to gdplot2
# J.L.Partain/MPC   5/25/98   Mods to plot same as AVN_hur
# J.W.Carr/HPC      7/20/98   Adjusted skip on 250 hght and wind and on MLW
# J.W.Carr/HPC      8/06/98   Changed map to medium resolution
# J.W.Carr/HPC      2/02/99   Changed skip to 0
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
export PS4='hur:$SECONDS + '
mkdir $DATA/hur
cd $DATA/hur
cp $FIXgempak/datatype.tbl datatype.tbl
#
mdl=nam
MDL=NAM
metatype="hur"
PDY2=`echo $PDY | cut -c3-`
metaname="${mdl}_${metatype}_${cyc}.meta"
device="nc | ${metaname}"
#
# Copy in datatype table to define gdfile type
#
#
gdattim="F00-F84-06"
gdattimpcpn24="F24-F84-06"

export pgm=gdplot2_nc;. prep_step; startmsg
gdplot2_nc >runlog << EOFplt
gdfile   = F-${MDL} | ${PDY2}/${cyc}00
gdattim  = ${gdattim}
garea    = 2.50;-105.95;24.87;-46.62
proj     = STR/90;-90;0
MAP      = 1/1/1/yes
LATLON   = 1//1/1/10
CONTUR	 = 2
clear    = y
skip     = 0/2
device   = ${device} 
PANEL	 = 0
TEXT	 = 1/22/2/hw
filter   = y

GLEVEL	 = 30:0!0
GVCORD	 = pdly!none
SCALE	 = 0
GDPFUN	 = mag(kntv(wnd))!sm5s(pmsl)!kntv(wnd@30:0%pdly)
TYPE	 = c/f!c!b
CINT	 = 5/20!4
LINE	 = 32/1/2/2!19//2
FINT	 = 20;35;50;65
FLINE	 = 0;24;25;30;15
HILO	 = 0!20/H#;L#/1020-1070;900-1012
HLSYM	 = 0!1.3;1.3//22;22/3;3/hw
CLRBAR	 = 1/V/LL!0
WIND	 = bk0!bk0!bk9/0.9/1.4/112
REFVEC	 =
TITLE	 = 1/-2/~ ? ${MDL} PMSL, BL WIND (0-30MB AGL; KTS)|~0-30MB AGL WND
r

GLEVEL	 = 700
GVCORD   = pres
GDPFUN	 = vor(wnd)              !vor(wnd)!kntv(wnd)
CINT	 = 2/-99/-2              !2/2/99
LINE	 = 29/5/1/2              !7/5/1/2
HILO	 = 2;6/X;N/-99--4;4-99   !                   
SCALE	 = 5                     !5 
WIND     = bk0!bk0!bk6/.8/1.4/112!0 
TITLE    = 1/-2/~ ? ${MDL} @ WIND AND REL VORT|~@ WIND AND REL VORT!0
FINT     = 4;6;8;10;12;14;16;18
FLINE	 = 0;14-20
TYPE	 = c/f!c!b

GLEVEL   = 500
GVCORD   = PRES
SCALE    = 5                  !5       !5         !5        !-1
GDPFUN   = (avor(wnd))//v     !v       !mul(v,-1) !mul(v,-1)!sm5s(hght)!kntv(wnd)
TYPE     = c/f                !c       !c/f       !c        !c         !b
CINT     = 2/10/99            !2/4/8   !2/10/99   !2/4/8    !3
LINE     = 7/5/1/2            !29/5/1/2!7/5/1/2   !29/5/1/2 !20/1/2/1
FINT     = 16;20;24;28;32;36;40;44
FLINE    = 0;23-15
HILO     = 2;6/X;N/10-99;10-99!        !2;6/X;N/10-99;10-99!
HLSYM    = 1;1//22;22/3;3/hw
CLRBAR   = 1
WIND     = bk0!bk0!bk0!bk0!bk0!bk9/0.8/1.4/112!0
REFVEC   =
TITLE    = 1/-2/~ ? ${MDL} @ ABS HGT AND VORTICITY|~@ HGHT AND VORTICITY!0

GLEVEL   = 850                !850      !0         !850
GVCORD   = pres               !pres     !none      !pres
GDPFUN   = vor(wnd)           !vor(wnd) !sm9s(emsl)!kntv(wnd)
TYPE     = c/f                !c        !c         !b
CINT     = 2/-99/-2           !2/2/99   !2//1008
LINE     = 29/5/1/2           !7/5/1/2  !6/1/1
HILO     = 2;6/X;N/-99--4;4-99!         !6/L#/880-1004///1
HLSYM    = 1;1//22;22/3;3/hw
SCALE    = 5                  !5        !0
WIND     = bk0                !bk0      !bk0       !bk9/.8/1.4/112
TITLE    = 1/-2/~ ? ${MDL} @ WIND AND REL VORT|~@ WIND AND REL VORT!0
FINT     = 4;6;8;10;12;14;16;18
FLINE    = 0;14-21
r

GLEVEL   = 700                !700      !0         !700
GVCORD   = pres               !pres     !none      !pres
GDPFUN   = vor(wnd)           !vor(wnd) !sm9s(emsl)!kntv(wnd)
CINT     = 2/-99/-2           !2/2/99   !2//1008
LINE     = 29/5/1/2           !7/5/1/2  !6//1
HILO     = 2;6/X;N/-99--4;4-99!         !6/L#/880-1004///1
HLSYM    = 1;1//22;22/3;3/hw
SCALE    = 5                  !5        !0
WIND     = bk0                !bk0      !bk0       !bk9/.8/1.4/112
TITLE    = 1/-2/~ ? ${MDL} @ WIND AND REL VORT|~@ WIND AND REL VORT!0
FINT     = 4;6;8;10;12;14;16;18
FLINE    = 0;14-21
TYPE     = c/f                !c        !c         !b
r

GLEVEL   = 500
GVCORD   = PRES
SKIP     = 0/1 
GDPFUN   = (avor(wnd))//v    !v       !mul(v,-1) !mul(v,-1)!sm5s(hght)!kntv(wnd)
CINT     = 2/10/99            !2/4/8   !2/10/99   !2/4/8    !2
LINE     = 7/5/1/2            !29/5/1/2!7/5/1/2   !29/5/1/2 !20/1/2/1
HILO     = 2;6/X;N/10-99;10-99!        !2;6/X;N/10-99;10-99!
HLSYM    = 1;1//22;22/3;3/hw
SCALE    = 5                  !5       !5         !5        !-1
CLRBAR   = 1
WIND     = bk0!bk0!bk0!bk0!bk0!bk9/0.8/1.4/112!0
TITLE    = 1/-2/~ ? ${MDL} @ WIND AND ABS VORT|~@ WIND AND ABS VORT!0
FINT     = 16;20;24;28;32;36;40;44
FLINE    = 0;23-15
TYPE     = c/f                !c       !c/f       !c        !c         !b
r

GLEVEL   = 250
GDPFUN   = (avor(wnd))//v     !v       !mul(v,-1)          !mul(v,-1)!sm5s(hght)!kntv(wnd)
TITLE    = 1/-2/~ ? ${MDL} @ ABS HGT AND VORTICITY|~@ HGHT AND VORTICITY!0

GLEVEL   = 250                                                                     
GVCORD   = PRES                                                                    
PANEL    = 0                                                                       
SKIP     = 0/1;1                
SCALE    = 0                        ! -1        !0
GDPFUN   = knts((mag(wnd)))         !sm9s(hght) !kntv(wnd)
TYPE     = c/f                      !c          !b
CINT     = 30;50;70;90;110;130;150  !12                                      
LINE     = 27/5/2/1                 !20/1/2/1                                       
FINT     = 70;90;110;130;150                                                       
FLINE    = 0;25;24;29;7;15                                                         
HILO     =                                                                         
HLSYM    =                                                                        
CLRBAR   = 1                                                                       
REFVEC   =                                                                      
WIND     = bk9/0.7/2/112 
filter   = no
TITLE	 = 1/-2/~ ? ${MDL} @ HEIGHTS, ISOTACHS AND WIND (KTS)|~@ HGHT AND WIND!0

GLEVEL   = 300:850       !850      !300
GVCORD   = pres          !pres     !pres
SKIP     = 0             !0/3;3    !0/3;3
SCALE    = 0
GDPFUN   = mag(vldf(wnd)!kntv(wnd)!kntv(wnd)
TYPE     = c/f           !a        !a
CINT     = 5/20
LINE     = 26//1
FINT     = 5/25
FLINE    = 0;24;30;29;23;22;14;15;16;17;20;5
HILO     =
HLSYM    =
CLRBAR   = 1
WIND     = ak0           !ak7/.1/1/221/.2!ak6/.1/1/221/.2
REFVEC   = 0!10 
TITLE    = 1/-2/~ ? ${MDL} @ WIND SHEAR (850=Purple, 300=Cyan) |~850-300MB WIND SHEAR!0
r

glevel   = 250
gvcord   = pres
skip     = 0             !0       !0       !0/2;2
scale    = 0             !5       !5
gdpfun   = mag(kntv(wnd))!div(wnd)!div(wnd)!kntv(wnd)
type     = c/f           !c       !c       !b
cint     = 30;50;70;90;110;130;150;170;190!2/-13/-3!2/3/18
line     = 26/1/2        !19/2/2  !3/1/2
fint     = 70;90;110;130;150;170;190
fline    = 0;24;25;29;7;15;14;2
hilo     = 0
hlsym    = 0
clrbar   = 1/V/LL!0
wind     = bk0           !bk0      !bk0      !bk9/.8/1.3/112
refvec   = 10
title    = 1/-2/~ ? ${MDL} @ HGHTS, ISOTACHS, & DIVERG|~@ SPEED & DIVERG!0
r

glevel   = 400:850!0
gvcord   = pres!none
scale    = 0
gdpfun   = squo(2,vadd(vlav(wnd@850:700%pres,vlav(wnd@500:400%pres)!sm9s(emsl)
type     = b                                                       !c
cint     = 0!4
line     = 0!20//3
SKIP     = 0/1;1
fint     =
fline    =
hilo     = 0!26;2/H#;L#/1020-1070;900-1012//30;30/y
hlsym    = 0!2;1.5//21//hw
clrbar   = 0
wind     = bk10/0.8/1.3/112!bk0
refvec   =
title    = 1/-2/~ ? ${MDL} 850-400mb MLW and MSLP|~850-400mb MLW & MSLP!0
r

GDATTIM	 = ${gdattimpcpn24}
GLEVEL	 = 0
GVCORD	 = none
SKIP	 = 0
SCALE	 = 0
GDPFUN	 = p24m
TYPE	 = c/f
CINT	 = 1;5;10
LINE	 = 32//1/0
FINT	 = 1;5;10;15;20;25;30;35;40;45;50;55;60;65;70;75;80;85
FLINE	 = 0;21-30;14-20;5
HILO	 = 31;0/x#/10-500///y
HLSYM	 = 1.5
CLRBAR	 = 1/V/LL
WIND	 = 
REFVEC	 =
TITLE	 = 1/-2/~ ? ${MDL} 24-HOUR TOTAL PCPN|~24-HR TOTAL PCPN
r

GDATTIM	 = ${gdattim}
glevel   = 400:800!0
gvcord   = pres!none
scale    = 0
gdpfun   = squo(2,vadd(vlav(wnd@800:700%pres,vlav(wnd@500:400%pres)!sm9s(emsl)
type     = b!c
cint     = !2
line     = !20//3
fint     = 
fline    = 
hilo     = 0!26;2/H#;L#/1020-1070;900-1012//30;30/y
hlsym    = 0!1.3;1.3//21//hw
clrbar   = 0
wind     = bk10/0.9/1.4/112!bk0
refvec   = 
title    = 1/-2/~ ? ${MDL} 800-400 MLW AND MSLP|~MLW & MSLP!0

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

