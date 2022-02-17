SHELL=		/bin/bash
LIBS=           ${W3NCO_LIBd} ${W3EMC_LIBd} ${BACIO_LIB4}
FC=		ftn
LDFLAGS=
FFLAGS=		-O3 -r8 -convert big_endian
SRCS=		icwf.f 
OBJS=		icwf.o
CMD=		${OUTDIR}/nam_icwf

all:		$(CMD)

$(CMD):		$(OBJS)
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(LIBS)
clean:
	rm $(OBJS) $(CMD)
