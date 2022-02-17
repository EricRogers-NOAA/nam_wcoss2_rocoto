      PROGRAM ICWF
C$$$  MAIN PROGRAM DOCUMENTATION BLOCK
C                .      .    .     
C MAIN PROGRAM: ETA_ICWF.F
C   PRGMMR: ROGERS           ORG: NP22        DATE: 1999-09-24
C     
C ABSTRACT:
C   THIS PROGRAM READS A GRIB 1 FILE AND WRITES OUT ICWF FIELDS.
C
C   The standard input file is a list of complete path names to the
C   GRIB files to be used to build ICWF files.  The output files are
C   the same names with _icwf appended.
C     
C     
C PROGRAM HISTORY LOG:
C   93-??-??  MARK IREDELL
C   93-10-05  RUSS TREADON - ENHANCED COMMENTS
C   95-04-05  MIKE BALDWIN - COMBINE RDGRBI AND GRIBIT TO MAKE
C                              BRKOUT
C   95-06-30  KEITH BRILL  - REWRITE FOR ICWF
C   96-10-25  KEITH BRILL  - UPDATE PDS9 and PDS10 for cloud, snow, LI
C				made PROB (THNDR) function of LI only
C				compute snow depth from water equiv.
C   96-11-20  KEITH BRILL  - Look for PDS9 = 132 only for LI, stop
C			     reading when all required fields are found
C   97-06-03  KEITH BRILL  - Compute snow accumulations over the shortes
C			     interval permitted by the frequency of the
C			     available data (as for precip)
C   98-07-28  KEITH BRILL  - f90, remove W3LOG calls, W3TAGE before all
C			     STOPs, remove in-file W3 code
C   98-09-03  KEITH BRILL  - Make precip probability just 0 or 100%
C 1999-05-26  Gilbert      - Converted to run on IBM.
C                            Replaced obsolete internal routines SKIPGB,
C                            RDGB and GBREAD with standard W3LIB/BACIO
C                            routines SKGB and BAREAD.
C 2000-03-22  ROGERS       - Modified GENPDS so that if input grid = 212
C                            model generating number is hardwired to 89.
C 2004-04-14  MANIKIN      - added processing for grid 218
C     
C   INPUT FILES:
C     FORT.5  - STANDARD INPUT - PATH/FILE NAMES
C     FORT.12 - INPUT GRIB DATA FILE.
C
C   OUTPUT FILES:
C     FORT.6  - RUNTIME STANDARD OUTPUT.
C     FORT.51 - EXTRACTED DATA
C     
C   SUBPROGRAMS CALLED:
C     UTILITIES:
C       GRIBIT,GENPDS
C	ST_LSTR, PD_DWPT, GDSLLO
C	W3FI71, W3FI72
C     LIBRARY:
C       W3FB07, W3FB09, W3FB12
C	W3LOG, W3TAGB
C     
C   ATTRIBUTES:
C     LANGUAGE: FORTRAN
C     MACHINE : IBM SP
C$$$  
C
      PARAMETER(IMX=620,JMX=430)
      PARAMETER  (MDATA=IMX*JMX, MXTIMS=1)
      PARAMETER  ( RTD = 180. / 3.141593 )
C
C     MAXIMUM DIMENSIONS FOR OUTPUT GRID
C     
C
      INTEGER STDOUT
      INTEGER LLGRIB,LLSKIP,KKPDS(200),KKGDS(200),kcpds(30),ktpds(30)
      INTEGER KPTR(50)
      INTEGER IDOUT(30),IGDS(30)
C
      LOGICAL*1 LBMS(MDATA)
C
      REAL DATA(MDATA),DATAOT(IMX*JMX), 
     +     TMPK (IMX*JMX, MXTIMS), relh (IMX*JMX),
     +     urel (IMX*JMX), vrel (IMX*JMX), rli (IMX*JMX),
     +     wxts (IMX*JMX), wxtp (IMX*JMX), prcplast (IMX*JMX),
     +     tmax (IMX*JMX), tmin (IMX*JMX), wxtz (IMX*JMX),
     +     rlon (IMX*JMX), rlat (IMX*JMX), snowlast (IMX*JMX)
C*
      LOGICAL*1 havtmp, havrh, havu, havv, havli, havts, havtp,
     +		havtz, havp03, havcld, havsno, havwnd, first, frst
C
      CHARACTER FILNAM*256,FNAME*256,CBUF(500000)*1
C
      DATA  STDOUT/  6 /
      DATA  LUNGRB/ 12 /
      DATA  LCNTRL/ 5 /
      DATA  LUNOUT/ 51 /
      DATA  MSEEK/32000/
C     
C***********************************************************************
      CALL W3TAGB('ETA_ICWF.F',1999,0267,0081,'NP22')                   
C*
C*
	jtlast = 1
	first = .true.
	frst = .true.
	idtset = 0
	idsset = 0
C
C*      Loop over the input file names.
C
 10   CONTINUE
C
C*	Read the next input file name from the control file.
C***
C	FNAME = Input file name: the complete path name
C***
	READ(LCNTRL,2000,END=9999) FNAME
 2000 	FORMAT(A)
C
C*	Make an output file name.
C
	CALL ST_LSTR ( fname, lns, ier )
	filnam = fname (1:lns) // '_icwf'
C
C*	Open the output file.
C
        CALL BAOPEN(LUNOUT,FILNAM,IRT)
	WRITE (STDOUT,*) ' INPUT FILE = ',FNAME
	WRITE (STDOUT,*) ' Output file = ', filnam
C
C*      ASSIGN AND OPEN UNIT FOR GRIB INPUT DATA FILE.
C
        CALL BAOPENR(LUNGRB,FNAME,iostat)
	IF ( iostat .ne. 0 ) THEN
	    WRITE ( STDOUT, * ) FNAME, ' COULD NOT BE OPENED.',
     &                          '  ERROR = ',iostat
	    CALL W3TAGE('ETA_ICWF.F') 
	    STOP
	ENDIF
C
C*	FIND GRIB
C
	havtmp = .false.
	havrh = .false.
	havu = .false.
	havv = .false.
	havli = .false.
	havts = .false.
	havtp = .false.
	havtz = .false.
	havp03 = .false.
	havcld = .false.
	havsno = .false.
	havwnd = .false.
C*
	ISEEK = 0
	CALL SKGB(LUNGRB,ISEEK,MSEEK,LLSKIP,LLGRIB)
C
C*	Loop over all the grids in the GRIB FILE.
C
	igcnt = 0
	DO WHILE (LLGRIB.GT.0 .and. igcnt .lt. 11)
C
C*  	    UNPACK GRIB  Note:  This routine returns the full grid
C*		with zeroes stored at points masked by the bit map.
C
            CALL BAREAD(LUNGRB,LLSKIP,LLGRIB,NBUF,CBUF)
C
C* 	    CHECK PDS, DO WE NEED THIS GRID?
C
            ipds9 = mova2i(cbuf(17))
c	    ipds9 = kkpds (5)
	    ipds10 = mova2i(cbuf(18))
