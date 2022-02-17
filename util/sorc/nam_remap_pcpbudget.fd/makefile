SHELL = bash
FC   = ftn
FLAGS=  -O2 -assume byterecl -fp-model strict -convert big_endian
LIBS= ${W3NCO_LIB4} ${W3EMC_LIB4} ${BACIO_LIB4}
CMD1 = ${OUTDIR}/grb_to_bin.x
CMD2 = ${OUTDIR}/grid_to_grb.x

$(CMD1): grb_to_bin.f $(CMD2) 
	${FC} -o $(@) ${FLAGS} grb_to_bin.f ${LIBS}

$(CMD2): grid_to_grb.f
	${FC} -o $(@) ${FLAGS} grid_to_grb.f ${LIBS} 

clean:
	/bin/rm -f *.o *.x
