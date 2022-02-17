#!/bin/sh
#
# Metafile Script : nam_meta_mar_comp.sh
#
# This is a script which creates a metafile that runs a comparison of 500 MB 
# heights and PMSL between the older NAM model run and the newer one. 
# Log :
# J. Carr/PMB      12/11/2004      Pushed into production.
#
#
# Set up Local Variables
#
set -x
#
export PS4='mar_comp:$SECONDS + '
mkdir $DATA/mar_comp
cd $DATA/mar_comp
cp $FIXgempak/datatype.tbl datatype.tbl

mdl=nam
MDL=NAM
metatype="mar_comp"
PDY2=`echo $PDY | cut -c3-`
metaname="${mdl}_${metatype}_${cyc}.meta"
device="nc | ${metaname}"
MODEL=${COMROOT:?}/nawips/${envir:?}

export DBN_ALERT_TYPE=NAM_METAFILE

# DEFINE YESTERDAY
PDYm1=`$NDATE -24 ${PDY}${cyc} | cut -c -8`
PDY2m1=`echo $PDYm1 | cut -c 3-`
# DEFINE 2 DAYS AGO 
PDYm2=`$NDATE -48 ${PDY}${cyc} | cut -c -8`
PDY2m2=`echo $PDYm2 | cut -c 3-`

if [ ${cyc} -eq 12 ] ; then
    grid="F-${MDL} | ${PDY2}/${cyc}00"
    for gareas in WATL EPAC
    do
        if [ ${gareas} = "WATL" ] ; then
            garea="13;-84;50;-38"
            proj="str/90;-67;1"
            latlon="18/2///5;5"
        elif [ ${gareas} = "EPAC" ] ; then
            garea="11;-135;75;-98"
            proj="str/90;-100;1"
            latlon="18/2///5;5"
        fi
        for runtime in 06 00
        do
            if [ ${runtime} = "06" ] ; then
                cyc2="06"
                grid2="F-${MDL} | ${PDY2}/0600"
                add="06"
                testnamfhr="42"
            elif [ ${runtime} = "00" ] ; then
                cyc2="00"
                grid2="F-${MDL} | ${PDY2}/0000"
                add="12"
                testnamfhr="72"
            fi
            gdpfun1="sm5s(hght)!sm5s(hght)"
            gdpfun2="sm5s(pmsl)!sm5s(pmsl)"
            line="5/1/3/2/2!6/1/3/2/2"
            hilo1="5/H#;L#//5/5;5/y!6/H#;L#//5/5;5/y"
            hilo2="5/H#;L#/1018-1060;900-1012/5/10;10/y!6/H#;L#/1018-1060;900-1012/5/10;10/y"
            hilo3="5/H#;L#//5/5;5/y"
            hilo4="5/H#;L#/1018-1060;900-1012/5/10;10/y"
            title1="5/-2/~ ? ${MDL} @ HGT (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z 500 HGT!6/-3/~ ? ${MDL} @ HGT (${cyc2}Z CYAN)"
            title2="5/-2/~ ? ${MDL} PMSL (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z PMSL!6/-3/~ ? ${MDL} PMSL (${cyc2}Z CYAN)"
            title3="5/-2/~ ? ${MDL} @ HGT (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z 500 HGT"
            title4="5/-2/~ ? ${MDL} PMSL (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z PMSL"
            for namfhr in 00 06 12 18 24 30 36 42 48 54 60 66 72 78 84
            do
                namoldfhr="F`expr ${namfhr} + ${add}`"
                namfhr2=`echo ${namfhr}`
                namfhr="F${namfhr}"                 
                if [ ${namfhr2} -gt ${testnamfhr} ] ; then
                    grid="F-${MDL} | ${PDY2}/${cyc}00"
                    grid2=" "
                    namoldfhr=" "
                    gdpfun1="sm5s(hght)"
                    gdpfun2="sm5s(pmsl)"
                    line="5/1/3/2/2"
                    hilo1=`echo ${hilo3}`
                    hilo2=`echo ${hilo4}`
                    title1=`echo ${title3}`
                    title2=`echo ${title4}`
                fi 
export pgm=gdplot2_nc;. prep_step; startmsg

gdplot2_nc >runlog << EOF
DEVICE  = ${device}
MAP     = 1/1/1/yes
CLEAR   = yes
GAREA   = $garea
PROJ    = $proj
LATLON  = $latlon
SKIP    = 0
PANEL   = 0
CONTUR  = 1
CLRBAR  = 
FINT    = 
FLINE   = 
REFVEC  =  
WIND    = 0 

