
################################################################################
#
# Name : getgfsbc_nam.sh           Author : Eric Rogers
#
# Abstract: This script copies sigma coefficient files from the specified GFS
#           run to the local directory for use as boundary conditions in the
#           NDAS/NAM. This script also returns the where_gfs_ran file and  
#           the sfcanl file
#
# Log:
#
# 98-06-15 : Eric Rogers
# 98-10-13 : Eric Rogers - Modified to use ndate/getges.sh to get best 
#            available sigma coefficient file (either GFS or GDAS)
# 02-05-17 : Eric Rogers created new version for T254/L64 Global model. 
#            Script determines resolution of coefficient file and runs
#            global_chgres to convert sigma file to T254/L64 resolution
#            if necessary
# 05-03-21 : New version for T382 GFS; remove check on T254 resolution since
#            T382 resolution data will be available out to 7 days
#             
# Usage:
#
# getgfsbc_nam.sh $DATE $IHFIN envira
#
# DATE  = 10 digit starting date date (e.g., 1998061900)
# IHFIN = Last forecast hour to be copied
# envir_getges = Environment ($envir) variable from calling script (prod, para, test)
#
set -x

if [ $# -lt 2 ] ; then
   echo "Usage: $0 DATE IHFIN"
   exit 8
fi

gfsstart=$1
ifin=$2
envira=$3
tmmark=$4
ifhr=00
icnt=0

while [ $ifhr -le $ifin ] ; do

  $NDATE $ifhr $gfsstart > valdate
  VDATE=`cut -c 1-10 valdate`

  $UTIL_USHnam/getges_linkges.sh -t sigcur -v $VDATE -e $envira gfsbc${icnt}.${tmmark}

  let "icnt = icnt + 1"
  let "ifhr = ifhr + 3"
  typeset -Z2 ifhr

done

let "icnt = icnt - 1"

if [[ -e gfsbc${icnt}.${tmmark} ]]
then
  echo The $VDATE forecast was successfully copied
  exit $?
else
  echo The $VDATE forecast did not finish
  exit 8
fi


