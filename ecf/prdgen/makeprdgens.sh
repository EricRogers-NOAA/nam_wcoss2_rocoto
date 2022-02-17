set -x
# runs in ksh

hr=00

while [ $hr -le 36 ] ; do
# cat run_nam_prdgen_tm00.sh_template | sed s/FHR/${hr}/ > run_nam_prdgen_tm00_f${hr}.sh
  qsub run_nam_prdgen_tm00_f${hr}.sh
  sleep 4
  let "hr=hr+1"
  typeset -Z2 hr
done

hr=39

while [ $hr -le 84 ] ; do
# cat run_nam_prdgen_tm00.sh_template | sed s/FHR/${hr}/ > run_nam_prdgen_tm00_f${hr}.sh
  qsub run_nam_prdgen_tm00_f${hr}.sh
  sleep 4
  let "hr=hr+3"
  typeset -Z2 hr
done

