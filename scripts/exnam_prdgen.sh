#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#. .
# Script name:         exnam_prdgen.sh
# Script description:  Run nam product generator jobs
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract: This script runs the Nam PRDGEN jobs
#
# Script history log:
# 1999-06-23  Eric Rogers
# 1999-08-25  Brent Gordon  Modified for production, removed here file.
# 2003-03-21  Eric Rogers  Modified for special hourly output
# 2006-10-31  Eric Rogers  Added 6,7th PRDGEN step to make NAM grids for AFWA
#    (3-hourly only)
# 2008-08-14  Eric Rogers  Added 8th PRDGEN step to make expanded 32 km output grid 
#    (3-hourly only)
# 2011-02-18  Eric Rogers  Make expanded 32-km grid hourly to 36-h.
# 2015-??-??  Eric Rogers  Convert to GRIB2 : drop PRDGEN code, use wgrib2 for
#                          interpolation
# 2016-11-08  Eric Rogers  Drop ICWF processing for grid #207 and #217
# 2019-01-18  Eric Rogers  Changes to run on Dell

set -xa
msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA

#
# Get needed variables from exnam_prelim.sh.ecf
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh

########################################################
# Create a script to be poe'd
#

for fhr in $fcsthrs
do
  if [ -s $COMIN/${RUN}.${cycle}.bgdawp${fhr}.${tmmark} ]; then
    ln -s -f $COMIN/${RUN}.${cycle}.bgdawp${fhr}.${tmmark} BGDAWP${fhr}.${tmmark}
  else
    msg="NAM bgdawp file missing, exit"
    err_exit $msg
  fi

  if [ $fhr -eq 00 ]; then
    ln -s -f $COMIN/${RUN}.${cycle}.bgdawp${fhr}.${tmmark}.anl BGDAWP${fhr}.${tmmark}.anl
    if [ $tmmark = tm06 ]; then    
      ln -s -f $COMIN/${RUN}.${cycle}.bgdawp${fhr}.${tmmark}.ges BGDAWP${fhr}.${tmmark}.ges
    fi
  fi

  mkdir -p $DATA/prdgen1_${fhr}
  mkdir -p $DATA/prdgen2_${fhr}
  mkdir -p $DATA/prdgen3_${fhr}
  mkdir -p $DATA/prdgen4_${fhr}
  mkdir -p $DATA/prdgen5_${fhr}
  mkdir -p $DATA/prdgen6_${fhr}
  mkdir -p $DATA/prdgen7_${fhr}
  mkdir -p $DATA/prdgen8_${fhr}

  y=`expr $fhr % 3`

# y = 0 ---> Standard 3-hourly output
# y = 1 ---> Special hourly output for forecast hours < 36 h

  echo "$USHnam/nam_prdgen1.sh $fhr $y" >> $DATA/poescript
  echo "$USHnam/nam_prdgen2.sh $fhr $y" >> $DATA/poescript
  echo "$USHnam/nam_prdgen3.sh $fhr $y" >> $DATA/poescript
  echo "$USHnam/nam_prdgen4.sh $fhr $y" >> $DATA/poescript
  echo "$USHnam/nam_prdgen5.sh $fhr $y" >> $DATA/poescript
  echo "$USHnam/nam_prdgen6.sh $fhr $y" >> $DATA/poescript
  echo "$USHnam/nam_prdgen7.sh $fhr $y" >> $DATA/poescript
  echo "$USHnam/nam_prdgen8.sh $fhr $y" >> $DATA/poescript
done
chmod 775 $DATA/poescript

#
# Execute the script 
# 
export CMDFILE=$DATA/poescript
${MPIEXEC} -cpu-bind core -configfile $CMDFILE
export err=$?; err_chk

#
# Convert grids used for ICWF and/or AWIPS job back to GRIB1
#

if [ $tmmark = tm00 -a $y -eq 0 -a $RUNTYPE = CATCHUP ] ; then