c	    ipds10 = kkpds (6)
            call gbyte(cbuf,ipds11,18*8,16)
            ipdser1 = mova2i(cbuf(19))
            ipdser2 = mova2i(cbuf(20))
            ipds11 = ipdser2
c           write (stdout,*) ipdser1,ipdser2
c 	    ipds11 = kkpds (7)
	    ipds20 = mova2i(cbuf(28))
c	    ipds20 = kkpds (15)
	    inhr = mova2i(cbuf(24))
c	    inhr = kkpds (11)
	    ifhr = mova2i(cbuf(27))
c	    ifhr = kkpds (14)
	    iutc = inhr + ifhr
	    iutc = MOD ( iutc, 24 )
c           WRITE (STDOUT,*) ipds9,ipds10,ipds11,ipds20,inhr,ifhr,iutc
C*
	    IF ( ipds9 .eq. 11 .and. ipds10 .eq. 105 .and.
     +		 ipds11 .eq. 2 .and. .not. havtmp ) THEN

              CALL W3FI63(CBUF,KKPDS,KKGDS,LBMS,DATA,KPTR,KRET)
              IF (KRET.EQ.0) THEN
                NDATA=KPTR(10)
c               WRITE(STDOUT,*)' Tmp ', NDATA
              ELSE
                WRITE(STDOUT,*)' Tmp Error decoding GRIB message = ',KRET
                NDATA=0
              ENDIF
              IBFLAG=IBITS(KKPDS(4),6,1)

		igcnt = igcnt + 1
C
C*		Capture the 2m temperature
C
C*---		jtlast = jtlast + 1
		DO ij = 1, ndata
		    tmpk (ij, jtlast) = data (ij)
		    IF ( first ) THEN
C
C*			Initialize max/min temps.
C
			IF ( ij .eq. 1 ) THEN
	    		    WRITE (STDOUT,*)
     +		             ' Initializing max/min tmps at UTC = ',
     +			     iutc
			END IF
			tmin (ij) = tmpk (ij,jtlast)
			tmax (ij) = tmpk (ij,jtlast)
		    ELSE IF ( iutc .gt. 12 ) THEN
C
C*			Check day-time max.
C
			IF ( tmpk (ij,jtlast) .gt. tmax (ij) )
     +			    tmax (ij) = tmpk (ij,jtlast)
		    ELSE IF ( iutc .eq. 12 ) THEN
C
C*			Set max temps.
C
			tmax (ij) = tmpk (ij,jtlast)
			IF ( tmpk (ij,jtlast) .lt. tmin (ij) )
     +			    tmin (ij) = tmpk (ij,jtlast)
		    ELSE IF ( iutc .eq. 0 ) THEN
C
C*			Set min temps.
C
			tmin (ij) = tmpk (ij,jtlast)
			IF ( tmpk (ij,jtlast) .gt. tmax (ij) )
     +			    tmax (ij) = tmpk (ij,jtlast)
		    ELSE
C
C*			Check night-time min.
C
			IF ( tmpk (ij,jtlast) .lt. tmin (ij) )
     +			    tmin (ij) = tmpk (ij,jtlast)
		    END IF
		END DO
		first = .false.
		havtmp = .true.
		ntmps = ndata
		DO k = 1, 22
		    ktpds (k) = kkpds (k)
		END DO
C
C*		Write out T, Tmax, and Tmin.
C
		CALL GENPDS (kkpds, ibflag, idout)
		CALL W3FI71 (kkpds(3),igds,ierr)
		DO ij = 1, ndata
		    dataot (ij) = tmpk (ij, jtlast)
		END DO
		rpack = 3.3
                CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			     ndata,rpack,lunout,ierr)
C*
		kkpds (5) = 15
		CALL GENPDS ( kkpds, ibflag, idout)
		CALL W3FI71 (kkpds(3),igds,ierr)
		DO ij = 1, ndata
		    dataot (ij) = tmax (ij)
		END DO
		rpack = 3.3
                CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			     ndata,rpack,lunout,ierr)
C*
		kkpds (5) = 16
		CALL GENPDS ( kkpds, ibflag, idout)
		CALL W3FI71 (kkpds(3),igds,ierr)
		DO ij = 1, ndata
		    dataot (ij) = tmin (ij)
		END DO
		rpack = 3.3
                CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			     ndata,rpack,lunout,ierr)
C*			
	    ELSE IF ( ipds9 .eq. 52 .and. ipds10 .eq. 105 .and.
     +		 ipds11 .eq. 2 .and. .not. havrh ) THEN

              CALL W3FI63(CBUF,KKPDS,KKGDS,LBMS,DATA,KPTR,KRET)
              IF (KRET.EQ.0) THEN
                NDATA=KPTR(10)
              ELSE
                WRITE (STDOUT,*)' RH Error decoding GRIB message = ',KRET
                NDATA=0
              ENDIF
              IBFLAG=IBITS(KKPDS(4),6,1)

		igcnt = igcnt + 1
C*
		DO ij = 1, ndata
		    relh (ij) = data (ij)
		END DO
		havrh = .true.
C*
	    ELSE IF ( ipds9 .eq. 33 .and. ipds10 .eq. 105 .and.
     +		 ipds11 .eq. 10 .and. .not. havu ) THEN

              CALL W3FI63(CBUF,KKPDS,KKGDS,LBMS,DATA,KPTR,KRET)
              IF (KRET.EQ.0) THEN
                NDATA=KPTR(10)
              ELSE
                WRITE (STDOUT,*)' 10u Error decoding GRIB message = ',KRET
                NDATA=0
              ENDIF
              IBFLAG=IBITS(KKPDS(4),6,1)

		igcnt = igcnt + 1
C*
		DO ij = 1, ndata
		    urel (ij) = data (ij)
		END DO
		havu = .true.
C*
	    ELSE IF ( ipds9 .eq. 34 .and. ipds10 .eq. 105 .and.
     +		 ipds11 .eq. 10 .and. .not. havv ) THEN

              CALL W3FI63(CBUF,KKPDS,KKGDS,LBMS,DATA,KPTR,KRET)
              IF (KRET.EQ.0) THEN
                NDATA=KPTR(10)
              ELSE
                WRITE (STDOUT,*) ' 10v Error decoding GRIB message = ',KRET
                NDATA=0
              ENDIF
              IBFLAG=IBITS(KKPDS(4),6,1)

		igcnt = igcnt + 1
C*
		DO ij = 1, ndata
		    vrel (ij) = data (ij)
		END DO
		havv = .true.
C*
	    ELSE IF ( ipds9 .eq. 71 .and. ipds10 .eq. 200 .and.
     +		 ipds11 .eq. 0 .and. ipds20 .eq. 0 .and.
     +		 .not. havcld ) THEN

              CALL W3FI63(CBUF,KKPDS,KKGDS,LBMS,DATA,KPTR,KRET)
              IF (KRET.EQ.0) THEN
                NDATA=KPTR(10)
              ELSE
                WRITE (STDOUT,*)' Cld Error decoding GRIB message = ',KRET
                NDATA=0
              ENDIF
              IBFLAG=IBITS(KKPDS(4),6,1)

		igcnt = igcnt + 1
