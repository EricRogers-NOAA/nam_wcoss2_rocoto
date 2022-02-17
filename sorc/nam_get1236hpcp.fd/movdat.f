      subroutine MOVDAT(IDATE1,IDATE2,IHOUR)
C
C Subroutine to increment a 10-digit date (yyyymmddhh) by 'IHOUR' hours.
C Based on cray3: /nwprod/util/sorc/ndate.fd/ndate.f
C Y. Lin, 1999/4/13 on cray3
C         1999/11/10 on the SP
C
C Input variable:    IDATE1 (yyyymmddhh)
C                    IHOUR  
C Output variable:   IDATE2 (yyyymmddhh)
C
C To compile a main program (test.f) calling movdat.f:
C   xlf test.f /emcsrc3/wx22yl/utils/subs/movdat.f /nwprod/w3lib90/w3lib_4_604 
C
      INTEGER IDAT(8),JDAT(8)
      REAL RINC(5)
      CHARACTER*10 CDATE
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
      RINC=0
      RINC(2)=IHOUR
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      WRITE(CDATE,'(I10.10)') IDATE1
      IDAT=0
      READ(CDATE,'(i4,3i2)') IDAT(1),IDAT(2),IDAT(3),IDAT(5)
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C  COMPUTE AND PRINT NEW DATE
      CALL W3MOVDAT(RINC,IDAT,JDAT)
      WRITE(CDATE,'(I4.4,3I2.2)') JDAT(1),JDAT(2),JDAT(3),JDAT(5)
      READ(CDATE,'(I10)') IDATE2
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      END