$CNVGRIB -g21 $COMOUT/${RUN}.${cycle}.awip3d${fhr}.tm00.grib2 ${RUN}.${cycle}.awip3d${fhr}.tm00
$CNVGRIB -g21 $COMOUT/${RUN}.${cycle}.awip20${fhr}.tm00.grib2 ${RUN}.${cycle}.awip20${fhr}.tm00
$CNVGRIB -g21 $COMOUT/${RUN}.${cycle}.awipak${fhr}.tm00.grib2 ${RUN}.${cycle}.awipak${fhr}.tm00
$CNVGRIB -g21 $COMOUT/${RUN}.${cycle}.awip12${fhr}.tm00.grib2 ${RUN}.${cycle}.awip12${fhr}.tm00
$CNVGRIB -g21 $COMOUT/${RUN}.${cycle}.awak3d${fhr}.tm00.grib2 ${RUN}.${cycle}.awak3d${fhr}.tm00
$CNVGRIB -g21 $COMOUT/${RUN}.${cycle}.awp237${fhr}.tm00.grib2 ${RUN}.${cycle}.awp237${fhr}.tm00
$CNVGRIB -g21 $COMOUT/${RUN}.${cycle}.awp207${fhr}.tm00.grib2 ${RUN}.${cycle}.awp207${fhr}.tm00
$CNVGRIB -g21 $COMOUT/${RUN}.${cycle}.awp211${fhr}.tm00.grib2 ${RUN}.${cycle}.awp211${fhr}.tm00

# Change to correct GRIB1 grid number so ICWF and/or tocgrib will work
# On Dell, use overgridid from prod_util

echo 212 > input
rm fort.*
export pgm=overgridid;. prep_step
ln -s ${RUN}.${cycle}.awip3d${fhr}.tm00 fort.11
ln -s $COMOUT/${RUN}.${cycle}.awip3d${fhr}.tm00 fort.51
${OVERGRIDID} < input >> $pgmout
export err=$?;err_chk
rm ${RUN}.${cycle}.awip3d${fhr}.tm00 input

echo 215 > input
rm fort.*
export pgm=overgridid;. prep_step
ln -s ${RUN}.${cycle}.awip20${fhr}.tm00 fort.11
ln -s $COMOUT/${RUN}.${cycle}.awip20${fhr}.tm00 fort.51
${OVERGRIDID} < input >> $pgmout
export err=$?;err_chk
rm ${RUN}.${cycle}.awip20${fhr}.tm00 input

echo 216 > input
rm fort.*
export pgm=overgridid;. prep_step
ln -s ${RUN}.${cycle}.awipak${fhr}.tm00 fort.11
ln -s $COMOUT/${RUN}.${cycle}.awipak${fhr}.tm00 fort.51
${OVERGRIDID} < input >> $pgmout
export err=$?;err_chk
rm ${RUN}.${cycle}.awipak${fhr}.tm00 input

echo 218 > input
rm fort.*
export pgm=overgridid;. prep_step
ln -s ${RUN}.${cycle}.awip12${fhr}.tm00 fort.11
ln -s $COMOUT/${RUN}.${cycle}.awip12${fhr}.tm00 fort.51
${OVERGRIDID} < input >> $pgmout
export err=$?;err_chk
rm ${RUN}.${cycle}.awip12${fhr}.tm00 input

echo 242 > input
rm fort.*
export pgm=overgridid;. prep_step
ln -s ${RUN}.${cycle}.awak3d${fhr}.tm00 fort.11
ln -s $COMOUT/${RUN}.${cycle}.awak3d${fhr}.tm00 fort.51
${OVERGRIDID} < input >> $pgmout
export err=$?;err_chk
rm ${RUN}.${cycle}.awak3d${fhr}.tm00 input

echo 237 > input
rm fort.*
export pgm=overgridid;. prep_step
ln -s ${RUN}.${cycle}.awp237${fhr}.tm00 fort.11
ln -s $COMOUT/${RUN}.${cycle}.awp237${fhr}.tm00 fort.51
${OVERGRIDID} < input >> $pgmout
export err=$?;err_chk
rm ${RUN}.${cycle}.awp237${fhr}.tm00 input

echo 207 > input
rm fort.*
export pgm=overgridid;. prep_step
ln -s ${RUN}.${cycle}.awp207${fhr}.tm00 fort.11
ln -s $COMOUT/${RUN}.${cycle}.awp207${fhr}.tm00 fort.51
${OVERGRIDID} < input >> $pgmout
export err=$?;err_chk
rm ${RUN}.${cycle}.awp207${fhr}.tm00 input

echo 211 > input
rm fort.*
export pgm=overgridid;. prep_step
ln -s ${RUN}.${cycle}.awp211${fhr}.tm00 fort.11
ln -s $COMOUT/${RUN}.${cycle}.awp211${fhr}.tm00 fort.51
${OVERGRIDID} < input >> $pgmout
export err=$?;err_chk
rm ${RUN}.${cycle}.awp211${fhr}.tm00 input

