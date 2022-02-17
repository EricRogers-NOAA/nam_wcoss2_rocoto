SHELL=		/bin/bash
LIBS=           ${W3NCO_LIB4} ${W3EMC_LIB4} ${BACIO_LIB4}
FC=		ftn
LDFLAGS=
FFLAGS=		-O -convert big_endian
SRCS=		pcpbudget.f 
OBJS=		pcpbudget.o
CMD=		${OUTDIR}/nam_pcpbudget

all:		$(CMD)

$(CMD):		$(OBJS)
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(LIBS)
clean:
	rm $(OBJS) $(CMD)
