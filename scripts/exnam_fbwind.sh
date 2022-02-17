#!/bin/sh
#####################################################################
echo "------------------------------------------------"
echo "EXNAM_FBWIND - 24hr NAM postprocessing"
echo "------------------------------------------------"
echo "History: Oct 2004 - First implementation of this new script."
echo "         FBWNDTRX (FB Winds) program for CONUS"
#####################################################################

cd $DATA

######################
# Set up Here Files.
######################

set -x
msg="Begin job for $job"
postmsg "$msg"

export comrun=$COMIN/${model}.${cycle}

echo " "
echo "#############################################################"
echo " Process Bulletins of fcst winds and temps for US and Canada."
echo "#############################################################"
echo " "
set -x

hour="06 12 24"

for fhr in $hour
do

GRIBIN=$comrun.awip32${fhr}.tm00.grib2

$WGRIB2 $GRIBIN | grep -f $HOMEnam/util/fix/nam_extractg221_fbwinds.txt|$WGRIB2 -i -grib temp $GRIBIN
$CNVGRIB -g21 temp awip32${fhr}.tm00.g255
rm temp 

echo 221 > input
export pgm=overgridid;. prep_step
ln -s awip32${fhr}.tm00.g255 fort.11
ln -s awip32${fhr}.tm00 fort.51
${OVERGRIDID} < input >> $pgmout
export err=$?;err_chk
rm awip32${fhr}.tm00.g255 input temp
rm fort.11 fort.51

$GRBINDEX awip32${fhr}.tm00 awip32i${fhr}

done

export pgm=fbwndtrx
. prep_step

export FORT11="awip3206.tm00"
export FORT12="awip3212.tm00"
export FORT13="awip3224.tm00"

#       NAM grib index files

export FORT31="awip32i06"
export FORT32="awip32i12"
export FORT33="awip32i24"

#
#   1280 byte transmission file
#

export FORT51="tran.fbwnd_conus"

startmsg

${UTIL_EXECnam}/fbwndtrx < ${UTIL_PARMnam}/fbwnd_conus.stnlist  >> $pgmout 2> errfile
err=$?;export err;err_chk

if test "$SENDCOM" = 'YES'
then
    cp tran.fbwnd_conus $COMOUTwmo/tran.fbwnd_conus.$job
fi

if test "$SENDDBN" = 'YES'
then
   $USHutil/make_ntc_bull.pl  WMOBH NONE KWNO NONE tran.fbwnd_conus $COMOUTwmo/tran.fbwnd_conus.$job  
fi
   
##################################################################
#
#      Process Bulletins of OLD FD WIND at 00Z and 12Z
#
##################################################################

if test ${cycle} = 't00z' -o ${cycle} = 't12z'
then

   set +x
   echo " "
   echo "#############################################################"
   echo " Process Bulletins of fcst winds and temps for US and Canada."
   echo "#############################################################"
   echo " "
   set -x

   export pgm=bulls_fdwndtrx
   . prep_step

   export FORT11="awip3206.tm00"
   export FORT12="awip3212.tm00"
   export FORT13="awip3224.tm00"

   #       NAM grib index files

   export FORT31="awip32i06"
   export FORT32="awip32i12"
   export FORT33="awip32i24"

   export FORT49="ncepdate"

   #
   #   1280 byte transmission file
   #

   export FORT51="tran.fdwnd"

   startmsg

   ${UTIL_EXECnam}/bulls_fdwndtrx < ${UTIL_PARMnam}/bulls_fdwnd.stnlist >> $pgmout 2> errfile
   err=$?;export err;err_chk

   if test "$SENDCOM" = 'YES'
   then
     cp tran.fdwnd $COMOUTwmo/tran.fdwnd.$job
   fi

   if test "$SENDDBN" = 'YES'
   then
      $USHutil/make_ntc_bull.pl  WMOBH NONE KWNO NONE tran.fdwnd $COMOUTwmo/tran.fdwnd.$job
   fi

fi

#####################################################################
# GOOD RUN
set +x
echo "**************EXNAM_FBWIND COMPLETED NORMALLY ON IBM-SP"
echo "**************EXNAM_FBWIND COMPLETED NORMALLY ON IBM-SP"
echo "**************EXNAM_FBWIND COMPLETED NORMALLY ON IBM-SP"
set -x
#####################################################################

msg='Job completed normally.'
echo $msg
postmsg "$msg"

############################### END OF SCRIPT #######################

