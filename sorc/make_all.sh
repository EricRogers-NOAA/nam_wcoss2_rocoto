#!/bin/bash

SORCnam=$(pwd)
MACHID=wcoss2

set -x

versiondir=`dirname $(readlink -f ../versions)`
echo $versiondir
. $versiondir/versions/build.ver

module purge
module load envvar/${envvar_ver}

moduledir=`dirname $(readlink -f ../modulefiles/${MACHID})`
module use ${moduledir}
source ${moduledir}/${MACHID}/build/v4.0.0_build_new

set -x
export OUTmain=`dirname $(readlink -f ../exec/ )`
export OUTDIR=${OUTmain}/exec
mkdir -p $OUTDIR

make -f ./Makefile

cd $SORCnam
# Now build ref2nemsio
./build_ref2nemsio.sh > build_ref2nemsio.log 2>> build_ref2nemsio.log

# Now build nam_post0 code
cd ${SORCnam}/nam_post0.fd
./build_post0.sh > ${SORCnam}/build_post0.log 2>> build_post0.log

# Now build ncep post
cd ${SORCnam}/nam_nceppost.fd/sorc
./build_ncep_post.sh > ${SORCnam}/build_post.log 2>> build_post.log

# Now build NMMB forecast model code
cd ${SORCnam}/nam_nems_nmmb.fd/src
./build.sh > ${SORCnam}/build_fcst.log 2>> build_fcst.log

# Now build land-surface utility codes
cd ${SORCnam}/nam_land_utilities.fd/sorc
./build_emcsfc.sh > ${SORCnam}/build_emcsfc.log 2>> build_emcsfc.log

# Now build the GSI
cd $SORCnam
./build_gsi.sh > ${SORCnam}/build_gsi.log 2>> build_gsi.log

cd ${SORCnam}/nam_nps.fd/sorc
./build.sh > ${SORCnam}/build_nps.log 2>> build_nps.log

cd $SORCnam

exit 0
