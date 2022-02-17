#!/bin/ksh
######################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_fcst_parentext.sh.ecf
# Script description:  Run NAM forecast
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract: This script runs the Nam forecast
#
# Script history log:
# 1999-06-23  Eric Rogers
# 1999-08-02  Brent Gordon  - Modified for production.
# 2006-01-13  Eric Rogers   - Modified for WRF-NMM
# 2009-12-07  Eric Rogers   - Modifications for NAM
# 2013-01-03  Jacob Carley  - Run 60-84h NAM parent domain only
# 2019-05-01  Eric Rogers   - Mods to run on Dell
# 2021-11-17  Eric Rogers   - WCOSS2 changes
#

set -xa

msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA

export domain=${domain:-parentonly}
export NODE_CONFIGFILE=${NODE_CONFIGFILE:-$PARMnam/nam_node_decomposition_opsconfig.tm00_wcoss2_63tasks_node}

export tmmark=tm00

export CDATE=$PDY$cyc
#
# Get needed variables from exndas_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh
USEREF=false
tmval=`echo $tmmark | cut -c3-4`

export SDATE=$CYCLE

### modify namelist file

lasthour=`ls -1rt restartdone.01.????h_* | tail -1 | cut -c 18-19`

START=${FMAX_CATCHUP_NEST}
LENGTH=${FMAX_CATCHUP_PARENT}

rhour=$LENGTH
resint=360
rday=0

ystart=`echo $SDATE | cut -c1-4`
mstart=`echo $SDATE | cut -c5-6`
dstart=`echo $SDATE | cut -c7-8`
hstart=`echo $SDATE | cut -c9-10`

ystartm1=`expr $ystart - 1`

end=$(${NDATE} +$LENGTH $SDATE)

yend=`echo $end | cut -c1-4`
mend=`echo $end | cut -c5-6`
dend=`echo $end | cut -c7-8`
hend=`echo $end | cut -c9-10`


pflag=false
freerun=true

#Turn off digital filter when restarting
filteropt=0

#Turn off radar initialization when restarting
radar_init=0

filtvar=nam_filt_vars_norad.txt

# DO write out last restart file and nemsio files!
export wrtlast=false
#DO NOT write out first restart file
export rstout=false
export restval=true

if [ $cyc -eq 00 -o $cyc -eq 12 ]; then
  #12hr pcp buckets and 6hr buckets for all other fields
  pcpbucket=12
  heatbucket=6
  cloudbucket=6
  lwbucket=6
  swbucket=6
  evapbucket=6
else
  #3hr buckets for all
  pcpbucket=3
  heatbucket=3
  cloudbucket=3
  lwbucket=3
  swbucket=3
  evapbucket=3
fi

NLNAME=nam_configfile
# Run config file to import node decomposition (already set to parent only at top of script)
set -a; . $NODE_CONFIGFILE; set +a

numdom=1
numchild=0

cat $PARMnam/$NLNAME | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
 | sed s:INPES:$inpes: | sed s:JNPES:$jnpes: | sed s:WRITE_GROUPS:$write_groups: | sed s:WRITE_TASKS:$write_tasks: \
 | sed s:DSTART:$dstart: | sed s:HSTART:$hstart: | sed s:YEND:$yend: \
 | sed s:MEND:$mend:     | sed s:DEND:$dend: | sed s:HEND:$hend:  \
 | sed s:RH:$rhour:      | sed s:RD:$rday: | sed s:LENGTH:$LENGTH: \
 | sed s:RESINT:$resint: | sed s:REST:$restval: | sed s:FREE:$freerun: | sed s:OUTRST:$rstout: \
 | sed s:WRTLAST:$wrtlast: | sed s:PFLAG:$pflag:   | sed s:FILTEROPTION:$filteropt: | sed s:USE_RADAR:$radar_init: \
 | sed s:NUMDOM:$numdom: | sed s:NCHILD:$numchild: \
 | sed s:PRECIPBUCKET:$pcpbucket: | sed s:HEATBUCKET:$heatbucket: | sed s:CLOUDBUCKET:$cloudbucket: \
 | sed s:LWBUCKET:$lwbucket: | sed s:SWBUCKET:$swbucket: | sed s:EVAPBUCKET:$evapbucket: > configure_file

