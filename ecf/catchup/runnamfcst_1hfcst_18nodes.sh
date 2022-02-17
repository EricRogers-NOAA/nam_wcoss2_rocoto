#!/bin/sh
#PBS -N nam_catchup_forecast_tm06_12
#PBS -l place=scatter:excl,select=18:ncpus=128
#PBS -l walltime=00:45:00
#PBS -e nam_catchup_forecast_tm06_12.out
#PBS -o nam_catchup_forecast_tm06_12.out
#PBS -q dev
#PBS -A NAM-DEV
#PBS -l hyper=true
#PBS -l debug=true
#PBS -V

module purge
module load envvar/1.0
module load PrgEnv-intel/8.1.0
module load craype/2.7.10
module load intel/19.1.3.304
module load cray-mpich/8.1.9
module load cray-pals/1.0.17
module load hdf5/1.10.6
module load netcdf/4.7.4
module load esmf/7.1.0r
module load nemsio/2.5.2

set -x

EXECnam=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/exec/nam_nems_nmmb_fcst
##EXECnam=/lfs/h2/emc/eib/noscrub/James.A.Abeles/nam.v4.2.0/nam_nems_nmmb.fd.er/exe/NEMS.x
FIXnam=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/fix

##BASEDIR=/lfs/h2/emc/eib/noscrub/James.A.Abeles
##EXEC=$BASEDIR/nam.v4.2.0/nam_nems_nmmb.fd.er/exe/NEMS.x

###export ntasks=2048
export ntasks=1152
###export ppn=128
export ppn=64
###export threads=1
export threads=2

mkdir -p /lfs/h2/emc/stmp/Eric.Rogers/testfcst.tm06_erexec18_mine1
cd /lfs/h2/emc/stmp/Eric.Rogers/testfcst.tm06_erexec18_mine1
cp /lfs/h2/emc/ptmp/Eric.Rogers/input.2021082412.tm06fcst/* .

ln -sf $FIXnam/nam_global_o3prdlos.f77 fort.28
ln -sf $FIXnam/nam_global_o3clim.txt fort.48

ulimit -s unlimited
ulimit -a
export OMP_NUM_THREADS=2
###export OMP_NUM_THREADS=1
export OMP_PROC_BIND=true
export OMP_STACKSIZE=1G
export MPICH_ABORT_ON_ERROR=1
#export MPICH_ENV_DISPLAY=1
#export MPICH_VERSION_DISPLAY=1
#export MPICH_RANK_REORDER_DISPLAY=1

#ulimit -c unlimited
export MALLOC_MMAP_MAX_=0
export MALLOC_TRIM_THRESHOLD_=134217728
export FORT_FMT_NO_WRAP_MARGIN=true
export MPICH_REDUCE_NO_SMP=1
export FOR_DISABLE_KMP_MALLOC=TRUE
export FI_OFI_RXM_RX_SIZE=40000
export FI_OFI_RXM_TX_SIZE=40000
export MPICH_OFI_STARTUP_CONNECT=1
export MPICH_OFI_VERBOSE=1
export MPICH_OFI_NIC_VERBOSE=1

#  export PMI_DEBUG=1
export FI_OFI_RXM_RX_SIZE=40000
export FI_OFI_RXM_TX_SIZE=40000
#export FI_VERBS_PREFER_XRC=1

mpiexec -n ${ntasks} -ppn ${ppn} --cpu-bind core --depth ${threads} $EXECnam > pgmout.c5 2>errfile.c5

grep wall pgmout.c5
