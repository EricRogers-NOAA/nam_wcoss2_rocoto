#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_gsireg_nest.sh.ecf
# Script description:  Runs regional GSI variational analysis for NAM nests
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Script history log:
# 1999-06-23  Eric Rogers
# 1999-08-02  Brent Gordon  - Modified for production
# 2006-01-13  Eric Rogers - Modified for WRF-NMM GSI analysis
# 2013-01-24  Jacob Carley - Converted to NAM retro
# 2015-??-??  Jacob Carley - NAMV4 version
# 2018-08-24  Eric.Rogers - Changes for FV3GFS input
# 2020-07-27  Eric Rogers - Changes for GDAS v16 (new GSI code, netcdf enkf files)
# 2021-11-17  Eric Rogers - WCOSS2 changes
#

set -x
cd $DATA

msg="JOB $job HAS BEGUN"
postmsg "$msg"

#
# Get needed variables from exnam_prelim.sh.sms
#
. $GESDIR/nam.t${cyc}z.envir.sh

offset=-`echo $tmmark | cut -c 3-4`
DATEANL=`${NDATE} $offset $CYCLE`
SDATE=`${NDATE} $offset $CYCLE`

adate=$SDATE

case $tmmark in
  tm06) export tmmark_prev=tm06;;
  tm05) export tmmark_prev=tm06;;
  tm04) export tmmark_prev=tm05;;
  tm03) export tmmark_prev=tm04;;
  tm02) export tmmark_prev=tm03;;
  tm01) export tmmark_prev=tm02;;
  tm00) export tmmark_prev=tm01;;
esac

offset_prev=-`echo $tmmark_prev | cut -c 3-4`
SDATE_PREV=`${NDATE} $offset_prev $CYCLE`

# Specify fixed field and data directories.
aday=`echo $adate | cut -c1-8`
cya=`echo $adate | cut -c9-10`
cday=`echo $CYCLE | cut -c1-8`
CYC=`echo $CYCLE | cut -c9-10`

# Check for EnKF files every time since the script will make the 
#   decision to use the files on the fly.  So start by always setting HYB_ENS true

HYB_ENS=".true."

# We expect 81 total files to be present (80 enkf + 1 mean)
nens=81

# Not using FGAT or 4DEnVar, so hardwire nhr_assimilation to 3
nhr_assimilation=3
typeset -Z2 nhr_assimilation
rm filelist${nhr_assimilation}

# With the enhanced bias correction scheme switched on, there is no need to update
# the predictors in the nest since the satellite bias corrections from the nest are
# NOT cycled.  Rather the nest uses the bias corrections from the parent.
SETUP2="upd_pred(1)=0.0,upd_pred(2)=0.0,upd_pred(3)=0.0,upd_pred(4)=0.0,upd_pred(5)=0.0"
SETUP3="upd_pred(6)=0.0,upd_pred(7)=0.0,upd_pred(8)=0.0,upd_pred(9)=0.0,upd_pred(10)=0.0"
SETUP4="upd_pred(11)=0.0,upd_pred(12)=0.0,upd_pred(13)=0.0,upd_pred(14)=0.0,upd_pred(15)=0.0"
SETUP5="upd_pred(16)=0.0,upd_pred(17)=0.0,upd_pred(18)=0.0,upd_pred(19)=0.0,upd_pred(20)=0.0"

#####  connect with GDAS EnKF ensemble #################
if [ $HYB_ENS = ".true." ]; then
    # Get 81 members, including the mean, best available (not necessarily valid at adate), store their paths in filelist${nhr_assimilation}
    #  and link the ensemble mean to the provide 03 filename
    #  Will not write an output file if nens members do not exist
    python $UTIL_USHnam/getbest_EnKF_linkfiles.py -v $adate --exact=no --minsize=${nens} -m yes -d ${COMINgfs}/enkfgdas -o filelist${nhr_assimilation} --o3fname=gfs_sigf${nhr_assimilation} --gfs_netcdf=yes
fi

sync

#Check to see if ensembles were found
if [ ! -s filelist${nhr_assimilation} ]; then
  echo "Ensembles not found - turning off HYBENS!"
  HYB_ENS=".false."
else
# make filelist03 to be read into code
  mv filelist${nhr_assimilation} $COMOUT/${RUN}.${cycle}.${domain}nest.filelist${nhr_assimilation}.location.${tmmark}
  ls ens_* >>filelist${nhr_assimilation}
fi


# Turned off for FV3GFS
USEGFSO3=.false.

# Set some parameters in the GSI namelist related to the choice of background
#  (and, indirectly, the berror file)
if [ $GUESS = GDAS -a ${tmmark} = tm06 ] ; then
  
  fstat=.false.
  vs=0.6
  refflag=-1
  berror=$FIXnam/nam_nmmstat_na_glberror.gcv
  anavinfo=$FIXnam/anavinfo_nems_nmmb_glb

else

  vs=1.0
  fstat=.true.
  berror=$FIXnam/nam_nmmstat_na.gcv
  anavinfo=$FIXnam/anavinfo_nems_nmmb

  # Get radar Ref file if it is available

  mydate=`echo ${adate} |cut -c1-8`
  thishour=`echo ${adate} |cut -c9-10`
  mydbzinfile=refd3d.t${thishour}z.grb2f00
  datref=${COMINradar}/radar.${mydate}

  if [ $domain = alaska -o $domain = hawaii -o $domain = prico -o $domain = firewx ]; then
    # No radar data available in AK quite yet, so switch off in AK nest for now
    # HI/PR/FW nests not-cycled so switch off for the domains
    refflag=-99
  else
    cp ${datref}/$mydbzinfile .
    refflag=$?
  fi

fi

# Reset tm00 settings if coldstarting NAM forecast off GDAS
if [ $tmmark = tm00 -a $RUNTYPE = CATCHUP ] ; then 
  if [ $GUESStm00 = GDAS ] ; then 
    fstat=.false.
    vs=0.6
    if [ $domain = alaska -o $domain = hawaii -o $domain = prico -o $domain = firewx ] ; then
      refflag=-99
    else
      refflag=-1
    fi
    berror=$FIXnam/nam_nmmstat_na_glberror.gcv
    anavinfo=$FIXnam/anavinfo_nems_nmmb_glb
  fi
fi