GDFILE  = ${grid}!${grid2}
GDATTIM = ${namfhr}!${namoldfhr}
GLEVEL  = 500
GVCORD  = PRES
GDPFUN  = ${gdpfun1}
LINE    = ${line} 
SCALE   = -1
TYPE    = c
CINT    = 6
HLSYM   = 1.2;1.2//21//hw
TEXT    = 1/21//hw
HILO    = ${hilo1}
TITLE   = ${title1}
list
run

CLEAR   = yes
GLEVEL  = 0
GVCORD  = none
SCALE   = 0
GDPFUN  = ${gdpfun2}
CINT    = 4
HLSYM   = 1.2;1.2//21//hw
TEXT    = 1/21//hw
GDFILE  = ${grid}  !${grid2}
GDATTIM = ${namfhr}!${namoldfhr}
LINE    = ${line}
HILO    = ${hilo2}
TITLE   = ${title2}
list
run

ex
EOF
cat runlog
            done
        done
    done 
elif [ ${cyc} -eq 18 ] ; then
    grid="F-${MDL} | ${PDY2}/${cyc}00"
    for gareas in WATL EPAC
    do
        if [ ${gareas} = "WATL" ] ; then
            garea="13;-84;50;-38"
            proj="str/90;-67;1"
            latlon="18/2///5;5"
        elif [ ${gareas} = "EPAC" ] ; then
            garea="11;-135;75;-98"
            proj="str/90;-100;1"
            latlon="18/2///5;5"
        fi
        for runtime in 12 06
        do
            if [ ${runtime} = "12" ] ; then
                cyc2="12"
                grid2="F-${MDL} | ${PDY2}/1200"
                add="06"
                testnamfhr="48"
            elif [ ${runtime} = "06" ] ; then
                cyc2="06"
                grid2="F-${MDL} | ${PDY2}/0600"
                add="12"
                testnamfhr="36"	
            fi
            gdpfun1="sm5s(hght)!sm5s(hght)"
            gdpfun2="sm5s(pmsl)!sm5s(pmsl)"
            line="5/1/3/2/2!6/1/3/2/2"
            hilo1="5/H#;L#//5/5;5/y!6/H#;L#//5/5;5/y"
            hilo2="5/H#;L#/1018-1060;900-1012/5/10;10/y!6/H#;L#/1018-1060;900-1012/5/10;10/y"
            hilo3="5/H#;L#//5/5;5/y"
            hilo4="5/H#;L#/1018-1060;900-1012/5/10;10/y"
            title1="5/-2/~ ? ${MDL} @ HGT (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z 500 HGT!6/-3/~ ? ${MDL} @ HGT (${cyc2}Z CYAN)"
            title2="5/-2/~ ? ${MDL} PMSL (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z PMSL!6/-3/~ ? ${MDL} PMSL (${cyc2}Z CYAN)"
            title3="5/-2/~ ? ${MDL} @ HGT (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z 500 HGT"
            title4="5/-2/~ ? ${MDL} PMSL (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z PMSL"
            for namfhr in 00 06 12 18 24 30 36 42 48 54 60 66 72 78 84
            do
                namoldfhr="F`expr ${namfhr} + ${add}`"
                namfhr2=`echo ${namfhr}`
                namfhr="F${namfhr}"                 
                if [ ${namfhr2} -gt ${testnamfhr} ] ; then
                    grid="F-${MDL} | ${PDY2}/${cyc}00"
                    grid2=" "
                    namoldfhr=" "
                    gdpfun1="sm5s(hght)"
                    gdpfun2="sm5s(pmsl)"
                    line="5/1/3/2/2"
                    hilo1=`echo ${hilo3}`
                    hilo2=`echo ${hilo4}`
                    title1=`echo ${title3}`
                    title2=`echo ${title4}`
                fi 

gdplot2_nc >runlog << EOF
DEVICE  = ${device}
MAP     = 1/1/1/yes
CLEAR   = yes
GAREA   = $garea
PROJ    = $proj
LATLON  = $latlon
SKIP    = 0            
PANEL   = 0
CONTUR  = 1
CLRBAR  = 
FINT    = 
FLINE   = 
REFVEC  =  
WIND    = 0 

GDFILE  = ${grid}!${grid2}
GDATTIM = ${namfhr}!${namoldfhr}
GLEVEL  = 500
GVCORD  = PRES
GDPFUN  = ${gdpfun1}
LINE    = ${line} 
SCALE   = -1
TYPE    = c
CINT    = 6
HLSYM   = 1.2;1.2//21//hw
TEXT    = 1/21//hw
HILO    = ${hilo1}
TITLE   = ${title1}
run

