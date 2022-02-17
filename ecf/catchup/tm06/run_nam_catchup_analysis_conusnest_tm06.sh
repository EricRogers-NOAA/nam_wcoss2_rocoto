#!/bin/sh
#PBS -N nam_catchup_analysis_conus_tm06_12
#PBS -l place=vscatter:excl,select=11:ncpus=128:mpiprocs=16:ompthreads=8
#PBS -l walltime=00:20:00
#PBS -e /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/logs/nam_catchup_analysis_conus_tm06_12.out
#PBS -o /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/logs/nam_catchup_analysis_conus_tm06_12.out
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
module load crtm/${crtm_ver}
module load cfp/${cfp_ver}
module load netcdf/${netcdf_ver}

set -x

export FI_OFI_RXM_SAR_LIMIT=3145728
export MPICH_COLL_OPT_OFF=1

export ntasks=176
export ppn=16
export threads=8

# OMP settings
export OMP_PLACES=cores
export OMP_NUM_THREADS=$threads
export OMP_STACKSIZE=1G

export cyc=12
export PDY=20210824
export tmmark=tm06
export envir=canned
export domain=conus
export nam_ver=v4.2.0
export jobid=jnam_catchup_analysis_${domain}.${tmmark}_${cyc}.${PBS_JOBID}
export job=nam_catchup_analysis_${domain}.${tmmark}_${cyc}
export NWROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers
export PACKAGEROOT=/lfs/h2/emc/lam/noscrub/Eric.Rogers

export MPI_LABELIO=YES
export MP_STDOUTMODE="ORDERED"

export PS4='+ $SECONDS + '
export COMDATEROOT=/lfs/h1/ops/canned/com
export HOMEjobs=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/jobs

#execute J-job

$HOMEjobs/JNAM_ANALYSIS_NEST







