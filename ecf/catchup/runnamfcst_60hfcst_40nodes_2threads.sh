#!/bin/sh
#PBS -N nam_forecast_12_40nodes
#PBS -l place=vscatter:excl,select=40:ncpus=128:mpiprocs=64:ompthreads=2
#PBS -l walltime=02:45:00
#PBS -e nam_forecast_12.out_40nodes_2threads
#PBS -o nam_forecast_12.out_40nodes_2threads
#PBS -q dev
#PBS -A NAM-DEV
#PBS -l debug=true
#PBS -V

module purge
module load envvar/1.0
module load PrgEnv-intel/8.1.0
module load craype/2.7.10
module load intel/19.1.3.304
module load cray-mpich/8.1.9
module load cray-pals/1.0.17

#module load prod_util/2.0.9
#module load prod_envir/2.0.4
#module load cfp/2.0.4
module load hdf5/1.10.6
module load netcdf/4.7.4
#module load nemsio/2.5.2
#module load libpng/1.6.37
#module load libjpeg/9c
#module load grib_util/1.2.3

set -x

EXECnam=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/exec/nam_nems_nmmb_fcst
EXECnam_nco=/lfs/h1/ops/para/packages/nam.v4.2.0/exec/nam_nems_nmmb_fcst
FIXnam=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/fix

# OMP settings
export OMP_NUM_THREADS=2
export OMP_STACKSIZE=1G

mkdir -p /lfs/h2/emc/stmp/Eric.Rogers/testfcst.40nodes
cd /lfs/h2/emc/stmp/Eric.Rogers/testfcst.40nodes
cp /lfs/h2/emc/ptmp/Eric.Rogers/inputfcst_40nodes/* .

ln -sf nam_global_o3prdlos.f77 fort.28
ln -sf nam_global_o3clim.txt fort.48

# Needed for NAM fcst

export LANG=en_US
export MPI_LABELIO=YES
export MP_STDOUTMODE=ORDERED

ulimit -s unlimited

export OMP_PROC_BIND=true
export OMP_NUM_THREADS=2
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

mpiexec --line-buffer --label -n 2560 -ppn 64 --cpu-bind depth --depth 2 $EXECnam_nco > pgmout.c5 2>errfile.c5
