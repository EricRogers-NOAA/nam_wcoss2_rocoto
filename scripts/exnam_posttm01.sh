#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_posttm01.sh.ecf
# Script description:  Run nam post job off NAM 12 km first guess
#                      restart file for TC relocation                      
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract:  Run nam post job off NAM 12 km first guess for TC relocation
#
# Script history log:
# 1999-06-23  Eric Rogers
# 1999-08-17  Brent Gordon  -- Modified for production.
# 2007-10-03  Bradley Mabe  -- Implemented latest changes
# 2013-??-??  Guang Ping Lou -- Initial version for TC relocation
# 2015-??-??  Eric Rogers -- Convert to GRIB2, mods for NAMv4
#

set -xa
cd $DATA 

msg="$job HAS BBGUN"
postmsg "$msg"

#
# Get needed variables from exndas_prelim.sh.ecf
#

. $GESDIR/${RUN}.t${cyc}z.envir.sh

export SDATE=$CYCLE
export MODELTYPE=NMM
export OUTTYP=binarynemsio
export GTYPE=grib2

####export FORT_BUFFERED=true

tmval=`echo $tmmark | cut -c3-4`
export SDATE=`${NDATE} -$tmval $CYCLE`
export CYCLE

export fhr=01

nposts=01
incpst=01

VALDATE=`${NDATE} ${fhr} ${SDATE}`

valyr=`echo $VALDATE | cut -c1-4`
valmn=`echo $VALDATE | cut -c5-6`
valdy=`echo $VALDATE | cut -c7-8`
valhr=`echo $VALDATE | cut -c9-10`

timeform=${valyr}"-"${valmn}"-"${valdy}"_"${valhr}":00:00"

cp $FIXnam/nam_micro_lookup.dat eta_micro_lookup.dat
cp $PARMnam/nam_post_avblflds.xml post_avblflds.xml
cp $PARMnam/nam_params_grib2_tbl params_grib2_tbl_new

cp $PARMnam/nam_cntrlanl_flatfile.txt postxconfig-NT.txt

cat > itag <<EOF
$GESDIR/${RUN}.t${cyc}z.nmm_b_restart_nemsio.tm01
$OUTTYP
$GTYPE
$timeform
$MODELTYPE
EOF

export pgm=nam_ncep_post
. prep_step

startmsg
${MPIEXEC} -n ${procs} -ppn ${procspernode} --cpu-bind core --depth 1 $EXECnam/nam_ncep_post < itag >> $pgmout 2>errfile
export err=$?;err_chk

cp BGDANL${fhr}.tm01 $COMOUT/nam.${cycle}.bgdges${fhr}.tm01.grib2

filnam=awpges
gridspecs="nps:260:60 217.5:1196:12679 -2.5:817:12679"

cp $PARMnam/wgrib2.txtlists/neighbor_interp.parm .

$WGRIB2 BGDANL${fhr}.tm01 | grep -F -f $PARMnam/wgrib2.txtlists/nam_${filnam}.txt | $WGRIB2 -i -grib inputs.grib${gridnum} BGDANL${fhr}.tm01
$WGRIB2 inputs.grib${gridnum} -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv inputs.grib${gridnum}.uv
python $USHnam/wgrib2_parm_filter.py $PARMnam/wgrib2.txtlists/forpyscript/nam_${filnam}.txt
#Extract NEIGHBOR and BUDGET envars
NEIGHBOR=`cat neighbor.txt`
BUDGET=`cat budget.txt`
$WGRIB2 inputs.grib${gridnum}.uv -set_bitmap 1 -set_grib_type c3 -new_grid_winds grid -new_grid_vectors "UGRD:VGRD:USTM:VSTM" \
     -new_grid_interpolation bilinear \
     -if $NEIGHBOR -new_grid_interpolation neighbor -fi \
     -if $BUDGET -new_grid_interpolation budget -fi \
     -new_grid ${gridspecs} ${filnam}${fhr}.tm01.uv
$WGRIB2 ${filnam}${fhr}.tm01.uv -new_grid_vectors "UGRD:VGRD:USTM:VSTM" -submsg_uv ${filnam}${fhr}.tm01.grib2
export err=$?;err_chk

mv ${filnam}${fhr}.tm01.grib2 $COMOUT/nam.${cycle}.${filnam}${fhr}.tm01.grib2

echo EXITING $0
exit $err
#
