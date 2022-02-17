SHELL=		/bin/bash
LIBS =          ${W3NCO_LIB4} ${W3EMC_LIB4} ${BACIO_LIB4}
FC=		ftn
LDLAGS=        
FFLAGS=		-O -FR -convert big_endian
SRCS=		merge2n4.f 
OBJS=		merge2n4.o 
CMD=		${OUTDIR}/nam_merge2n4

all:		$(CMD)

$(CMD):		$(OBJS)
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(LIBS)
clean:
	rm -rf $(OBJS) $(CMD)

