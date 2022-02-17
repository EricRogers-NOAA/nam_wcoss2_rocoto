#!/bin/ksh
######################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exndas_h2obudget.sh
#             
# Script description:  Update the long-term precipitation budget array
#                      by comparing the hourly precipitation input for 
#                      the time period of ${TM48}-${TM24} 
#                      (where T0=$CYCLE=${day}12)
#                      i.e. the first 6 hours from NDAS cycles
#
#                      For 6-h NAM catchup cycle, which runs only with 12Z CATCHUP at TM06:
#
#                           ${daym1}00   (TM42 cycle, covering TM48-TM42)
#                           ${daym1}06   (TM36 cycle, covering TM42-TM36)
#                           ${daym1}12   (TM24 cycle, covering TM36-TM30)
#                           ${daym1}18   (TM18 cycle, covering TM30-TM12)
#
#                      against the CPC 1/8 deg daily precip analysis
#                      covering the same time period, obtained from
#                           /dcom/us007003/$day/wgrbbul/rfc8.${daym1}12
#
#                      The NDAS hourly 'snow ratio' arrays are used to 
#                      determine whether a given grid point is snowing
#                      for the given hour.  During the 24h period 
#                      (${TM48}-${TM24}), if it snowed at a grid point
#                      in any hour, then this grid point is not used
#                      in the budget calculation.
#
#                      This script is called once a day, at the
#                      beginning of the 12Z cycle.
#
# Author:      Ying Lin     Org: NP22        Date: 2003-06-09
#

# Script history log:
# 2003-06-09  Y Lin
# 2003-12-11  Y Lin  Updated for 4-cycles-per-day configuration
# 2005-02-16  Y Lin  Updated to use lspa instead of bgrdsf file
# 2006-01-13  Y Lin  Since lspa / sratio are now in bgrdsf file, 
#                    use this instead of lspa
# 2008-06-11  Y Lin  Use the binary version of the CPC analysis from /dcom,
#      GRIB'd within this script, rather than the one pre-GRIB'd by us twice 
#      a day on a fixed schedule.  This will allow us to use more up-to-date
#      CPC analysis if CPC makes a re-run to correct for errors.  Also, check
#      for size of GRIB'd file, do not use if size < 95,000 bytes (most faulty
#      files fall under this category).
# 2009-04-22  Y Lin  B-grid version
# 2009-12-07  E Rogers modified for NAMRR

set -x

cd $DATA

CYCTM18=`${NDATE} -18 $CYCLE`
PDYM18=`echo $CYCTM18 | cut -c 1-8`
HH18=`echo $CYCTM18 | cut -c 9-10`

CYCTM24=`${NDATE} -24 $CYCLE`
PDYM24=`echo $CYCTM24 | cut -c 1-8`
HH24=`echo $CYCTM24 | cut -c 9-10`

CYCTM30=`${NDATE} -30 $CYCLE`
PDYM30=`echo $CYCTM30 | cut -c 1-8`
HH30=`echo $CYCTM30 | cut -c 9-10`

CYCTM36=`${NDATE} -36 $CYCLE`
PDYM36=`echo $CYCTM36 | cut -c 1-8`
HH36=`echo $CYCTM36 | cut -c 9-10`

CYCTM42=`${NDATE} -42 $CYCLE`
PDYM42=`echo $CYCTM42 | cut -c 1-8`
HH42=`echo $CYCTM42 | cut -c 9-10`

CYCTM48=`${NDATE} -48 $CYCLE`
PDYM48=`echo $CYCTM48 | cut -c 1-8`
HH48=`echo $CYCTM48 | cut -c 9-10`

daym1=`echo $CYCTM24 | cut -c 1-8`
daym2=`echo $CYCTM48 | cut -c 1-8`

DIRTM18=${COM_IN}/${RUN}.$PDYM18
DIRTM24=${COM_IN}/${RUN}.$PDYM24
DIRTM30=${COM_IN}/${RUN}.$PDYM30
DIRTM36=${COM_IN}/${RUN}.$PDYM36
DIRTM42=${COM_IN}/${RUN}.$PDYM42