C
C*		Write out cloud cover.
C
		kkpds (6) = 200
		CALL GENPDS (kkpds, ibflag, idout)
		CALL W3FI71 (kkpds(3),igds,ierr)
		DO ij = 1, ndata
		    dataot (ij) = data (ij)
		    IF ( dataot (ij) .gt. 100. )
     +			dataot (ij) = dataot (ij) - 100.
		END DO
		rpack = 0
                CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			     ndata,rpack,lunout,ierr)
		havcld = .true.
C*
	    ELSE IF ( ipds9 .eq. 61 .and. ipds10 .eq. 1 .and.
     +		 ipds11 .eq. 0 .and. .not. havp03 ) THEN

              CALL W3FI63(CBUF,KKPDS,KKGDS,LBMS,DATA,KPTR,KRET)
              IF (KRET.EQ.0) THEN
                NDATA=KPTR(10)
              ELSE
                WRITE (STDOUT,*)' Pcp Error decoding GRIB message = ',KRET
                NDATA=0
              ENDIF
              IBFLAG=IBITS(KKPDS(4),6,1)

		igcnt = igcnt + 1
C
C*		Write out precipitation.
C
		idt = kkpds (15) - kkpds (14)
		IF ( idt .gt. 0 .and. idtset .eq. 0 ) idtset = idt
		IF ( idtset .gt. 0 .and. idt .gt. idtset ) THEN
		    idt = idtset
		    DO ij = 1, ndata
			dataot (ij) = data (ij) - prcplast (ij)
		        prcplast (ij) = data (ij)
		    END DO
		    kkpds (14) = kkpds (15) - idt
		ELSE
		    DO ij = 1, ndata
			dataot (ij) = data (ij)
		        prcplast (ij) = data (ij)
		    END DO
		END IF
		CALL GENPDS (kkpds, ibflag, idout)
		CALL W3FI71 (kkpds(3),igds,ierr)
		rpack = 3.3
                CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			     ndata,rpack,lunout,ierr)
		havp03 = .true.
C
C*		Assign precip probability.
C
		DO ij = 1, ndata
		    IF ( data (ij) .lt. .01 ) THEN
			dataot (ij) = 0.0
		    ELSE 
			dataot (ij) = 100.
		    END IF
		END DO
		kkpds (5) = 193
		kkpds (22) = 0
		CALL GENPDS (kkpds, ibflag, idout)
		CALL W3FI71 (kkpds(3),igds,ierr)
		rpack = 0
                CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			     ndata,rpack,lunout,ierr)
C
C*		Store precip chance PDS.
C
		DO k = 1, 22
		    kcpds (k) = kkpds (k)
		END DO
		nprob = ndata
C*
	    ELSE IF ( ipds9 .eq. 65 .and. ipds10 .eq. 1 .and.
     +		 ipds11 .eq. 0 .and.
     +		 ( ipds20 .ne. 0 .or. ( ipds20 .eq. 0 .and. frst ) )
     +		 .and. .not. havsno ) THEN

              CALL W3FI63(CBUF,KKPDS,KKGDS,LBMS,DATA,KPTR,KRET)
              IF (KRET.EQ.0) THEN
                NDATA=KPTR(10)
              ELSE
                WRITE (STDOUT,*)' Error decoding GRIB message = ',KRET
                NDATA=0
              ENDIF
              IBFLAG=IBITS(KKPDS(4),6,1)

		igcnt = igcnt + 1
C
C*		Accumulate snow over smallest time interval available.
C
		idt = kkpds (15) - kkpds (14)
		IF ( idt .gt. 0 .and. idsset .eq. 0 ) idsset = idt
		IF ( idsset .gt. 0 .and. idt .gt. idsset ) THEN
		    idt = idsset
		    DO ij = 1, ndata
			dataot (ij) = data (ij) - snowlast (ij)
		        snowlast (ij) = data (ij)
		    END DO
		    kkpds (14) = kkpds (15) - idt
		ELSE IF ( .not. frst ) THEN
		    DO ij = 1, ndata
			dataot (ij) = data (ij)
		        snowlast (ij) = data (ij)
		    END DO
		ELSE
		    DO ij = 1, ndata
		        snowlast (ij) = 0.0
		    END DO
		END IF
C
C*		Convert snow water equivalent in mm to snow
C*		depth in meters.
C
		kkpds (5) = 66
		CALL GENPDS (kkpds, ibflag, idout)
		CALL W3FI71 (kkpds(3),igds,ierr)
		IF ( frst ) THEN
		    snofac = 0.0
		ELSE
		    snofac = 1/100.
		END IF
		DO ij = 1, ndata
		    dataot (ij) = dataot (ij) * snofac
		END DO
		rpack = 3.3
                CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			     ndata,rpack,lunout,ierr)
		havsno = .true.
		frst = .false.
C*
	    ELSE IF ( ipds9 .eq. 132 .and. .not. havli ) THEN

              CALL W3FI63(CBUF,KKPDS,KKGDS,LBMS,DATA,KPTR,KRET)
              IF (KRET.EQ.0) THEN
                NDATA=KPTR(10)
              ELSE
                WRITE (STDOUT,*)' Li Error decoding GRIB message = ',KRET
                NDATA=0
              ENDIF
              IBFLAG=IBITS(KKPDS(4),6,1)

		igcnt = igcnt + 1
C*
		DO ij = 1, ndata
		    rli (ij) = data (ij)
		END DO
		havli = .true.
		nc03 = ndata
C*
	    ELSE IF ( ipds9 .eq. 143 .and. ipds10 .eq. 1 .and.
     +		 ipds11 .eq. 0 .and. .not. havts ) THEN

              CALL W3FI63(CBUF,KKPDS,KKGDS,LBMS,DATA,KPTR,KRET)
              IF (KRET.EQ.0) THEN
                NDATA=KPTR(10)
              ELSE
                WRITE (STDOUT,*)' Ts Error decoding GRIB message = ',KRET
                NDATA=0
              ENDIF
              IBFLAG=IBITS(KKPDS(4),6,1)

		igcnt = igcnt + 1
C*
		DO ij = 1, ndata
		    wxts (ij) = data (ij)
		END DO
		havts = .true.
		nwx = ndata
C*
	    ELSE IF ( ipds9 .eq. 142 .and. ipds10 .eq. 1 .and.
     +		 ipds11 .eq. 0 .and. .not. havtp ) THEN

              CALL W3FI63(CBUF,KKPDS,KKGDS,LBMS,DATA,KPTR,KRET)
              IF (KRET.EQ.0) THEN
                NDATA=KPTR(10)
              ELSE
                WRITE (STDOUT,*)' Error decoding GRIB message = ',KRET
                NDATA=0
              ENDIF
              IBFLAG=IBITS(KKPDS(4),6,1)

		igcnt = igcnt + 1
C*
		DO ij = 1, ndata
		    wxtp (ij) = data (ij)
		END DO
		havtp = .true.
		nwx = ndata
