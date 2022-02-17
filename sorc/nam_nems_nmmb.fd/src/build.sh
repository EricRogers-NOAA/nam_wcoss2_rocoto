#!/bin/bash

set -x

SORC=$(pwd)

cd ../../../versions
source build.ver
cd $SORC

make clean
./configure wcoss2
. conf/modules.nems.wcoss2
./compile.sh_pll
