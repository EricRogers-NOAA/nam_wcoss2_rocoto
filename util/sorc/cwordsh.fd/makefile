LIBS = ${W3NCO_LIB4} ${BUFR_LIB4}
CMD = ${OUTDIR}/cwordsh
$(CMD):
	ftn -O3 -assume noold_ldout_format -Xlinker -s -o $(@) cwordsh.f $(LIBS)
clean:
	rm *.o
