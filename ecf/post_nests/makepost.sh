set -x
# runs in ksh

hr=00

while [ $hr -le 60 ] ; do

if [ $hr -le 36 ] ; then
area="alaska conus hawaii prico firewx"
else
area="alaska conus hawaii prico"
fi

for reg in $area
do
  if [ $reg = alaska ] ; then
   mem=60
  elif [ $reg = conus ] ; then
   mem=100
  else
   mem=28
  fi
# cat run_nam_post_nests_template.sh | sed s/FHR/${hr}/ | sed s/DOMAIN/$reg/ | sed s/MEM/$mem/ > run_nam_post_${reg}_tm00_f${hr}.sh
  qsub run_nam_post_${reg}_tm00_f${hr}.sh
  sleep 4
done
  let "hr=hr+1"
  typeset -Z2 hr
done

