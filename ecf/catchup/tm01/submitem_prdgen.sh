set -x

qsub run_nam_catchup_prdgen_alaska_tm01_f00.sh
qsub run_nam_catchup_prdgen_alaska_tm01_f01.sh
qsub run_nam_catchup_prdgen_conus_tm01_f00.sh
qsub run_nam_catchup_prdgen_conus_tm01_f01.sh
qsub run_nam_catchup_prdgen_tm01_f00.sh
qsub run_nam_catchup_prdgen_tm01_f01.sh
