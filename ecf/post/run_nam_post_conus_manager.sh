#!/bin/sh
#PBS -N nam_post_conus_manager_12
#PBS -l select=1:ncpus=1:mem=200MB
#PBS -l walltime=02:20:00
#PBS -e /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/logs/nam_post_conus_manager_12.out
#PBS -o /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/logs/nam_post_conus_manager_12.out
#PBS -q dev
#PBS -A NAM-DEV
#PBS -l debug=true
#PBS -V

VERFILE=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/versions
. $VERFILE/run.ver

module purge
module load envvar/${envvar_ver}
module load PrgEnv-intel/${PrgEnv_intel_ver}
module load intel/${intel_ver}
module load craype/${craype_ver}
module load cray-mpich/${cray_mpich_ver}
module load cray-pals/${cray_pals_ver}

module load netcdf/${netcdf_ver}
module load prod_util/${prod_util_ver}
module load prod_envir/${prod_envir_ver}
module load libjpeg/${libjpeg_ver}
module load grib_util/${grib_util_ver}

set -x

export cyc=12
export PDY=20210824
export tmmark=tm00
export domain=conus
export envir=canned
export nam_ver=v4.2.0
export jobid=jnam_post_conus_manager_${cyc}.${PBS_JOBID}
export job=nam_post_conus_manager_${cyc}

export NWROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers
export PACKAGEROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers
export WKDIRNAME=nam_{cyc}_main_${envir}

export MPI_LABELIO=YES
export MP_STDOUTMODE="ORDERED"

export PS4='+ $SECONDS + '
export COMDATEROOT=/lfs/h1/ops/canned/com
export HOMEjobs=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/jobs

#execute J-job

$HOMEjobs/JNAM_POST_MANAGER_NEST
