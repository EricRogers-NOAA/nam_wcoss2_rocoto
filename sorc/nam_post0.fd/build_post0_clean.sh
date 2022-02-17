set -x

BASE=`pwd`
export BASE

cd ../../versions
source build.ver
cd $BASE

module purge
module use -a modulefiles
module load modulefile.nam_post0_wcoss2
make clean
