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
# cat run_nam_prdgen_nests_tm00.sh | sed s/FHR/${hr}/ | sed s/DOMAIN/$reg/ > run_nam_prdgen_${reg}_f${hr}.sh
  qsub run_nam_prdgen_${reg}_f${hr}.sh
  sleep 4
done
  let "hr=hr+1"
  typeset -Z2 hr
done