C*
	    ELSE IF ( ipds9 .eq. 141 .and. ipds10 .eq. 1 .and.
     +		 ipds11 .eq. 0 .and. .not. havtz ) THEN

              CALL W3FI63(CBUF,KKPDS,KKGDS,LBMS,DATA,KPTR,KRET)
              IF (KRET.EQ.0) THEN
                NDATA=KPTR(10)
              ELSE
                WRITE (STDOUT,*)' Error decoding GRIB message = ',KRET
                NDATA=0
              ENDIF
              IBFLAG=IBITS(KKPDS(4),6,1)

		igcnt = igcnt + 1
C*
		DO ij = 1, ndata
		    wxtz (ij) = data (ij)
		END DO
		havtz = .true.
		nwx = ndata
C*
	    END IF
C
C*	    While still in the loop over grids, do the winds.
C
	    IF ( havu .and. havv .and. .not. havwnd ) THEN
		havwnd = .true.
C
C*		Compute wind speed.
C
		DO ij = 1, ndata
		    dataot (ij) = SQRT ( urel (ij) * urel (ij) +
     +				  vrel (ij) * vrel (ij) )
		END DO
C
C*		We should still have a wind PDS in KKPDS.
C
		kkpds (5) = 32
		CALL GENPDS ( kkpds, ibflag, idout)
		CALL W3FI71 (kkpds(3),igds,ierr)
		rpack = -2
                CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			     ndata,rpack,lunout,ierr)
C
C*		Do wind direction (need rotation).
C
		CALL GDSLLO ( kkgds, rlonc, cone, rlat, rlon, npts,
     +				ier )
		IF ( ier .ne. 0 ) THEN
		    WRITE (STDOUT,*) ' Return from GDSLLO = ', ier
		    WRITE (STDOUT,*) ' Wind speed not done.'
		ELSE IF ( npts .ne. ndata ) THEN
		    WRITE (STDOUT,*) ' Number of lat/lon points not',
     +				     ' equal to number of grid points.'
		    WRITE (STDOUT,*) ' Wind speed not done.'
		ELSE
		    DO ij = 1, ndata
C ER 3/2017: code expects rlonc to be negative west longitude     
		    	IF ( rlonc .gt. -999 ) THEN
                            rloncw=rlonc-360.0
		    	    dlam = ( rlon(ij) - rloncw ) * cone
		    	ELSE
			    dlam = 0.
		    	END IF
			IF ( urel (ij) .eq. 0.0 .and.
     +				vrel (ij) .eq. 0.0 ) THEN
			    angle = 0.0
			ELSE
		    	    angle = ATAN2 ( -urel(ij), -vrel(ij) ) * RTD
			END IF
		    	angle = angle + dlam
		    	IF ( angle .ge. 360. ) angle = angle - 360.
		    	IF ( angle .lt. 0. ) angle = angle + 360.
		    	dataot (ij) = angle
		    END DO
		    kkpds (5) = 31
		    CALL GENPDS ( kkpds, ibflag, idout)
		    CALL W3FI71 (kkpds(3),igds,ierr)
		    rpack = 0
                    CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			         ndata,rpack,lunout,
     +				 ierr)
		END IF
	    END IF
C
C*	    FIND NEXT GRIB
C
            ISEEK=LLSKIP+LLGRIB
            CALL SKGB(LUNGRB,ISEEK,MSEEK,LLSKIP,LLGRIB)
	END DO
C
C*	Use saved fields and PDS's to do the remaining grids.
C
	IF ( havtmp .and. havrh ) THEN
C
C*	    Generate the dewpoint temperature.
C
	    CALL PD_DWPT ( tmpk(1,jtlast), relh, ntmps, dataot, iret )
	    ktpds (5) = 17
	    CALL GENPDS ( ktpds, ibflag, idout)
	    CALL W3FI71 (ktpds(3),igds,ierr)
	    rpack = 3.3
            CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			 ntmps,rpack,lunout,ierr)
	ELSE
	    WRITE (STDOUT,*) ' Dewpoint temperature not done.'
	END IF
C*
	IF ( havli .and. nprob .eq. nc03 ) THEN
C
C*	    Generate the thunderstorm probability.
C
	    DO ij = 1, nc03
C
C*	  	Use linear fit to Jason Taylor's data.
C
		prob = -12.76 * rli (ij) + 29.33
		IF ( prob .gt. 100. ) prob = 100.
		IF ( prob .lt. 0.0 ) prob = 0.
		dataot (ij) = prob
	    END DO
	    kcpds (5) = 60
	    CALL GENPDS ( kcpds, ibflag, idout)
	    CALL W3FI71 (kcpds(3),igds,ierr)
	    rpack = 0
            CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			 nc03,rpack,lunout,ierr)
	ELSE
	    WRITE (STDOUT,*) ' T-storm probability not done.'
	END IF
C*
	IF ( havts .and. havtp ) THEN
C
C*	    Generate probability of frozen precip.
C
	    DO ij = 1, nwx
		IF ( wxts (ij) .eq. 1. .or. wxtp (ij) .eq. 1. ) THEN
		    dataot (ij) = 100.
		ELSE
		    dataot (ij) = 0.
		END IF
	    END DO
	    kcpds (5) = 194
	    CALL GENPDS ( kcpds, ibflag, idout)
	    CALL W3FI71 (kcpds(3),igds,ierr)
	    rpack = 0
            CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			 nwx,rpack,lunout,ierr)
	ELSE
	    WRITE (STDOUT,*) ' Frozen precip probability not done.'
	END IF
C*
	IF ( havtz ) THEN
C
C*	    Generate probability of freezing precip.
C
	    DO ij = 1, nwx
		IF ( wxtz (ij) .eq. 1. ) THEN
		    dataot (ij) = 100.
		ELSE
		    dataot (ij) = 0.
		END IF
	    END DO
	    kcpds (5) = 195
	    CALL GENPDS ( kcpds, ibflag, idout)
	    CALL W3FI71 (kcpds(3),igds,ierr)
	    rpack = 0
            CALL GRIBIT (dataot,idout,igds,ibflag,lbms,
     +			 nwx,rpack,lunout,ierr)
	ELSE
	    WRITE (STDOUT,*) ' Freezing precip probability not done.'
	END IF
C
C*	Check for existence of other output already done.
C
	IF ( .not. havcld ) THEN
	    WRITE (STDOUT,*) ' Cloud cover not done.'
	END IF
	IF ( .not. havp03 ) THEN
	    WRITE (STDOUT,*) ' Precip and its probability not done.'
	END IF
	IF ( .not. havsno ) THEN
	    WRITE (STDOUT,*) ' Snow cover not done.'
	END IF
	IF ( .not. havwnd ) THEN
	    WRITE (STDOUT,*) ' Winds are not available.'
	END IF

        CALL BACLOSE(LUNGRB,IRET)
        CALL BACLOSE(LUNOUT,IRET)
C
C   TRY NEXT INPUT FILE
C
      GOTO 10
C     
C     END OF PROGRAM
C     
9999    CALL W3TAGE('ETA_ICWF.F') 
C*
	STOP
      END
C*************************************************************
      SUBROUTINE GENPDS(KPDS,IBFLAG, ID)
      DIMENSION KPDS(22),ID(25)
