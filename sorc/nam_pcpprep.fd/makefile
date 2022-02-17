SHELL=		/bin/bash
LIBS=		${BACIO_LIB4} ${W3NCO_LIB4} ${W3EMC_LIB4}
FC=		ftn
FFLAGS=		-O -FR -convert big_endian
LDFLAGS=       
SRCS=		pcpprep.f
OBJS=		pcpprep.o
CMD=		${OUTDIR}/nam_pcpprep

all:		$(CMD)

$(CMD):		$(OBJS)
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(LIBS)
clean:
	rm -rf $(CMD) $(OBJS)
