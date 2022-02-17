#!/bin/sh
#########################################################################
#									#
# Script:  nam_bfr2gpk							#
#									#
#  This script reads nam BUFR output and transfers it into GEMPAK	#
#  surface and sounding data files.					#
#									#
# Log:									#
# K. Brill/HPC		11/28/01					#
#########################################################################  
set -x

#  Go to a working directory.

cd $DATA

DOMAIN=`echo $domain | tr '[a-z]' '[A-Z]'`

#  Set input file name.

#Get the domain id number
export numdomain=`grep ${domain} $PARMnam/nam_nestdomains | awk '{print $2}'`

# CWORDX needed for cwordsh script, which calls the cwordsh exec
export CWORDX=${UTIL_EXECnam}/cwordsh

${UTIL_USHnam}/cwordsh unblk $COMIN/nam.t${cyc}z.class1.bufr_${domain}nest.${tmmark} class1.bufr_${domain}nest.${tmmark}_unblk
${UTIL_USHnam}/cwordsh block class1.bufr_${domain}nest.${tmmark}_unblk class1.bufr_${domain}nest.${tmmark}_blk

INFILE=class1.bufr_${domain}nest.${tmmark}_blk
export INFILE

#  Set output directory:

outfilbase=nam_${domain}nest_${PDY}${cyc}

namsnd << EOF > /dev/null
SNBUFR   = $INFILE
SNOUTF   = ${outfilbase}.snd
SFOUTF   = ${outfilbase}.sfc+
SNPRMF   = sneta.prm
SFPRMF   = sfeta.prm
TIMSTN   = 85/2000
r

exit
EOF

/bin/rm *.nts

snd=${outfilbase}.snd
sfc=${outfilbase}.sfc
aux=${outfilbase}.sfc_aux
cp $snd $COMOUT/.$snd
cp $sfc $COMOUT/.$sfc
cp $aux $COMOUT/.$aux

mv $COMOUT/.$snd $COMOUT/$snd.${tmmark}
mv $COMOUT/.$sfc $COMOUT/$sfc.${tmmark}
mv $COMOUT/.$aux $COMOUT/$aux.${tmmark}


if [ $SENDDBN = "YES" ]
then
   $DBNROOT/bin/dbn_alert MODEL SFC_NAM_${DOMAIN}NEST $job $COMOUT/$sfc.${tmmark}
   $DBNROOT/bin/dbn_alert MODEL SFC_NAM_${DOMAIN}NEST $job $COMOUT/$aux.${tmmark}
   $DBNROOT/bin/dbn_alert MODEL SND_NAM_${DOMAIN}NEST $job $COMOUT/$snd.${tmmark}
fi

echo done > $DATA/gembufr_${numdomain}.done
