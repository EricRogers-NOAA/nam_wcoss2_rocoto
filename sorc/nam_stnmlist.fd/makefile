SHELL=/bin/bash
SRCS = stnmlist.f  
OBJS = stnmlist.o 
FC =  ftn
LDFLAGS =	
LIBS = ${W3NCO_LIB4} ${W3EMC_LIB4} ${BUFR_LIB4} 
CMD = ${OUTDIR}/nam_stnmlist	

FFLAGS = -O

all: $(CMD)

$(CMD):	$(OBJS)
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(LIBS)

clean:
	-rm -f $(OBJS) ${CMD}
