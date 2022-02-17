#!/bin/sh
#PBS -N nam_catchup_coldstart_prep_hawaii_00
#PBS -l select=1:ncpus=32:mem=100GB
#PBS -l walltime=00:20:00
#PBS -e /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/logs/nam_catchup_coldstart_prep_hawaii_00.out
#PBS -o /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/logs/nam_catchup_coldstart_prep_hawaii_00.out
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

module load netcdf/${netcdf_ver}
module load prod_util/${prod_util_ver}
module load prod_envir/${prod_envir_ver}
module load libjpeg/${libjpeg_ver}
module load grib_util/${grib_util_ver}

set -x

export cyc=00
export PDY=20210825
export tmmark=tm00
export envir=canned
export nam_ver=v4.2.0
export domain=hawaii

export jobid=jnam_catchup_coldstart_prep_${domain}_${cyc}.${PBS_JOBID}
export job=nam_catchup_coldstart_prep_${domain}_${cyc}
export NWROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers
export PACKAGEROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers

export MPI_LABELIO=YES
export MP_STDOUTMODE="ORDERED"

export procs=32
export procspernode=32

export PS4='+ $SECONDS + '
export COMDATEROOT=/lfs/h1/ops/canned/com
export HOMEjobs=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/jobs

#execute J-job

$HOMEjobs/JNAM_COLDSTART_PREP_NEST






