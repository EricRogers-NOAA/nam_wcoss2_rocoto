#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_coldstart_prepnest_tm00.sh.ecf
# Script description:  Runs NPS off GDAS first guess input for NAM nests 
#                      to coldstart NAM 84-h forecast ofg global
#                      if catchup cycle did not finish
#
# Author:        Eric Rogers       Org: NP22         Date: 2004-07-02
#
# Script history log:
# 2006-02-01  Eric Rogers - Based on HIRESW script
# 2008-08-14  Eric Rogers - Converted to use WPS
# 2009-05-22  Eric Rogers - Converted to use NPS
# 2013-01-25  Jacob Carley - NAM retro
# 2015-11-25  Eric Rogers - Added non-cycled nests to NAM
# 2016-07-27  Eric Rogers - Special version for coldstart of NAM off GDAS
# 2016-12-29  Eric Rogers - Modified for GFS 2017Q3 version
# 2020-05-25  Eric Rogers - Convert to use GDAS 0.25 deg GRIB2 data for GFS v16

set -x

msg="JOB $job FOR NMMB HAS BEGUN"
postmsg "$msg"

export DOMNAM=nam

spectral=false
gribsrc=GFS
doclouds=false

#
# Get needed variables from exnam_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh

mkdir -p $DATA/ungrib
mkdir -p $DATA/metgrid
mkdir -p $DATA/nemsinterp

