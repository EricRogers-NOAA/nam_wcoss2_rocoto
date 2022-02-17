#!/bin/ksh
######################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         exnam_fcst.sh.ecf
# Script description:  Run NAM forecast
#
# Author:        Eric Rogers       Org: NP22         Date: 1999-06-23
#
# Abstract: This script runs the NAM forecast
#
# Script history log:
# 1999-06-23  Eric Rogers
# 1999-08-02  Brent Gordon  - Modified for production.
# 2006-01-13  Eric Rogers   - Modified for WRF-NMM
# 2009-12-07  Eric Rogers   - Modifications for NAM
# 2015-??-??  Carley/Rogers - General forecast script for NAMv4
# 2019-05-01  Eric Rogers   - Mods to run on Dell
# 2021-10-05  Eric Rogers   - Mods to run on WCOSS2
# 2021-11-17  Eric Rogers   - WCOSS2 changes
#

set -xa

msg="JOB $job HAS BEGUN"
postmsg "$msg"

cd $DATA

export run_firewx=${run_firewx:-NO}
if [ $tmmark = tm00 ] ; then
  export NODE_CONFIGFILE=${NODE_CONFIGFILE:-$PARMnam/nam_node_decomposition_opsconfig.tm00_wcoss2_38nodes}
# export NODE_CONFIGFILE=${NODE_CONFIGFILE:-$PARMnam/nam_node_decomposition_opsconfig.tm00_wcoss2_63tasks_node}
else
  export NODE_CONFIGFILE=${NODE_CONFIGFILE:-$PARMnam/nam_node_decomposition_opsconfig.tm06-01_wcoss2}
fi

export CDATE=$PDY$cyc
#
# Get needed variables from exndas_prelim.sh.sms
#
. $GESDIR/${RUN}.t${cyc}z.envir.sh

# Always start from 00-h for non-tm00 forecasts

if [ $tmmark != tm00 ] ; then
RESTARTNZF=NO
fi

# Simple check to see if there are any fcstdone files; if not, assume
# we are starting from initial conditions

if [ $tmmark = tm00 ] ; then

  pwd
  testhour=`ls -1rt fcstdone.??.????h_* | tail -1 | cut -c 15-16`

  if [ -z "$testhour" -o $RERUN = "YES" ]; then
    echo "NAM forecast starting from initial conditions"
  else

    # Need to check of the existence of ALL restart files (parent and nests) to
    # determine if we are restarting from a non-zero forecast hour

    if [ $RUNTYPE = CATCHUP ] ; then
      reg="1 2 3 4 5 6"
      num="01 02 03 04 05 06"
    else
      reg="1 2 3"
      num="01 02 03"
    fi

    for domain in $reg; do
      lasthour=`ls -1rt restartdone.0${domain}.????h_* | tail -1 | cut -c 18-19`
      let lasthour_0$domain=$lasthour
      typeset -Z2 lasthour_0$domain
    done

    if [ $RUNTYPE = CATCHUP ] ; then
      lasthour=`(echo "$lasthour_01" ; echo "$lasthour_02" ; echo "$lasthour_03" ; echo "$lasthour_04" ; echo "$lasthour_05" ; echo "$lasthour_06") | sort -nr | tail -n1`
    else
      lasthour=`(echo "$lasthour_01" ; echo "$lasthour_02" ; echo "$lasthour_03") | sort -nr | tail -n1`
    fi

    # If there are no restart files but there are fcstdone files delete all fcstdone and nmmb_hst files
    # For NAM restart files are hourly through 18-h, 6-hourly thereafter

    if [ -z "$lasthour" -a $testhour -le 1 ]; then
      rm fcstdone* nmmb_hst*
      echo "restart NAM forecast from initial conditions"
    else
      echo "restart NAM forecast from hour $lasthour"

      # Set lasthour for each domain to be the value of lasthour found in the above test

      for numnest in $num; do
        export lasthour_${numnest}=$lasthour
      done

    fi
  fi

