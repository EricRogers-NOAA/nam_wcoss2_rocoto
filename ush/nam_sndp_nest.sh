#! /bin/ksh

#
# nam_namsndp_nest.sh
#
# Create bufr sounding files
#

export PS4='SNDP $SECONDS + '
set -x

cd $DATA

DOMAIN=`echo $domain | tr '[a-z]' '[A-Z]'`

cp $PARMnam/nam_sndp.parm.mono $DATA/nam_sndp.parm.mono
cp $PARMnam/nam_bufr.tbl $DATA/nam_bufr.tbl

export pgm=nam_sndp
. prep_step

export FORT11=$DATA/nam_sndp.parm.mono
export FORT32=$DATA/nam_bufr.tbl
export FORT66=$DATA/profilm.c1_${domain}.${tmmark}
export FORT78=$DATA/class1.bufr_${domain}.${tmmark}
startmsg
$EXECnam/nam_sndp <  $PARMnam/nam_modtop.parm >> $pgmout 2>errfile
export err=$?;err_chk

#
# Run the breakout code
#
if [ $RUN = "nam" -a $tmmark = tm00 ]
then

# remove bufr file breakout directory in $COMOUT if it exists

if [ -d ${COMOUT}/bufr_${domain}nest.${cycle}.${tmmark} ]
then
  cd $COMOUT
  rm -r bufr_${domain}nest.${cycle}.${tmmark}
  rm nam.${cycle}.${tmmark}.bufrsnd_${domain}nest.tar.gz 
  cd $DATA
fi

cat <<EOF > stnmlist_input
1
class1.bufr_${domain}.${tmmark}
${COMOUT}/bufr_${domain}nest.${cycle}.${tmmark}/bufr
EOF

  mkdir -p ${COMOUT}/bufr_${domain}nest.${cycle}.${tmmark}

  export pgm=nam_stnmlist
  . prep_step
  export FORT20=class1.bufr_${domain}.${tmmark}
  export DIRD=${COMOUT}/bufr_${domain}nest.${cycle}/bufr

  startmsg
  $EXECnam/nam_stnmlist  < stnmlist_input >> $pgmout 2>errfile
  export err=$?;err_chk

  echo ${COMOUT}/bufr_${domain}nest.${cycle}.${tmmark} > ${COMOUT}/bufr_${domain}nest.${cycle}.${tmmark}/bufrloc
  cp class1.bufr_${domain}.${tmmark} $COMOUT/${RUN}.${cycle}.class1.bufr_${domain}nest.${tmmark}

  if test "$SENDECF" = 'YES'
  then
     ecflow_client --event release_gempak
  fi

  if [ $SENDDBN = "YES" ]
  then
     $DBNROOT/bin/dbn_alert MODEL NAM_BUFR_SND_${DOMAIN}NEST $job $COMOUT/bufr_${domain}nest.${cycle}.${tmmark}/bufrloc
     $DBNROOT/bin/dbn_alert MODEL NAM_BUFR_CLASS1_${DOMAIN}NEST $job $COMOUT/${RUN}.${cycle}.class1.bufr_${domain}nest.${tmmark}
  fi

# Tar and gzip the individual bufr files and send them to /com
cd ${COMOUT}/bufr_${domain}nest.${cycle}.${tmmark}
tar -cf - . | /usr/bin/gzip > ../nam.${cycle}.${tmmark}.bufrsnd_${domain}nest.tar.gz
cd $DATA

#Send the alerts
if test "$SENDDBN" = 'YES'
  then
#   $DBNROOT/bin/dbn_alert MODEL NAM_BUFRSND_${DOMAIN}NEST.TAR $job $COMOUT/nam.${cycle}.bufrsnd_${domain}nest.${tmmark}.tar.gz
   $DBNROOT/bin/dbn_alert MODEL NAM_BUFRSND_${DOMAIN}NEST_TAR $job $COMOUT/nam.${cycle}.${tmmark}.bufrsnd_${domain}nest.tar.gz
fi

  #
  # Create GEMPAK BUFR Sounding Files
  # This call to nam_bfr2gpk.sh can be removed into a seperate job
  # to expedite the bufr sounding processing if necessary
  #
$USHnam/nam_bfr2gpk_nest.sh

fi

exit $err
<
