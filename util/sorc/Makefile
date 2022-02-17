SHELL=/bin/bash
# All libraries needed for compiling
#   should have been loaded prior to the
#   execution of this makefile

SUBDIRS0 = bulls_fdwndtrx.fd fbwndtrx.fd nam32tx.fd cwordsh.fd nam_remap_pcpbudget.fd tocsbufr.fd setfirewx.fd

all: $(SUBDIRS0) 
	@for dir in $(SUBDIRS0); do \
           ( cd $$dir; echo "Making $@ in `pwd`" ; make ) ; \
        done
clean: $(SUBDIRS0)
	@for dir in $(SUBDIRS0); do \
          ( cd $$dir; echo "Cleaning `pwd`" ; \
           make $@ ) ; \
	done
