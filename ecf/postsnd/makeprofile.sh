set -x
# runs in ksh

hr=00

while [ $hr -le 84 ] ; do
# cat run_nam_profile_template.sh | sed s/FHR/${hr}/ > run_nam_profile_tm00_f${hr}.sh
  qsub run_nam_profile_tm00_f${hr}.sh
  let "hr=hr+1"
  sleep 3
  typeset -Z2 hr
done