useref_envir=$GESDIR/nam.t${cyc}z.useref_envir_${domain}_${tmmark}.sh

if [ $refflag -ne 0 ] ; then
  echo "Radar reflectivity assimilation is turned OFF. refflag:${refflag} tmmark: ${tmmark}"
  echo "false" > ${useref_envir}
  i_gsdcldanal_type=0
else
  echo "Radar reflectivity assimilation is turned ON. refflag:${refflag} tmmark: ${tmmark}"
  echo "true" > ${useref_envir}
  i_gsdcldanal_type=2
fi

# Make gsi namelist
cat << EOF > gsiparm.anl
 &SETUP
   miter=2,niter(1)=50,niter(2)=50,niter_no_qc(1)=20,
   write_diag(1)=.true.,write_diag(2)=.false.,write_diag(3)=.true.,
   gencode=78,qoption=2,
   factqmin=0.0,factqmax=0.0,
   iguess=-1,use_gfs_ozone=${USEGFSO3},
   oneobtest=.false.,retrieval=.false.,
   nhr_assimilation=${nhr_assimilation},l_foto=.false.,
   use_pbl=.false.,gpstop=30.,
   use_gfs_nemsio=.false.,use_gfs_ncio=.true.,
   print_diag_pcg=.true.,
   newpc4pred=.true., adp_anglebc=.true., angord=4,
   passive_bc=.true., use_edges=.false., emiss_bc=.true.,
   diag_precon=.true., step_start=1.e-3, tzr_qc=0,
   verbose=.false.,
   ${SETUP2},
   ${SETUP3},
   ${SETUP4},
   ${SETUP5},   
 /
 &GRIDOPTS
  wrf_nmm_regional=.false.,wrf_mass_regional=.false.,nems_nmmb_regional=.true.,diagnostic_reg=.false.,
  nmmb_reference_grid='H',grid_ratio_nmmb=3.0,
  filled_grid=.false.,half_grid=.false.,netcdf=.false.,nvege_type=20,
 /
 &BKGERR
   hzscl=0.373,0.746,1.50,
   vs=${vs},bw=0.,fstat=${fstat},
 /
 &ANBKGERR
   anisotropic=.false.,
 /
 &JCOPTS
 /
 &STRONGOPTS
   nstrong=0,nvmodes_keep=20,period_max=3.,
    baldiag_full=.true.,baldiag_inc=.true.,  
 /
 &OBSQC
   dfact=0.75,dfact1=3.0,noiqc=.false.,c_varqc=0.02,
   vadfile='prepbufr',njqc=.false.,vqc=.true.,
   HUB_NORM=.false.,
 /
 &OBS_INPUT
   dmesh(1)=120.0,time_window_max=1.5,ext_sonde=.true.,
 /
OBS_INPUT::
!  dfile          dtype       dplat       dsis                  dval    dthin  dsfcalc
   prepbufr       ps          null        ps                  0.0     0     0
   prepbufr       t           null        t                   0.0     0     0
   prepbufr_profl t           null        t                   0.0     0     0
   prepbufr       q           null        q                   0.0     0     0
   prepbufr_profl q           null        q                   0.0     0     0
   prepbufr       pw          null        pw                  0.0     0     0
   prepbufr       uv          null        uv                  0.0     0     0
   prepbufr_profl uv          null        uv                  0.0     0     0
   satwndbufr     uv          null        uv                  0.0     0     0
   prepbufr       spd         null        spd                 0.0     0     0
   prepbufr       dw          null        dw                  0.0     0     0
   l2rwbufr       rw          null        l2rw                0.0     0     0
   prepbufr       sst         null        sst                 0.0     0     0
   nsstbufr       sst         nsst        sst                 0.0     0     0
   gpsrobufr      gps_bnd     null        gps                 0.0     0     0
   hirs3bufr      hirs3       n17         hirs3_n17           0.0     1     0
   hirs4bufr      hirs4       metop-a     hirs4_metop-a       0.0     1     1
   gimgrbufr      goes_img    g11         imgr_g11            0.0     1     0
   gimgrbufr      goes_img    g12         imgr_g12            0.0     1     0
   airsbufr       airs        aqua        airs_aqua           0.0     1     1
   amsuabufr      amsua       n15         amsua_n15           0.0     1     1
   amsuabufr      amsua       n18         amsua_n18           0.0     1     1
   amsuabufr      amsua       metop-a     amsua_metop-a       0.0     1     1
   airsbufr       amsua       aqua        amsua_aqua          0.0     1     1
   amsubbufr      amsub       n17         amsub_n17           0.0     1     1
   mhsbufr        mhs         n18         mhs_n18             0.0     1     1
   mhsbufr        mhs         metop-a     mhs_metop-a         0.0     1     1
   ssmitbufr      ssmi        f14         ssmi_f14            0.0     1     0
   ssmitbufr      ssmi        f15         ssmi_f15            0.0     1     0
   amsrebufr      amsre_low   aqua        amsre_aqua          0.0     1     0
   amsrebufr      amsre_mid   aqua        amsre_aqua          0.0     1     0
   amsrebufr      amsre_hig   aqua        amsre_aqua          0.0     1     0
   ssmisbufr      ssmis       f16         ssmis_f16           0.0     1     0
   ssmisbufr      ssmis       f17         ssmis_f17           0.0     1     0
   ssmisbufr      ssmis       f18         ssmis_f18           0.0     1     0
   ssmisbufr      ssmis       f19         ssmis_f19           0.0     1     0
   gsnd1bufr      sndrd1      g12         sndrD1_g12          0.0     1     0
   gsnd1bufr      sndrd2      g12         sndrD2_g12          0.0     1     0
   gsnd1bufr      sndrd3      g12         sndrD3_g12          0.0     1     0
   gsnd1bufr      sndrd4      g12         sndrD4_g12          0.0     1     0
   gsnd1bufr      sndrd1      g11         sndrD1_g11          0.0     1     0
   gsnd1bufr      sndrd2      g11         sndrD2_g11          0.0     1     0
   gsnd1bufr      sndrd3      g11         sndrD3_g11          0.0     1     0
   gsnd1bufr      sndrd4      g11         sndrD4_g11          0.0     1     0
   gsnd1bufr      sndrd1      g13         sndrD1_g13          0.0     1     0
   gsnd1bufr      sndrd2      g13         sndrD2_g13          0.0     1     0
   gsnd1bufr      sndrd3      g13         sndrD3_g13          0.0     1     0
   gsnd1bufr      sndrd4      g13         sndrD4_g13          0.0     1     0
   iasibufr       iasi        metop-a     iasi_metop-a        0.0     1     1
   omibufr        omi         aura        omi_aura            0.0     2     0
   hirs4bufr      hirs4       n19         hirs4_n19           0.0     1     1
   amsuabufr      amsua       n19         amsua_n19           0.0     1     1
   mhsbufr        mhs         n19         mhs_n19             0.0     1     1
   tcvitl         tcp         null        tcp                 0.0     0     0
   seviribufr     seviri      m08         seviri_m08          0.0     1     0
   seviribufr     seviri      m09         seviri_m09          0.0     1     0
   seviribufr     seviri      m10         seviri_m10          0.0     1     0
   hirs4bufr      hirs4       metop-b     hirs4_metop-b       0.0     1     1
   amsuabufr      amsua       metop-b     amsua_metop-b       0.0     1     1
   mhsbufr        mhs         metop-b     mhs_metop-b         0.0     1     1
   iasibufr       iasi        metop-b     iasi_metop-b        0.0     1     1
   atmsbufr       atms        npp         atms_npp            0.0     1     0
   crisbufr       cris        npp         cris_npp            0.0     1     0
   gsnd1bufr      sndrd1      g14         sndrD1_g14          0.0     1     0
   gsnd1bufr      sndrd2      g14         sndrD2_g14          0.0     1     0
   gsnd1bufr      sndrd3      g14         sndrD3_g14          0.0     1     0
   gsnd1bufr      sndrd4      g14         sndrD4_g14          0.0     1     0
   gsnd1bufr      sndrd1      g15         sndrD1_g15          0.0     1     0
   gsnd1bufr      sndrd2      g15         sndrD2_g15          0.0     1     0
   gsnd1bufr      sndrd3      g15         sndrD3_g15          0.0     1     0
   gsnd1bufr      sndrd4      g15         sndrD4_g15          0.0     1     0
   oscatbufr      uv          null        uv                  0.0     0     0
   mlsbufr        mls30       aura        mls30_aura          0.0     0     0
   avhambufr      avhrr       metop-a     avhrr3_metop-a      0.0     1     0
   avhpmbufr      avhrr       n18         avhrr3_n18          0.0     1     0
   prepbufr       mta_cld     null        mta_cld             1.0     0     0     
   prepbufr       gos_ctp     null        gos_ctp             1.0     0     0     
   lgycldbufr     larccld     null        larccld             1.0     0     0
   lghtnbufr      lghtn       null        lghtn               1.0     0     0
