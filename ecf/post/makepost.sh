set -x
# runs in ksh

hr=00

while [ $hr -le 84 ] ; do
# cat run_nam_post_template.sh | sed s/FHR/${hr}/ > run_nam_post_tm00_f${hr}.sh
  qsub run_nam_post_tm00_f${hr}.sh
  sleep 4
  let "hr=hr+1"
  typeset -Z2 hr
done
