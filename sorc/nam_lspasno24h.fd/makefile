SHELL=		/bin/bash
LIBS=		${W3NCO_LIB4} ${W3EMC_LIB4} ${BACIO_LIB4}
FC=		ftn
LDFLAGS=
FFLAGS=		-O -g -traceback -convert big_endian
SRCS=		lspasno24h.f 
OBJS=		lspasno24h.o
CMD=		${OUTDIR}/nam_lspasno24h

all:		$(CMD)

$(CMD):		$(OBJS)
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(LIBS)
clean:
	-rm -f $(OBJS) $(CMD)

