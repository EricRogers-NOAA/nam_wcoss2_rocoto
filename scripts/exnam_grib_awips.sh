#!/bin/ksh
######################################################################
#  UTILITY SCRIPT NAME :  exnam_grib_awips.sh.sm
#         DATE WRITTEN :  10/06/2004
#
#  Abstract:  This utility script produces the NAM AWIPS GRIB
#
#     Input:  1 arguments are passed to this script.
#             1st argument - Forecast Hour - format of 2I
#
#  2016-11-07  Rogers   Drop grids #215, and 217
#
#####################################################################

#####################################################################
echo "------------------------------------------------"
echo "EXNAM_GRIB_AWIPS - NAM post processing"
echo "------------------------------------------------"
echo "History: Oct 2004 - First implementation of this new script."
echo "         "
#####################################################################

set -x
msg="Begin job for $job"
postmsg "$msg"

#####################################################################
set +x
fcsthrs="$1"
num=$#

if test "$num" -ge 1
then
   echo " Appropriate number of arguments were passed"
   set -x
   export comrun=$COMIN/${model}.${cycle}
else
   echo ""
   echo "Usage: exnam_grib_awips.sh.ecf  \$fcsthrs "
   echo ""
   exit 16
fi

cd $DATA

hours48="00 03 06 09 12 15 18 21 24 27 30 33 36 39 42 45 48"
hours60="00 03 06 09 12 15 18 21 24 27 30 33 36 39 42 45 48 51 54 57 60"

if test "$cycle" = "t00z" -o "$cycle" = "t12z"
then

   set +x
   echo " "
   echo "###############################################################"
   echo " Process GRIB AWIP PRODUCTS"
   echo "###############################################################"
   echo " "
   set -x

   fhr=`expr ${fcsthrs} % 6`
   if test $fhr -eq 0 -a $fcsthrs -le 60
   then
      export GRID
      for GRID in 207 211
      do
        sh $UTIL_USHnam/mkawpgrb.sh  ${fcsthrs}
      done
   fi

   if test $fcsthrs -le 06
   then
      export GRID=237
      sh $UTIL_USHnam/mkawpgrb.sh  ${fcsthrs}
   fi

   if test $fcsthrs -le 60
   then
      export GRID
      for GRID in 212 216
      do 
        sh $UTIL_USHnam/mkawpgrb.sh  ${fcsthrs}
      done
   fi

   export GRID=218g2
   # convert g2 file from complex to jpeg2000 (makes awip G2 files smaller)
   $CNVGRIB -g22 -p40 $COMIN/nam.t${cyc}z.awphys${fcsthrs}.tm00.grib2 $COMIN/nam.t${cyc}z.awphys${fcsthrs}.grb2.tm00
   sh $UTIL_USHnam/mkawpgrb.sh ${fcsthrs}
   rm $COMIN/nam.t${cyc}z.awphys${fcsthrs}.grb2.tm00

   export GRID=242g2

# ER 11/2016:For NAMv4, extract CFRZR from awak3d file first,
# then cat it to the top of the awak3d file used in mkawpgrb.sh
# so that it is at the top of the GRIB2 file and therefore
# processed instead of CFOFP

   GFILE=$COMIN/nam.t${cyc}z.awak3d${fcsthrs}.tm00.grib2
   $WGRIB2 $GFILE | grep "CFRZR" | $WGRIB2 -i $GFILE -grib cfrzr.${fcsthrs}
   cat cfrzr.${fcsthrs} $COMIN/nam.t${cyc}z.awak3d${fcsthrs}.tm00.grib2 $COMIN/nam.t${cyc}z.awp242${fcsthrs}.tm00.grib2 > $DATA/tmp242
   $CNVGRIB -g22 -p40 $DATA/tmp242 $COMIN/nam.t${cyc}z.awak3d${fcsthrs}.grb2.tm00
   $WGRIB2 -s $COMIN/nam.t${cyc}z.awak3d${fcsthrs}.grb2.tm00 > $COMIN/nam.t${cyc}z.awak3d${fcsthrs}.grb2.tm00.idx
   sh $UTIL_USHnam/mkawpgrb.sh  ${fcsthrs}
   rm $COMIN/nam.t${cyc}z.awak3d${fcsthrs}.grb2.tm00.idx
# Moved DBNalert to NAM PRDGEN job
#  if test $SENDDBN = 'YES'
#  then
#   $DBNROOT/bin/dbn_alert MODEL NAM_A242_3D_GB2 $job $COMOUT/nam.t${cyc}z.awak3d${fcsthrs}.tm00.grib2
#   $DBNROOT/bin/dbn_alert MODEL NAM_A242_3D_GB2_WIDX $job $COMOUT/nam.t${cyc}z.awak3d${fcsthrs}.tm00.grib2.idx
#  fi

   if test $fcsthrs -eq 60
   then

      set +x
      echo " "
      echo "############################################################"
      echo "    Execute WMOGRIB to send ICWF fields to OSO              "
      echo "############################################################"
      echo " "
      set -x

      export GRID=icwf_off
      sh $UTIL_USHnam/mkawpgrb.sh "$hours60"

      export GRID=icwf
      sh $UTIL_USHnam/mkawpgrb.sh "$hours48"

   fi

