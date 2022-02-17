set -x
# runs in ksh

hr=00

while [ $hr -le 60 ] ; do

area="alaska conus hawaii prico"

for reg in $area
do
# cat run_nam_profile_nests_template.sh | sed s/FHR/${hr}/ | sed s/DOMAIN/$reg/ > run_nam_profile_${reg}_tm00_f${hr}.sh
  qsub run_nam_profile_${reg}_tm00_f${hr}.sh
  sleep 3
done
  let "hr=hr+1"
  typeset -Z2 hr
done

