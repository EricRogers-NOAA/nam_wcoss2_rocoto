#!/bin/bash -l

VERFILE=/lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0_rocoto/versions
. $VERFILE/run.ver

module purge
module load envvar/${envvar_ver}
module load PrgEnv-intel/${PrgEnv_intel_ver}
module load intel/${intel_ver}
module load craype/${craype_ver}
module load cray-mpich/${cray_mpich_ver}
module load cray-pals/${cray_pals_ver}

module use /apps/ops/test/nco/modulefiles/
module load core/rocoto/1.3.4

mkdir -p /lfs/h2/emc/ptmp/Eric.Rogers/output_para
mkdir -p /lfs/h2/emc/stmp/Eric.Rogers/tmp

rocotorun -v 10 -w /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0_rocoto/NAM_wcoss2_ops.xml -d /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0_rocoto/NAM_wcoss2.db
##rocotorun -v 10 -w /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0_rocoto/NAM_wcoss2_opshyper.xml -d /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0_rocoto/NAM_wcoss2.db
###rocotorun -v 10 -w /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0_rocoto/NAM_wcoss2.xml -d /lfs/h2/emc/lam/noscrub/Eric.Rogers/nam.v4.2.0_rocoto/NAM_wcoss2.db