# extract first 6 hours' of NDAS precip files from TM42, TM36, TM30 and TM24
# cycles:

cp $PARMnam/wgrib2.txtlists/nam_lspasnow.txt .

# Modifed for hourly update - convert necessary bgrdsf file contents to grib1

tmmarks="tm06 tm05 tm04 tm03 tm02 tm01"
for tmmark in ${tmmarks}; do

gb2file=$DIRTM42/${RUN}.t${HH42}z.bgrdsf01.${tmmark} 
$WGRIB2 ${gb2file} | grep -F -f nam_lspasnow.txt | $WGRIB2 -i -grib $CYCTM42.bgrdsf.${tmmark}.lspasnow ${gb2file}
$CNVGRIB -g21 $CYCTM42.bgrdsf.${tmmark}.lspasnow $CYCTM42.bgrdsf.${tmmark}

gb2file=$DIRTM36/${RUN}.t${HH36}z.bgrdsf01.${tmmark} 
$WGRIB2 ${gb2file} | grep -F -f nam_lspasnow.txt | $WGRIB2 -i -grib $CYCTM36.bgrdsf.${tmmark}.lspasnow ${gb2file}
$CNVGRIB -g21 $CYCTM36.bgrdsf.${tmmark}.lspasnow $CYCTM36.bgrdsf.${tmmark}

gb2file=$DIRTM30/${RUN}.t${HH30}z.bgrdsf01.${tmmark} 
$WGRIB2 ${gb2file} | grep -F -f nam_lspasnow.txt | $WGRIB2 -i -grib $CYCTM30.bgrdsf.${tmmark}.lspasnow ${gb2file}
$CNVGRIB -g21 $CYCTM30.bgrdsf.${tmmark}.lspasnow $CYCTM30.bgrdsf.${tmmark}

gb2file=$DIRTM24/${RUN}.t${HH24}z.bgrdsf01.${tmmark} 
$WGRIB2 ${gb2file} | grep -F -f nam_lspasnow.txt | $WGRIB2 -i -grib $CYCTM24.bgrdsf.${tmmark}.lspasnow ${gb2file}
$CNVGRIB -g21 $CYCTM24.bgrdsf.${tmmark}.lspasnow $CYCTM24.bgrdsf.${tmmark}

done

rm *bgrdsf.tm*.lspasnow

# Compute 24h sum (12Z-12Z) of adjusted hourly precip, also create
# daily snow map:

SUM24ADJ=YES
for file in $CYCTM42.bgrdsf.tm06 \
            $CYCTM42.bgrdsf.tm05 \
            $CYCTM42.bgrdsf.tm04 \
            $CYCTM42.bgrdsf.tm03 \
            $CYCTM42.bgrdsf.tm02 \
            $CYCTM42.bgrdsf.tm01 \
            $CYCTM36.bgrdsf.tm06 \
            $CYCTM36.bgrdsf.tm05 \
            $CYCTM36.bgrdsf.tm04 \
            $CYCTM36.bgrdsf.tm03 \
            $CYCTM36.bgrdsf.tm02 \
            $CYCTM36.bgrdsf.tm01 \
            $CYCTM30.bgrdsf.tm06 \
            $CYCTM30.bgrdsf.tm05 \
            $CYCTM30.bgrdsf.tm04 \
            $CYCTM30.bgrdsf.tm03 \
            $CYCTM30.bgrdsf.tm02 \
            $CYCTM30.bgrdsf.tm01 \
            $CYCTM24.bgrdsf.tm06 \
            $CYCTM24.bgrdsf.tm05 \
            $CYCTM24.bgrdsf.tm04 \
            $CYCTM24.bgrdsf.tm03 \
            $CYCTM24.bgrdsf.tm02 \
            $CYCTM24.bgrdsf.tm01

do
  if [ ! -e $file ]; then
    echo $file does not exist
    SUM24ADJ=NO
  fi
done

