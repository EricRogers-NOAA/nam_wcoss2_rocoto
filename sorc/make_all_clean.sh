#!/bin/bash

MACHID=wcoss2
SORCnam=$(pwd)

set -x

versiondir=`dirname $(readlink -f ../versions)`
echo $versiondir
. $versiondir/versions/build.ver

moduledir=`dirname $(readlink -f ../modulefiles/${MACHID})`
module use ${moduledir}
source ${moduledir}/${MACHID}/build/v4.0.0_build_new

set -x
export OUTmain=`dirname $(readlink -f ../exec/ )`
export OUTDIR=${OUTmain}/exec

make -f ./Makefile clean

# Clean post0 code
cd ${SORCnam}/nam_post0.fd
./build_post0_clean.sh

# Clean ncep post
cd ${SORCnam}/nam_nceppost.fd/sorc
./build_ncep_post.sh_cleanonly > build_post.log 2>> build_post.log

# Clean nam_nems_nmmb.fd
cd ${SORCnam}/nam_nems_nmmb.fd/src
./clean.sh

#clean nam_land_utilities
cd ${SORCnam}/nam_land_utilities.fd/sorc
./build_emcsfc.sh_cleanonly > build_emcsfc.log 2>> build_emcsfc.log

# clean NPS code
cd ${SORCnam}/nam_nps.fd/sorc
./build.sh_cleanonly

# clean GSI code (remove ./GSI/build subdirectory)
cd ${SORCnam}/nam_gsi.fd/GSI
rm -rf build

# remove remaining executables
rm $OUTDIR/*

cd ${SORCnam}

exit 0
