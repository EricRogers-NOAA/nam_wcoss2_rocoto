#!/bin/ksh

################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         nam_boco_ungrib_gen_catchup.sh
# Script description:  Runs the NPS ungrib executable to process
#                      GFS GRIB data for NAM catchup cycle boco file generation
#
# Author:        Eric Rogers       Org: NP22         Date: 2016-12-23
#
# Script history log:
# 2016-12-23  Eric Rogers - Adapted for NAM based on HIRESW script

set -x

cyc=${1}
stream=${2}

cd $DATA/run_ungrib_${stream}

cp $PARMnam/nam_Vtable.GFS.bocos Vtable
cp $DATA/namelist.nps.${stream} namelist.nps

export pgm=nam_ungrib_boco
startmsg

$EXECnam/nam_ungrib_boco >> $pgmout 2>errfile
export err=$?
err_chk

exit
