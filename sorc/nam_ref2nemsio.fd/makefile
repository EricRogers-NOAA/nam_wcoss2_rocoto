SHELL   =/bin/bash
EXEC    =  nam_ref2nemsio
FC      =  ftn
FOPTS  = -FR -O3 -I${NEMSIO_INC}
LIBS   = ${NEMSIO_LIB} ${BACIO_LIB4} ${W3EMC_LIB4} ${W3NCO_LIB4}
OBJS = ref2nemsio.o
SRCS = ref2nemsio.f
# *************************************************************************
$(EXEC): $(OBJS)

$(OBJS): $(SRCS)
	$(FC)  $(FOPTS) $(SRCS) -o $(EXEC) $(LIBS)