fi

echo done > $FCSTDIR/namprdgen.done${fhr}.tm00

########################################################
DOICWF=YES

if [ $tmmark = tm00 -a $DOICWF = YES -a $RUNTYPE = CATCHUP ] ; then

    if [ $cyc -eq 06 -o $cyc -eq 18 ]
    then
	FHMAX=48
	FHMAX2=48
    else
	FHMAX=60
	FHMAX2=84
    fi
    
    if [ $fcsthrs -eq $FHMAX -o $fcsthrs -eq $FHMAX2 ]
    then
	if [ $fcsthrs -eq $FHMAX2 ]
	then
	    FHMAX=$FHMAX2
	fi
	icnt=0
	while [ $icnt -lt 1000 ]
	do
	    fh=00
	    typeset -Z2 fh
	    
	    while [ $fh -le $FHMAX ]
	    do
		if [ -s $COMOUT/${RUN}.${cycle}.awip3d${fh}.tm00 -a \
		    -s $COMOUT/${RUN}.${cycle}.awip20${fh}.tm00 ]
		then
		    let "fh=fh+3"
		    typeset -Z2 fh
		else
		    break
		fi
	    done
	    
	    if [ $fh -gt $FHMAX ]
	    then
		break
	    fi
	    
	    let "icnt=$icnt + 1"
	    sleep 10
	    
	    if [ $icnt -ge 180 ]
	    then
		msg="ABORTING after 30 minutes of waiting for Nam Post F${fh} to end."
		err_exit $msg
	    fi
	done
	
	echo $COMOUT/${RUN}.${cycle}.awip3d00.tm00 > icwf_control
	echo $COMOUT/${RUN}.${cycle}.awip2000.tm00 > icwf_control_20
	fh=03
	inumf=1
	while [ $fh -le $FHMAX ]
	do
	    echo $COMOUT/${RUN}.${cycle}.awip3d${fh}.tm00 >> icwf_control
	    echo $COMOUT/${RUN}.${cycle}.awip20${fh}.tm00 >> icwf_control_20
	    let "fh=fh+3"
	    let "inumf=inumf+1"
	    typeset -Z2 fh
	done
	
	echo $inumf > NUMFILES
	
	rm fort.11
	export pgm=nam_icwf;. prep_step
	ln -s NUMFILES fort.11
	$EXECnam/nam_icwf < icwf_control
	export err=$?;err_chk
	rm icwf_control
	
	rm fort.11
	export pgm=nam_icwf;. prep_step
	ln -s NUMFILES fort.11
	$EXECnam/nam_icwf < icwf_control_20
	export err=$?;err_chk
	rm icwf_control_20
	
	typeset -Z2 fh
	fh=00
	while [ $fh -le $FHMAX ]
	do
       #############################
       # Convert to grib2 format
       #############################
            $CNVGRIB -g12 -p40 $COMOUT/${RUN}.${cycle}.awip3d$fh.tm00_icwf $COMOUT/${RUN}.${cycle}.awip3d$fh.tm00_icwf.grib2 
            $WGRIB2 $COMOUT/${RUN}.${cycle}.awip3d$fh.tm00_icwf.grib2 -s >$COMOUT/${RUN}.${cycle}.awip3d$fh.tm00_icwf.grib2.idx
            $CNVGRIB -g12 -p40 $COMOUT/${RUN}.${cycle}.awip20$fh.tm00_icwf $COMOUT/${RUN}.${cycle}.awip20$fh.tm00_icwf.grib2 
            $WGRIB2 $COMOUT/${RUN}.${cycle}.awip20$fh.tm00_icwf.grib2 -s >$COMOUT/${RUN}.${cycle}.awip20$fh.tm00_icwf.grib2.idx
	    
            if test "$SENDDBN" = 'YES'
            then
         # Now the ICWF 3d Grids
		$DBNROOT/bin/dbn_alert MODEL NAM_AW3DCWF $job $COMOUT/${RUN}.${cycle}.awip3d$fh.tm00_icwf
         # Now the ICWF 215 Grids
		$DBNROOT/bin/dbn_alert MODEL NAM_AW20CWF $job $COMOUT/${RUN}.${cycle}.awip20$fh.tm00_icwf
		
		$DBNROOT/bin/dbn_alert MODEL NAM_AW3DCWF_GB2 $job $COMOUT/${RUN}.${cycle}.awip3d$fh.tm00_icwf.grib2
		$DBNROOT/bin/dbn_alert MODEL NAM_AW3DCWF_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awip3d$fh.tm00_icwf.grib2.idx
		$DBNROOT/bin/dbn_alert MODEL NAM_AW20CWF_GB2 $job $COMOUT/${RUN}.${cycle}.awip20$fh.tm00_icwf.grib2
		$DBNROOT/bin/dbn_alert MODEL NAM_AW20CWF_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.awip20$fh.tm00_icwf.grib2.idx
            fi
            
	    let "fh=fh+3"
	done
    fi
    
