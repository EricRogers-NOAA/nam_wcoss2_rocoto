#!/bin/sh

########################################
# Script to clean up NAM model run directories 
########################################

set -xa

cd $DATA 

if [ ! -s ${GESDIR}/cleaned_${CDATE}.out ]; then

  set -x

    if [ -d ${DATAROOT} ]; then
      cd ${DATAROOT}
#     rm -rf ${DATAROOT}/${RUN}_${cyc}_pmgr_conus_${tmmark}_${envir}
      if [ $tmmark = tm00 ]; then
        #And clean up any remaining nam_${cyc}_tm*_${envir} directories that may have been missed previously
        rm -rf ${DATAROOT}/${RUN}_${cyc}_tm*_${envir}
#       rm -rf ${DATAROOT}/${RUN}_${cyc}_pmgr_conus_tm*_${envir}
#       rm -rf ${DATAROOT}/${RUN}_${cyc}_pmgr_alaska_tm*_${envir}
        rm -rf ${DATAROOT}/${RUN}_${cyc}_main_${envir}
      fi
      date
      cd $DATAROOT
    fi
    echo "ALL_CLEAN!" > ${GESDIR}/cleaned_${CDATE}.out
fi

exit 0 

