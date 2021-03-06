#!/bin/sh
#PBS -N nam_catchup_postguess
#PBS -l select=1:ncpus=28:mem=28GB
#PBS -l walltime=00:20:00
#PBS -e nam_catchup_postguess.out_wen
#PBS -o nam_catchup_postguess.out_wen
#PBS -q dev
#PBS -A NAM-DEV
#####PBS -l debug=true
#PBS -V

module purge
module load envvar/1.0
module load PrgEnv-intel/8.1.0
module load intel/19.1.3.304
module load craype/2.7.6
module load cray-mpich/8.1.7
module load cray-pals/1.0.12
module load cfp/2.0.4

module load hdf5/1.10.6
module load netcdf/4.7.4
module load crtm/2.3.0
module load prod_util/2.0.8
module load prod_envir/2.0.5
module load libjpeg/9c
module load grib_util/1.2.2

set -x

mkdir -p /lfs/h2/emc/stmp/Eric.Rogers/testpost_wen
cd /lfs/h2/emc/stmp/Eric.Rogers/testpost_wen

export procs=28
export procspernode=28

export cyc=12
export PDY=20210824
export CYCLE=2021082412
export fhr=01
export tmmark=tm01
export envir=canned
export nam_ver=v4.2.0

export NWROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers

export MPI_LABELIO=YES
export MP_STDOUTMODE="ORDERED"

export PS4='+ $SECONDS + '

export SDATE=$CYCLE
export MODELTYPE=NMM
export OUTTYP=binarynemsio
export GTYPE=grib2

####export FORT_BUFFERED=true

tmval=`echo $tmmark | cut -c3-4`
export SDATE=`${NDATE} -$tmval $CYCLE`
export CYCLE

export fhr=01

nposts=01
incpst=01

VALDATE=`${NDATE} ${fhr} ${SDATE}`

valyr=`echo $VALDATE | cut -c1-4`
valmn=`echo $VALDATE | cut -c5-6`
valdy=`echo $VALDATE | cut -c7-8`
valhr=`echo $VALDATE | cut -c9-10`

timeform=${valyr}"-"${valmn}"-"${valdy}"_"${valhr}":00:00"

export HOMEnam=$NWROOT/nam.v4.2.0
export FIXnam=$HOMEnam/fix
export PARMnam=$HOMEnam/parm
export EXECnam=$HOMEnam/exec

cp $FIXnam/nam_micro_lookup.dat eta_micro_lookup.dat
cp $PARMnam/nam_post_avblflds.xml post_avblflds.xml
cp $PARMnam/nam_params_grib2_tbl params_grib2_tbl_new
cp $PARMnam/nam_cntrlanl_flatfile.txt postxconfig-NT.txt

export RUN=nam
export cyc=12
export GESDIR=/lfs/h2/emc/ptmp/Eric.Rogers/canned/com/nam/v4.2/nwges/nam.20210824

export threads=1
export MP_LABELIO=yes
export OMP_NUM_THREADS=$threads
export OMP_PLACES=cores

cat > itag <<EOF
$GESDIR/${RUN}.t${cyc}z.nmm_b_restart_nemsio.tm01
$OUTTYP
$GTYPE
$timeform
$MODELTYPE
EOF

###mpiexec -n 28 -ppn 28 --cpu-bind core --depth 1 /u/Wen.Meng/noscrub/ncep_post/gfsv16/UPP/exec/ncep_post < itag >> pgmout 2>errfile
mpiexec -n 28 -ppn 28 --cpu-bind core --depth 1 $EXECnam/nam_ncep_post < itag >> pgmout 2>errfile

echo DONE

