SHELL=		/bin/bash
LIBS=           ${BACIO_LIB4} ${W3NCO_LIB4} ${W3EMC_LIB4}
FC=		ftn
FFLAGS=		-O -FR -convert big_endian
LDFLAGS=
SRCS=		nam_pcp_conus.f 
OBJS=		nam_pcp_conus.o
CMD=		$(OUTDIR)/nam_pcp_conus

all:		$(CMD)

$(CMD):		$(OBJS)
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(LIBS)

clean:
	rm $(CMD) *.o

