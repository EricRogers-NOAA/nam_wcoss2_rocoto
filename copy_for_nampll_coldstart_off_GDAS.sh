set -x

export prodenv=canned
export devenv=canned

mkdir -p /lfs/h2/emc/stmp/Eric.Rogers/setup
cd /lfs/h2/emc/stmp/Eric.Rogers/setup

set +x
module load prod_util/2.0.12
set -x

mkdir -p /lfs/h2/emc/ptmp/Eric.Rogers/output_para
mkdir -p /lfs/h2/emc/stmp/Eric.Rogers/tmpnwprd/para

export PDY=20210824
export cyc=12
export cycle=t${cyc}z

export nam_ver=v4.2

OPS=`compath.py ${prodenv}/nam/$nam_ver`

DEV=/lfs/h2/emc/ptmp/Eric.Rogers/${prodenv}/com/nam/v4.2
mkdir -p /lfs/h2/emc/ptmp/Eric.Rogers/${devenv}/com/nam/v4.2

setpdy.sh
. ./PDY

exit

DATEtm06=`$NDATE -6 $PDY$cyc`
PDYtm06=`$NDATE -6 $PDY$cyc | cut -c 1-8`
cyctm06=`$NDATE -6 $PDY$cyc | cut -c 9-10`
DATEtm12=`$NDATE -12 $PDY$cyc`
PDYtm12=`$NDATE -12 $PDY$cyc | cut -c 1-8`
cyctm12=`$NDATE -12 $PDY$cyc | cut -c 9-10`
DATEtm18=`$NDATE -18 $PDY$cyc`
PDYtm18=`$NDATE -18 $PDY$cyc | cut -c 1-8`
cyctm18=`$NDATE -18 $PDY$cyc | cut -c 9-10`
DATEtm24=`$NDATE -24 $PDY$cyc`
PDYtm24=`$NDATE -24 $PDY$cyc | cut -c 1-8`
cyctm24=`$NDATE -24 $PDY$cyc | cut -c 9-10`

OPSnam=${OPS}/nam.$PDY
OPSnam_m1=${OPS}/nam.$PDYtm06

DEVnam=${DEV}/nam.$PDY
DEVnam_m1=${DEV}/nam.$PDYtm06
mkdir -p $DEVnam $DEVnam_m1

OPSNWGES=/lfs/h1/ops/${prodenv}/com/nam/v4.2/nwges
DEVNWGES=/lfs/h2/emc/ptmp/Eric.Rogers/${devenv}/com/nam/v4.2/nwges
mkdir -p $DEVNWGES/nam.${PDYtm06}

###nwges/nam.hold not in canned data on Dogwood
if [ $prodenv != canned ]
then
OPSNWGES_HOLD=$OPSNWGES/nam.hold
fi

DEVNWGES_HOLD=$DEVNWGES/nam.hold
mkdir -p $DEVNWGES_HOLD

# copy all files from COM

cp $OPS/nam.$PDYtm06/nam.t${cyctm06}z.satbias.tm01 $DEV/nam.$PDYtm06/.
cp $OPS/nam.$PDYtm06/nam.t${cyctm06}z.satbias_pc.tm01 $DEV/nam.$PDYtm06/.
cp $OPS/nam.$PDYtm06/nam.t${cyctm06}z.radstat.tm01 $DEV/nam.$PDYtm06/.

#copy all files from nwges

if [ $prodenv = prod ]
then
cp $OPSNWGES_HOLD/satbias_in $DEVNWGES_HOLD/.
cp $OPSNWGES_HOLD/satbias_pc $DEVNWGES_HOLD/.
cp $OPSNWGES_HOLD/radstat.nam $DEVNWGES_HOLD/.
cp $OPSNWGES_HOLD/pcpbudget* $DEVNWGES_HOLD/.
cp $OPSNWGES_HOLD/*reject* $DEVNWGES_HOLD/.
cp $OPSNWGES_HOLD/nmm_b_restart_nemsio_hold.${cyc}z $DEVNWGES_HOLD/.
cp $OPSNWGES_HOLD/nmm_b_restart_conusnest_nemsio_hold.${cyc}z $DEVNWGES_HOLD/.
cp $OPSNWGES_HOLD/nmm_b_restart_alaskanest_nemsio_hold.${cyc}z $DEVNWGES_HOLD/.
else
cp $OPSNWGES/nam.${PDYtm06}/nam.t${cyctm06}z.nmm_b_restart_nemsio.tm01 $DEVNWGES_HOLD/nmm_b_restart_nemsio_hold.${cyctm06}z
cp $OPSNWGES/nam.${PDYtm06}/nam.t${cyctm06}z.nmm_b_restart_conusnest_nemsio.tm01 $DEVNWGES_HOLD/nmm_b_restart_conusnest_nemsio_hold.${cyctm06}z
cp $OPSNWGES/nam.${PDYtm06}/nam.t${cyctm06}z.nmm_b_restart_alaskanest_nemsio.tm01 $DEVNWGES_HOLD/nmm_b_restart_alaskanest_nemsio_hold.${cyctm06}z
cp $OPS/nam.$PDYtm06/nam.t${cyctm06}z.satbias.tm01 $DEVNWGES_HOLD/satbias_in
cp $OPS/nam.$PDYtm06/nam.t${cyctm06}z.satbias_pc.tm01 $DEVNWGES_HOLD/satbias_pc
cp $OPS/nam.$PDYtm06/nam.t${cyctm06}z.radstat.tm01 $DEVNWGES_HOLD/radstat.nam
fi