::
 &SUPEROB_RADAR
   del_azimuth=5.,del_elev=.25,del_range=5000.,del_time=.5,elev_angle_max=5.,minnum=50,range_max=100000.,
   l2superob_only=.false.,
 /
 &LAG_DATA
 /
 &HYBRID_ENSEMBLE
   l_hyb_ens=$HYB_ENS,
   n_ens=$nens,
   uv_hyb_ens=.true.,
   beta_s0=0.25,
   s_ens_h=300,
   s_ens_v=5,
   generate_ens=.false.,
   regional_ensemble_option=1,
   aniso_a_en=.false.,
   nlon_ens=0,
   nlat_ens=0,
   jcap_ens=574,
   l_ens_in_diff_time=.true.,
   jcap_ens_test=0,readin_beta=.false.,
   full_ensemble=.true.,pwgtflg=.true.,
   ensemble_path="",
 /
 &RAPIDREFRESH_CLDSURF
   i_gsdcldanal_type=${i_gsdcldanal_type},
   dfi_radar_latent_heat_time_period=10.0,
   l_use_hydroretrieval_all=.false.,
   metar_impact_radius=10.0,
   metar_impact_radius_lowCloud=4.0,
   l_gsd_terrain_match_surfTobs=.false.,
   l_sfcobserror_ramp_t=.false.,
   l_sfcobserror_ramp_q=.false.,
   l_PBL_pseudo_SurfobsT=.false.,
   l_PBL_pseudo_SurfobsQ=.false.,
   l_PBL_pseudo_SurfobsUV=.false.,
   pblH_ration=0.75,
   pps_press_incr=20.0,
   l_gsd_limit_ocean_q=.false.,
   l_pw_hgt_adjust=.false.,
   l_limit_pw_innov=.false.,
   max_innov_pct=0.1,
   l_cleanSnow_WarmTs=.false.,
   r_cleanSnow_WarmTs_threshold=5.0,
   l_conserve_thetaV=.false.,
   i_conserve_thetaV_iternum=3,
   l_cld_bld=.false.,
   cld_bld_hgt=1200.0,
   build_cloud_frac_p=0.50,
   clear_cloud_frac_p=0.1,
   iclean_hydro_withRef=1,
   iclean_hydro_withRef_allcol=0,
 /
 &CHEM
 /
 &NST
   nst_gsi=0,
 /
 &SINGLEOB_TEST
   maginnov=0.1,magoberr=0.1,oneob_type='t',
   oblat=45.,oblon=270.,obpres=850.,obdattim=${adate},
   obhourset=0.,
 /
EOF


emiscoef_IRwater=$FIXCRTM/Nalli.IRwater.EmisCoeff.bin
emiscoef_IRice=$FIXCRTM/NPOESS.IRice.EmisCoeff.bin
emiscoef_IRland=$FIXCRTM/NPOESS.IRland.EmisCoeff.bin
emiscoef_IRsnow=$FIXCRTM/NPOESS.IRsnow.EmisCoeff.bin
emiscoef_VISice=$FIXCRTM/NPOESS.VISice.EmisCoeff.bin
emiscoef_VISland=$FIXCRTM/NPOESS.VISland.EmisCoeff.bin
emiscoef_VISsnow=$FIXCRTM/NPOESS.VISsnow.EmisCoeff.bin
emiscoef_VISwater=$FIXCRTM/NPOESS.VISwater.EmisCoeff.bin
emiscoef_MWwater=$FIXCRTM/FASTEM6.MWwater.EmisCoeff.bin
aercoef=$FIXCRTM/AerosolCoeff.bin
cldcoef=$FIXCRTM/CloudCoeff.bin

