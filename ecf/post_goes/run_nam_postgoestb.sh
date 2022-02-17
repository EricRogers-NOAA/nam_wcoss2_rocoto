#!/bin/sh
#PBS -N nam_post_goestb_12
#PBS -l place=vscatter:excl,select=1:ncpus=128
####PBS -l select=1:ncpus=84:mem=200GB
#PBS -l walltime=02:20:00
#PBS -e /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/logs/nam_post_goestb_12.out
#PBS -o /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/logs/nam_post_goestb_12.out
#PBS -q dev
#PBS -A NAM-DEV
#PBS -l debug=true
#PBS -V

set -x

VERFILE=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/versions
. $VERFILE/nam.ver

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

export procs=128
export procspernode=128

export cyc=12
export PDY=20210824
export tmmark=tm00
export envir=canned
export nam_ver=v4.2.0
export jobid=jnam_post_goestb_${cyc}.${PBS_JOBID}
export NWROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers
export PACKAGEROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers

export MPI_LABELIO=YES

export PS4='+ $SECONDS + '
export COMDATEROOT=/lfs/h1/ops/canned/com
export HOMEjobs=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/jobs

export threads=1
export MP_LABELIO=yes
export OMP_NUM_THREADS=$threads
export OMP_PLACES=cores

#execute J-job

$HOMEjobs/JNAM_POST_GOESTB
