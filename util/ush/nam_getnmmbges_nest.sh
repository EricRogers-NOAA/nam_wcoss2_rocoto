set -x

CYCLE=$1
domain=$2

echo $CYCLE > datefile
cyc=`cut -c 9-10 datefile`

TM01=`${NDATE} -01 $CYCLE`
TM02=`${NDATE} -02 $CYCLE`
TM03=`${NDATE} -03 $CYCLE`
TM04=`${NDATE} -04 $CYCLE`
TM05=`${NDATE} -05 $CYCLE`
TM06=`${NDATE} -06 $CYCLE`

yyyymmdd=`echo $CYCLE | cut -c 1-8`
hh=`echo $CYCLE | cut -c 9-10`
yyyymmddm01=`echo $TM01 | cut -c 1-8`
yyyymmddm02=`echo $TM02 | cut -c 1-8`
yyyymmddm03=`echo $TM03 | cut -c 1-8`
yyyymmddm04=`echo $TM04 | cut -c 1-8`
yyyymmddm05=`echo $TM05 | cut -c 1-8`
yyyymmddm06=`echo $TM06 | cut -c 1-8`

case $cyc in
 00) inputfile1=${gespath}/${RUN}.${yyyymmddm01}/nam.t23z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmddm01}/nam.t22z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmddm01}/nam.t21z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmddm01}/nam.t20z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmddm01}/nam.t19z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmddm01}/nam.t18z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 01) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t00z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmddm02}/nam.t23z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmddm02}/nam.t22z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmddm02}/nam.t21z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmddm02}/nam.t20z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmddm02}/nam.t19z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 02) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t01z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t00z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmddm03}/nam.t23z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmddm03}/nam.t22z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmddm03}/nam.t21z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmddm03}/nam.t20z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 03) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t02z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t01z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t00z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmddm04}/nam.t23z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmddm04}/nam.t22z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmddm04}/nam.t21z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 04) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t03z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t02z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t01z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t00z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmddm05}/nam.t23z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmddm05}/nam.t22z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 05) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t04z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t03z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t02z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t01z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t00z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmddm06}/nam.t23z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 06) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t05z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t04z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t03z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t02z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t01z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t00z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 07) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t06z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t05z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t04z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t03z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t02z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t01z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 08) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t07z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t06z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t05z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t04z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t03z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t02z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 09) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t08z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t07z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t06z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t05z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t04z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t03z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 10) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t09z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t08z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t07z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t06z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t05z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t04z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 11) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t10z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t09z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t08z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t07z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t06z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t05z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 12) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t11z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t10z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t09z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t08z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t07z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t06z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 13) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t12z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t11z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t10z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t09z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t08z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t07z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 14) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t13z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t12z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t11z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t10z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t09z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t08z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 15) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t14z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t13z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t12z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t11z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t10z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t09z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 16) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t15z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t14z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t13z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t12z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t11z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t10z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 17) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t16z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t15z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t14z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t13z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t12z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t11z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 18) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t17z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t16z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t15z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t14z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t13z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t12z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 19) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t18z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t17z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t16z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t15z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t14z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t13z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 20) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t19z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t18z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t17z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t16z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t15z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t14z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 21) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t20z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t19z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t18z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t17z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t16z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t15z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 22) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t21z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t20z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t19z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t18z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t17z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t16z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
 23) inputfile1=${gespath}/${RUN}.${yyyymmdd}/nam.t22z.nmm_b_restart_${domain}nest_nemsio.f001.tm00
     inputfile2=${gespath}/${RUN}.${yyyymmdd}/nam.t21z.nmm_b_restart_${domain}nest_nemsio.f002.tm00
     inputfile3=${gespath}/${RUN}.${yyyymmdd}/nam.t20z.nmm_b_restart_${domain}nest_nemsio.f003.tm00
     inputfile4=${gespath}/${RUN}.${yyyymmdd}/nam.t19z.nmm_b_restart_${domain}nest_nemsio.f004.tm00
     inputfile5=${gespath}/${RUN}.${yyyymmdd}/nam.t18z.nmm_b_restart_${domain}nest_nemsio.f005.tm00
     inputfile6=${gespath}/${RUN}.${yyyymmdd}/nam.t17z.nmm_b_restart_${domain}nest_nemsio.f006.tm00;;
esac

if [ -s $inputfile1 ]
then
  cp $inputfile1 restart_file_${domain}nest
  msg="JOB $job $CYCLE USING NEST ${inputfile1}"
else
  if [ -s $inputfile2 ]
  then
    cp $inputfile2 restart_file_${domain}nest
    msg="JOB $job $CYCLE USING NEST ${inputfile2}"
  else
    if [ -s $inputfile3 ]
    then
      cp $inputfile3 restart_file_${domain}nest
      msg="JOB $job $CYCLE USING NEST ${inputfile3}"
    else
      if [ -s $inputfile4 ]
      then
        cp $inputfile4 restart_file_${domain}nest
        msg="JOB $job $CYCLE USING NEST ${inputfile4}"
      else
        if [ -s $inputfile5 ]
        then
          cp $inputfile5 restart_file_${domain}nest
          msg="JOB $job $CYCLE USING NEST ${inputfile5}"
        else
          if [ -s $inputfile6 ]
          then
            cp $inputfile6 restart_file_${domain}nest
            msg="JOB $job $CYCLE USING NEST ${inputfile6}"
          fi
        fi
      fi
    fi
  fi
fi


# Send message to namlog w/date and origin of first guess for NEST HOURLY cycle
postmsg "$jlogfile" "$msg"