if [ $SUM24ADJ = YES ]; then
  ln -sf "$CYCTM42.bgrdsf.tm06" fort.11
  ln -sf "$CYCTM42.bgrdsf.tm05" fort.12
  ln -sf "$CYCTM42.bgrdsf.tm04" fort.13
  ln -sf "$CYCTM42.bgrdsf.tm03" fort.14
  ln -sf "$CYCTM42.bgrdsf.tm02" fort.15
  ln -sf "$CYCTM42.bgrdsf.tm01" fort.16

  ln -sf "$CYCTM36.bgrdsf.tm06" fort.17
  ln -sf "$CYCTM36.bgrdsf.tm05" fort.18
  ln -sf "$CYCTM36.bgrdsf.tm04" fort.19
  ln -sf "$CYCTM36.bgrdsf.tm03" fort.20
  ln -sf "$CYCTM36.bgrdsf.tm02" fort.21
  ln -sf "$CYCTM36.bgrdsf.tm01" fort.22

  ln -sf "$CYCTM30.bgrdsf.tm06" fort.23
  ln -sf "$CYCTM30.bgrdsf.tm05" fort.24
  ln -sf "$CYCTM30.bgrdsf.tm04" fort.25
  ln -sf "$CYCTM30.bgrdsf.tm03" fort.26
  ln -sf "$CYCTM30.bgrdsf.tm02" fort.27
  ln -sf "$CYCTM30.bgrdsf.tm01" fort.28

  ln -sf "$CYCTM24.bgrdsf.tm06" fort.29
  ln -sf "$CYCTM24.bgrdsf.tm05" fort.30
  ln -sf "$CYCTM24.bgrdsf.tm04" fort.31
  ln -sf "$CYCTM24.bgrdsf.tm03" fort.32
  ln -sf "$CYCTM24.bgrdsf.tm02" fort.33
  ln -sf "$CYCTM24.bgrdsf.tm01" fort.34

  ln -sf "lspa.$CYCTM24.24h" fort.51
  ln -sf "snowmask.$daym1" fort.52
  $EXECnam/nam_lspasno24h
  err=$?
  if [ $err -eq 0 ]; then
    cp lspa.$CYCTM24.24h $COMOUT/${RUN}.t${cyc}z.lspa.$CYCTM24.24h 
    cp snowmask.$daym1 $COMOUT/${RUN}.t${cyc}z.snowmask.$daym1
  else
    SUM24ADJ=NO
    echo 'Error making 24h sum of NDAS precip ending $CMCTM24'
  fi
fi


#
# Get the 6-hourly CCPA covering ${daym2}12 - ${daym1}12

  #Use the COMINccpa specified in the forecast J-Job
  ccpa1=$COMINccpa/ccpa.$daym2/18/ccpa.t18z.06h.hrap.conus
  ccpa2=$COMINccpa/ccpa.$daym1/00/ccpa.t00z.06h.hrap.conus
  ccpa3=$COMINccpa/ccpa.$daym1/06/ccpa.t06z.06h.hrap.conus
  ccpa4=$COMINccpa/ccpa.$daym1/12/ccpa.t12z.06h.hrap.conus

cat > input_acc_ccpa <<EOF
obs
ccpa.
EOF

# find out if any of the CCPA 6-hourly file is "good".  wgrib will make
# a non-zero return if the file does not exist ($? /=0).  However, if the
# file exist but does not contain GRIB data (e.g. it is empty or contains
# ascii characters), it will have $?=1, and no output.  So we'll do a two-step
# test to determine if a grib file is good.  After 'wgrib', see if
#  1) $? = 0
#  2) Size of output > 0?

for ccpaf in $ccpa1 $ccpa2 $ccpa3 $ccpa4
do
  ${WGRIB} $ccpaf > wgrib.out
  if [[ $? -eq 0 && -s wgrib.out ]]; then
    cat >> input_acc_ccpa <<EOF
$ccpaf
EOF
    ccpaflag=YES
  else
    ccpaflag=NO
    echo Problem getting $ccpaf
    break
  fi
done

cat input_acc_ccpa

if [ $ccpaflag = YES ]; then

  ln -sf input_acc_ccpa fort.545
  $EXECnam/nam_stage4_acc
  ccpa24=ccpa.${daym1}12.24h

  if [[ $? -eq 0 && -s $ccpa24 ]]; then
    ${WGRIB} $ccpa24 > wgrib.out
    if [[ $? -eq 0 && -s wgrib.out ]]; then
      ccpaflag=YES
    else
      ccpaflag=NO
    fi
  else
    ccpaflag=NO
  fi