# If no parent restartdone file, assume we are starting forecast from initial conditions

  if [ -z "$lasthour" -o "$RERUN" = "YES" ] ; then

    ### This is the "restart from non-zero forecast hour" switch which should always be set to NO here
    RESTARTNZF=NO
    rstout=true

  else

  ### If we end up here, the "restart from non-zero forecast hour" switch which should always be set to yes
  ### For NEMS, no need to change start/end date in config file, only make sure RESTART=TRUE and
  ### move last restart file to default name expected by code (restart_file_DOMAINNUMBER_nemsio)

  RESTARTNZF=YES
  rstout=false

  ### FOR PARENT + NESTED RUNS: we already checked to ensure that ALL restart files for forecast hour XX
  ### were written out. If not, we set lasthour back by 3-h for all domains.

  if [ $RUNTYPE = CATCHUP ] ; then
    num="01 02 03 04 05 06"
  else
    num="01 02 03"
  fi

  for numdomain in $num; do
    mv nmmb_rst_${numdomain}_nio_00${lasthour}h_00m_00.00s restart_file_${numdomain}_nemsio
  done

  #end test on non-zero fcst hour
  fi

#end tm00 check
fi

#
# Run script to compute precipitation budget for bias correction
# (12z cycle)

#Only do the budget update for the parent for now
if [ $RUNTYPE = CATCHUP ]; then
  if [ $cyc -eq 12 ] ; then
    if [ $tmmark = tm06 ] ; then
       ${USHnam}/nam_h2obudget.sh
    fi
  fi
fi

#
# Run script to get hourly NCEP Stage2/4 precipitation interpolated
# to the Nam model grid.  (CATCHUP ONLY)

#Also remap the files to the nest domain
if [ $RUNTYPE = CATCHUP ]; then
  if [ $tmmark != tm00 ]; then
    ${USHnam}/nam_getpcp.sh
    ${USHnam}/nam_getpcp_nest.sh
  fi
fi

tmval=`echo $tmmark | cut -c3-4`

export SDATE=`${NDATE} -$tmval $CYCLE`

### modify namelist file

export restval=true

if [ $tmmark != tm00 ]; then
  nests="conus alaska"   #These are cycled
  numdom=3
  numchild=2
  LENGTH=01
  #resint is in minutes!
  resint=60
  #freerun is always true since we use the digital filter
  export freerun=true
  export run_firewx=NO
fi

if [ $tmmark = tm00 ]; then
  export freerun=true
  if [ $RUNTYPE = CATCHUP ]; then
    # Do not use the FMAX* variable to specify the max forecast length
    #  here for the CATCHUP cycle.  
    LENGTH=60
    FHRRST=18
    #resint is in minutes!
    resint=360
    histint=60
    # Change run_firewx=YES
    export run_firewx=YES
    # ER: I think this line is not needed
    export NODE_CONFIGFILE=${NODE_CONFIGFILE:-$PARMnam/nam_node_decomposition_opsconfig.tm00}
    numdom=6
    numchild=4
    # Add additional nests here which have a free
    #  forecast component (and may not have a DA cycle)
    nests="conus alaska hawaii prico firewx"                             
  else
    if [ ${FMAX_HOURLY_PARENT} -eq ${FMAX_HOURLY_NEST} ]; then
      LENGTH=${FMAX_HOURLY_PARENT}
    else
      #NEST forecast length must be less than the parent, so assign max length to nest
      # with assumption that the fcst will be restarted later with just the parent domain
      LENGTH=${FMAX_HOURLY_NEST}
    fi
    #resint is in minutes!
    resint=60
    # For 0-18 h CONUS/AK nests we make 15 minute history files
    histint=15
    numchild=2
    numdom=3
    nests="conus alaska"  # Free forecasts only with cycled nests in with RUNTYPE=HOURLY
  fi
fi

rhour=$LENGTH
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

NLNAME=nam_configfile

if [ $tmmark = tm06 ] ; then
  if [ $GUESS = GDAS ] ; then
    export restval=false
  else
    export restval=true
  fi
else
  if [ $RUNTYPE = CATCHUP -a $tmmark = tm00 ] ; then
    if [ $GUESStm00 = NAM ] ; then
      export restval=true
    fi
    if [ $GUESStm00 = GDAS ] ; then
      export restval=false
    fi
  else
    export restval=true
  fi
fi

#Set up the parent first

# Only do precip assim during catchup cycle