CLEAR   = yes
GLEVEL  = 0
GVCORD  = none
SCALE   = 0
GDPFUN  = ${gdpfun2}
CINT    = 4
HLSYM   = 1.2;1.2//21//hw
TEXT    = 1/21//hw
GDFILE  = ${grid}  !${grid2}
GDATTIM = ${namfhr}!${namoldfhr}
LINE    = ${line}
HILO    = ${hilo2}
TITLE   = ${title2}
run

ex
EOF
cat runlog
            done
        done 
    done 
elif [ ${cyc} -eq 00 ] ; then
    grid="F-${MDL} | ${PDY2}/${cyc}00"
    for gareas in WATL EPAC
    do
        if [ ${gareas} = "WATL" ] ; then
            garea="13;-84;50;-38"
            proj="str/90;-67;1"
            latlon="18/2///5;5"
        elif [ ${gareas} = "EPAC" ] ; then
            garea="11;-135;75;-98"
            proj="str/90;-100;1"
            latlon="18/2///5;5"
        fi
        for runtime in 18 12
        do
            if [ ${runtime} = "18" ] ; then
                cyc2="18"
                export HPCNAM=${MODEL}/nam.${PDYm1}
                grid2="F-NAMHPC | ${PDY2m1}/1800"
                add="06"
                testnamfhr="42"
            elif [ ${runtime} = "12" ] ; then
                cyc2="12"
                export HPCNAM=${MODEL}/nam.${PDYm1}
                grid2="F-NAMHPC | ${PDY2m1}/1200"
                add="12"
                testnamfhr="72"	
            fi
            gdpfun1="sm5s(hght)!sm5s(hght)"
            gdpfun2="sm5s(pmsl)!sm5s(pmsl)"
            line="5/1/3/2/2\6/1/3/2/2"
            hilo1="5/H#;L#//5/5;5/y!6/H#;L#//5/5;5/y"
            hilo2="5/H#;L#/1018-1060;900-1012/5/10;10/y!6/H#;L#/1018-1060;900-1012/5/10;10/y"
            hilo3="5/H#;L#//5/5;5/y"
            hilo4="5/H#;L#/1018-1060;900-1012/5/10;10/y"
            title1="5/-2/~ ? ${MDL} @ HGT (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z 500 HGT!6/-3/~ ? ${MDL} @ HGT (${cyc2}Z CYAN)"
            title2="5/-2/~ ? ${MDL} PMSL (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z PMSL!6/-3/~ ? ${MDL} PMSL (${cyc2}Z CYAN)"
            title3="5/-2/~ ? ${MDL} @ HGT (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z 500 HGT"
            title4="5/-2/~ ? ${MDL} PMSL (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z PMSL"
            for namfhr in 00 06 12 18 24 30 36 42 48 54 60 66 72 78 84
            do
                namoldfhr=F`expr ${namfhr} + ${add}`
                namfhr2=`echo ${namfhr}`
                namfhr="F${namfhr}"
                if [ ${namfhr2} -gt ${testnamfhr} ] ; then
                    grid="F-${MDL} | ${PDY2}/${cyc}00"
                    grid2=" "
                    namoldfhr=" "
                    gdpfun1="sm5s(hght)"
                    gdpfun2="sm5s(pmsl)"
                    line="5/1/3/2/2"
                    hilo1=`echo ${hilo3}`
                    hilo2=`echo ${hilo4}`
                    title1=`echo ${title3}`
                    title2=`echo ${title4}`
                fi

gdplot2_nc >runlog << EOF
DEVICE  = ${device}
MAP     = 1/1/1/yes
CLEAR   = yes
GAREA   = $garea
PROJ    = $proj
LATLON  = $latlon
SKIP    = 0            
PANEL   = 0
CONTUR  = 1
CLRBAR  = 
FINT    = 
FLINE   = 
REFVEC  = 
WIND    = 0 

GDFILE  = ${grid}!${grid2}
GDATTIM = ${namfhr}!${namoldfhr}
GLEVEL  = 500
GVCORD  = PRES
GDPFUN  = ${gdpfun1}
LINE    = ${line} 
SCALE   = -1
TYPE    = c
CINT    = 6
HLSYM   = 1.2;1.2//21//hw
TEXT    = 1/21//hw
HILO    = ${hilo1}
TITLE   = ${title1}
list
run

CLEAR   = yes
GLEVEL  = 0
GVCORD  = none
SCALE   = 0
GDPFUN  = ${gdpfun2}
CINT    = 4
HLSYM   = 1.2;1.2//21//hw
TEXT    = 1/21//hw
GDFILE  = ${grid}  !${grid2}
GDATTIM = ${namfhr}!${namoldfhr}
LINE    = ${line}
HILO    = ${hilo2}
TITLE   = ${title2}
list
run