else

  # PROCESS OFFTIME (06Z and 18Z) DATA
  #
   set +x
   echo " "
   echo "###############################################################"
   echo " Process GRIB AWIP PRODUCTS"
   echo "###############################################################"
   echo " "
   set -x

   if test $fcsthrs -le 48
   then
      export GRID
      for  GRID in 212
      do
        sh $UTIL_USHnam/mkawpgrb.sh "$fcsthrs"
      done
   fi

   if test $fcsthrs -le 06
   then
     export GRID=237_off
     sh $UTIL_USHnam/mkawpgrb.sh "$fcsthrs"
   fi

   export GRID=218g2
   # convert g2 file from complex to jpeg2000 (makes awip G2 files smaller)
   $CNVGRIB -g22 -p40 $COMIN/nam.t${cyc}z.awphys${fcsthrs}.tm00.grib2 $COMIN/nam.t${cyc}z.awphys${fcsthrs}.grb2.tm00
   sh $UTIL_USHnam/mkawpgrb.sh ${fcsthrs}
   rm $COMIN/nam.t${cyc}z.awphys${fcsthrs}.grb2.tm00

   export GRID=242g2

# ER 11/2016:For NAMv4, extract CFRZR from awak3d file first,
# then cat it to the top of the awak3d file used in mkawpgrb.sh
# so that it is at the top of the GRIB2 file and therefore
# processed instead of CFOFP

   GFILE=$COMIN/nam.t${cyc}z.awak3d${fcsthrs}.tm00.grib2
   $WGRIB2 $GFILE | grep "CFRZR" | $WGRIB2 -i $GFILE -grib cfrzr.${fcsthrs}
   cat cfrzr.${fcsthrs} $COMIN/nam.t${cyc}z.awak3d${fcsthrs}.tm00.grib2 $COMIN/nam.t${cyc}z.awp242${fcsthrs}.tm00.grib2 > $DATA/tmp242
   $CNVGRIB -g22 -p40 $DATA/tmp242 $COMIN/nam.t${cyc}z.awak3d${fcsthrs}.grb2.tm00
   $WGRIB2 -s $COMIN/nam.t${cyc}z.awak3d${fcsthrs}.grb2.tm00 > $COMIN/nam.t${cyc}z.awak3d${fcsthrs}.grb2.tm00.idx
   sh $UTIL_USHnam/mkawpgrb.sh "$fcsthrs"
   rm $COMIN/nam.t${cyc}z.awak3d${fcsthrs}.grb2.tm00
# Moved DBNalert to NAM PRDGEN job
#  if test $SENDDBN = 'YES'
#  then
#   $DBNROOT/bin/dbn_alert MODEL NAM_A242_3D_GB2 $job $COMOUT/nam.t${cyc}z.awak3d${fcsthrs}.tm00.grib2
#   $DBNROOT/bin/dbn_alert MODEL NAM_A242_3D_GB2_WIDX $COMOUT/nam.t${cyc}z.awak3d${fcsthrs}.tm00.grib2.idx
#  fi

   if test $fcsthrs -eq 48
   then

      set +x
      echo " "
      echo "############################################################"
      echo "    Execute WMOGRIB to send ICWF fields to OSO              "
      echo "############################################################"
      echo " "
      set -x
      export GRID=icwf_off
      sh $UTIL_USHnam/mkawpgrb.sh "$hours48"

   fi

fi

if test $fcsthrs -eq 84
then

   fcst_hours="00 03 06 09 12 15 18 21 24 27 30 33 36 39 42 45 48 51 54 57 60 63 66 69 \
	       72 75 78 81 84"

   for fhr in $fcst_hours
   do
     $CNVGRIB -g12 -p40000 $COMIN/nam.t${cyc}z.awip12${fhr}.tm00_icwf \
	    $COMOUT/nam.t${cyc}z.awip12${fhr}.grb2.tm00_icwf

     export GRID=218_icwf
     sh $UTIL_USHnam/mkawpgrb.sh $fhr

     $CNVGRIB -g12 -p40000 $COMIN/nam.t${cyc}z.awak3d${fhr}.tm00_icwf \
	    $COMOUT/nam.t${cyc}z.awak3d${fhr}.grb2.tm00_icwf

     export GRID=242_icwf
     sh $UTIL_USHnam/mkawpgrb.sh $fhr
   done
fi

#####################################################################
# GOOD RUN
set +x
echo "**************JOB EXNAM_GRIB_AWIPS COMPLETED NORMALLY"
echo "**************JOB EXNAM_GRIB_AWIPS COMPLETED NORMALLY"
echo "**************JOB EXNAM_GRIB_AWIPS COMPLETED NORMALLY"
set -x
#####################################################################

cat $pgmout

msg="HAS COMPLETED NORMALLY!"
echo $msg
postmsg "$msg"

############## END OF SCRIPT #######################

