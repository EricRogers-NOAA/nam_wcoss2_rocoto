################################################################################
# 
#     Makefile for WRFBUFR code
#
#     Use:
#     make         -  build the executable
#     make clean   -  start with a clean slate
#
#     The following macros will be of interest:
#
#         TARGET   - name of the executable
#         FC       - name of Fortran compiler
#         CPP      - name of CPP
#         CPPFLAGS - CPP flags
#         OPTS     - compiler code optimizations
#         DEBUG    - -g
#
#################################################################################
#
# Define the name of the executable
#
TARGET =nam_post0
#
# CPP, Compiler, and Linker Options
#

FC       = ftn
CPP      = /lib/cpp -P
CPPFLAGS = 
OPTS     = 
FREE     = -FR
DEBUG    = -debug -g -traceback -convert big_endian
# -check all 
#-check all -check bounds -check uninit -ftrapuv
W3EMC_INC = -I${W3EMC_INC4}
NEMSIOINC = -I${NEMSIO_INC}

#
# Assemble Options
#
FFLAGS   = $(OPTS) $(DEBUG) $(W3EMC_INC) $(NEMSIOINC)
FFLAGST  = $(OPTS) $(FREE) $(DEBUG) $(W3EMC_INC) $(NEMSIOINC)
LDFLAGS  = 
LIBS= ${NEMSIO_LIB} ${SIGIO_LIB4} ${SFCIO_LIB4} ${BACIO_LIB4} ${SP_LIB4} ${W3NCO_LIB4} ${W3EMC_LIB4}


#
#
# free-format object files
#
OBJST=	kinds_mod.o next_buf.o retrieve_index.o GETNEMSANDPLACE.o
#
# fixed-format object files
#
OBJS=	VRBLS2D_mod.o VRBLS3D_mod.o MASKS_mod.o SOIL_mod.o \
        WRFBUFR.o PROF_NMMB.o \
        iw3jdn.o w3fs26.o w3movdat.o w3reddat.o gdswiz.o gdswiz01.o \
        gdswiz03.o gdswiz05.o

DEPS= parmsoil 

.SUFFIXES:	.F .f .o

.F.f:
	$(CPP) $(CPPFLAGS) $< > $*.f

$(TARGET):	$(OBJST) $(OBJS)
	$(FC) $(LDFLAGS) -o $@ $(OBJST) $(OBJS) $(LIBS) 

$(OBJS):	$(DEPS)
	$(FC) -c $(FFLAGS) $(@:.o=.f)

$(OBJST):	$(DEPS)
	$(FC) -c $(FFLAGST) $(@:.o=.f)

clean:	
	/bin/rm -f  $(TARGET) *.lst *.o *.mod
#