if [ $RUNTYPE = CATCHUP -a $tmmark != tm00 ]; then
  filesize1=0

  if [ -s $COMIN/${RUN}.t${cyc}z.pcp.${tmmark}.hr1.${CDATE}.bin ]; then
    let filesize1=`ls -l $COMIN/${RUN}.t${cyc}z.pcp.${tmmark}.hr1.${CDATE}.bin | awk '{print $5}'`
  fi

  if [ $filesize1 -lt 3000000 ]; then
    pflag=false
  else
    pflag=true
    ln -s -f $COMIN/${RUN}.t${cyc}z.pcp.${tmmark}.hr1.${CDATE}.bin pcp.hr1.01.bin 
  fi
else
  pflag=false
fi

#Run digital filter for ALL hourly forecasts!
filteropt=3

# If starting from non-zero fcst hour do not run digital filter

if [ $RESTARTNZF = "NO" ]; then
  filteropt=3
else
  filteropt=0
fi

#Use heating tendencies from GSI cloud analysis for the parent?
radar_init=0
filtvar=nam_filt_vars_norad.txt
USEREF=`cat $GESDIR/nam.t${cyc}z.useref_envir_parent_${tmmark}.sh`
if [ $USEREF = true -a $RESTARTNZF = "NO" ]; then
  radar_init=1
  # The same filtvar file is used for all domains, so if any domain uses
  #  the radar enhanced DFI we use the new filt vars file for all domains
  #  (see the same if-block below in the construction of the nest namelists)
  filtvar=nam_filt_vars.txt
fi

#write out first restart file and nemsio files!
export wrtlast=true
export rstout=true

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

#For parent, reset restval=true for restarting from non-zero fcst hour
if [ $RESTARTNZF = "YES" ]; then
  export restval=true
fi

# Run config file to import node decomposition
export domain=parent
set -a; . $NODE_CONFIGFILE; set +a

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

cp configure_file $COMOUT/${RUN}.t${cyc}z.configure_file.${tmmark}
cpreq configure_file configure_file_01
cpreq configure_file model_configure


##################################################################################
############# START NEST SET UP ##################################################
##################################################################################
# Only do precip assim during catchup cycle