satinfo=$FIXnam/nam_regional_satinfo.txt
scaninfo=$FIXnam/nam_regional_scaninfo.txt

pcpinfo=$FIXnam/nam_global_pcpinfo.txt
ozinfo=$FIXnam/nam_global_ozinfo.txt
errtable=$FIXnam/nam_errtable.r3dv
convinfo=$FIXnam/nam_regional_convinfo.txt
mesonetuselist=$FIXnam/nam_mesonet_uselist.txt
stnuselist=$FIXnam/nam_mesonet_stnuselist.txt
atmsfilter=$FIXnam/atms_beamwidth.txt
locinfo=$FIXnam/nam_hybens_d01_info

qdaylist=$FIXnam/q_day_rejectlist
qnightlist=$FIXnam/q_night_rejectlist
tdaylist=$FIXnam/t_day_rejectlist
tnightlist=$FIXnam/t_night_rejectlist
wbinuselist=$FIXnam/wbinuselist

cpreq $anavinfo ./anavinfo
cpreq $berror   ./berror_stats
cpreq $errtable ./errtable
cpreq $emiscoef_IRwater ./Nalli.IRwater.EmisCoeff.bin
cpreq $emiscoef_IRice ./NPOESS.IRice.EmisCoeff.bin
cpreq $emiscoef_IRsnow ./NPOESS.IRsnow.EmisCoeff.bin
cpreq $emiscoef_IRland ./NPOESS.IRland.EmisCoeff.bin
cpreq $emiscoef_VISice ./NPOESS.VISice.EmisCoeff.bin
cpreq $emiscoef_VISland ./NPOESS.VISland.EmisCoeff.bin
cpreq $emiscoef_VISsnow ./NPOESS.VISsnow.EmisCoeff.bin
cpreq $emiscoef_VISwater ./NPOESS.VISwater.EmisCoeff.bin
cpreq $emiscoef_MWwater ./FASTEM6.MWwater.EmisCoeff.bin
cpreq $aercoef  ./AerosolCoeff.bin
cpreq $cldcoef  ./CloudCoeff.bin
cpreq $satinfo  ./satinfo
cpreq $scaninfo ./scaninfo
cpreq $pcpinfo  ./pcpinfo
cpreq $ozinfo   ./ozinfo
cpreq $convinfo ./convinfo
cpreq $atmsfilter ./atms_beamwidth.txt

cp $mesonetuselist ./mesonetuselist
cp $stnuselist ./mesonet_stnuselist
cp $qdaylist ./q_day_rejectlist
cp $qnightlist ./q_night_rejectlist
cp $tdaylist ./t_day_rejectlist
cp $tnightlist ./t_night_rejectlist
cp $wbinuselist ./wbinuselist
cp $locinfo        ./hybens_info

# Copy CRTM coefficient files based on entries in satinfo file
# CRTM Spectral and Transmittance coefficients
set +x
for file in `awk '{if($1!~"!"){print $1}}' ./satinfo | sort | uniq` ;do
   cpreq $FIXCRTM/${file}.SpcCoeff.bin ./
   cpreq $FIXCRTM/${file}.TauCoeff.bin ./
done
set -x

#Grab the reject lists from RTMA
MP=$COMINrtma/rtma2p5.${aday}

cp $MP/rtma2p5.t${cya}z.w_rejectlist ./w_rejectlist
cp $MP/rtma2p5.t${cya}z.t_rejectlist ./t_rejectlist
cp $MP/rtma2p5.t${cya}z.p_rejectlist ./p_rejectlist
cp $MP/rtma2p5.t${cya}z.q_rejectlist ./q_rejectlist

ls -1 w_rejectlist t_rejectlist p_rejectlist q_rejectlist
err5=$?

