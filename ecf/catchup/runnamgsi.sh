#!/bin/bash

#PBS -N nam_catchup_analysis_tm06
#PBS -l place=vscatter:excl,select=9:ncpus=128:mpiprocs=16:ompthreads=8
#PBS -l walltime=00:20:00
#PBS -j oe
#PBS -q dev
#PBS -A NAM-DEV
#PBS -l debug=true
#PBS -V

set -ax

module purge
module load envvar/1.0
module load PrgEnv-intel/8.1.0
module load craype/2.7.10
module load intel/19.1.3.304
module load cray-mpich/8.1.9
module load cray-pals/1.0.17

module load prod_util/2.0.10
module load prod_envir/2.0.5
module load crtm/2.3.0
module load cfp/2.0.4
module load netcdf/4.7.4

export FI_OFI_RXM_SAR_LIMIT=3145728

export ntasks=144
export ppn=16
export threads=8

# OMP settings
export OMP_PLACES=cores
export OMP_NUM_THREADS=$threads
export OMP_STACKSIZE=1G

DATA=/lfs/h2/emc/stmp/$LOGNAME/testnamgsi_dogwood_latest
rm -rf $DATA
mkdir -p $DATA
cd $DATA

cp /lfs/h2/emc/ptmp/Eric.Rogers/inputgsi.tm06/* .

EXECnam=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0/exec/nam_gsi_dogwood_latest

cp $EXECnam ./gsi.x

qstat -f $PBS_JOBID

APRUN="mpiexec -n $ntasks -ppn $ppn --cpu-bind core --depth $threads"

$APRUN $EXECnam < gsiparm.anl 1> stdout 2> stderr

exit