# block for 218 and 242
    FHMAX=84
    if [ $fcsthrs -eq $FHMAX ]
    then
	icnt=0
	while [ $icnt -lt 1000 ]
	do
	    fh=00
	    typeset -Z2 fh
	    
	    while [ $fh -le $FHMAX ]
	    do
		if [ -s $COMOUT/${RUN}.${cycle}.awip12${fh}.tm00 -a \
                    $COMOUT/${RUN}.${cycle}.awak3d${fh}.tm00 ]
		then
		    let "fh=fh+3"
		    typeset -Z2 fh
		else
		    break
		fi
	    done
            
	    if [ $fh -gt $FHMAX ]
	    then
		break
	    fi
            
	    let "icnt=$icnt + 1"
	    sleep 10
	    
	    if [ $icnt -ge 180 ]
	    then
		msg="ABORTING after 30 minutes of waiting for Nam Post F${fh} to end."
		err_exit $msg
	    fi
	done
        
	echo $COMOUT/${RUN}.${cycle}.awip1200.tm00 > icwf_control_12
	echo $COMOUT/${RUN}.${cycle}.awak3d00.tm00 > icwf_control_ak
	fh=03
	inumf=1
	while [ $fh -le $FHMAX ]
	do
	    echo $COMOUT/${RUN}.${cycle}.awip12${fh}.tm00 >> icwf_control_12
	    echo $COMOUT/${RUN}.${cycle}.awak3d${fh}.tm00 >> icwf_control_ak
	    let "fh=fh+3"
	    let "inumf=inumf+1"
	    typeset -Z2 fh
	done
	
	echo $inumf > NUMFILES2
        
	rm fort.11
	export pgm=nam_icwf;. prep_step
	ln -s NUMFILES2 fort.11
	$EXECnam/nam_icwf < icwf_control_12
	export err=$?;err_chk
	rm icwf_control_12
	
	rm fort.11
	export pgm=nam_icwf;. prep_step
	ln -s NUMFILES2 fort.11
	$EXECnam/nam_icwf < icwf_control_ak
	export err=$?;err_chk
	rm icwf_control_ak
	
	if test "$SENDDBN" = 'YES'
	then
	    typeset -Z2 fh
	    fh=00
	    while [ $fh -le $FHMAX ]
	    do
# Now the ICWF 218 Grids
       # JY: the file name in first alert is incorrect and caused the alert failed
       # the file name in second alert is correct, comment out for now as it did not alert on CCS
       # will turn it on for the next NAM upgrade. 06/25/2013
       # ER : Alert never turned back on in NAMv3 2014 upgrade; is this needed?
       ### $DBNROOT/bin/dbn_alert MODEL NAM_A218CWF $job $COMOUT/${RUN}.${cycle}.awp218$fh.tm00_icwf
       # $DBNROOT/bin/dbn_alert MODEL NAM_A218CWF $job $COMOUT/${RUN}.${cycle}.awip12$fh.tm00_icwf                                            
		let "fh=fh+3"
	    done
	fi
	
    fi
# end 218 block
    
#end DOICWF test
fi

# Extract hourly precipitation from 00z NAM
# 12-36 h forecast for OCONUS soil moisture adjustment
# during catchup cycle
#

if [ $cyc -eq 00 -a $fcsthrs -eq 84 ]; then
    export CYCLE=${PDY}${cyc}
    ${USHnam}/nam_getpcp_nam00z.sh
    ${USHnam}/nam_getpcp_nam00z_nest.sh conus
fi

#####################################################################
# GOOD RUN
set +x
echo "NAM $fhr PRDGEN JOB COMPLETED NORMALLY"
set -x
#####################################################################

echo EXITING $0
exit $err
#