#Remove any potential pre-existing files in these subdirectories
rm -f $DATA/ungrib/*
rm -f $DATA/metgrid/*
rm -f $DATA/nemsinterp/*

if [ $domain = firewx ]; then

  mkdir -p $DATA/gridgen_sfc
  mkdir -p $DATA/geogrid
  rm -r $DATA/gridgen_sfc/*
  rm -r $DATA/geogrid/*

  cd $DATA/gridgen_sfc
  rm b_d03*

  cpreq ${FIRE_WX_CENTER_POINTS} ./firewx_loc

  centlat=${centlat:-`grep ${cyc}z firewx_loc | awk '{print $2}'`}
  centlon=${centlon:-`grep ${cyc}z firewx_loc | awk '{print $3}'`}

  echo $centlat $centlon > $COMOUT/nam.t${cyc}z.firewxnest_center_latlon
  if [ $SENDDBN = YES ]; then
     $DBNROOT/bin/dbn_alert MODEL NAM_FIREWXNEST_TEXT $job $COMIN/nam.t${cyc}z.firewxnest_center_latlon
  fi

  if [ $centlat -ge 52 ]; then
    firewx_location=alaska
    echo $firewx_location > $COMOUT/nam.t${cyc}z.firewxnest_location
  else
    firewx_location=conus
    echo $firewx_location > $COMOUT/nam.t${cyc}z.firewxnest_location
  fi

  echo "export firewx_location=`cat $COMIN/nam.t${cyc}z.firewxnest_location | awk '{print $1}'`" >> $GESDIR/nam.t${cyc}z.envir.sh

  cpreq $PARMnam/nam_firewx_${firewx_location}.nml_stub .

cat > nam_firewx_${firewx_location}.nml_stub1 << !
&input_data
  leaf_area_idx_file=""
  gfrac_file="$FIXnam/geog/green.0.144.bin"
  mxsnow_alb_file="$FIXnam/geog/mxsno.1.0.bin"
  roughness_file="igbp"
  slopetype_file="$FIXnam/geog/slope.1.0.bin"
  snowfree_albedo_file="$FIXnam/geog/albedo.1.0.bin"
  soiltype_tile_file="$FIXnam/geog/topsoil_fao.30s"
  substrate_temp_file="$FIXnam/geog/tbot.1.0.bin"
  vegtype_tile_file="$FIXnam/geog/veg_igbp1a.bin"
  lsmask_file="$FIXnam/geog/mask.umd.flake.30s.bin"
  orog_file="$FIXnam/geog/terrain_usgs.v2_30s.bin"
/
!

  cat nam_firewx_${firewx_location}.nml_stub nam_firewx_${firewx_location}.nml_stub1 > nam_firewx_${firewx_location}.nml

  cat nam_firewx_${firewx_location}.nml | sed s:CENTLAT_FWX:$centlat: \
   | sed s:CENTLON_FWX:$centlon: > testb.nml

  export pgm=emcsfc_gridgen_sfc
  . prep_step

  ln -sf testb.nml fort.41

  startmsg
  ${MPIEXEC} $EXECnam/emcsfc_gridgen_sfc >> $pgmout 2>errfile
  export err=$?;err_chk

  cp $pgmout $DATA/${pgmout}.gridgen_sfc
  cp errfile $DATA/errfile.gridgen_sfc

  cpreq b_d03* $DATA/geogrid/.
  cpreq testb.nml $DATA/geogrid/firewx.nml

  cd $DATA/geogrid

  mkdir geogrid
  cpreq $PARMnam/nam_GEOGRID.TBL.NMB ./geogrid/GEOGRID.TBL

  echo DATEXX${CYCLE} > ncepdate.npstm00

  ### modify namelist file
  ystart=`cat ncepdate.npstm00 | cut -c7-10`
  mstart=`cat ncepdate.npstm00 | cut -c11-12`
  dstart=`cat ncepdate.npstm00 | cut -c13-14`
  hstart=`cat ncepdate.npstm00 | cut -c15-16`

  start=$ystart$mstart$dstart$hstart
  end=`${NDATE} +00 $start`

  yend=`echo $end | cut -c1-4`
  mend=`echo $end | cut -c5-6`
  dend=`echo $end | cut -c7-8`
  hend=`echo $end | cut -c9-10`

  geog_path=$FIXnam/geog
  ignore_gridgen_sfc=".true."

  cat $PARMnam/nam_namelist.geogrid_${firewx_location}_firewx | sed s:YSTART:$ystart:g | sed s:MSTART:$mstart:g \
   | sed s:DSTART:$dstart:g | sed s:HSTART:$hstart:g | sed s:YEND:$yend:g \
   | sed s:MEND:$mend:g  | sed s:DEND:$dend:g | sed s:HEND:$hend:g \
   | sed s:CENTLAT_FWX:$centlat: | sed s:CENTLON_FWX:$centlon: | sed s:GEOG_PATH:$geog_path: \
   | sed s:IGNORE_GRIDGEN:${ignore_gridgen_sfc}: > namelist.nps

  export pgm=nam_geogrid
  . prep_step

  ln -sf firewx.nml fort.81

  startmsg
  ${MPIEXEC} $EXECnam/nam_geogrid >> $pgmout 2>errfile
  export err=$?;err_chk

  cp $pgmout $DATA/${pgmout}.geogrid
  cp errfile $DATA/errfile.geogrid

  cpreq nest_start_03 $COMOUT/nam.t${cyc}z.firewx_ijstart.txt

  # send firewx fix files to /com for archival and for coldstart job

  type="tbot slopeidx elevtiles hpnt_latitudes hpnt_longitudes mxsnoalb slmask snowfree_albedo soiltiles vegfrac vegtiles vpnt_latitudes vpnt_longitudes z0clim"

  for file in ${type}; do
    mv b_d03_${file}.grb $COMOUT/nam.t${cyc}z.firewx_${file}.grb
  done

  mv geo_nmb.d03.dio $COMOUT/nam.t${cyc}z.geo_nmb.firewx.dio

  # end firewx block for gridgen_sfc and geogrid
fi

cd $DATA/ungrib
sh 

datetm00=`${NDATE} -0 $CYCLE`

echo DATEXX${datetm00} > ncepdate.npstm00
cpreq ncepdate.npstm00 $DATA/metgrid/.

### modify namelist file
PDYstart=`cat ncepdate.npstm00 | cut -c7-14`
ystart=`cat ncepdate.npstm00 | cut -c7-10`
mstart=`cat ncepdate.npstm00 | cut -c11-12`
dstart=`cat ncepdate.npstm00 | cut -c13-14`
hstart=`cat ncepdate.npstm00 | cut -c15-16`

start=$ystart$mstart$dstart$hstart

CYCer=`cat ncepdate.npstm00 | cut -c 7-16`
CYCstart=`${NDATE} -0 $CYCer`
CYCgdas=`${NDATE} -6 $CYCer`

echo DATEXX${CYCgdas} > nmcdate.gdas

PDYgds=`cat nmcdate.gdas | cut -c7-14`
yygds=`cat nmcdate.gdas | cut -c7-10`
mmgds=`cat nmcdate.gdas | cut -c11-12`
ddgds=`cat nmcdate.gdas | cut -c13-14`
cycgds=`cat nmcdate.gdas | cut -c15-16`

end=`${NDATE} +00 $start`

yend=`echo $end | cut -c1-4`
mend=`echo $end | cut -c5-6`
dend=`echo $end | cut -c7-8`
hend=`echo $end | cut -c9-10`
  
ignore_gridgen_sfc=".false."

if [ $domain = firewx ]; then

  cat $PARMnam/nam_namelist.nps_${domain}nest_${firewx_location} | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
   | sed s:DSTART:$dstart: | sed s:HSTART:$hstart: | sed s:YEND:$yend: \
   | sed s:MEND:$mend:     | sed s:DEND:$dend: | sed s:HEND:$hend: \
   | sed s:CENTLAT_FWX:$centlat: | sed s:CENTLON_FWX:$centlon: \
   | sed s:SPECTRAL:$spectral: | sed s:DOCLOUDS:$doclouds: | sed s:GRIBSRC:$gribsrc: \
   | sed s:IGNORE_GRIDGEN:${ignore_gridgen_sfc}: > namelist.nps

else

  cat $PARMnam/nam_namelist.nps_${domain}nest | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
   | sed s:DSTART:$dstart: | sed s:HSTART:$hstart: | sed s:YEND:$yend: \
   | sed s:MEND:$mend:     | sed s:DEND:$dend: | sed s:HEND:$hend: \
   | sed s:SPECTRAL:$spectral: | sed s:DOCLOUDS:$doclouds: | sed s:GRIBSRC:$gribsrc: \
   | sed s:IGNORE_GRIDGEN:${ignore_gridgen_sfc}: > namelist.nps

fi

DATE=`echo $start | cut -c1-8`

rm Vtable

#####

cpreq $PARMnam/nam_Vtable.GFS.bocos Vtable

hrs="06"
   
for hr in ${hrs}; do

  vldgdas=`${NDATE} $hr ${PDYgds}${cycgds}`

  $UTIL_USHnam/getges_linkges_pgrb.sh -t pg2ges -v $vldgdas -e ${envir_getges} gdas.pgb2f${hr}

done

ln -sf gdas.pgb2f06 GRIBFILE.AAA

####

export pgm=nam_ungrib
. prep_step

startmsg
${MPIEXEC} $EXECnam/nam_ungrib >> $pgmout 2>errfile
export err=$?;err_chk

mv errfile $DATA/errfile.ungrib

### run metgrid

cd $DATA/metgrid
sh 

mv $DATA/ungrib/$pgmout .

STARTHR=00
ENDHR=00
INCRHR=00

ystart=`cat ncepdate.npstm00 | cut -c7-10`
echo ystart $ystart
mstart=`cat ncepdate.npstm00 | cut -c11-12`
echo mstart $mstart
dstart=`cat ncepdate.npstm00 | cut -c13-14`
echo dstart $dstart
hstart=`cat ncepdate.npstm00 | cut -c15-16`

orig_start=$ystart$mstart$dstart${hstart}

start=`${NDATE} 0 ${orig_start}`
ystart=`echo $start | cut -c1-4`
mstart=`echo $start | cut -c5-6`
dstart=`echo $start | cut -c7-8`
hstart=`echo $start | cut -c9-10`

end=`${NDATE} 0 ${orig_start}`

echo $start
echo $end

yend=`echo $end | cut -c1-4`
mend=`echo $end | cut -c5-6`
dend=`echo $end | cut -c7-8`
hend=`echo $end | cut -c9-10`

ignore_gridgen_sfc=".false."

if [ $domain = firewx ]; then

  cat $PARMnam/nam_namelist.nps_${domain}nest_${firewx_location} | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
   | sed s:DSTART:$dstart: | sed s:HSTART:$hstart: | sed s:YEND:$yend: \
   | sed s:MEND:$mend:     | sed s:DEND:$dend: | sed s:HEND:$hend: \
   | sed s:CENTLAT_FWX:$centlat: | sed s:CENTLON_FWX:$centlon: \
   | sed s:SPECTRAL:$spectral: | sed s:DOCLOUDS:$doclouds: | sed s:GRIBSRC:$gribsrc: \
   | sed s:IGNORE_GRIDGEN:${ignore_gridgen_sfc}: > namelist.nps

  cpreq $COMIN/nam.t${cyc}z.geo_nmb.firewx.dio geo_nmb.d01.dio

else

  cat $PARMnam/nam_namelist.nps_${domain}nest | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
   | sed s:DSTART:$dstart: | sed s:HSTART:${hstart}: | sed s:YEND:$yend: \
   | sed s:MEND:$mend:     | sed s:DEND:$dend: | sed s:HEND:$hend: \
   | sed s:SPECTRAL:$spectral: | sed s:DOCLOUDS:$doclouds: | sed s:GRIBSRC:$gribsrc: \
   | sed s:IGNORE_GRIDGEN:${ignore_gridgen_sfc}: > namelist.nps

  cpreq $FIXnam/nam_geo_nmb.d01.dio_${domain}nest geo_nmb.d01.dio
fi
cpreq $PARMnam/nam_METGRID.TBL.NMM_gfsgrib2 METGRID.TBL

FHR=$STARTHR

time=`${NDATE} +${FHR} ${orig_start}`
yy=`echo $time | cut -c1-4`
mm=`echo $time | cut -c5-6`
dd=`echo $time | cut -c7-8`
hh=`echo $time | cut -c9-10`

cpreq $DATA/ungrib/FILE:${yy}-${mm}-${dd}_${hh} .
echo GRABBED $FHR
 
FHR=`expr $FHR + $INCRHR`
 
echo $FHR

export pgm=nam_metgrid
. prep_step

startmsg
${MPIEXEC} $EXECnam/nam_metgrid >> $pgmout 2>errfile
export err=$?;err_chk

mv errfile $DATA/errfile.metgrid

### run nemsinterp

cd $DATA/nemsinterp
sh 

cp $DATA/metgrid/$pgmout .
ln -sf $DATA/metgrid/met_nmb*dio . 
cpreq $DATA/metgrid/namelist.nps .

export pgm=nam_nemsinterp
. prep_step

startmsg
${MPIEXEC} $EXECnam/nam_nemsinterp >> $pgmout 2>errfile
export err=$?;err_chk

mv errfile $DATA/errfile.nemsinterp

# move files back to GESDIR

mv input_domain_01_nemsio $GESDIR/nam.t${cyc}z.input_domain_${domain}nest_nemsio.tm00_precoldstart

mv $pgmout $DATA/.

cd $DATA

cat errfile.ungrib errfile.metgrid errfile.nemsinterp > errfile

exit $err 