for domain in ${nests}; do

  export numdomain=`grep ${domain} $PARMnam/nam_nestdomains | awk '{print $2}'`

  #Use heating tendencies from GSI cloud analysis for the nest?
  radar_init=0
  nestref=false
  nestref=`cat $GESDIR/${RUN}.t${cyc}z.useref_envir_${domain}_${tmmark}.sh`
  if [ $nestref = true -a $RESTARTNZF = "NO" ]; then
    radar_init=1
    # The same filtvar file is used for all domains, so if any domain uses
    #  the radar enhanced DFI we use the new filt vars file for all domains
    filtvar=nam_filt_vars.txt
  fi

  if [ $RUNTYPE = CATCHUP -a $tmmark != tm00 ]; then
    filesize1=0                   
    if [ -s $COMIN/${RUN}.t${cyc}z.pcp.${domain}nest.${tmmark}.hr1.${CDATE}.bin ]; then
      let filesize1=`ls -l $COMIN/${RUN}.t${cyc}z.pcp.${domain}nest.${tmmark}.hr1.${CDATE}.bin | awk '{print $5}'`
    fi
    if [ $filesize1 -lt 4000000 ]; then
      pflag=false
    else
      pflag=true
      ln -s -f $COMIN/${RUN}.t${cyc}z.pcp.${domain}nest.${tmmark}.hr1.${CDATE}.bin pcp.hr1.${numdomain}.bin
    fi
  else
    pflag=false
  fi

  #write out first restart file and nemsio files!
  export wrtlast=true
  export rstout=true
  export freerun=true  #always true since the digital filter is in use

  #No need to modify buckets for the nests

  # Run config file to import node decomposition
  export domain
  set -a; . $NODE_CONFIGFILE; set +a

  NLNAME=nam_configfile_${domain}nest

  if [ $RUNTYPE = CATCHUP -a $tmmark != tm00 ]; then

    #--If this is a CATCHUP cycle but still in the DA cycling phase--#

    numchild_firewx=0
    histint=60
    cat $PARMnam/$NLNAME | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
     | sed s:INPES:$inpes: | sed s:JNPES:$jnpes: | sed s:WRITE_GROUPS:$write_groups: | sed s:WRITE_TASKS:$write_tasks: \
     | sed s:DSTART:$dstart: | sed s:HSTART:$hstart: | sed s:YEND:$yend: \
     | sed s:MEND:$mend:     | sed s:DEND:$dend: | sed s:HEND:$hend:  \
     | sed s:RH:$rhour:      | sed s:RD:$rday: | sed s:LENGTH:$LENGTH: | sed s:HISTINT:$histint: \
     | sed s:RESINT:$resint: | sed s:REST:$restval: | sed s:FREE:$freerun: | sed s:OUTRST:$rstout: \
     | sed s:WRTLAST:$wrtlast: | sed s:PFLAG:$pflag: | sed s:FILTEROPTION:$filteropt: \
     | sed s:USE_RADAR:$radar_init: | sed s:NCHILD_FIREWX:$numchild_firewx: > configure_file_${domain}

    cp configure_file_${domain} $COMOUT/${RUN}.t${cyc}z.configure_file_${domain}nest.${tmmark}
    mv configure_file_${domain} configure_file_${numdomain}

  else

    #--Free forecast phase of CATCHUP or HOURLY cycles--#

    if [ $domain = hawaii -o $domain = prico -o $domain = firewx ] ; then
      #--restart file interval always 6-h for non-cycled nests 
      #--NO! must be hourly for 1-5 h post jobs to run!!!
      #--Changed back to 6-h(360 min) for ops, remember to remove restart file dependency to 
      #--run 00-06 h post jobs in Rocoto xml file
      resint=360 
      wrtlast=false
      if [ $RESTARTNZF = "NO" ]; then
        export restval=false
      else
        export restval=true
      fi
    else
      if [ $RUNTYPE = HOURLY ] ; then
        export restval=true
      fi
      if [ $RUNTYPE = CATCHUP ] ; then
        if [ $GUESStm00 = NAM ] ; then
          export restval=true
        fi
        if [ $GUESStm00 = GDAS ] ; then
          export restval=false
        fi
       # This ensures all nests get restval=true for restarting from non-zero fcst hour
        if [ $RESTARTNZF = "YES" ]; then
          export restval=true
        fi
      fi
    fi
    
    #--Special block for fire weather nest configure file--#

    if [ $firewx_location = $domain -a $run_firewx = YES ]; then

      #--If firewx domain is inside conus or alaska nest domains--#

      wrtlast=false
      numchild_firewx=1
      cat $PARMnam/$NLNAME | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
       | sed s:INPES:$inpes: | sed s:JNPES:$jnpes: | sed s:WRITE_GROUPS:$write_groups: | sed s:WRITE_TASKS:$write_tasks: \
       | sed s:DSTART:$dstart: | sed s:HSTART:$hstart: | sed s:YEND:$yend: \
       | sed s:MEND:$mend:     | sed s:DEND:$dend: | sed s:HEND:$hend:  \
       | sed s:RH:$rhour:      | sed s:RD:$rday: | sed s:LENGTH:$LENGTH: | sed s:HISTINT:$histint: \
       | sed s:RESINT:$resint: | sed s:REST:$restval: | sed s:FREE:$freerun: | sed s:OUTRST:$rstout: \
       | sed s:WRTLAST:$wrtlast: | sed s:PFLAG:$pflag:   | sed s:FILTEROPTION:$filteropt: | sed s:USE_RADAR:$radar_init: \
       | sed s:NCHILD_FIREWX:$numchild_firewx: > configure_file_${domain}

      cp configure_file_${domain} $COMOUT/${RUN}.t${cyc}z.configure_file_${domain}nest.${tmmark}
      mv configure_file_${domain} configure_file_${numdomain}
     
    elif [ $domain = "firewx" ]; then
       
       #--If this domain is the firewx nest domain--#

       numchild_firewx=0
       if [ -s $COMOUT/${RUN}.t${cyc}z.firewx_ijstart.txt ] ; then
         cp $COMOUT/${RUN}.t${cyc}z.firewx_ijstart.txt firewx_ijstart.txt
         export istart=${istart:-`grep i_parent_start firewx_ijstart.txt | awk '{print $2}'`}
         export jstart=${jstart:-`grep j_parent_start firewx_ijstart.txt | awk '{print $2}'`}
       else
         msg="ijstart file for fire weather nest missing, abort run."
         err_exit $msg
       fi

       NLNAME=nam_configfile_${domain}nest_${firewx_location}
       filteropt=0
       radar_init=0
       wrtlast=false

      cat $PARMnam/$NLNAME | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
       | sed s:INPES:$inpes: | sed s:JNPES:$jnpes: | sed s:WRITE_GROUPS:$write_groups: | sed s:WRITE_TASKS:$write_tasks: \
       | sed s:DSTART:$dstart: | sed s:HSTART:$hstart: | sed s:YEND:$yend: \
       | sed s:MEND:$mend:     | sed s:DEND:$dend: | sed s:HEND:$hend:  \
       | sed s:RH:$rhour:      | sed s:RD:$rday: | sed s:LENGTH:$LENGTH: | sed s:HISTINT:$histint: \
       | sed s:RESINT:$resint: | sed s:REST:$restval: | sed s:FREE:$freerun: | sed s:OUTRST:$rstout: \
       | sed s:WRTLAST:$wrtlast: | sed s:PFLAG:$pflag:   | sed s:FILTEROPTION:$filteropt: | sed s:USE_RADAR:$radar_init: \
       | sed s:I_START_FIREWX:$istart: | sed s:J_START_FIREWX:$jstart: > configure_file_${domain}

      cp configure_file_${domain} $COMOUT/${RUN}.t${cyc}z.configure_file_${domain}nest.${tmmark}
      mv configure_file_${domain} configure_file_${numdomain}

    else

      numchild_firewx=0
      wrtlast=false

      cat $PARMnam/$NLNAME | sed s:YSTART:$ystart: | sed s:MSTART:$mstart: \
       | sed s:INPES:$inpes: | sed s:JNPES:$jnpes: | sed s:WRITE_GROUPS:$write_groups: | sed s:WRITE_TASKS:$write_tasks: \
       | sed s:DSTART:$dstart: | sed s:HSTART:$hstart: | sed s:YEND:$yend: \
       | sed s:MEND:$mend:     | sed s:DEND:$dend: | sed s:HEND:$hend:  \
       | sed s:RH:$rhour:      | sed s:RD:$rday: | sed s:LENGTH:$LENGTH: | sed s:HISTINT:$histint: \
       | sed s:RESINT:$resint: | sed s:REST:$restval: | sed s:FREE:$freerun: | sed s:OUTRST:$rstout: \
       | sed s:WRTLAST:$wrtlast: | sed s:PFLAG:$pflag:   | sed s:FILTEROPTION:$filteropt: | sed s:USE_RADAR:$radar_init: \
       | sed s:NCHILD_FIREWX:$numchild_firewx: > configure_file_${domain}

      cp configure_file_${domain} $COMOUT/${RUN}.t${cyc}z.configure_file_${domain}nest.${tmmark}
      mv configure_file_${domain} configure_file_${numdomain}

    #end firewx check
    fi

  #End CATCHUP cycle check
  fi

