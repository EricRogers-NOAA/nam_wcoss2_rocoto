SHELL=/bin/sh
#
# This makefile compiles and creates an NAM32TX executable program.
#

SRCS=	nam32tx.f  w3fc03.f  fous40.f  fous60.f  frzlvl.f  gentbl.f  precip.f \
        precip48h.f stnij1.f   fous4048h.f  fous6048h.f  frzlvl48h.f

OBJS=	nam32tx.o  w3fc03.o  fous40.o  fous60.o  frzlvl.o  gentbl.o  precip.o \
        precip48h.o stnij1.o   fous4048h.o  fous6048h.o  frzlvl48h.o

# Tunable parameters
#
# FC		Name of the fortran compiling system to use
# LDFLAGS	Flags to the loader
# LIBS		List of libraries
# CMD		Name of the executable
# PROFLIB	Library needed for profiling
#
FC =		ftn
# LDFLAGS =	-bnoquiet
LIBS = ${W3EMC_LIB8} ${W3NCO_LIB8} ${BACIO_LIB8}
CMD =		$(OUTDIR)/nam32tx
PROFLIB =	-lprof

# To perform the default compilation, use the first line
# To compile with flowtracing turned on, use the second line
# To compile giving profile additonal information, use the third line
# WARNING:  SIMULTANEOUSLY PROFILING AND FLOWTRACING IS NOT RECOMMENDED
FFLAGS =        -O3  -g -assume byterecl -assume noold_ldout_format -convert big_endian -r8 -i8

# Lines from here on down should not need to be changed.  They are the
# actual rules which make uses to build a.out.
#
all:		$(CMD)

$(CMD):		$(OBJS)
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(LIBS)
	rm -f $(OBJS)

# Make the profiled version of the command and call it a.out.prof
#
$(CMD).prof:	$(OBJS)
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(PROFLIB) $(LIBS)

clean:
	-rm -f $(OBJS)

clobber:	clean
	-rm -f $(CMD) $(CMD).prof

void:	clobber
	-rm -f $(SRCS) makefile
