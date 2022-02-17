#!/bin/sh
#PBS -N nam_catchup_post_tm06_f01_12
#PBS -l select=1:ncpus=28:mem=28GB
#PBS -l walltime=00:20:00
#PBS -e /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/logs/nam_catchup_post_tm06_f01_12.out
#PBS -o /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/logs/nam_catchup_post_tm06_f01_12.out
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

module load hdf5/${hdf5_ver}
module load netcdf/${netcdf_ver}
module load prod_util/${prod_util_ver}
module load crtm/${crtm_ver}

set -x

export procs=28
export procspernode=28

export cyc=12
export PDY=20210824
export tmmark=tm06
export envir=canned
export nam_ver=v4.2.0
export post_times=01
export jobid=jnam_catchup_post_tm06_f01_${cyc}.${PBS_JOBID}
export job=nam_catchup_post_tm06_f01_${cyc}
export NWROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers
export PACKAGEROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers

export MPI_LABELIO=YES

export PS4='+ $SECONDS + '
export COMDATEROOT=/lfs/h1/ops/canned/com
export HOMEjobs=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/jobs

export threads=1
export MP_LABELIO=yes
export OMP_NUM_THREADS=1
export OMP_PLACES=cores

#execute J-job

$HOMEjobs/JNAM_POST
