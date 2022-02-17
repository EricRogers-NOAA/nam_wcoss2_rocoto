#! /bin/ksh

#
# nam_namsndp.sh
#
# Create bufr sounding files
#

export PS4='SNDP $SECONDS + '
set -x

cd $DATA

cp $PARMnam/nam_sndp.parm.mono $DATA/nam_sndp.parm.mono
cp $PARMnam/nam_bufr.tbl $DATA/nam_bufr.tbl

export pgm=nam_sndp
. prep_step
export FORT11=$DATA/nam_sndp.parm.mono
export FORT32=$DATA/nam_bufr.tbl
export FORT66=$DATA/profilm.c1.${tmmark}
export FORT78=$DATA/class1.bufr.${tmmark}

startmsg
$EXECnam/nam_sndp < $PARMnam/nam_modtop.parm >> $pgmout 2>errfile
export err=$?;err_chk

#
# Run the breakout code
#
if [ $RUN = "nam" -a $tmmark = tm00 ]
then

# remove bufr file breakout directory in $COMOUT if it exists

if [ -d ${COMOUT}/bufr.${cycle}.${tmmark} ]
then
  cd $COMOUT
  rm -r bufr.${cycle}.${tmmark} 
  rm nam.${cycle}.${tmmark}.bufrsnd.tar.gz 
  cd $DATA
fi

cat <<EOF > stnmlist_input
1
$DATA/class1.bufr.${tmmark}
${COMOUT}/bufr.${cycle}.${tmmark}/bufr
EOF

  mkdir -p ${COMOUT}/bufr.${cycle}.${tmmark}

  export pgm=nam_stnmlist
  . prep_step
  export FORT20=$DATA/class1.bufr.${tmmark}
  export DIRD=${COMOUT}/bufr.${cycle}.${tmmark}/bufr

  startmsg
  $EXECnam/nam_stnmlist < stnmlist_input >> $pgmout 2>errfile
  export err=$?;err_chk

  echo ${COMOUT}/bufr.${cycle}.${tmmark} > ${COMOUT}/bufr.${cycle}.${tmmark}/bufrloc
  cp class1.bufr.${tmmark} $COMOUT/${RUN}.${cycle}.class1.bufr.${tmmark}

  if test "$SENDECF" = 'YES'
  then
     ecflow_client --event release_gempak
  fi

  if [ $SENDDBN = "YES" ]
  then
     $DBNROOT/bin/dbn_alert MODEL NAM_BUFR_SND $job $COMOUT/bufr.${cycle}.${tmmark}/bufrloc
     $DBNROOT/bin/dbn_alert MODEL NAM_BUFR_CLASS1 $job $COMOUT/${RUN}.${cycle}.class1.bufr.${tmmark}
  fi

# Tar and gzip the individual bufr files and send them to /com
cd ${COMOUT}/bufr.${cycle}.${tmmark}
tar -cf - . | /bin/gzip > ../nam.${cycle}.${tmmark}.bufrsnd.tar.gz
cd $DATA

#Send the alerts
if test "$SENDDBN" = 'YES'
  then
   $DBNROOT/bin/dbn_alert MODEL NAM_BUFRSND_TAR $job $COMOUT/nam.${cycle}.${tmmark}.bufrsnd.tar.gz
fi

  #
  # Create GEMPAK BUFR Sounding Files
  # This call to nam_bfr2gpk.sh can be removed into a seperate job
  # to expedite the bufr sounding processing if necessary
  #
$USHnam/nam_bfr2gpk.sh

DOCOLLECTIVES=YES

if [ $DOCOLLECTIVES = YES ] ; then

if [ $RUNTYPE = CATCHUP -a $tmmark = tm00 ] ; then

  #  now create "collectives" consisting of groupings of the soundings
  #  into files designated by geographical region.   Each input
  #  file nam_collective*.list (1-9) contains the list of stations to
  #  put in a particular collective output file.  There are
  #  currently no stations in the Nam in region 8, so it is bypassed.

  cp $FIXnam/nam_collective* $DATA/.
  CCCC=KWNO
  let "m=1"
  while [ $m -lt 10 ]
  do
    file_list=nam_collective$m.list

    if [ $m -lt 3 ]
    then
      WMOHEAD=JUSA4$m
    elif [ $m -lt 7 ]
    then
      WMOHEAD=JUSB4$m
    else
      WMOHEAD=JUSX4$m
    fi

    for stn in `cat $file_list`
    do
       cp ${COMIN}/bufr.${cycle}.${tmmark}/bufr.$stn.$PDY$cyc $DATA/bufrin
       export pgm=tocsbufr
       . prep_step
       export FORT11="$DATA/bufrin"
       export FORT51="$DATA/bufrout"
       startmsg
       ${UTIL_EXECnam}/tocsbufr << EOF >> $pgmout 2>errfile
 &INPUT
  BULHED="$WMOHEAD",KWBX="$CCCC",
  NCEP2STD=.TRUE.,
  SEPARATE=.TRUE.,
  MAXFILESIZE=200000
 /
EOF
       export err=$?;err_chk
       cat $DATA/bufrout >> nam_collective$m.fil
       rm $DATA/bufrin
       rm $DATA/bufrout
    done

    if test $SENDCOM = 'YES'
    then
      cp nam_collective$m.fil ${COMOUT}/bufr.${cycle}.${tmmark}/.
      cp nam_collective$m.fil $pcom/nam_collective$m.$job
      if [ $SENDDBN = 'YES' ] ; then
        $DBNROOT/bin/dbn_alert GRIB_LOW BUFR $job $pcom/nam_collective$m.$job
        $DBNROOT/bin/dbn_alert MODEL NAM_BUFR_COLL $job ${COMOUT}/bufr.${cycle}.${tmmark}/nam_collective$m.fil
      fi
    fi

    let "m=m+1"
    if [ $m -eq 8 ]
      then let "m=m + 1"
    fi

  done
#end CATCHUP, tm00 check
fi
#end DOCOLLECTIVES check
fi

fi

exit $err