C***********************************************************************
C     START GENPDS HERE.
C
C     SET ARRAY ID VALUES TO GENERATE GRIB1 PDS USING KPDS WHICH
C     COMES FROM W3FI63.
C    OUTPUT:
C        ID(1)  = NUMBER OF BYTES IN PRODUCT DEFINITION SECTION (PDS)
C        ID(2)  = PARAMETER TABLE VERSION NUMBER
C        ID(3)  = IDENTIFICATION OF ORIGINATING CENTER
C        ID(4)  = MODEL IDENTIFICATION (ALLOCATED BY ORIGINATING CENTER)
C        ID(5)  = GRID IDENTIFICATION
C        ID(6)  = 0 IF NO GDS SECTION, 1 IF GDS SECTION IS INCLUDED
C        ID(7)  = 0 IF NO BMS SECTION, 1 IF BMS SECTION IS INCLUDED
C        ID(8)  = INDICATOR OF PARAMETER AND UNITS (TABLE 2)
C        ID(9)  = INDICATOR OF TYPE OF LEVEL       (TABLE 3)
C        ID(10) = VALUE 1 OF LEVEL  (0 FOR 1-100,102,103,105,107
C              111,160   LEVEL IS IN ID WORD 11)
C        ID(11) = VALUE 2 OF LEVEL
C        ID(12) = YEAR OF CENTURY
C        ID(13) = MONTH OF YEAR
C        ID(14) = DAY OF MONTH
C        ID(15) = HOUR OF DAY
C        ID(16) = MINUTE OF HOUR   (IN MOST CASES SET TO 0)
C        ID(17) = FCST TIME UNIT
C        ID(18) = P1 PERIOD OF TIME
C        ID(19) = P2 PERIOD OF TIME
C        ID(20) = TIME RANGE INDICATOR
C        ID(21) = NUMBER INCLUDED IN AVERAGE
C        ID(22) = NUMBER MISSING FROM AVERAGES
C        ID(23) = CENTURY  (20, CHANGE TO 21 ON JAN. 1, 2001)
C        ID(24) = RESERVED - SET TO 0
C        ID(25) = SCALING POWER OF 10
C    INPUT:
C     KPDS     - ARRAY CONTAINING PDS ELEMENTS.  (EDITION 1)
C          (1)   - ID OF CENTER
C          (2)   - GENERATING PROCESS ID NUMBER
C          (3)   - GRID DEFINITION
C          (4)   - GDS/BMS FLAG (RIGHT ADJ COPY OF OCTET 8)
C          (5)   - INDICATOR OF PARAMETER
C          (6)   - TYPE OF LEVEL
C          (7)   - HEIGHT/PRESSURE , ETC OF LEVEL
C          (8)   - YEAR INCLUDING (CENTURY-1)
C          (9)   - MONTH OF YEAR
C          (10)  - DAY OF MONTH
C          (11)  - HOUR OF DAY
C          (12)  - MINUTE OF HOUR
C          (13)  - INDICATOR OF FORECAST TIME UNIT
C          (14)  - TIME RANGE 1
C          (15)  - TIME RANGE 2
C          (16)  - TIME RANGE FLAG
C          (17)  - NUMBER INCLUDED IN AVERAGE
C          (18)  - VERSION NR OF GRIB SPECIFICATION
C          (19)  - VERSION NR OF PARAMETER TABLE
C          (20)  - NR MISSING FROM AVERAGE/ACCUMULATION
C          (21)  - CENTURY OF REFERENCE TIME OF DATA
C          (22)  - UNITS DECIMAL SCALE FACTOR
C          (23)  - SUBCENTER NUMBER
C
      ID(01) = 28
      ID(02) = KPDS(19)
      ID(03) = KPDS(1)
CER     
CER  3/22/00 - E. ROGERS ADDED TEST TO HARDWIRE MODEL GENERATING
CER            NUMBER TO 89 FOR GRID 212 ICWF
CER
      IF(KPDS(3) .EQ. 212) THEN
        ID(04) = 89
      ELSE 
        ID(04) = KPDS(2)
      ENDIF
CER
      ID(05) = KPDS(3)
      ID(06) = 1
      ID(07) = ibflag
      ID(08) = KPDS(5)
      ID(09) = KPDS(6)
      ID(10) = 0
      ID(11) = KPDS(7)
      ID(12) = KPDS(8)
      ID(13) = KPDS(9)
      ID(14) = KPDS(10)
      ID(15) = KPDS(11)
      ID(16) = KPDS(12)
      ID(17) = KPDS(13)
      ID(18) = KPDS(14)
      ID(19) = KPDS(15)
      ID(20) = KPDS(16)
      ID(21) = KPDS(17)
      ID(22) = KPDS(20)
      ID(23) = KPDS(21)
      ID(24) = 0
      ID(25) = KPDS(22)
      RETURN
      END
      SUBROUTINE GRIBIT ( GRID, ID, IGDS, IBFLAG, LBMS, IJOUT, RPACK,
     +			  LUNOUT, IERR)
C     
C     GENERATE COMPLETE GRIB1 MESSAGE USING W3FI72.
C        ITYPE  = 0 SPECIFIES REAL DATA TO BE PACKED.
C        IGRD   = DUMMY ARRAY FOR INTEGER DATA.
C        IBITL  = NBIT TELLS W3FI72 TO PACK DATA USING NBIT BITS.
C        IPFLAG = 0 IS PDS INFORMATION IN USER ARRAY ID.
C                 1 IS PDS (GENERATED ABOVE BY W3FP12).
C        ID     = (DUMMY) ARRAY FOR USER DEFINED PDS.
C        IGFLAG = 0 TELLS W3FI72 TO MAKE GDS USING IGRID.
C                 1 IS GDS GENERATED BY USER IN ARRAY IGDS
C        IGRID  = GRIB1 GRID TYPE (TABLE B OF ON388).
C        IGDS   = ARRAY FOR USER DEFINED GDS.
C        ICOMP  = 0 FOR EARTH ORIENTED WINDS,
C                 1 FOR GRID ORIENTED WINDS.
C        IBFLAG = 1 TELLS W3FI72 TO MAKE BIT MAP FROM USER
C                 SUPPLIED DATA.
C	 LBMS   = LOGICAL BIT MAP (TRUE FOR DATA)
C        IBMAP  = ARRAY CONTAINING USER DEFINED BIT MAP.
C        IBLEN  = LENGTH OF ARRAY IBMAP.
C        IBDSFL = ARRAY CONTAINING TABLE 11 (ON388) FLAG INFORMATION.
C        NPTS   = LENGTH OF ARRAY GRID OR IGRD.  MUST AGREE WITH IBLEN.
C        RPACK  = # of sig digits or binary precision for FNDBIT
C     
C     INTIALIZE VARIABLES.
      PARAMETER (MNBIT=0,MXBIT=16,LENPDS=28,LENGDS=32)
      PARAMETER(IMX=800,JMX=600)
