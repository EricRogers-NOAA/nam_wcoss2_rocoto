set -x

ER=/meso/save/Eric.Rogers/tempscripts

time="tm06 tm05 tm04 tm03 tm02 tm01"

for tmmark in $time
do

cat $ER/runnam_nemsinterp_catchup_template | sed s:TMMARK:$tmmark: > runnam_nemsinterp_catchup.${tmmark}

bsub < runnam_nemsinterp_catchup.${tmmark}
sleep 45

done
