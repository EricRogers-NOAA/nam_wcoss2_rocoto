#!/bin/bash

MACHID=wcoss2

set -x

export bufr_ver=11.4.0

versiondir=`dirname $(readlink -f ../../versions)`
echo $versiondir
. $versiondir/versions/build.ver

#overwrite build.ver bufr/11.5.0 with older version; tocsbufr aborts 
#with bufr/11.5.0
export bufr_ver=11.4.0

module purge
module load envvar/${envvar_ver}

moduledir=`dirname $(readlink -f ../../modulefiles/${MACHID})`
module use ${moduledir}
source ${moduledir}/${MACHID}/build/v4.0.0_build_new

export OUTmain=`dirname $(readlink -f ../exec/ )`
export OUTDIR=${OUTmain}/exec

make -f ./Makefile

cd wgrib2_v2.0.7a/sorc
./install_all_grib_util_wcoss.sh_wgrib2only
cd ../exec
cp wgrib2 ../../../exec/.

set +x
module unload build/v4.0.0_build_new
set -x
exit 0