C     
C     DECLARE VARIABLES.
C     
      LOGICAL*1 LBMS (*)
      CHARACTER*1  KBUF(30+LENPDS+LENGDS+IMX*JMX*(MXBIT+2)/8)
      CHARACTER*28 PDS
      INTEGER IBDSFL(9),IBMAP(IMX*JMX)
      INTEGER IGRD(IMX*JMX),ID(25),IGDS(18)
      REAL GRID(IJOUT),GRIDOT(IMX*JMX)
C
      IBM  = IBFLAG
      IF ( IBM .eq. 1 ) THEN
  	DO ij = 1, ijout
	    IF ( lbms (ij) ) THEN
		ibmap (ij) = 1
	    ELSE
		ibmap (ij) = 0
	    END IF
	END DO
      END IF
      CALL GETBT(IBM,RPACK,IJOUT,IBMAP,GRID,GRIDOT,GMIN,GMAX,NBIT)
      ITYPE  = 0
      DO 5 K = 1,IJOUT
         IGRD(K) = 0
 5    CONTINUE
      IBITL  = MIN(NBIT,MXBIT)
C
      IPFLAG = 0
C
      IGFLAG = 1
      IBFLG = 0
      ICOMP  = 0
      IBLEN  = IJOUT
      DO 30 K = 1,9
         IBDSFL(K) = 0
 30   CONTINUE
      NPTS=IJOUT
C     
      CALL W3FI72(ITYPE,GRIDOT,IGRD,IBITL,
     X            IPFLAG,ID,PDS,
     X            IGFLAG,IGRID,IGDS,ICOMP,
     X            IBFLG,IBMAP,IBLEN,
     X            IBDSFL,
     X            NPTS,KBUF,ITOT,IER)
C     
C     
C     WRITE GRIB1 MESSAGE TO OUTPUT FILE.
      CALL WRYTE(LUNOUT,ITOT,KBUF)
      RETURN
      END
C-----------------------------------------------------------------------
CFPP$ NOCONCUR R
      SUBROUTINE GETBT(IBM,RPC,LEN,MG,G,GROUND,GMIN,GMAX,NBIT)
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C
C SUBPROGRAM:    GETBT      COMPUTE NUMBER OF BITS AND ROUND FIELD.
C   PRGMMR: IREDELL          ORG: W/NMC23    DATE: 92-10-31
C
C ABSTRACT: THE NUMBER OF BITS REQUIRED TO PACK A GIVEN FIELD
C   AT A PARTICULAR DECIMAL SCALING IS COMPUTED USING THE FIELD RANGE.
C   THE FIELD IS ROUNDED OFF TO THE DECIMAL SCALING FOR PACKING.
C   THE MINIMUM AND MAXIMUM ROUNDED FIELD VALUES ARE ALSO RETURNED.
C   GRIB BITMAP MASKING FOR VALID DATA IS OPTIONALLY USED.
C
C PROGRAM HISTORY LOG:
C   92-10-31  IREDELL
C
C USAGE:    CALL GETBT(IBM,IDS,LEN,MG,G,GMIN,GMAX,NBIT)
C   INPUT ARGUMENT LIST:
C     IBM      - INTEGER BITMAP FLAG (=0 FOR NO BITMAP)
C     RPC      - # of sig digits or binary precision for FNDBIT
C     LEN      - INTEGER LENGTH OF THE FIELD AND BITMAP
C     MG       - INTEGER (LEN) BITMAP IF IBM=1 (0 TO SKIP, 1 TO KEEP)
C     G        - REAL (LEN) FIELD
C
C   OUTPUT ARGUMENT LIST:
C     GROUND   - REAL (LEN) FIELD ROUNDED TO DECIMAL SCALING
C     GMIN     - REAL MINIMUM VALID ROUNDED FIELD VALUE
C     GMAX     - REAL MAXIMUM VALID ROUNDED FIELD VALUE
C     NBIT     - INTEGER NUMBER OF BITS TO PACK
C
C SUBPROGRAMS CALLED:
C   ISRCHNE  - FIND FIRST VALUE IN AN ARRAY NOT EQUAL TO TARGET VALUE
C
C ATTRIBUTES:
C   LANGUAGE: CRAY FORTRAN
C
C$$$
      DIMENSION MG(LEN),G(LEN),GROUND(LEN)
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C  ROUND FIELD AND DETERMINE EXTREMES WHERE BITMAP IS ON
CCCCCC      DS=10.**IDS
      IF(IBM.EQ.0) THEN
CCCCCC        GROUND(1)=NINT(G(1)*DS)/DS
        GROUND(1)=G(1)
        GMAX=GROUND(1)
        GMIN=GROUND(1)
	imin = 1
        DO I=2,LEN
CCCCCC          GROUND(I)=NINT(G(I)*DS)/DS
          GROUND(I)=G(I)
          GMAX=MAX(GMAX,GROUND(I))
	  GMIN0 = GMIN
          GMIN=MIN(GMIN,GROUND(I))
	  IF ( GMIN0 .ne. GMIN ) imin = i
        ENDDO
      ELSE
        I1=ISRCHNE(LEN,MG,1,0)
        IF(I1.GT.0.AND.I1.LE.LEN) THEN
CCCCCC          GROUND(I1)=NINT(G(I1)*DS)/DS
          GROUND(I1)=G(I1)
          GMAX=GROUND(I1)
          GMIN=GROUND(I1)
	  imin = i1
          DO I=I1+1,LEN
            IF(MG(I).NE.0) THEN
CCCCCC              GROUND(I)=NINT(G(I)*DS)/DS
              GROUND(I)=G(I)
              GMAX=MAX(GMAX,GROUND(I))
	      GMIN0 = GMIN
              GMIN=MIN(GMIN,GROUND(I))
	      IF ( GMIN0 .ne. GMIN ) imin = i
            ENDIF
          ENDDO
        ELSE
          GMAX=0.
          GMIN=0.
	  imin = 1
        ENDIF
      ENDIF
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C  COMPUTE NUMBER OF BITS
C****      NBIT=LOG((GMAX-GMIN)*DS+0.9)/LOG(2.)+1.
	CALL FNDBIT ( gmin, gmax, rpc, nbit, iscale, rmn, ier )
	GROUND (imin) = rmn
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      RETURN
      END
	SUBROUTINE FNDBIT  ( rmin, rmax, rdb, nmbts, iscale, rmn, iret )