#End loop over nests
done

##################################################################################
############# END NEST SET UP ####################################################
##################################################################################

rm fort.*

if [ $RUNTYPE = CATCHUP -a $tmmark != tm00 ]; then
  if [ -s $COMIN/${RUN}.t${cyc}z.boco.01.000.${tmmark} ]; then
   ln -s -f $COMIN/${RUN}.t${cyc}z.boco.01.000.${tmmark} boco.0000
  else
    msg="Boundary file not found, abort run."
    err_exit $msg
  fi
fi

if [ $tmmark = tm00 ]; then
   if [ $RUNTYPE = HOURLY ]; then
     hour=00
     while [ $hour -le ${FMAX_HOURLY_PARENT} ] ; do
       if [ -s $COMIN/${RUN}.t${cyc}z.boco.01.0${hour}.${tmmark} ] ; then
         ln -s -f $COMIN/${RUN}.t${cyc}z.boco.01.0${hour}.${tmmark} boco.00${hour}
       else
         msg="Boundary file not found, abort run."
         err_exit $msg
       fi
       let "hour=hour+1"
       typeset -Z2 hour
     done
   else
     hour=00
     while [ $hour -le ${FMAX_CATCHUP_PARENT_BOCO} ] ; do
       if [ -s $COMIN/${RUN}.t${cyc}z.boco.01.0${hour}.${tmmark} ]; then
         ln -s -f $COMIN/${RUN}.t${cyc}z.boco.01.0${hour}.${tmmark} boco.00${hour}
       else
         msg="Boundary file not found, abort run."
         err_exit $msg
       fi
       let "hour=hour+3"
       typeset -Z2 hour
     done
   fi
