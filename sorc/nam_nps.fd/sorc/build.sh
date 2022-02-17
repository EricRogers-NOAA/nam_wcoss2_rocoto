#!/bin/bash

SORC=$(pwd)
cd ../../../versions
source build.ver
cd $SORC

module load envvar/${envvar_ver:-1.0}
module load PrgEnv-intel/${PrgEnv_intel_ver:-8.1.0}
module load intel/${intel_ver:-19.1.3.304}
module load craype/${craype_ver:-2.7.10}
module load cray-mpich/${cray_mpich_ver:-8.1.10}

cd NMMB_init/NPS
./clean

moduledir=`dirname $(readlink -f ../../../modulefiles/wcoss2)`
module use ${moduledir}
source ${moduledir}/wcoss2/v4.1.0_build

./conf wcoss2

module list

cp configure.nps_wcoss2_dmpara configure.nps

OUTDIR_WCOSS2=../../../../../exec/
OUTDIR=../../exec

mkdir -p $OUTDIR

./compile geogrid
cp -L geogrid.exe ${OUTDIR}/nam_geogrid

./compile metgrid
cp -L metgrid.exe ${OUTDIR}/nam_metgrid

./compile ungrib
cp -L ungrib.exe  ${OUTDIR}/nam_ungrib

./compile nemsinterp
cp -L nemsinterp.exe ${OUTDIR}/nam_nemsinterp

# this clean might not be necessary, but seems like a good idea
./clean

cp configure.nps_wcoss2_serial configure.nps

./compile metgrid
cp -L metgrid.exe ${OUTDIR}/nam_metgrid_boco

./compile ungrib
cp -L ungrib/src/ungribs.exe  ${OUTDIR}/nam_ungrib_boco

# not needed
##./compile nemsinterp
##cp -L nemsinterp.exe ${OUTDIR}/nam_nemsinterp_boco

pwd
cp ${OUTDIR}/* ${OUTDIR_WCOSS2}/.
cd ../..