C***********************************************************************
C* FNDBIT								*
C*									*
C* This subroutine computes the number of packing bits given the	*
C* maximum number (< 50) of significant digits to preserve or the	*
C* binary precision to store the data.  The binary precision is given	*
C* as zero, a negative integer, or as a postitive integer greater than	*
C* or equal to 50.  If the binary precision is given, ISCALE will	*
C* always be zero in this case.						*
C*									*
C* The binary precision translates as follows:				*
C*     53  =>  store data to nearest 8					*
C*     52  =>  store data to nearest 4					*
C*     51  =>  store data to nearest 2					*
C*     50  =>  store data to nearest 1					*
C*      0  =>  store data to nearest 1					*
C*     -1  =>  store data to nearest 1/2				*
C*     -2  =>  store data to nearest 1/4				*
C*     -3  =>  store data to nearest 1/8				*
C*									*
C* Note that RDB - 50 give the nearest whole power of two for binary	*
C* precision.								*
C*									*
C* Note that a fractional number of significant digits is allowed.	*
C*									*
C* FNDBIT ( RMIN, RMAX, RDB, NBITS, ISCALE, RMN, IRET )			*
C*									*
C* Input parameters:							*
C*	RMIN 		REAL		Minimum value			*
C*	RMAX		REAL		Maximum value			*
C*	RDB		REAL		Maximum # of significant digits	*
C*					  OR binary precision if < 0	*
C*									*
C* Output parameters:							*
C*	NBITS		INTEGER		Number of bits for packing	*
C*	ISCALE		INTEGER		Power of 10 scaling to use	*
C*	RMN		REAL		Rounded miniumum		*
C*	IRET		INTEGER		Return code			*
C*					  0 = normal return		*
C**									*
C* Log:									*
C* K. Brill/NMC		06/92						*
C* K. Brill/EMC		12/95	Added binary precision; added RMN	*
C***********************************************************************
C*
	DATA		rln2/0.69314718/
C-----------------------------------------------------------------------
	iret = 0
	icnt = 0
	iscale = 0
	rmn = rmin
	range = rmax - rmin
	IF ( range .le. 0.00 ) THEN
	    nmbts = 8
	    RETURN
	END IF
C*
	IF ( rdb .gt. 0.0 .and. rdb .lt. 50. ) THEN
	    po = FLOAT ( INT ( ALOG10 ( range ) ) )
	    IF ( range .lt. 1.00 ) po = po - 1.
	    po = po - rdb + 1.
	    iscale = - INT ( po )
	    rr = range * 10. ** ( -po )
	    nmbts = INT ( ALOG ( rr ) / rln2 ) + 1
	ELSE
	    ibin = NINT ( -rdb )
	    IF ( ibin .le. -50. ) ibin = ibin + 50
	    rng2 = range * 2. ** ibin
	    nmbts = INT ( ALOG ( rng2 ) / rln2 ) + 1
	END IF
	IF ( nmbts .le. 0 ) THEN
	    iret = 1
	    nmbts = 8
	END IF
C
C*	Compute RMN, the first packable value less than or equal to
C*	RMIN.
C
	x = ( ALOG ( range ) - ALOG ( 2 ** nmbts - 1. ) ) / rln2
	ixp = INT ( x )
	IF ( FLOAT ( ixp ) .ne. x .and. x .gt. 0. ) ixp = ixp + 1
	irmn = NINT ( rmin / ( 2. ** ixp ) )
	rmn = FLOAT ( irmn ) * ( 2. ** ixp )
	IF ( rmn .gt. rmin ) rmn = rmn - ( 2. ** ixp )
C*
	RETURN
	END
	SUBROUTINE PD_DWPT  ( tmpk, relh, npt, dwpk, iret )
C***********************************************************************
C* PD_DWPT								*
C*									*
C* This subroutine computes DWPK from MIXR and RELH.  The following	*
C* equation derive from Teton's formula is used:			*
C*									*
C*   DWPK = C * B / ( 1 - C )						*
C*									*
C*        B = 243.5							*
C*        C = (1/A) * ln (RELH) + TMPC / ( TMPC + B )			*
C*        A = 17.67							*
C*     TMPC = TMPK - 273.16
C*									*
C* PD_DWPT  ( TMPK, RELH, NPT, DWPK, IRET )				*
C*									*
C* Input parameters:							*
C*	TMPK (NPT)	REAL		Temperature (K)			*
C*	RELH (NPT)	REAL   		Relative humidity		*
C*	NPT		INTEGER		Number of points		*
C*									*
C* Output parameters:							*
C*	DWPK (NPT)	REAL   		Dewpoint temperature (K)	*
C*	IRET		INTEGER		Return code			*
C*					  0 = normal return		*
C**									*
C* Log:									*
C* K. Brill								*
C***********************************************************************
	REAL		tmpk (*), relh (*), dwpk (*)
	PARAMETER	(A = 17.67, B = 243.5 )
C*
C-----------------------------------------------------------------------
	iret = 0
C
C*	Loop through all the points.
C
	DO  i = 1, npt
	    IF ( relh (i) .le. 0.0 ) THEN
		rh = .001
	    ELSE
		rh = relh (i) / 100.
	    END IF
	    tmpc = tmpk (i) - 273.16
	    C = ALOG ( rh ) / A + tmpc / ( tmpc + B )
	    dwpc = C * B / ( 1. - C )
	    dwpk (i) = dwpc + 273.16
	END DO
C*
	RETURN
	END
	SUBROUTINE ST_LSTR  ( string, lens, iret )
C***********************************************************************
C* ST_LSTR								*
C*									*
C* This subroutine returns the number of characters in a string 	*
C* disregarding trailing null characters, tabs and spaces.		*
C*									*
C* ST_LSTR  ( STRING, LENS, IRET )					*
C*									*
C* Input parameters:							*
C*	STRING		CHAR*		String 				*
C*									*
C* Output parameters:							*
C*	LENS		INTEGER 	Length of string		*
C*	IRET		INTEGER		Return code			*
C*				 	 0 = normal return 		*
C**									*
C* Log:									*
C* J. Woytek/GSFC	 6/82 	STR_LNSTR				*
C* I. Graffman/RDS	 2/84 	Fix zero length string handling		*
C* M. desJardins/GSFC	 6/88	Rewritten				*
C* K. Brill/NMC		 1/94	Make free from GEMPAK include		*
C***********************************************************************
	CHARACTER*1	CHSPAC, CHTAB, CHNULL
C*
	CHARACTER*(*)	string
C*
	CHARACTER*1	c
C*----------------------------------------------------------------------
	CHNULL = CHAR (0)
	CHSPAC = CHAR (32)
	CHTAB  = CHAR (9)
	lens = 0
	iret = 0
C
C*	Get the actual length of the string.
C
	lens = LEN  ( string )
	IF  ( lens .eq. 0 )  RETURN
C
C*	Start at last character and loop backwards.
C
	ip = lens
	DO WHILE  ( ip .gt. 0 )
C
C*	    Get current value of string and check for space, null, tab.
c
	    c = string ( ip : ip )
	    IF  ( ( c .eq. CHSPAC ) .or. ( c .eq. CHNULL ) .or.
     +		  ( c .eq. CHTAB  ) )  THEN
		lens = lens - 1
		ip   = ip - 1
	      ELSE
		ip   = 0
	    END IF
	END DO
C*
	RETURN
	END
	SUBROUTINE GDSLLO ( kgds, rlonc, ccone, alat, alon, npts, iret )