fi

if [ $tmmark = "tm06" ]; then
  if [ $GUESS = NAM ]; then 
     ln -s -f $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_nemsio_anl.${tmmark} restart_file_01_nemsio
  else
     ln -s -f $GESDIR/${RUN}.t${cyc}z.input_domain_01_nemsio.anl.${tmmark} input_domain_01_nemsio
  fi
else
  if [ $tmmark = tm00 ] ; then
    if [ $RESTARTNZF = "NO" ] ; then
      if [ $GUESStm00 = NAM ] ; then
        ln -s -f $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_nemsio_anl.${tmmark} restart_file_01_nemsio
      else
        ln -s -f $GESDIR/${RUN}.t${cyc}z.input_domain_01_nemsio.anl.${tmmark} input_domain_01_nemsio
      fi
    fi
  else
    ln -s -f $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_nemsio_anl.${tmmark} restart_file_01_nemsio
  fi
fi

##################################################################################
############# LINK NEST ANALYSIS FILES############################################
##################################################################################
for domain in ${nests}; do
  export numdomain=`grep ${domain} $PARMnam/nam_nestdomains | awk '{print $2}'`
  if [ $tmmark = "tm06" ]; then
    if [ $GUESS = NAM ]; then
      ln -s -f $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_${domain}nest_nemsio_anl.${tmmark} restart_file_${numdomain}_nemsio
    else
      ln -s -f $GESDIR/${RUN}.t${cyc}z.input_domain_${domain}nest_nemsio.anl.${tmmark} input_domain_${numdomain}_nemsio
    fi
  else
    if [ $tmmark = tm00 ] ; then
      if [ $RESTARTNZF = "NO" ] ; then
       if [ $domain = conus -o $domain = alaska ] ; then
         if [ $GUESStm00 = NAM ] ; then
           ln -s -f $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_${domain}nest_nemsio_anl.${tmmark} restart_file_${numdomain}_nemsio
         fi
         if [ $GUESStm00 = GDAS ] ; then
           # All analysis nemsio input files if GUESStm00 = GDAS called restart files for simplicity
           ln -s -f $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_${domain}nest_nemsio_anl.${tmmark} input_domain_${numdomain}_nemsio
         fi
       else
         # non-cycled nest analysis files are really input files, not restart files  
         ln -s -f $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_${domain}nest_nemsio_anl.${tmmark} input_domain_${numdomain}_nemsio
       fi
      fi
    else
      ln -s -f $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_${domain}nest_nemsio_anl.${tmmark} restart_file_${numdomain}_nemsio
    fi
  fi
done

##################################################################################
############# END LINK NEST ANALYSIS FILES########################################
##################################################################################

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

# Needed for NAM fcst

export LANG=en_US

export pgm=nam_nems_nmmb_fcst
. prep_step

startmsg

${MPIEXEC} --line-buffer --label -n ${ntasks} -ppn ${ppn} --cpu-bind depth --depth ${threads} $EXECnam/nam_nems_nmmb_fcst >>$pgmout 2>errfile
export err=$?;err_chk

if [ $RUNTYPE = CATCHUP -a $tmmark != tm00 ]; then
  mv nmmb_rst_01_nio_0001h_00m_00.00s $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_nemsio.${tmmark}
  export err=$?;err_chk
  for domain in ${nests}; do
    export numdomain=`grep ${domain} $PARMnam/nam_nestdomains | awk '{print $2}'`
    mv nmmb_rst_${numdomain}_nio_0001h_00m_00.00s $GESDIR/${RUN}.t${cyc}z.nmm_b_restart_${domain}nest_nemsio.${tmmark}
    export err=$?;err_chk
  done
fi

date
echo EXITING $0

exit $err
