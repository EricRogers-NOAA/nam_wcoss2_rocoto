SHELL=/bin/bash
# All libraries should be set in the environment prior to compiling
# 11/5/2019 : nam_post0 compiled separately

SUBDIRS0 = nam_pcpbudget.fd nam_sndp.fd nam_firewx_gridspecs.fd \
           nam_lspasno24h.fd nam_makeprecip.fd nam_merge2n4.fd \
           nam_pcp_conus.fd nam_pcpprep.fd nam_icwf.fd \
           nam_ref2nemsio.fd nam_stage4_acc.fd nam_stnmlist.fd

SUBDIRS1 = nam_get1236hpcp.fd

all: $(SUBDIRS0) $(SUBDIRS1)
	@for dir in $(SUBDIRS0); do \
           ( cd $$dir; echo "Making $@ in `pwd`" ; make ) ; \
        done
	@for dir in $(SUBDIRS1); do \
           ( cd $$dir; echo "Making $@ in `pwd`" ; ./compile ) ; \
        done
clean: $(SUBDIRS0)
	@for dir in $(SUBDIRS0); do \
          ( cd $$dir; echo "Cleaning `pwd`" ; make $@ ) ; \
	done