if [ $err5 -ne 0 ] ; then
  cp ${gespath}/${RUN}.hold/*_rejectlist .
fi

cp w_rejectlist $COMIN/nam.t${cyc}z.rtma2p5.t${cya}z.w_rejectlist.${tmmark}
cp t_rejectlist $COMIN/nam.t${cyc}z.rtma2p5.t${cya}z.t_rejectlist.${tmmark}
cp p_rejectlist $COMIN/nam.t${cyc}z.rtma2p5.t${cya}z.p_rejectlist.${tmmark}
cp q_rejectlist $COMIN/nam.t${cyc}z.rtma2p5.t${cya}z.q_rejectlist.${tmmark}

# Get prepbufr file, satellite radiances, and other data

# NOTE: All ob-type COM environment variables (COM_PREPBUFR, COM_IASI, etc) are set in the 
# JNAM_ENVARS script; they will default to COM_IN=${COMROOT}/${NET}/${envir}
# If the COM_IN data is not available the script will get ops NAM data at tm00
# and RAP data at tm06->tm01  

RUNobs=${RUN}

# Get prepbufr file, satellite radiances, and other data

# Start with the dump files
ofiles=( mtiasi 1bhrs3 1bhrs4 1bamua 1bamub 1bmhs gpsro goesfv airsev \
         radwnd nexrad esamua lgycld lghtng satwnd atms cris sevcsr ssmisu )
# -- Loop over dump files
for ofile in ${ofiles[@]}; do
  case $ofile in
    mtiasi)export OBSINPUT=${COM_IASI}/${RUNobs}.${PDY}
           export obsbufr_name=iasibufr ;;
    1bhrs3)export OBSINPUT=${COM_HIRS3}/${RUNobs}.${PDY}
           export obsbufr_name=hirs3bufr ;;
    1bhrs4)export OBSINPUT=${COM_HIRS4}/${RUNobs}.${PDY}
           export obsbufr_name=hirs4bufr ;;
    1bamua)export OBSINPUT=${COM_AMSUA}/${RUNobs}.${PDY}
           export obsbufr_name=amsuabufr ;;
    1bamub)export OBSINPUT=${COM_AMSUB}/${RUNobs}.${PDY}
           export obsbufr_name=amsubbufr ;;
    1bmhs) export OBSINPUT=${COM_MHS}/${RUNobs}.${PDY}
           export obsbufr_name=mhsbufr ;;
    gpsro) export OBSINPUT=${COM_GPSRO}/${RUNobs}.${PDY}
           export obsbufr_name=gpsrobufr ;;
    goesfv)export OBSINPUT=${COM_GOESFV}/${RUNobs}.${PDY}
           export obsbufr_name=gsnd1bufr ;;
    airsev)export OBSINPUT=${COM_AIRS}/${RUNobs}.${PDY}
           export obsbufr_name=airsbufr ;;
    radwnd)export OBSINPUT=${COM_RADWND}/${RUNobs}.${PDY}
           export obsbufr_name=radarbufr ;;
    nexrad)export OBSINPUT=${COM_NEXRAD}/${RUNobs}.${PDY}
           export obsbufr_name=l2rwbufr ;;
    esamua)export OBSINPUT=${COM_ESAMUA}/${RUNobs}.${PDY}
           export obsbufr_name=amsuabufrears ;;
    lgycld)export OBSINPUT=${COM_LGYCLD}/${RUNobs}.${PDY}
           export obsbufr_name=lgycldbufr ;;
    lghtng)export OBSINPUT=${COM_LGHTNG}/${RUNobs}.${PDY}
           export obsbufr_name=lghtnbufr ;;
    satwnd)export OBSINPUT=${COM_SATWND}/${RUNobs}.${PDY}
           export obsbufr_name=satwndbufr ;;
    atms)  export OBSINPUT=${COM_ATMS}/${RUNobs}.${PDY}
           export obsbufr_name=atmsbufr ;;
    cris)  export OBSINPUT=${COM_CRIS}/${RUNobs}.${PDY}
           export obsbufr_name=crisbufr ;;
    sevcsr)export OBSINPUT=${COM_SEVIRI}/${RUNobs}.${PDY}
           export obsbufr_name=seviribufr ;;
    ssmisu)export OBSINPUT=${COM_SSMIS}/${RUNobs}.${PDY}
           export obsbufr_name=ssmisbufr ;;
  esac

  #---- Try NAM dumps, if not there then try RAP

   if [ $tmmark = tm00 ] ; then
    python $UTIL_USHnam/copybest_file.py --fname1=${OBSINPUT}/nam.t${cyc}z.${ofile}.${tmmark}.bufr_d \
                                     --fname2=${COMNAM}/nam.${aday}/nam.t${cya}z.${ofile}.tm00.bufr_d \
                                     --jlogfile=${jlogfile} -o $DATA/${obsbufr_name}
   else
    python $UTIL_USHnam/copybest_file.py --fname1=${OBSINPUT}/nam.t${cyc}z.${ofile}.${tmmark}.bufr_d \
                                     --fname2=${COMINrap}/rap.${aday}/rap.t${cya}z.${ofile}.tm00.bufr_d \
                                     --jlogfile=${jlogfile} -o $DATA/${obsbufr_name}
   fi
done

# Now handle the prepbufr

  if [ $tmmark = tm00 ] ; then
    python $UTIL_USHnam/copybest_file.py --fname1=${COM_PREPBUFR}/${RUNobs}.${PDY}/nam.t${cyc}z.prepbufr.${tmmark} \
                                     --fname2=${COMNAM}/nam.${aday}/nam.t${cya}z.prepbufr.tm00 \
                                     --jlogfile=${jlogfile} -o $DATA/prepbufr
  else
    python $UTIL_USHnam/copybest_file.py --fname1=${COM_PREPBUFR}/${RUNobs}.${PDY}/nam.t${cyc}z.prepbufr.${tmmark} \
                                     --fname2=${COMINrap}/rap.${aday}/rap.t${cya}z.prepbufr.tm00 \
                                     --jlogfile=${jlogfile} -o $DATA/prepbufr
  fi

if [ ! -s $DATA/prepbufr ]; then
  msg="WARNING: - RUNNING WITHOUT PREPBUFR DATA - "
  postmsg "$msg"
fi

chmod 640 $DATA/prepbufr
chgrp rstprod $DATA/prepbufr

TM06=`${NDATE} -06 $CYCLE`
TM05=`${NDATE} -05 $CYCLE`
TM04=`${NDATE} -04 $CYCLE`
TM03=`${NDATE} -03 $CYCLE`
TM02=`${NDATE} -02 $CYCLE`
TM01=`${NDATE} -01 $CYCLE`

yyyymmdd=`echo $CYCLE | cut -c 1-8`
hh=`echo $CYCLE | cut -c 9-10`

yyyymmddm06=`echo $TM06 | cut -c 1-8`
yyyymmddm05=`echo $TM05 | cut -c 1-8`
yyyymmddm04=`echo $TM04 | cut -c 1-8`
yyyymmddm03=`echo $TM03 | cut -c 1-8`
yyyymmddm02=`echo $TM02 | cut -c 1-8`
yyyymmddm01=`echo $TM01 | cut -c 1-8`
hhm06=`echo $TM06 | cut -c 9-10`
hhm05=`echo $TM05 | cut -c 9-10`
hhm04=`echo $TM04 | cut -c 9-10`
hhm03=`echo $TM03 | cut -c 9-10`
hhm02=`echo $TM02 | cut -c 9-10`
hhm01=`echo $TM01 | cut -c 9-10`

# tmmark=tm06 is valid ONLY for the catchup cycle !

# For nest we use the parent's bias corrections.  We also don't need to update the
# predictors and so should switch that off (do not have to)

if [ $RUNTYPE = CATCHUP ] 
then

case $cyc in
 00) bias1=${COM_IN}/${RUN}.${yyyymmddm06}/nam.t18z.satbias.tm01
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 06) bias1=${COM_IN}/${RUN}.${yyyymmddm06}/nam.t00z.satbias.tm01
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 12) bias1=${COM_IN}/${RUN}.${yyyymmddm06}/nam.t06z.satbias.tm01
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 18) bias1=${COM_IN}/${RUN}.${yyyymmddm06}/nam.t12z.satbias.tm01
     bias2=${gespath}/${RUN}.hold/satbias_in;;
esac

if [ $tmmark = tm06 ]
then
  if [ -s $bias1 ]
  then
    cp $bias1 $DATA/satbias_in
  else
    if [ -s $bias2 ]
    then
      cp $bias2 $DATA/satbias_in
      echo "WARNING : No $bias1 AVAIALBLE FOR CYCLE $CYCLE!  USING VERSION FROM NAM HOLD!" 
    else
      echo "WARNING : NO SATBIAS AVAIALBLE FOR CYCLE $CYCLE!"
    fi
  fi
fi

if [ $tmmark = tm05 -o $tmmark = tm04 -o $tmmark = tm03 -o $tmmark = tm02 -o $tmmark = tm01 ] ; then
  cp $COMIN/nam.t${cyc}z.satbias.${tmmark_prev} $DATA/satbias_in
fi

if [ $tmmark = tm00 ] ; then
  if [ $GUESStm00 = NAM ] ; then
    cp $COMIN/nam.t${cyc}z.satbias.${tmmark_prev} $DATA/satbias_in
  else
    cp ${gespath}/${RUN}.hold/satbias_in $DATA/satbias_in
  fi
fi

case $cyc in
 00) pc1=${COM_IN}/${RUN}.${yyyymmddm06}/nam.t18z.satbias_pc.tm01
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 06) pc1=${COM_IN}/${RUN}.${yyyymmddm06}/nam.t00z.satbias_pc.tm01
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 12) pc1=${COM_IN}/${RUN}.${yyyymmddm06}/nam.t06z.satbias_pc.tm01
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 18) pc1=${COM_IN}/${RUN}.${yyyymmddm06}/nam.t12z.satbias_pc.tm01
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
esac

if [ $tmmark = tm06 ]
then
  if [ -s $pc1 ]
  then
    cp $pc1 $DATA/satbias_pc
  else
    if [ -s $pc2 ]
    then
      echo "WARNING : No $pc1 AVAIALBLE FOR CYCLE $CYCLE!  USING VERSION FROM NAM HOLD!" 
      cp $pc2 $DATA/satbias_pc
    else
      echo "WARNING : NO SATBIAS_PC FILE AVAIALBLE FOR CYCLE $CYCLE!"
    fi
  fi
fi

if [ $tmmark = tm05 -o $tmmark = tm04 -o $tmmark = tm03 -o $tmmark = tm02 -o $tmmark = tm01 ] ; then
  cp $COMIN/nam.t${cyc}z.satbias_pc.${tmmark_prev} $DATA/satbias_pc
fi

if [ $tmmark = tm00 ] ; then
  if [ $GUESStm00 = NAM ] ; then
    cp $COMIN/nam.t${cyc}z.satbias_pc.${tmmark_prev} $DATA/satbias_pc
  else
    cp ${gespath}/${RUN}.hold/satbias_pc $DATA/satbias_pc
  fi
fi

case $cyc in
 00) rad1=${COM_IN}/${RUN}.${yyyymmddm06}/nam.t18z.radstat.tm01
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 06) rad1=${COM_IN}/${RUN}.${yyyymmddm06}/nam.t00z.radstat.tm01
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 12) rad1=${COM_IN}/${RUN}.${yyyymmddm06}/nam.t06z.radstat.tm01
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 18) rad1=${COM_IN}/${RUN}.${yyyymmddm06}/nam.t12z.radstat.tm01
     rad2=${gespath}/${RUN}.hold/radstat.nam;;

esac

if [ $tmmark = tm06 ]
then
  if [ -s $rad1 ]
  then
    cp $rad1 $DATA/radstat.nam
  else
    if [ -s $rad2 ]
    then
      cp $rad2 $DATA/radstat.nam
      echo "WARNING : No $rad1 AVAIALBLE FOR CYCLE $CYCLE!  USING VERSION FROM NAM HOLD!" 
    else
      echo "WARNING NO RADSTAT FILE AVAILABLE FOR CYCLE $CYCLE!"  
    fi
  fi
fi

if [ $tmmark = tm05 -o $tmmark = tm04 -o $tmmark = tm03 -o $tmmark = tm02 -o $tmmark = tm01 ] ; then
  cp $COMIN/nam.t${cyc}z.radstat.${tmmark_prev} $DATA/radstat.nam
fi

if [ $tmmark = tm00 ] ; then
  if [ $GUESStm00 = NAM ] ; then
    cp $COMIN/nam.t${cyc}z.radstat.${tmmark_prev} $DATA/radstat.nam
  else
    cp ${gespath}/${RUN}.hold/radstat.nam $DATA/radstat.nam
  fi
fi

listdiag=`tar xvf radstat.nam | cut -d' ' -f2 | grep _anl`
rm -f diag*_ges.*.gz
for type in $listdiag; do
   diag_file=`echo $type | cut -d',' -f1`
   fname=`echo $diag_file | cut -d'.' -f1`
   date=`echo $diag_file | cut -d'.' -f2`
   gunzip $diag_file
   fnameanl=$(echo $fname|sed 's/_anl//g')
   mv $fname.$date $fnameanl
done



else

# this is for RUNTYPE=HOURLY

case $cyc in
 00) bias1=${COM_IN}/${RUN}.${yyyymmddm01}/nam.t23z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 01) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t00z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 02) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t01z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 03) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t02z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 04) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t03z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 05) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t04z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 06) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t05z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 07) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t06z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 08) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t07z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 09) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t08z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 10) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t09z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 11) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t10z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 12) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t11z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 13) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t12z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 14) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t13z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 15) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t14z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 16) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t15z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 17) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t16z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 18) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t17z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 19) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t18z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 20) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t19z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 21) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t20z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 22) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t21z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
 23) bias1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t22z.satbias.tm00
     bias2=${gespath}/${RUN}.hold/satbias_in;;
esac

if [ -s $bias1 ]
then
  cp $bias1 $DATA/satbias_in
else
  if [ -s $bias2 ]
  then
    cp $bias2 $DATA/satbias_in
    echo "WARNING : No $bias1 AVAIALBLE FOR CYCLE $CYCLE!  USING VERSION FROM NAM HOLD!" 
  else
    echo "WARNING : NO SATBIAS AVAIALBLE FOR CYCLE $CYCLE!"
  fi
fi

case $cyc in
 00) pc1=${COM_IN}/${RUN}.${yyyymmddm01}/nam.t23z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 01) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t00z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 02) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t01z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 03) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t02z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 04) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t03z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 05) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t04z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 06) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t05z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 07) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t06z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 08) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t07z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 09) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t08z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 10) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t09z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 11) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t10z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 12) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t11z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 13) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t12z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 14) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t13z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 15) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t14z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 16) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t15z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 17) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t16z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 18) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t17z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 19) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t18z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 20) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t19z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 21) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t20z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 22) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t21z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
 23) pc1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t22z.satbias_pc.tm00
     pc2=${gespath}/${RUN}.hold/satbias_pc;;
esac

if [ -s $pc1 ]
then
  cp $pc1 $DATA/satbias_pc
else
  if [ -s $pc2 ]
  then
    cp $pc2 $DATA/satbias_pc
    echo "WARNING : No $pc1 AVAIALBLE FOR CYCLE $CYCLE!  USING VERSION FROM NAM HOLD!" 
  else
    echo "WARNING : NO SATBIAS_PC FILE AVAIALBLE FOR CYCLE $CYCLE!"
  fi
fi



case $cyc in
 
 00) rad1=${COM_IN}/${RUN}.${yyyymmddm01}/nam.t23z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 01) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t00z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 02) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t01z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 03) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t02z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 04) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t03z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 05) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t04z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 06) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t05z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 07) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t06z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 08) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t07z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 09) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t08z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 10) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t09z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 11) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t10z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 12) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t11z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 13) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t12z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 14) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t13z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 15) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t14z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 16) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t15z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 17) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t16z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 18) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t17z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 19) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t18z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 20) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t19z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 21) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t20z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 22) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t21z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;
 23) rad1=${COM_IN}/${RUN}.${yyyymmdd}/nam.t22z.radstat.tm00
     rad2=${gespath}/${RUN}.hold/radstat.nam;;

esac

  if [ -s $rad1 ]
  then
    cp $rad1 $DATA/radstat.nam
  else
    if [ -s $rad2 ]
    then
      cp $rad2 $DATA/radstat.nam
      echo "WARNING : No $rad1 AVAIALBLE FOR CYCLE $CYCLE!  USING VERSION FROM NAM HOLD!" 
    else
      echo "WARNING NO RADSTAT FILES AVAILABLE FOR CYCLE $CYCLE!"  
    fi
  fi

listdiag=`tar xvf radstat.nam | cut -d' ' -f2 | grep _anl`
rm -f diag*_ges.*.gz
for type in $listdiag; do
   diag_file=`echo $type | cut -d',' -f1`
   fname=`echo $diag_file | cut -d'.' -f1`
   date=`echo $diag_file | cut -d'.' -f2`
   gunzip $diag_file
   fnameanl=$(echo $fname|sed 's/_anl//g')
   mv $fname.$date $fnameanl
done

#end check on RUNTYPE
fi

# E.Rogers 2/07 : Change links to copies below since
# the tm09 wrfrst first guess file is also used to start the 
# next NDAS cycle. If this is not done, the tm09 wrfrst file in
# /nwges/prod is changed to the tm06 analysis since the GSI uses
# the same name (wrf_inout) for the input and output file.
#
# Changed links to copies for all tm* analysis times so that PMB can
# rerun this job using the correct first guess

# IN NAM tmmark=tm06 is ALWAYS from a GDAS coldstart

if [ $tmmark = "tm06" ]
then
  cpreq $GESDIR/nam.t${cyc}z.input_domain_${domain}nest_nemsio.tm06 ./wrf_inout${nhr_assimilation}
fi

if [ $RUNTYPE = CATCHUP -a $tmmark != "tm06" ] 
then
  if [ $tmmark = tm00 ] ; then
    if [ $GUESStm00 = NAM ] ; then
      if [ $domain = conus -o $domain = alaska ] ; then
         cpreq $GESDIR/nam.t${cyc}z.nmm_b_restart_${domain}nest_nemsio.${tmmark_prev} ./wrf_inout${nhr_assimilation}
      else
         cpreq $GESDIR/nam.t${cyc}z.input_domain_${domain}nest_nemsio ./wrf_inout${nhr_assimilation}
      fi
    fi
    if [ $GUESStm00 = GDAS ] ; then
      cpreq $GESDIR/nam.t${cyc}z.input_domain_${domain}nest_nemsio.tm00 ./wrf_inout${nhr_assimilation}
    fi 
  else
    if [ $domain = conus -o $domain = alaska ] ; then
       cpreq $GESDIR/nam.t${cyc}z.nmm_b_restart_${domain}nest_nemsio.${tmmark_prev} ./wrf_inout${nhr_assimilation}
    else
       cpreq $GESDIR/nam.t${cyc}z.input_domain_${domain}nest_nemsio ./wrf_inout${nhr_assimilation}
    fi
  fi
fi

# At tmmark=tm00, the first guess is either the last forecast of the catchup cycle or
# the 1-h old forecast from the previous cycle

#For HOURLY tmmark is always tm00

if [ $RUNTYPE = HOURLY -a $tmmark = "tm00" ]
then
  cpreq $GESDIR/nam.t${cyc}z.nmm_b_restart_${domain}nest_nemsio.ges ./wrf_inout${nhr_assimilation}
fi

sync

if [ $i_gsdcldanal_type -eq 2 ] ; then
  echo "RUNNING CLOUD ANALYSIS PREP `date`"
  rm -f anavinfo
  cpreq $FIXnam/anavinfo_nems_nmmb_cld  ./anavinfo 
  outfile=ref3d
  $WGRIB2 -s $mydbzinfile | grep ":REFD:" | $WGRIB2 -i $mydbzinfile -text $outfile
  export pgm=nam_cloud_analysis_prep
  . prep_step
  startmsg
  $EXECnam/nam_ref2nemsio wrf_inout${nhr_assimilation} > ref_log >> $pgmout
  export err=$?;err_chk
  echo "CLOUD ANALYSIS PREP DONE `date`"
fi

export pgm=nam_nems_nmmb_gsi
. prep_step

startmsg
${MPIEXEC} -n $ntasks -ppn $ppn --cpu-bind core --depth $threads $EXECnam/nam_gsi < gsiparm.anl >> $pgmout 2>errfile
export err=$?;err_chk

mv fort.201 fit_p1
mv fort.202 fit_w1
mv fort.203 fit_t1
mv fort.204 fit_q1
mv fort.205 fit_pw1
mv fort.207 fit_rad1
mv fort.209 fit_rw1

cat fit_p1 fit_w1 fit_t1 fit_q1 fit_pw1 fit_rad1 fit_rw1 > $COMOUT/${RUN}.${cycle}.fits_${domain}nest.${tmmark}
cat fort.208 fort.210 fort.211 fort.212 fort.213 fort.220 > $COMOUT/${RUN}.${cycle}.fits2_${domain}nest.${tmmark}

# Let logs know if GSI ran with the hybrid switched on
if [ $HYB_ENS = ".true." ]; then
  msg="$CYCLE JOB $job USED HYBRID 3DENVAR"
else
  msg="$CYCLE JOB $job USED 3DVAR"
fi
postmsg "$msg"

if [ $GUESS = GDAS -a $tmmark = tm06 ] ; then
   mv wrf_inout${nhr_assimilation} $GESDIR/${RUN}.t${cyc}z.input_domain_${domain}nest_nemsio.anl.${tmmark}
   export err=$?;err_chk
else
   if [ $RUNTYPE = CATCHUP -a $tmmark = tm00 ] ; then
     if [ $GUESStm00 = NAM ] ; then
       mv wrf_inout${nhr_assimilation} $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_${domain}nest_nemsio_anl.${tmmark}
       export err=$?;err_chk
     fi
     # Call input files if coldstarting NAM off GDAS "restart" files so forecast script doesn't have to be
     # modified
     if [ $GUESStm00 = GDAS ] ; then
        mv wrf_inout${nhr_assimilation} $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_${domain}nest_nemsio_anl.${tmmark}
        export err=$?;err_chk
     fi
   else
     mv wrf_inout${nhr_assimilation} $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_${domain}nest_nemsio_anl.${tmmark}
     export err=$?;err_chk
   fi
   if [ $cyc -eq 00 -o $cyc = 06 -o $cyc -eq 12 -o $cyc -eq 18 ] 
   then
     if [ $tmmark = tm00 -a $GUESStm00 = NAM ]; then
       #Save file for its land states in next catchup cycle (tp6)
       cpreq $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_${domain}nest_nemsio_anl.${tmmark} ${gespath}/${RUN}.hold/nmm_b_restart_${domain}nest_nemsio_hold.${cyc}z
     fi
   fi
fi

mv radar_supobs_from_level2 $COMOUT/nam.t${cyc}z.l2suob_${domain}nest.${tmmark}

RADSTAT=${COMOUT}/${RUN}.t${cyc}z.radstat_${domain}nest.${tmmark}
CNVSTAT=${COMOUT}/${RUN}.t${cyc}z.cnvstat_${domain}nest.${tmmark}

# Set up lists and variables for various types of diagnostic files.
ntype=1

diagtype[0]="conv"
diagtype[1]="hirs2_n14 msu_n14 sndr_g08 sndr_g11 sndr_g12 sndr_g13 sndr_g08_prep sndr_g11_prep sndr_g12_prep sndr_g13_prep sndrd1_g11 sndrd2_g11 sndrd3_g11 sndrd4_g11 sndrd1_g12 sndrd2_g12 sndrd3_g12 sndrd4_g12 sndrd1_g13 sndrd2_g13 sndrd3_g13 sndrd4_g13 sndrd1_g14 sndrd2_g14 sndrd3_g14 sndrd4_g14 sndrd1_g15 sndrd2_g15 sndrd3_g15 sndrd4_g15 hirs3_n15 hirs3_n16 hirs3_n17 amsua_n15 amsua_n16 amsua_n17 amsub_n15 amsub_n16 amsub_n17 hsb_aqua airs_aqua amsua_aqua imgr_g08 imgr_g11 imgr_g12 imgr_g14 imgr_g15 ssmi_f13 ssmi_f14 ssmi_f15 hirs4_n18 hirs4_metop-a amsua_n18 amsua_metop-a mhs_n18 mhs_metop-a amsre_low_aqua amsre_mid_aqua amsre_hig_aqua ssmis_las_f16 ssmis_uas_f16 ssmis_img_f16 ssmis_env_f16 ssmis_las_f17 ssmis_uas_f17 ssmis_img_f17 ssmis_env_f17 ssmis_las_f18 ssmis_uas_f18 ssmis_img_f18 ssmis_env_f18 ssmis_las_f19 ssmis_uas_f19 ssmis_img_f19 ssmis_env_f19 ssmis_las_f20 ssmis_uas_f20 ssmis_img_f20 ssmis_env_f20 iasi_metop-a hirs4_n19 amsua_n19 mhs_n19 seviri_m08 seviri_m09 seviri_m10 cris_npp atms_npp hirs4_metop-b amsua_metop-b mhs_metop-b iasi_metop-b gome_metop-b"

diaglist[0]=listcnv
diaglist[1]=listrad

diagfile[0]=$CNVSTAT
diagfile[1]=$RADSTAT

numfile[0]=0
numfile[1]=0


# Set diagnostic file prefix based on lrun_subdirs variable
   prefix="pe*"

# Compress and tar diagnostic files.

loops="01 03"
for loop in $loops; do
   case $loop in
     01) string=ges;;
     03) string=anl;;
      *) string=$loop;;
   esac
   n=-1
   while [ $((n+=1)) -le $ntype ] ;do
      for type in `echo ${diagtype[n]}`; do
         count=`ls ${prefix}${type}_${loop}* | wc -l`
         if [ $count -gt 0 ]; then
            cat ${prefix}${type}_${loop}* > diag_${type}_${string}.${SDATE}
            echo "diag_${type}_${string}.${SDATE}*" >> ${diaglist[n]}
            numfile[n]=`expr ${numfile[n]} + 1`
         fi
      done
   done
done


#  compress diagnostic files
   for file in `ls diag_*${SDATE}`; do
      gzip $file
   done

# If requested, create diagnostic file tarballs
   n=-1
   while [ $((n+=1)) -le $ntype ] ;do
      TAROPTS="-uvf"
      if [ ! -s ${diagfile[n]} ]; then
         TAROPTS="-cvf"
      fi
      if [ ${numfile[n]} -gt 0 ]; then
         tar $TAROPTS ${diagfile[n]} `cat ${diaglist[n]}`
      fi
   done

#  Restrict CNVSTAT
   chmod 750 $CNVSTAT
   chgrp rstprod $CNVSTAT

echo EXITING $0 with return code $err
exit $err