fi

if [ $ccpaflag = NO ]; then
  echo 'Do not have the CCPA 24h total.  Skip budget adjustment.'
  exit
fi

#
# CCPA inherits Stage 4's bitmap.  As of Apr 2012, the RFCs have not activated
# a data/no data mask on their precipitation analyses (the bitmap in their GRIB
# files are not really in use), so CCPA's bitmap falsely indicate large area
# of data coverage outside of ConUS.  We are using domain map to modify the
# CCPA bitmap - to screen out the OConUS areas.
#

cp $FIXnam/stage3_mask.grb .
ln -sf stage3_mask.grb fort.11
ln -sf $ccpa24 fort.12
ln -sf $ccpa24.conus fort.51
$EXECnam/nam_pcp_conus
err=$?

# Map to expanded 12-km NAM B-grid

# These will be used when George's new ip/w3 libs are put into parallel
grid="255 205 954 835 -7491 -144134 136 54000 -106000 126 108 64 44539 14802"
$COPYGB -g "${grid}" -i3 -x $ccpa24.conus $ccpa24.bgrid

cp $ccpa24.bgrid $COMOUT/${RUN}.t${cyc}.$ccpa24.bgrid


# copy over old water budget history file.  
# It's safer to copy from previous day's 12Z NDAS directory.  During 
# the 32km NAMY tests, the 2003091612 run apparently got re-started 
# 3-times (production pre-empt'd development), so the exndas_h2obudget.sh 
# job was run three times.  There was no pcpbudget_history file from the 
# previous day, but because of this triple-run, the pcpbudget_history ended 
# up to have triple the amount of the day's budget (computed for the 24h
# ending 2003091612).
#
# Use the pcpbudget_history in nam*pll.hold as a backup, otherwise when
# one cycle is missing we'd have to start from scratch.  So we'll use
# ndasnam.$CYCTM24 as the primary location and nam.hold as the
# secondary location when looking for pcpbudget_history.
# 

cp $DIRTM24/${RUN}.t${HH24}z.pcpbudget_history pcpbudget_history.old
err1=$?

if [ $err1 -eq 0 ]; then
  HISTORY=history
else
  cp ${gespath}/${RUN}.hold/pcpbudget_history pcpbudget_history.old
  err2=$?
  if [ $err2 -eq 0 ]; then
    HISTORY=history
  else
    HISTORY=nohistory
    echo 'Old pcpbudget_history file not found.  Start accounting from scratch'
  fi
fi

rm fort.*

cat >itag <<EOF5
$daym1
$HISTORY
EOF5

ln -sf "$ccpa24.bgrid" fort.11
ln -sf "lspa.${daym1}12.24h" fort.12
ln -sf "snowmask.$daym1" fort.13
ln -sf "pcpbudget_history.old" fort.14
ln -sf "pcpbudget.$daym1" fort.51
ln -sf "pcpbudget_history" fort.52
ln -sf "avgbudsum.$daym1" fort.53
ln -sf itag                fort.55
$EXECnam/nam_pcpbudget
err=$?

if [ $err -ne 0 ]; then
  echo $daym1 Error running pcpbudget.x
  exit
else
  cp lspa.${daym1}12.24h $COMOUT/${RUN}.t${cyc}z.lspa.${daym1}12.24h
  cp pcpbudget.$daym1 $COMOUT/${RUN}.t${cyc}z.pcpbudget.$daym1
  cp pcpbudget_history $COMOUT/${RUN}.t${cyc}z.pcpbudget_history
  cp avgbudsum.$daym1 $COMOUT/${RUN}.t${cyc}z.avgbudsum.$daym1
  mv ${gespath}/${RUN}.hold/pcpbudget_history \
     ${gespath}/${RUN}.hold/pcpbudget_history.old
  cp pcpbudget_history ${gespath}/${RUN}.hold/.
fi

echo EXITING $0 with return code $err
exit $err

