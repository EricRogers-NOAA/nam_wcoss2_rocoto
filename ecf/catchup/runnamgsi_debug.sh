#!/bin/sh
#PBS -N nam_catchup_analysis_tm06
#PBS -l place=vscatter,select=8:ncpus=128:mpiprocs=32:mem=200GB
#PBS -l walltime=00:20:00
#PBS -e nam_catchup_analysis_tm06.out
#PBS -o nam_catchup_analysis_tm06.out
#PBS -q dev
#PBS -A NAM-DEV
#PBS -l debug=true
#PBS -V

module purge
module load envvar/1.0
module load PrgEnv-intel/8.1.0
module load intel/19.1.3.304
module load craype/2.7.6
module load cray-mpich/8.1.7
module load cray-pals/1.0.12

# Loading NetCDF 4
module load prod_util/2.0.8
module load prod_envir/2.0.5
module load libjpeg/9c
module load grib_util/1.2.2
module load crtm/2.3.0
module load hdf5-parallel/1.10.6
module load netcdf-hdf5parallel/4.7.4

set -x

mkdir -p /lfs/h2/emc/stmp/Eric.Rogers/testnamgsi_debug
cd /lfs/h2/emc/stmp/Eric.Rogers/testnamgsi_debug

export ntasks=256
export ppn=32
export threads=1

# OMP settings
export OMP_PLACES=cores
export OMP_NUM_THREADS=$threads
export OMP_STACKSIZE=1G

set +x
cp /lfs/h2/emc/ptmp/Eric.Rogers/inputgsi.tm06/* .
set -x

EXECnam=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/exec
EXEC=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/sorc/nam_gsi.fd/GSI/build/bin/gsi_DBG.x

export MP_STDOUTMODE="ORDERED"

mpiexec -n $ntasks -ppn $ppn --cpu-bind core --depth $threads $EXEC < gsiparm.anl > pgmout 2> errfile
