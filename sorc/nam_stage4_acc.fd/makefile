SHELL=		/bin/bash
LIBS=           ${BACIO_LIB4} ${W3NCO_LIB4} ${W3EMC_LIB4} 
FC=		ftn
LDFLAGS=	
FFLAGS=		-O -FR -convert big_endian
SRCS=		acc.f 
OBJS=		acc.o
CMD=		${OUTDIR}/nam_stage4_acc

all:		$(CMD)

$(CMD):		$(OBJS)
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(LIBS)

clean:
	-rm -rf *.o *.lst