ex
EOF
cat runlog
            done
        done 
    done 
elif [ ${cyc} -eq 06 ] ; then
    grid="F-${MDL} | ${PDY2}/${cyc}00"
    for gareas in WATL EPAC
    do
        if [ ${gareas} = "WATL" ] ; then
            garea="13;-84;50;-38"
            proj="str/90;-67;1"
            latlon="18/2///5;5"
        elif [ ${gareas} = "EPAC" ] ; then
            garea="11;-135;75;-98"
            proj="str/90;-100;1"
            latlon="18/2///5;5"
        fi
        for runtime in 00 18
        do
            if [ ${runtime} = "00" ] ; then
                cyc2="00"
                grid2="F-${MDL} | ${PDY2}/0000"
                add="06"
                testnamfhr="48"
            elif [ ${runtime} = "18" ] ; then
                cyc2="18"
                export HPCNAM=${MODEL}/nam.${PDYm1}
                grid2="F-NAMHPC | ${PDY2m1}/1800"
                add="12"
                testnamfhr="36"	
            fi
            gdpfun1="sm5s(hght)!sm5s(hght)"
            gdpfun2="sm5s(pmsl)!sm5s(pmsl)"
            line="5/1/3/2/2!6/1/3/2/2"
            hilo1="5/H#;L#//5/5;5/y!6/H#;L#//5/5;5/y"
            hilo2="5/H#;L#/1018-1060;900-1012/5/10;10/y!6/H#;L#/1018-1060;900-1012/5/10;10/y"
            hilo3="5/H#;L#//5/5;5/y"
            hilo4="5/H#;L#/1018-1060;900-1012/5/10;10/y"
            title1="5/-2/~ ? ${MDL} @ HGT (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z 500 HGT!6/-3/~ ? ${MDL} @ HGT (${cyc2}Z CYAN)"
            title2="5/-2/~ ? ${MDL} PMSL (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z PMSL!6/-3/~ ? ${MDL} PMSL (${cyc2}Z CYAN)"
            title3="5/-2/~ ? ${MDL} @ HGT (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z 500 HGT"
            title4="5/-2/~ ? ${MDL} PMSL (${cyc}Z YELLOW)|^${gareas} ${cyc}Z VS ${cyc2}Z PMSL"
            for namfhr in 00 06 12 18 24 30 36 42 48 54 60 66 72 78 84
            do
                namoldfhr=F`expr ${namfhr} + ${add}`
                namfhr2=`echo ${namfhr}`
                namfhr="F${namfhr}"                 
                if [ ${namfhr2} -gt ${testnamfhr} ] ; then
                    grid="F-${MDL} | ${PDY2}/${cyc}00"
                    grid2=" "
                    namoldfhr=" "
                    gdpfun1="sm5s(hght)"
                    gdpfun2="sm5s(pmsl)"
                    line="5/1/3/2/2"
                    hilo1=`echo ${hilo3}`
                    hilo2=`echo ${hilo4}`
                    title1=`echo ${title3}`
                    title2=`echo ${title4}`
                fi

gdplot2_nc >runlog << EOF
DEVICE  = ${device}
MAP     = 1/1/1/yes
CLEAR   = yes
GAREA   = $garea
PROJ    = $proj
LATLON  = $latlon
SKIP    = 0            
PANEL   = 0
CONTUR  = 1
CLRBAR  = 
FINT    = 
FLINE   = 
REFVEC  = 
WIND    = 0

GDFILE  = ${grid}!${grid2}
GDATTIM = ${namfhr}!${namoldfhr}
GLEVEL  = 500
GVCORD  = PRES
GDPFUN  = ${gdpfun1}
LINE    = ${line} 
SCALE   = -1
TYPE    = c
CINT    = 6
HLSYM   = 1.2;1.2//21//hw
TEXT    = 1/21//hw
HILO    = ${hilo1}
TITLE   = ${title1}
list
run

CLEAR   = yes
GLEVEL  = 0
GVCORD  = none
SCALE   = 0
GDPFUN  = ${gdpfun2}
CINT    = 4
HLSYM   = 1.2;1.2//21//hw
TEXT    = 1/21//hw
GDFILE  = ${grid}  !${grid2}
GDATTIM = ${namfhr}!${namoldfhr}
LINE    = ${line}
HILO    = ${hilo2}
TITLE   = ${title2}
list
run

ex
EOF
export err=$?;err_chk
cat runlog
            done
        done 
    done
fi

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
      ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job ${COMOUT}/${mdl}_${PDY}_${cyc}_${metatype}
   fi
fi

exit
