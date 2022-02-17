      PROGRAM WRFBUFR
C$$$  MAIN PROGRAM DOCUMENTATION BLOCK
C                .      .    .     
C MAIN PROGRAM: WRFBUFR
C   PRGMMR: PYLE             ORG: EMC/MMB    DATE: 2004-11-25
C     
C ABSTRACT:  
C     THIS PROGRAM DRIVES THE EXTERNAL WRF BUFR POST PROCESSOR.
C     
C PROGRAM HISTORY LOG (FOR THE PROF CODE):
C   99-04-22  T BLACK - ORIGINATOR
C   02-07-01  G MANIKIN - FIXED PROBLEM WITH DHCNVC AND DHRAIN
C                          COMPUTATIONS - SEE COMMENTS BELOW
C   03-04-01  M PYLE - BEGAN CONVERTING FOR WRF
C   04-05-26  M PYLE - MADE CHANGES FOR WRF-NMM
C   04-11-24  M PYLE - ELIMINATED USE OF PARMETA FILE, DIMENSIONS
C                      NOW READ IN FROM WRF OUTPUT FILE, WITH WORKING
C                      ARRAYS ALLOCATED TO NEEDED DIMENSIONS.  UNIFIED
C                      WRF-EM AND WRF-NMM VERSIONS INTO A SINGLE CODE
C                      THAT READS EITHER NETCDF OR BINARY OUTPUT FROM
C                      THE WRF MODEL.
C   05-08-29  M PYLE - ELIMINATE THE NEED TO RETAIN ALL WRF HISTORY FILES.
C   10-04-26  ROGERS - CHANGE ITAG and INCR to MINUTES FOR NMMB
C                      
C     
C USAGE:    WRFPOST
C   INPUT ARGUMENT LIST:
C     NONE     
C
C   OUTPUT ARGUMENT LIST: 
C     NONE
C     
C   SUBPROGRAMS CALLED:
C     UTILITIES:
C       NONE
C     LIBRARY:
C       COMMON - CTLBLK
C                RQSTFLD
C     
C   ATTRIBUTES:
C     LANGUAGE: FORTRAN 90
C     MACHINE : IBM RS/6000 SP
C$$$  
C
C
C
C     INCLUDE ARRAY DIMENSIONS.
C      INCLUDE "parmeta"
C      INCLUDE "mpif.h"
C
C     DECLARE VARIABLES.
C     
C     INCLUDE COMMON BLOCKS.
!tst      INCLUDE "CTLBLK.comm"
C     
C     SET HEADER WRITER FLAGS TO TRUE.
C
      real rinc(5)
      integer jdate(8),idate(8)
          integer iii
      character(len=6) :: IOFORM,model
      character(len=256) :: newname
!rv   character(len=108) :: fileName
      character(len=256) :: fileName
      character(len=19) :: DateStr
      character(len=3) :: ITAGLAB
      character(len=2) :: IMINLAB
      character(len=2):: hrpiece
      character(len=8):: minpiece
      integer :: DataHandle

 
      DATA hrpiece /'h_'/
      DATA minpiece /'m_00.00s'/
C
C**************************************************************************
C
C     START PROGRAM WRFBUFR.
C
	write(6,*) 'to read statements'
       read(5,111) fileName
	write(6,*) 'filename= ', filename
       read(5,113) model
	write(6,*) 'model type= ', model
       read(5,113) IOFORM
	write(6,*) 'ioform= ', ioform
       read(5,112) DateStr
	write(6,*) 'datestr= ', datestr
       read(5,*) NFILES
       read(5,*) INCR
       read(5,*) IMINTOT

!!!! CHANGE THIS ASSUMPTION???

! assume for now that the first date in the stdin file is the start date

       read(DateStr,300) iyear,imn,iday,ihrst

      write(*,*) 'in WRFBUFR iyear,imn,iday,ihrst',iyear,imn,iday,ihrst
 300  format(i4,1x,i2,1x,i2,1x,i2)
	
	IDATE=0

         IDATE(2)=imn
         IDATE(3)=iday
         IDATE(1)=iyear
         IDATE(5)=ihrst

!rv  111  format(a98)
 111  format(a256)
 112  format(a19)
 113  format(a6)
C
	do N=1,NFILES

	len=index(filename,' ')-1

!	add forecast hour/minutes to start time
 
        if (MOD(IMINTOT,60).EQ.0) THEN
          IHR=IMINTOT/60
          IMIN=0
        else
          IHR=IMINTOT/60
          IMIN=MOD(IMINTOT,60)
        endif
	
	RINC(1)=0.
	RINC(2)=float(IHR)
	RINC(3)=float(IMIN)
	RINC(4)=0.
	RINC(5)=0.

	call w3movdat(rinc,idate,jdate)

	if (model(1:4) .eq. 'NCEP') then
	write(DateStr,302) JDATE(1),JDATE(2),JDATE(3),JDATE(5)
	elseif (model(1:4) .eq. 'NCAR') then
	write(DateStr,302) JDATE(1),JDATE(2),JDATE(3),JDATE(5)
	endif

	write(ITAGLAB,303) IHR
  303	format(I3.3)
	write(IMINLAB,304) IMIN
  304	format(I2.2)

	if (model(1:4) .ne. 'NMMB') then
	filename=filename(1:len-19)//DateStr
        else
c       filename=filename(1:len-3)//ITAGLAB
        filename=filename(1:len-15)//ITAGLAB//hrpiece//IMINLAB//minpiece
	write(0,*) 'filename: ', filename
	endif

 301  format(i4,'-',i2.2,'-',i2.2,'T',i2.2,':00:00')
 302  format(i4,'-',i2.2,'-',i2.2,'_',i2.2,':00:00')

	write(6,*) 'calling prof.... '
	write(6,*) 'datestr: ', datestr
	write(6,*) 'fileName ', fileName
	write(6,*) 'IHR: ', IHR
	write(6,*) '--------------------------------'

	
c       if (ioform(1:6) .eq. 'binary') then 
c       if (model(1:4) .eq. 'NCEP') then
c       CALL PROF_NMM(fileName,DateStr,IHR,INCR)
c       elseif (model(1:4) .eq. 'NCAR') then
c       write(6,*) 'call PROF_EM...filename, datestr:: ', filename, datestr
c       CALL PROF_EM(fileName,DateStr,IHR,INCR)
c       endif
c       endif

c       if (ioform(1:6) .eq. 'netcdf') then 
c       if (model(1:4) .eq. 'NCEP') then
c       CALL PROF_NMM_NET(fileName,DateStr,IHR,INCR)
c       elseif (model(1:4) .eq. 'NCAR') then
c       CALL PROF_EM_NET(fileName,DateStr,IHR,INCR)
c       endif
c       endif

	if (ioform(1:6) .eq. 'nemsio') then 
	write(0,*) 'call PROF_NMMB'
        CALL PROF_NMMB(fileName,IMINTOT,INCR)
	endif

        write(6,*) 'back from prof', N
	END DO

      STOP
      END
