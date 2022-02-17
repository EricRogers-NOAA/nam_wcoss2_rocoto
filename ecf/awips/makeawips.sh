set -x
# runs in ksh

hr=06

while [ $hr -le 84 ] ; do
# cat run_nam_awips_template.sh | sed s/FHR/${hr}/ > run_nam_awips_f${hr}.sh
  qsub run_nam_awips_f${hr}.sh
  sleep 5
  let "hr=hr+3"
  typeset -Z2 hr
done