cp configure_file $COMOUT/${RUN}.t${cyc}z.configure_file_parentonly.${tmmark}
cpreq configure_file configure_file_01
cpreq configure_file model_configure

#do a little house keeping
rm configure_file_02 configure_file_03 configure_file_04 configure_file_05 configure_file_06

rm fort.*

#re-link bc's if needed
hour=00
while [ $hour -le ${FMAX_CATCHUP_PARENT_BOCO} ] ; do
  if [ -s $COMIN/${RUN}.t${cyc}z.boco.01.0${hour}.${tmmark} ]
  then
    ln -s -f $COMIN/${RUN}.t${cyc}z.boco.01.0${hour}.${tmmark} boco.00${hour}
  else
    msg="Boundary file not found, abort run."
    err_exit $msg
  fi
  let "hour=hour+3"
  typeset -Z2 hour
done

### Since model can only be restarted if modolo(fhr,3)=0, compare last fcstdone file to last
### restartdone file. If they are not at the same forecast hour, delete all fcstdone files with fhr > then
### the last restartdone file so that the restarted post and postsnd jobs are in synch with the restarted
### model run

fcstlasthr=`ls -1 fcstdone.01.00* | tail -1 | cut -c 15-16`
restartlasthr=`ls -1 restartdone.01.00* | tail -1 | cut -c 18-19`

if [ $fcstlasthr -gt $lasthour ]
then
   rm fcstdone.??.00${fcstlasthr}h_*
   rm restartdone.??.00${fcstlasthr}h_*
   let "fhrm1=fcstlasthr-1"
   typeset -Z3 fhrm1
   while [ $fhrm1 -gt $lasthour ]
   do
     rm fcstdone.??.00${fhrm1}h_*
     rm restartdone.??.00${fhrm1}h_*
     let "fhrm1=fhrm1-1"
   done
fi

mv nmmb_rst_01_nio_00${lasthour}h_00m_00.00s restart_file_01_nemsio

ln -s -f $FIXnam/nam_GWD.bin GWD_bin_01

cpreq $FIXnam/nam_micro_lookup.dat ETAMPNEW_DATA.expanded_rain
cpreq $FIXnam/nam_GENPARM.TBL GENPARM.TBL
cpreq $FIXnam/nam_LANDUSE.TBL LANDUSE.TBL
cpreq $FIXnam/nam_SOILPARM.TBL SOILPARM.TBL
cpreq $FIXnam/nam_VEGPARM.TBL VEGPARM.TBL

cpreq $PARMnam/nam_atmos.configure_nmm atmos.configure
cpreq $PARMnam/nam_ocean.configure ocean.configure
cpreq $PARMnam/nam_solver_state.txt solver_state.txt
cpreq $PARMnam/${filtvar} filt_vars.txt
cpreq $PARMnam/nam_nests.txt nests.txt

cpreq $PARMnam/nam_climaeropac_global.txt aerosol.dat

cpreq $FIXnam/nam_co2historicaldata_${ystart}.txt co2historicaldata_${ystart}.txt
cpreq $FIXnam/nam_co2historicaldata_${ystartm1}.txt co2historicaldata_${ystartm1}.txt

ln -sf $FIXnam/nam_global_o3prdlos.f77 fort.28
ln -sf $FIXnam/nam_global_o3clim.txt fort.48

export LANG=en_US

export pgm=nam_nems_nmmb_fcst
. prep_step

startmsg
${MPIEXEC} --line-buffer --label -n ${ntasks} -ppn ${ppn} --cpu-bind core --depth ${threads} $EXECnam/nam_nems_nmmb_fcst >>$pgmout 2>errfile
export err=$?

date
echo EXITING $0

exit $err