C***********************************************************************
C* GDSLLO								*
C*									*
C* This subroutine returns the LAT/LON of the grid points on a grid	*
C* defined by the input GRIB GDS.  Cylindrical Equidistant, Mercator,	*
C* Polar Stereographic, and Lambert Conic Conformal projections are	*
C* are supported. 							*
C*									*
C* If the center longitude is irrelevant its return value is -9999.	*
C*									*
C* Only scanning mode 010 is currently supported.  That is a grid	*
C* with (1,1) at the lower left with the first subscript increasing	*
C* with increasing x to the right.					*
C*									*
C* IMPORTANT:  All angles are returned as degrees.  West longitude is	*
C*	       negative.						*
C*									*
C* GDSLLO  ( KGDS, RLONC, CCONE, ALAT, ALON, NPTS, IRET )		*
C*									*
C* Input parameters:							*
C*	KGDS (*)	INTEGER		GDS values from W3FI63		*
C*									*
C* Output parameters:							*
C*	RLONC		REAL		Center longitude		*
C*	CCONE		REAL		Cone constant			*
C*	ALAT (NPTS)	REAL		Latitude values on grid		*
C*	ALON (NPTS)	REAL		Longitude values on grid	*
C*	NPTS		INTEGER		Number of grid points		*
C*	IRET		INTEGER		Return code			*
C*				 	 0 = normal return 		*
C*					-1 = invalid grid config	*
C*					-2 = dx != dy			*
C*					-3 = invalid projection		*
C*					-4 = Lambert not tangent proj	*
C**									*
C* Log:									*
C* K. Brill/NMC		 6/95						*
C***********************************************************************
	REAL		alat (*), alon (*)
	INTEGER		kgds (*)
C*
	INTEGER		ibits (8)
C*----------------------------------------------------------------------
	iret = 0
	ccone = 1.
C*
	iscan = kgds (11)
	CALL GB_BITI  ( iscan, ibits, iret )
	IF ( .not. ( ibits (1) .eq. 0 .and. ibits (2) .eq. 1 .and.
     +		     ibits (3) .eq. 0 ) ) THEN
	    iret = -1
	    RETURN
	END IF
C*	
	itype = kgds (1)
	ni = kgds (2)
	nj = kgds (3)
	npts = ni * nj
	rltll = FLOAT ( kgds (4) ) / 1000.
	rlnll = FLOAT ( kgds (5) ) / 1000.
C*
	IF ( itype .eq. 0 ) THEN
C
C*	    The grid is a lat/lon grid.
C
	    rlonc = -9999
	    rltur = FLOAT ( kgds (7) ) / 1000.
	    rlnur = FLOAT ( kgds (8) ) / 1000.
	    dphi = rltur - rltll
	    dlam = rlnur - rlnll
	    di = ni - 1
	    dj = nj - 1
	    ind = 0
	    DO j = 1, nj
		DO i = 1, ni
		    ind = ind + 1
		    alat (ind) = rltll + dphi * (j-1) / dj
		    alon (ind) = rlnll + dlam * (i-1) / di
		END DO
	    END DO 
	ELSE IF ( itype .eq. 1 ) THEN
C
C*	    The grid is a mercator projection.
C
	    IF ( kgds (13) .ne. kgds (12) ) THEN
		iret = -2
		RETURN
	    END IF
	    rlonc = -9999
	    alatin = FLOAT ( kgds (9) ) / 1000.
	    dx = FLOAT ( kgds (12) )
	    ind = 0
	    DO j = 1, nj
		DO i = 1, ni
		    ind = ind + 1
		    xi = i
		    xj = j
		    CALL W3FB09 ( xi, xj, rltll, rlnll, alatin, dx,
     +				  alat (ind), alon (ind) )
		END DO
	    END DO
	ELSE IF ( itype .eq. 3 ) THEN
C
C*	    The grid is a Lambert Conformal projection.
C
	    IF ( kgds (8) .ne. kgds (9) ) THEN
		iret = -2
		RETURN
	    END IF
	    IF ( kgds (12) .ne. kgds (13) ) THEN
		iret = -4
		RETURN
	    END IF
	    rlonc = FLOAT ( kgds (7) ) / 1000.
	    dx = FLOAT ( kgds (8) )
	    alatin = FLOAT ( kgds (12) ) / 1000.
	    ccone = SIN ( alatin * 3.14159 / 180. )
	    ind = 0
	    DO j = 1, nj
		DO i = 1, ni
		    ind = ind + 1
		    xi = i
		    xj = j
		    CALL W3FB12 ( xi, xj, rltll, rlnll, dx, rlonc,
     +				  alatin, alat (ind), alon (ind),
     +				  ierr )
		END DO
	    END DO
	ELSE IF ( itype .eq. 5 ) THEN
C
C*	    The grid is a Polar Stereographic projection.
C
	    IF ( kgds (8) .ne. kgds (9) ) THEN
		iret = -2
		RETURN
	    END IF
	    rlonc = FLOAT ( kgds (7) ) / 1000.
	    dx = FLOAT ( kgds (8) )
	    ind = 0
	    DO j = 1, nj
		DO i = 1, ni
		    ind = ind + 1
		    xi = i
		    xj = j
		    CALL W3FB07 ( xi, xj, rltll, rlnll, dx, rlonc,
     +				  alat (ind), alon (ind) )
		END DO
	    END DO
	
	ELSE
	    iret = -3
	    RETURN
	END IF
C
C*	Convert longitudes to negative west.
C
	DO ij = 1, npts
	    IF ( alon (ij) .gt. 180. ) alon (ij) = alon (ij) - 360.
	END DO
C*
	RETURN
	END
	SUBROUTINE GB_BITI  ( i4byt1, ibits, iret )
C***********************************************************************
C* GB_BITI								*
C*									*
C* This subroutine returns the value (1 or 0) of each of the 8 least	*
C* significant bits (1 byte) in I4BYT1.	 The value of the most		*
C* significant bit is in IBITS (1), the least significant in (8).	*
C*									*
C* GB_BITI  ( i4byt1, ibits, iret )					*
C*									*
C* Input parameters:							*
C*	I4BYT1		INTEGER		Input integer 			*
C*									*
C* Output parameters:							*
C*	IBITS (8)	INTEGER		Array of values of bits		*
C* 	IRET		INTEGER		Return code			*
C*					  0 = normal return		*
C**									*
C* Log:									*
C* K. Brill/NMC		 5/91						*
C***********************************************************************
	INTEGER		ibits (*)
C*
C-----------------------------------------------------------------------
	iret = 0
C*
	itemp = 255
	itemp = IAND ( itemp, i4byt1 )
C*
	ipwr2 = 1
	DO i = 1, 8
	    index = 8 - i + 1
	    ibits (index) = IAND ( itemp, ipwr2 )
	    IF ( ibits (index) .ne. 0 ) ibits (index) = 1
	    ipwr2 = ipwr2 * 2
	END DO
C*
	RETURN
C*
	END
	SUBROUTINE CHK ( a, im, jm, is )
C***********************************************************************
C*  This subroutine prints out a column of a grid.			*
C*									*
C*  CHK ( A, IM, JM, IS )						*
C*									*
C*  Input parameters:							*
C*	A (IM,JM)	REAL		Grid data			*
C*	IM		INTEGER		Grid i dimension		*
C*	JM		INTEGER		Grid j dimension		*
C*	IS		INTEGER		Column (j) value to print	*
C***********************************************************************
	REAL 		a (im,jm)
C-----------------------------------------------------------------------
	write (6,*) ' Values in column ', is
	write (6,*) ( a (is,jj), jj=1,jm)
C*
	RETURN
	END
