#!/bin/sh
#PBS -N nam_forecast_parentext_12
#PBS -l place=vscatter:excl,select=4:ncpus=128
#PBS -l walltime=00:30:00
#PBS -e /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/logs/nam_forecast_parentext_12.out
#PBS -o /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/logs/nam_forecast_parentext_12.out
#PBS -q dev
#PBS -A NAM-DEV
#PBS -l debug=true
#PBS -V

set -x

VERFILE=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/versions
. $VERFILE/run.ver

module purge
module load envvar/${envvar_ver}
module load PrgEnv-intel/${PrgEnv_intel_ver}
module load intel/${intel_ver}
module load craype/${craype_ver}
module load cray-mpich/${cray_mpich_ver}
module load cray-pals/${cray_pals_ver}

module load prod_util/${prod_util_ver}
module load prod_envir/${prod_envir_ver}
module load cfp/${cfp_ver}
module load hdf5/${hdf5_ver}
module load netcdf/${netcdf_ver}
module load nemsio/${nemsio_ver}
module load libpng/${libpng_ver}
module load libjpeg/${libjpeg_ver}
module load grib_util/${grib_util_ver}

set -x

export ntasks=512
export ppn=128
export threads=1

ulimit -s unlimited
ulimit -a
export OMP_PROC_BIND=true
export OMP_NUM_THREADS=$threads
export OMP_STACKSIZE=1G

export MPICH_ABORT_ON_ERROR=1
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

export cyc=12
export PDY=20210824
export tmmark=tm00
export envir=canned
export nam_ver=v4.2.0
export jobid=jnam_forecast_parentext_${cyc}.${PBS_JOBID}
export job=nam_forecast_parentext_${cyc}
export NWROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers
export PACKAGEROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers

export MPI_LABELIO=YES
export MP_STDOUTMODE="ORDERED"

export PS4='+ $SECONDS + '
export COMDATEROOT=/lfs/h1/ops/canned/com
export HOMEjobs=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/jobs

#execute J-job

$HOMEjobs/JNAM_FORECAST_PARENTEXT
