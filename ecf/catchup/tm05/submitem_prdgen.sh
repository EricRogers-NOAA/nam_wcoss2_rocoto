set -x

qsub run_nam_catchup_prdgen_alaska_tm05_f00.sh
qsub run_nam_catchup_prdgen_alaska_tm05_f01.sh
qsub run_nam_catchup_prdgen_conus_tm05_f00.sh
qsub run_nam_catchup_prdgen_conus_tm05_f01.sh
qsub run_nam_catchup_prdgen_tm05_f00.sh
qsub run_nam_catchup_prdgen_tm05_f01.sh