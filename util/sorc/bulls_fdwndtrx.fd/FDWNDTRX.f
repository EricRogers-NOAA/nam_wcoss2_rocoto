      PROGRAM FDWNDTRX
C$$$  MAIN PROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C MAIN PROGRAM: BULLS_FDWNDTRX
C   PRGMMR: VUONG            ORG: NP11        DATE: 2007-02-02
C
C ABSTRACT:  THIS PROGRAM CREATES BULLETINS OF FORECAST WINDS AND
C   TEMPS FOR UP TO 11 LEVELS FOR U.S.AND CANADA. THE PRIMARY (RMP)
C   IS RUN.
C     THE O/P IS BULLETINS FDUE1-6, FDUM1-6, FDUW1-6,
C   EACH BULTN OF A SET REPRESENTS A  6, 12 OR 24 HR FCST.
C   EACH ODD-EVEN PAIR COVERS A GEOGRAPHICAL AREA OF THE U.S.
C     ALSO GENERATED ARE THE FOLLOWING BULLETINS;
C         FDUS11-16       FDUC8-10
C         FDAK01-03       FDCN01-03         FDCN40-42
C     THE STATION FILE (FDWND.STNLIST) IS KEYED TO INDICATE WHICH BULLETIN
C   EACH STATION BELONGS IN.  WIND SPEED, WIND DIRECTION & TEMPERATURE
C   FOR EACH STATION APPEAR IN THE BULLETIN, ALL LEVELS APPEAR IN
C   EACH BULLETIN.
C     THE FORECAST INPUT DATA IS NAM MODEL OPERATIONAL GRIB GRID 221 
C   FORECAST FILES U,V,& T FIELDS, 11 LEVELS (3,6,9,12000' + 500-100MB).
C
C     THE INPUT STATION RECORD FOR EACH STATION CONTAINS STN ELEVATION
C   AND LATITUDE/LONGITUDE POSITION.
C
C PROGRAM HISTORY LOG:
C   86-01-03  CAVANAUGH
C   87-12-07  CAVANAUGH   XDAM TO VSAM FOR RGL FORECAST FILES
C   88-02-02  FARLEY      XDAM TO VSAM FOR ERL/AVN FORECAST FILES
C   88-05-04  CAVANAUGH   CHANGE TO READ PROD TIME FROM FT90F001
C   89-06-01  CAVANAUGH   INCREASED NR OF MAXSTNS
C                         MODIFIED TO ALLOW FOR 4 LETTER IDENTIFIERS
C   96-07-11  R.E.JONES   CONVERT TO RUN ON CRAY WITH GRIB INPUT FILES
C   96-12-11  JOHNSON     CORRECTED SIGN FOR POSITIVE TEMPS (2B TO 7C).
C                         OSO NEEDS SIGN TO BE A 4F (SOLID BAR).
C   97-06-11  G. DIMEGO   CONVERT TO RUN OFF EARLY NAM GRIB INPUT FILES
C                         USING GRID #104 SUPER-C GRID
C   98-04-29  VUONG       REPLACED W3FS11, W3FS13, W3FS15 WITH CALLS TO
C                         W3MOVDAT AND REMOVED W3LOG
C   98-08-28  J.A.ATOR    REWORKED LOGIC TO REPLACE GOTOS WITH IF-THEN-ELSE
C   98-08-31  GILBERT     REMOVED DATE CHECK AT THE BEGINNING OF PROGRAM
C   98-09-16  VUONG       CONVERT TO RUN ON GRIB INPUT FILES: GRID TYPE 6
C                         (LFM FORCAST) OR GRID TYPE 104 (NGM SUPER C GRID)
C   99-12-16  VUONG       CONVERTED TO RUN ON THE IBM SP AND REPLACED
C                         GETGB1 WITH CALLS TO GETGB AND GETGBP
C   00-04-14  VUONG       CHANGE THE TIME ON THE BULLETIN HEADER TO THE 
C                         TIME OF THE BULLETIN IS MADE
C   01-05-15  VUONG       MODIFIED THE PROGRAM TO RUN ON THE NAM
C                         FORECAST MODEL DATA FROM THE GRIB GRID 221 FILES.
C                         THE PROGRAM WAS SETUP TO RUN IN THE TWO CYCLES
C                         T00Z AND T12Z. 
C   03-05-12  VUONG       CORRECTED THE INPUT ARGUMENTS PASS TO THE SUBROUTINE 
C                         W3MOCDAT 
C   06-11-27  VUONG       MODIFIED THE PROGRAM TO USE LINEAR INTERPOLATION
C   07-06-28  VUONG       CHANGED WMO HEADER FDUS8,FDUS9,FDAK1,FDAK2,FDCN1,
C                         FDCN2 AND FDCN3 TO FDUS08,FDUS09,FDAK01,FDAK02,
C                         FDCN01,FDCN02 AND FDCN03
C   12-11-05  VUONG       MODIFIED VARIABLES NNPOS AND CHANGED
C                         VARIABLE ENVVAR TO CHARACTER*6
C USAGE:
C   INPUT FILES:
C    FORT.05   BULLS_FDWND.STNLIST     STATION DIRECTORY
C    FORT.49   /COM/DATE/TXXZ          TIME/TYPE LAST RUN
C
C    - NAM GRIB GRID TYPE 221 (LAMBERT CONFORMAL):
C      AWIPS GRID TYPE 221 DIMENSIONS 349 x 277 = 96673
C    FORT.11    /COM/NAM/PROD/NAM.${PDY}/NAM.${CYCLE}.AWIP3206.TM00
C    FORT.12    /COM/NAM/PROD/NAM.${PDY}/NAM.${CYCLE}.AWIP3212.TM00
C    FORT.13    /COM/NAM/PROD/NAM.${PDY}/NAM.${CYCLE}.AWIP3224.TM00
C    - NAM INDEX FILES FOR GRIB GRID 221:
C    FORT.31    /COM/NAM/PROD/NAM.${PDY}/NAM.${CYCLE}.AWIP32I06
C    FORT.32    /COM/NAM/PROD/NAM.${PDY}/NAM.${CYCLE}.AWIP32I12
C    FORT.33    /COM/NAM/PROD/NAM.${PDY}/NAM.${CYCLE}.AWIP32I24
C
C    WHERE PDY = YYYYMMDD,  YYYY IS THE YEAR, MM IS THE MONTH,
C                           DD IS THE DAY OF THE MONTH
C    AND 
C          CYCLE = T00Z, T06Z, T12Z, OR T18Z
C
C   OUTPUT FILES:
C    FORT.06    ERROR MESSAGES
C    FORT.51    BULLETIN RECORDS FOR TRANSMISSION
C
C   SUBPROGRAMS CALLED: (LIST ALL CALLED FROM ANYWHERE IN CODES)
C     LIBRARY:
C       W3AI15  WXAI19  W3FC03  W3FP11  W3FI01
C       GETGB   GETGBP (FOR GRIB FILES)
C       W3FT01  W3TAGE  XMOVEX  XSTORE  W3UTCDAT
C
C   EXIT STATES:
C      COND =  110   STN DIRECTORY READ ERR (CONSOLE MSG)
C             1050   NO DATA (FIELD ID IS PRINTED)(FT06 + CONSOLE)
C             1060   NO DATA (FIELD ID IS PRINTED)(FT06 + CONSOLE)
C             1070   NO DATA (FIELD ID IS PRINTED)(FT06 + CONSOLE)
C             1080   NO DATA (FIELD ID IS PRINTED)(FT06 + CONSOLE)
C             1090   NO DATA (FIELD ID IS PRINTED)(FT06 + CONSOLE)
C       ALL ARE FATAL
C             PLUS W3LIB SUB-RTN RETURN CODES
C
C REMARKS:
C
C    DATA CARDS FOR 'WLL' AND 'WYA' WERE MODIFIED TO "FIT" INTO
C    THE LFM GRID.  THE IBM/HDS MACHINES ALLOWED THIS CODE TO "GO
C    OFF THE GRID GRACEFULLY AND EVIDENTLY SEND OUT ERRONEOUS DATA
C    FOR YEARS.  THE CRAY WAS NOT SO FRIENDLY!  COULDN'T GET ANY
C    HELP FROM NWSH/OM REGARDING THIS DILEMA, SO ADJUSTED THE
C    LATITUDE VALUES OURSELVES TO GET THIS CODE CONVERTED TO THE
C    CRAY.  THE FOLLOWING CHANGES WERE MADE:
C         FOR 'WLL', THE LAT WAS CHANGED FROM 82.00 TO 78.00
C         FOR 'WYA', THE LAT WAS CHANGED FROM 84.00 TO 80.00
C    REJ/MAF.
C
C ATTRIBUTES:
C   LANGUAGE: F90 FORTRAN
C   MACHINE:  IBM RS600 SP
C
C$$$
C
      PARAMETER  (MXSIZE= 96673)
      PARAMETER  (MXSIZE8=MXSIZE*8)
      PARAMETER  (MAXSTN=700)
      PARAMETER  (III=349,JJJ=277)
C
      REAL       ALAT(MAXSTN)
      REAL       ALON(MAXSTN)
      REAL       ISTN(MAXSTN)
      REAL       JSTN(MAXSTN)
      REAL       ERAS(3)
      REAL       RFLD(MXSIZE)
      REAL       RINTRP(III,JJJ)
      REAL       ORIENT
      REAL       XMESHL
      REAL       XIP, XI
      REAL       XJP, XJ
      REAL       FHOUR
      REAL       ALAT1, ELON1, DX, ELONV, ALATAN, IPOLE, JPOLE
C
C...MAX NR STNS FOR READ-END SHOULD BE GT ACTUAL NR OF STNS ON STN FILE
      INTEGER    IELEV(MAXSTN)
      INTEGER    IGRIB(MXSIZE)
      INTEGER    IRAS(3)
      INTEGER    ISTN1(MAXSTN)
      INTEGER    JSTN1(MAXSTN)
      INTEGER    ITIME(8)
      INTEGER    NDATE(8)
      INTEGER    MDATE(8)
      INTEGER    JGDS(100)
      INTEGER    JREW
      INTEGER    KBYTES
      INTEGER    KGDS(100)
      INTEGER    KPDS(27)
      INTEGER    KREW
      INTEGER    KSTNU(MAXSTN,11)
      INTEGER    KTAU(3)
      INTEGER    LMTLWR(12)
      INTEGER    LMTUPR(12)
      INTEGER    MPDS(27)
      INTEGER    NTTT
C...NPOS(ITIVE) IS TRANSMISSION SIGN 7C MASK FOR TEMP
      INTEGER    IDWD1H(3)
      INTEGER    IDWD2H(3)
      INTEGER    IDWD1P(3)
      INTEGER    IDWD2P(3)
      INTEGER    IDWD2(11)
      INTEGER    NHGT1(19)
      INTEGER    NHGTP(11)
C
      INTEGER    ICKYR
      INTEGER    ICKMO
      INTEGER    ICKDAY
      INTEGER    ICKHR
      INTEGER    KSTNV(MAXSTN,11)
      INTEGER    KSTNT(MAXSTN,11)
C
C...S,L,T,B ARE SUBSCRIPTS FOR SEQ NR OF STATION, LEVEL, TAU, BULLETIN
C...  B IS COUNT OF BULTNS WITHIN TAU, BB IS CNT WITHIN RUN
C
      INTEGER    S,L,T,B, BB
C
      CHARACTER*6     NHGT6(11)
      CHARACTER*1     BSTART
      CHARACTER*1     BEND
      CHARACTER*1     BULTN(1280)
      CHARACTER*1     SPACE(1280)
      CHARACTER*1     ETBETX
      CHARACTER*1     ETB
      CHARACTER*1     ETX
      CHARACTER*1     ICK
      CHARACTER*1     ICKX
      CHARACTER*1     INDIC(MAXSTN)
      CHARACTER*1     JGRIB(MXSIZE)
      CHARACTER*1     LF
      CHARACTER*1     MINUS
      CHARACTER*1     MUSES(MAXSTN)
      CHARACTER*1     SPC80(80)
      CHARACTER*1     TRANSW
      CHARACTER*1     TSRCE
      CHARACTER*1     TMODE
      CHARACTER*1     TFLAG
      CHARACTER*3     CRCRLF
      CHARACTER*4     ITRTIM
      CHARACTER*4     STNID(MAXSTN)
      CHARACTER*4     IVALDA
      CHARACTER*1     NNPOS
      CHARACTER*4     NFDHDG(36)
      CHARACTER*4     NCATNR(36)
      CHARACTER*4     NVALTM(9)
      CHARACTER*9     NUSETM(9)
C
      CHARACTER*8     IBLANK
      CHARACTER*8     IBSDA
      CHARACTER*8     IBSTI
      CHARACTER*8     ITEMP(MAXSTN,11)
      CHARACTER*8     ITRDA
      CHARACTER*8     IWIND(MAXSTN,11)
      CHARACTER*8     NFILE
      CHARACTER*8     NTTT4
      CHARACTER*8     RF06
      CHARACTER*8     RF12
      CHARACTER*8     RF24
      CHARACTER*10    ENVVAR
      CHARACTER*80    FILEB, FILEI,FILEO 
C
      CHARACTER*76    LINE73
      CHARACTER*40    LN73A
      CHARACTER*36    LN73B
      CHARACTER*64    NBULHD
      CHARACTER*40    NBUL1
      CHARACTER*24    NBUL2
      CHARACTER*32    NBASHD
      CHARACTER*60    NVALHD
      CHARACTER*80    SPCS
      CHARACTER*86    TITLE
C
      LOGICAL         ENDBUL
      LOGICAL         KBMS(MXSIZE)
C
      EQUIVALENCE  (ICK,ICKX)
      EQUIVALENCE  (RFLD(1),RINTRP(1,1))
      EQUIVALENCE  (NBULHD(1:1),NBUL1(1:1))
      EQUIVALENCE  (NBULHD(41:41),NBUL2(1:1))
      EQUIVALENCE  (LINE73(1:1),LN73A(1:1))
      EQUIVALENCE  (LINE73(41:41),LN73B(1:1))
      EQUIVALENCE  (SPCS,SPC80)
      EQUIVALENCE  (NTTT,NTTT4(1:1))
      EQUIVALENCE  (IGRIB(1),JGRIB(1))
C
C      PARAMETERS FOR GRID 221
C
C        LATITUDE OF LOWER LEFT POINT OF GRID (POINT (1,1)
C
      DATA  ALAT1 /1.000/
C
C        EAST LONGITUDE OF OF LOWER LEFT POINT OF GRID (POINT (1,1)
C
      DATA  ELON1 /214.50/
C
C        MESH LENGTH OF GRID IN METERS AT TANGENT LATITUDE
C
      DATA  DX /32463.41/
C
C        THE ORIENTATION OF THE GRID
C
      DATA  ELONV /253.00/
C
C        THE LATITUDE AT WHICH THE LAMBERT CONE IS TANGENT TO
C        THE SPHERICAL EARTH
C
      DATA  IMAX /349/
      DATA  JMAX /277/
      DATA  INDEX /1/
      DATA  NCYCLK/ 0 /
      DATA  LIN   / 1 /
      DATA  ALATAN /50.00/
      DATA  IPOLE /174.507/
      DATA  JPOLE /307.764/
      DATA  CENLON /-107.00/
      DATA  XLAT1  /50.00/
C
      DATA  FHOUR /24.0/
      DATA  KTAU  /06,12,24/
      DATA  LMTLWR/1,1,1,1,1,1,1, 6, 6,1,1,10/
      DATA  LMTUPR/9,9,9,9,9,9,9,11,11,9,9,11/
      DATA  IDWD1H/         33,          34,          11/
      DATA  IDWD2H/        103,         103,         103/

      DATA  IDWD1P/         33,          34,          11/
      DATA  IDWD2P/        100,         100,         100/

      DATA  IDWD2 /        914,        1829,        2743,        3658,
     1                     500,         400,         300,         250,
     2                     200,         150,         100/
      DATA  NHGT6 /'3000  ','6000  ','9000  ','12000 ',
     1                      '18000 ','24000 ','30000 ','34000 ',
     2                      '39000 ','45000 ','53000'/
      DATA  NHGTP /5,5,6,6,6,6,6,6,6,6,5/
      DATA  BSTART/'B'/
      DATA  BEND  /'E'/
      DATA  ETB   /'>'/
      DATA  ETX   /'%'/
      DATA  MINUS /'-'/
      DATA  SPC80 /80*' '/
      DATA  CRCRLF/'<<@'/
      DATA  IBLANK/'        '/
      DATA  NFDHDG/
     1                  'UE01','UE02','UM01','UM02','UW01','UW02',
     2                  'AK01','CN01','CN40','US11','US12','US08',
     3                  'UE03','UE04','UM03','UM04','UW03','UW04',
     4                  'AK02','CN02','CN41','US13','US14','US09',
     5                  'UE05','UE06','UM05','UM06','UW05','UW06',
     4                  'AK03','CN03','CN42','US15','US16','US10'/
      DATA  NCATNR/
     1                  '1448','1449','1413','1414','1254','1377',
     2                  '9087','9874','5980','6707','6709','4809',
     3                  '1450','1451','1415','1418','1378','1386',
     4                  '9088','9875','5981','6726','6733','4810',
     5                  '1452','1453','1441','1443','1387','1412',
     6                  '9089','9876','5982','6736','6745','4811'/
      DATA  NVALTM/
     1                  '0600','1200','0000','1800','0000','1200',
     2                  '0600','1200','0000'/
      DATA  NUSETM/
     1                  '0500-0900','0900-1800','1800-0500',
     2                  '1700-2100','2100-0600','0600-1700',
     3                  '0500-0900','0900-1800','1800-0500'/
      DATA  RF06  /'6 HOURS '/
      DATA  RF12  /'12 HOURS'/
      DATA  RF24  /'24 HOURS'/
      DATA  LN7A /'                                        '/
      DATA  LN73B /'                              <<@^^^'/
      DATA  NBUL1 /
     1             '''10    PFD                              '/
      DATA  NBUL2/
     1              'FD     KWBC       <<@$^^'/
      DATA  NBASHD/'DATA BASED ON       Z    <<@@^^^'/
      DATA  NVALHD/
     1  'VALID       Z   FOR USE    -     Z. TEMPS NEG ABV 24000<<@@^'/
C
C
      NNPOS = CHAR(124)
      LUGO = 51
      CALL W3TAGB('BULLS_FDWNDTRX',2012,0132,0079,'NP11')
      ENVVAR='FORT  '
      WRITE(ENVVAR(5:6),FMT='(I2)') LUGO
      CALL GETENV(ENVVAR,FILEO)
      OPEN(LUGO,FILE=FILEO,ACCESS='DIRECT',RECL=1281)
      IREC=1
C...GET COMPUTER DATE-TIME & SAVE FOR DATA DATE VERIFICATION
      CALL W3UTCDAT(ITIME)
C
C...READ AND STORE STATION LIST FROM UNIT 5
C...INDIC = INDICATOR BEGIN, OR END, BULTN ('B' OR 'E')
C...MUSES = USED IN MULTIPLE BULTNS (FOR SAME TAU) IF '+'
C
      DO 25 I = 1, MAXSTN
         READ(5,10,ERR=109,END=130) INDIC(I),MUSES(I),STNID(I),
     &   IELEV(I),ALAT(I),ALON(I)
  25  CONTINUE
C
C///////////////////////////////////////////////////////////////////
   10 FORMAT(A1,A1,A4,1X,I5,1X,F5.2,1X,F6.2)
C
C...ERROR
  109 CONTINUE
      CALL W3TAGE('BULLS_FDWNDTRX')
      PRINT *,'STATION LIST READ ERROR'
      CALL ERREXIT (110)
C////////////////////////////////////////////////////////////////////
C
  130 CONTINUE
C
C     CONVERT THE LAT/LONG COORDINATES OF STATION TO LAMBERT
C     CONFORMAL PROJECTION I,J COORDINATES FOR GRID 221
C
      NRSTNS = I-1
      WRITE(6,'(A19,1X,I0)') ' NO. OF STATIONS = ',NRSTNS
C     PRINT *,'STN-ID     ISTN     JSTN      ALAT      ALON'
      DO 110 J = 1,NRSTNS
          ALONG = - ALON(J) 
          CALL W3FB11( ALAT(J), ALONG, ALAT1, ELON1, DX, ELONV, ALATAN,
     +             XI, XJ )
          ISTN(J) = XI 
          JSTN(J) = XJ
C         PRINT 111,STNID(J),ALAT(J),ALONG,ISTN(J),JSTN(J)
  111 FORMAT (3X,A3,2(2X,F8.2),2(2X,F8.3))
  110 CONTINUE
C
C...END READ. COUNT OF STATIONS STORED
C
C...GET EXEC PARMS
C...PARM FIELD TAKEN OUT, NEXT 4 VALUES HARD WIRED
      TRANSW = 'Y'
      TMODE  = 'M'
      TSRCE  = 'R'
      TFLAG  = 'P'
      PRINT *,'SOURCE=',TSRCE,'  MODE=',TMODE,'  FLAG=',TFLAG
C
C...GET DATE-TIME FOR LATER BULTN HDG PROCESSING
C
      READ(49,250)ICKYR,ICKMO,ICKDAY,ICKHR
  250 FORMAT(6X,I4,2I2.2,I4.4,16X)
      ICYC=1
      IF (ICKHR.EQ.1200) ICYC=2
      IBSTIM=ICKHR
C
C...GET NEXT DAY - FOR VALID DAY AND 12Z BACKUP TRAN DAY
C...UPDATE TO NEXT DAY
      NHOUR=ICKHR*.01
      CALL W3MOVDAT((/0.,FHOUR,0.,0.,0./),
     &    (/ICKYR,ICKMO,ICKDAY,0,NHOUR,0,0,0/),NDATE)
      CALL W3MOVDAT((/0.,FHOUR,0.,0.,0./),NDATE,MDATE)
C
C...12Z CYCLE,BACKUP RUN,24HR FCST: VALID DAY IS DAY-AFTER-NEXT
C...NEXT DAY-OF-MONTH NOW STORED IN 'NDATE(3)'
C...NEXT DAY PLUS 1 IN 'MDATE(3)'
C
C**********************************************************************
C
C...READ PACKED DATA, UNPACK, INTERPOLATE, STORE IN STATION ARRAYS,
C...  CREATE BULTN HDGS, INSERT STATION IN BULTNS, & WRITE BULTNS.
C
      BB = 0
C
C...BEGIN TAU
C
      DO 7000  ITAU=1, 3
C
          WRITE(6,'(A6,1X,I0)') ' ITAU=',ITAU
          T = ITAU
C
C SELECT FILE FOR TAU PERIOD (PRIMARY RUN)
C
          IF (KTAU(ITAU).EQ.6) THEN
              NFILE = RF06
              LUGB  = 11
              LUGI  = 31
          ELSE IF (KTAU(ITAU).EQ.12) THEN
              NFILE = RF12
              LUGB  = 12
              LUGI  = 32
          ELSE
              NFILE = RF24
              LUGB  = 13
              LUGI  = 33
          ENDIF
C
          WRITE(ENVVAR(5:6),FMT='(I2)') LUGB
          CALL GETENV(ENVVAR,FILEB)
          WRITE(ENVVAR(5:6),FMT='(I2)') LUGI
          CALL GETENV(ENVVAR,FILEI)
          CALL BAOPENR(LUGB,FILEB,IRET)
          CALL BAOPENR(LUGI,FILEI,IRET)
          PRINT 1025,NFILE, FILEB, FILEI
 1025     FORMAT('NFILE= ',A8,2X,'GRIB FILE= ',A15,'INDEX FILE= ',A15)
C
C..................................
          DO 2450  ITYP=1,3
C
C...          SEE O.N. 388 FOR FILE ID COMPOSITION
C
              DO 2400  L=1,11
C
C...USE SOME OF THE VALUES IN THE PDS TO GET RECORD
C
C     MPDS     = -1  SETS ARRAY MPDS TO -1
C     MPDS(3)  = GRID IDENTIFICATION  (PDS BYTE 7)
C     MPDS(5)  = INDICATOR OF PARAMETER (PDS BYTE 9)
C     MPDS(6)  = INDICATOR OF TYPE OF LEVEL OR LAYER (PDS BYTE 10)
C     MPDS(7)  = HGT,PRES,ETC. OF LEVEL OR LAYER (PDS BYTE 11,12)
C     MPDS(14) = P1 - PERIOD OF TIME (PDS BYTE 19)
C                VALUES NOT SET TO -1 ARE USED TO FIND RECORD
C
                  JREW    =  0
                  KREW    =  0
                  MPDS    = -1
C           
                  MPDS(3) = 221
                  IF (L.LE.4) THEN
                      MPDS(5) = IDWD1H(ITYP)
C...                      HEIGHT ABOVE MEAN SEA LEVEL  GPML
                      MPDS(6) = IDWD2H(ITYP)
                  ELSE
                      MPDS(5) = IDWD1P(ITYP)
C...                      PRESSURE  IN HectoPascals (hPa)   ISBL
                      MPDS(6) = IDWD2P(ITYP)
                  ENDIF

                  MPDS(7)  = IDWD2(L)
                  MPDS(14) = KTAU(ITAU)
C
C...              THE FILE ID COMPLETED.
C                 PRINT *,MPDS
C...              GET THE DATA FIELD.
C
                  CALL GETGB(LUGB,LUGI,MXSIZE,JREW,MPDS,JGDS,
     &                 KBYTES,KREW,KPDS,KGDS,KBMS,RFLD,IRET)
C                 WRITE(*,119) KPDS
119               FORMAT( 1X, 'MAIN: KPDS:',  3(/1X,10(I5,2X) ) )
C
C///////////////////////////////////////////////////////////////////////
C...ERROR
                  IF (IRET.NE.0) THEN
                      write(*,120) (MPDS(I),I=3,14)
120                   format(1x,' MPDS =   ',12(I0,1x))
                      WRITE(6,'(A9,1X,I0)') ' IRET = ',IRET
                      IF (IRET.EQ.96) THEN
                          PRINT *,'ERROR READING INDEX FILE'
                          CALL W3TAGE('BULLS_FDWNDTRX')
                          CALL ERREXIT (1050)
                      ELSE IF (IRET.EQ.97) THEN
                          PRINT *,'ERROR READING GRIB FILE'
                          CALL W3TAGE('BULLS_FDWNDTRX')
                          CALL ERREXIT (1060)
                      ELSE IF (IRET.EQ.98) THEN
                          PRINT *,'NUMBER OF DATA POINT GREATER',
     *                            ' THAN MXSIZE'
                          CALL W3TAGE('BULLS_FDWNDTRX')
                          CALL ERREXIT (1070)
                      ELSE IF (IRET.EQ.99) THEN
                          PRINT *,'RECORD REQUESTED NOT FOUND'
                          CALL W3TAGE('BULLS_FDWNDTRX')
                          CALL ERREXIT (1080)
                      ELSE
                          PRINT *,'GETGB-W3FI63 GRIB UNPACKER',
     *                            ' RETURN CODE'
                          CALL W3TAGE('BULLS_FDWNDTRX')
                          CALL ERREXIT (1090)
                      END IF
                  ENDIF
C
C                 CALL GETGBP(LUGB,LUGI,MXSIZE8,KREW-1,MPDS,JGDS,
C    &                 KBYTES,KREW,KPDS,KGDS,IGRIB,IRET)
C                 CALL W3FP11(IGRIB(1),IGRIB(2),TITLE,KERR)
C                 IF (KERR.NE.0) PRINT *,'W3FP11 ERR = ',KERR
C                 PRINT *,TITLE
C
C...CONVERT DATA TO CONVENTIONAL UNITS:
C...  WIND FROM METERS/SEC TO KNOTS AND TEMP FROM K TO CELSIUS
C
                  DO 1500  I=1,MXSIZE
C
                      IF (ITYP.EQ.3) THEN
                          RFLD(I)=RFLD(I)-273.15
                      ELSE
                          RFLD(I)=RFLD(I)*1.94254
                      ENDIF
C
 1500             CONTINUE
C
                  DO 2300  S=1,NRSTNS
C
C         INTERPOLATE GRIDPOINT DATA TO STATION.
C
          CALL W3FT01(ISTN(S),JSTN(S),RINTRP,X,IMAX,JMAX,NCYCLK,LIN)
C         WRITE(6,830) STNID(S),ISTN(S),JSTN(S),X
830       FORMAT(1X,'STN-ID = ', A4,3X,'SI,SJ = ', 2(F5.1,2X), 1X,
     A       'X = ', F10.0)
C
C...INTERPOLATION COMPLETE FOR THIS STATION
C
C...CONVERT WIND, U AND V TO INTEGER
C
                      IF (ITYP.EQ.1) THEN
                          KSTNU(S,L)=X*100.0
                      ELSE IF (ITYP.EQ.2) THEN
                          KSTNV(S,L)=X*100.0
C...CONVERT TEMP TO I*2
                      ELSE IF (ITYP.EQ.3) THEN
                          KSTNT(S,L)=X*100.0
                      ENDIF
C
 2300             CONTINUE
C...END OF STATION LOOP
C...................................
C
 2400         CONTINUE
C...END OF LEVEL LOOP
C...................................
C
 2450     CONTINUE
C...END OF DATA TYPE LOOP
C...................................
C
C...INTERPOLATED DATA FOR ALL STATIONS,1 TAU, NOW ARRAYED IN KSTNU-V-T.
C***********************************************************************
C
C...CONVERT WIND COMPONENTS TO DIRECTION AND SPEED
C
C.................................
C...BEGIN STATION
C
          DO 3900  S=1,NRSTNS
C.................................
              DO 3750  L=1,11
C
C...PUT U & V WIND COMPONENTS IN I*4 WORK AREA
                  IRAS(1)=KSTNU(S,L)
                  IRAS(2)=KSTNV(S,L)
C...FLOAT U & V
                  ERAS(1)=FLOAT(IRAS(1))*.01
                  ERAS(2)=FLOAT(IRAS(2))*.01
C
C...CONVERT TO WIND DIRECTION & SPEED
C
         CALL W3FC03( -ALON(S),ERAS(1),ERAS(2),CENLON,XLAT1,
     1            DD, SS )

C
C...WITH DIR & SPEED IN WORK AREA, PLACE TEMPERATURE -TT- IN WORK
                  IRAS(3)=KSTNT(S,L)
                  TT=FLOAT(IRAS(3))*.01
C
C...DIRECTION, SPEED & TEMP ALL REQUIRE ADDITIONAL TREATMENT TO
C     MEET REQUIREMENTS OF BULLETIN FORMAT
C
                  NDDD=(DD+5.0)/10.0
C...WIND DIRECTION ROUNDED TO NEAREST 10 DEGREEES
C
C...THERE IS A POSSIBILITY WIND DIRECTION NOT IN RANGE 1-36

                  IF ((NDDD.GT.36).OR.(NDDD.LE.0)) THEN
                      NDDD = MOD(NDDD, 36)
                      IF (NDDD.LE.0) NDDD = NDDD + 36
                  ENDIF
                  NSSS=SS+0.5
C...WIND SPEED ROUNDED TO NEAREST KNOT
C...FOR SPEED, KEEP UNITS AND TENS ONLY, ADDING 50 TO DIRECTION
C
C...SPEED GREATER THAN 199 KNOTS
                  IF (NSSS.GT.199) THEN
                      NSSS=99
                      NDDD=NDDD+50
C...SPEED GT 99 AND LE 199  KNOTS
                  ELSE IF (NSSS.GT.99) THEN
                      NSSS=NSSS-100
                      NDDD=NDDD+50
C
C...SPEED LT 5 KNOTS - CONSIDERED CALM
                  ELSE IF (NSSS.LT.5) THEN
                      NSSS=0
                      NDDD=99
                  ENDIF
C
C...COMBINE DIR & SPEED IN ONE WORD I*4
                  NDDSS=(NDDD*100)+NSSS
C
C...STORE IN ASCII IN LEVEL ARRAY, WIND FOR ONE STATION
                  CALL W3AI15(NDDSS,IWIND(S,L),1,4,MINUS)
C
C...TEMP NEXT. IF POSITIVE ROUND TO NEAREST DEGREE, CONV TO ASCII
                  NTTT    = TT
                  IF (TT.LE.-0.5) NTTT = TT - 0.5
                  IF (TT.GE.0.5) NTTT = TT + 0.5
                  CALL W3AI15(NTTT,NTTT,1,3,MINUS)
                  IF (TT.GT.-0.5) NTTT4(1:1) = NNPOS(1:1)

C...SIGN & 2 DIGITS OF TEMP NOW IN ASCII IN LEFT 3 BYTES OF NTTT
C
C
                  ITEMP(S,L)(1:3) = NTTT4(1:3)
C
 3750         CONTINUE
C...END LEVEL (WIND CONVERSION)
C.................................
C
C...AT END OF LVL LOOP FOR ONE STATION, ALL WIND & TEMP DATA IS ARRAYED,
C...  IN ASCII, IN IWIND (4 CHARACTER DIR & SPEED) AND ITEMP (3 CHAR
C...  INCL SIGN FOR 1ST 6 LVLS, 2 CHAR WITH NO SIGN FOR 5 UPPER LVLS)
C
C...BEFORE INSERTING INTO BULTN, TEMPS FOR LVLS OTHER THAN 3000'
C...  WHICH ARE LESS THAN 2500' ABOVE STATION MUST BE ELIMINATED.
C...  (TEMPS FOR 3000' ARE NOT TRANSMITTED)
C...WINDS ARE BLANKED FOR LVLS LESS THAN 1500' ABOVE STATION.
C
              IF (IELEV(S).GT.9500) ITEMP(S,4) = IBLANK
              IF (IELEV(S).GT.6500) ITEMP(S,3) = IBLANK
              IF (IELEV(S).GT.3500) ITEMP(S,2) = IBLANK
              ITEMP(S,1)=IBLANK
C
              IF (IELEV(S).GT.10500) IWIND(S,4) = IBLANK
              IF (IELEV(S).GT.7500) IWIND(S,3) = IBLANK
              IF (IELEV(S).GT.4500) IWIND(S,2) = IBLANK
              IF (IELEV(S).GT.1500) IWIND(S,1) = IBLANK

C...DATA FOR 1 STATION, 11 LVLS, 1 TAU NOW READY FOR BULTN LINE
C
 3900     CONTINUE
C...END STATION (WIND CONVERSION)
C
C...DATA FOR ALL STATIONS, ONE TAU, NOW READY FOR BULTN INSERTION
C**********************************************************************
C*********************************************************************
C
C...BULLETIN CREATION
C...REACH THIS POINT ONCE PER TAU
C...B IS BULTN CNT FOR TAU, BB CUMULATIVE BULTN CNT FOR RUN,
C...  S IS SEQ NR OF STN.
C...  (NOT NEEDED FOR U.S. WHICH IS SET AT #1.)
          B      = 0
          S      = 0
          ENDBUL = .FALSE.
C
      DO 6900 J = 1,12
C.......................................................................
C
C...UPDATE STATION COUNTER
C
 4150         S = S + 1
C
              ICKX=INDIC(S)
              IF (ICK(1:1).EQ.BSTART(1:1)) THEN

C...GO TO START, OR CONTINUE, BULTN
C
C...BEGIN BULLETIN
C
C
                  B  = B  + 1
                  BB = BB + 1
C***********************************************************************
C
C...PROCESS DATE-TIME FOR HEADINGS
C
                  IF (BB.EQ.1) THEN
C...............................
C...ONE TIME ENTRIES
C
C...TRAN HDGS
                      ITRDAY=ICKDAY
                      IBSDAY=ICKDAY
                      WRITE(ITRTIM(1:4),'(2(I2.2))') ITIME(5), ITIME(6) 
C
                      IF (TMODE.EQ.'T') THEN
C...BACKUP
                          IF (ICYC.EQ.2) THEN
C...TRAN DAY WILL BE NEXT DAY FOR 12Z CYCLE BACKUP
                              ITRDAY=NDATE(3)
                          ENDIF
                      ENDIF
C...END TRAN BACKUP DAY-HOUR
C
C...PLACE TRAN & BASE DAY-HOUR IN HDGS
                      CALL W3AI15(ITRDAY,ITRDA,1,2,MINUS)
                      CALL W3AI15(IBSDAY,IBSDA,1,2,MINUS)
                      CALL W3AI15(IBSTIM,IBSTI,1,4,MINUS)
C
                      NBUL2(13:14) = ITRDA(1:2)
                      NBUL2(15:18) = ITRTIM(1:4)
C
                      NBASHD(15:16) = IBSDA(1:2)
                      NBASHD(17:20) = IBSTI(1:4)
                  ENDIF
C ****************************************************************
C ****************************************************************
C    IF REQUIRED TO INDICATE THE SOURCE FOR THESE FD BULLETINS
C    REMOVE THE COMMENT STATUS FROM THE NEXT TWO LINES
C ****************************************************************
C ****************************************************************
C
C...END ONE-TIME ENTRIES
C............................
C
C...BLANK OUT CONTROL DATE AFTER 1ST BULTN
                  IF (BB.EQ.2) NBULHD(13:20) = SPCS(1:8)
C
C...CATALOG NUMBER (AND 'P' OR 'B' FOR PRIMARY OR BACKUP RUN)
                  NBULHD(8:8)   = TFLAG
                  NBULHD(4:7)   = NCATNR(BB)(1:4)
                  NBULHD(43:46) = NFDHDG(BB)(1:4)
C...END CATALOG NR
C
C...END TRAN HDGS
C.....................................................................
C
C...VALID-USE HDGS
                  IF (TMODE.EQ.'T') THEN

C...BACKUP DAY-HOURS WILL BE SAME AS PRIMARY RUN OF OPPOSITE CYCLE
                      IVLDAY=NDATE(3)
                      IF (ICYC.EQ.1.AND.T.EQ.1) IVLDAY=IBSDAY
                      IF (ICYC.EQ.2.AND.T.EQ.3) IVLDAY=MDATE(3)
C
C...SET POINTER OPPOSITE (USE WITH T -RELATIVE TAU- TO SET HOURS)
                      IF (ICYC.EQ.1) KCYC=2
                      IF (ICYC.EQ.2) KCYC=1
                  ELSE
                      KCYC=ICYC
                      IVLDAY=IBSDAY
                      IF (T.EQ.3) IVLDAY=NDATE(3)
                      IF (ICYC.EQ.2.AND.T.EQ.2) IVLDAY=NDATE(3)
                  ENDIF

C...END BACKUP DAY-HOUR.
C
C
C...CONVERT TO ASCII AND PLACE IN HDGS
                  CALL W3AI15(IVLDAY,IVALDA,1,2,MINUS)
                  NVALHD(7:8)   = IVALDA(1:2)
                  IITAU = ITAU
                  IF (ICYC.EQ.2) IITAU = ITAU + 3
                  NVALHD(9:12)  = NVALTM(IITAU)(1:4)
                  NVALHD(25:33) = NUSETM(IITAU)(1:9)
C
C...END VALID-USE HDGS
C
C...MOVE WORK HDGS TO BULTN O/P (TRAN, BASE, VALID, HEIGHT HDGS)
                  NEXT=0
                  CALL WXAI19(NBULHD,64,BULTN,1280,NEXT)
C                 PRINT *,(NBULHD(L:L),L=41,58)
                  CALL WXAI19(NBASHD,28,BULTN,1280,NEXT)
C                 PRINT *,(NBASHD(L:L),L=1,25)
                  CALL WXAI19(NVALHD,60,BULTN,1280,NEXT)
                  CALL WXAI19('<<@',3,BULTN,1280,NEXT)
C                 PRINT *, (NVALHD(L:L),L=1,55)
                  LINE73(1:73) = SPCS(1:73)
                  LINE73(1:2)  = 'FT'
                  NPOS1        = 5
                  DO 4500 N = LMTLWR(J), LMTUPR(J)
                      IF (N.EQ.2) THEN
                          NPOS1 = NPOS1 + 3
                      ELSE IF ((N.GE.3).AND.(N.LE.6)) THEN
                          NPOS1 = NPOS1 + 2
                      ELSE IF (N.GT.6) THEN
                          NPOS1 = NPOS1 + 1
                      ENDIF
                      NPOS2    = NPOS1 + 4
                      LINE73(NPOS1:NPOS2) = NHGT6(N)(1:5)
                      NPOS1 = NPOS1 + NHGTP(N)

 4500             CONTINUE

C                 PRINT *,(LINE73(II:II),II=1,NPOS2)
                  CALL WXAI19(LINE73,NPOS2,BULTN,1280,NEXT)
                  CALL WXAI19(CRCRLF,3,BULTN,1280,NEXT)
              ENDIF
C
C...BULLETIN HDGS FOR ONE BULTN COMPLETE IN O/P AREA
C
C***********************************************************************
C
C...CONTINUE BULTN, INSERTING DATA LINES.
C
              NPOS1 = 5
              LINE73(1:73) = SPCS(1:73)
              LINE73(1:1)   = '$'
              LINE73( 2: 5) = STNID(S)(1:4)
              DO 5300 M = LMTLWR(J), LMTUPR(J)
                  NPOS1 = NPOS1 + 1
                  NPOS2 = NPOS1 + 4
                  LINE73(NPOS1:NPOS2) = IWIND(S,M)(1:4)
                  NPOS1 = NPOS1 + 4
                  IF ((M.GT.1).AND.(M.LE.6))THEN
                      NPOS2 = NPOS1 + 2
                      LINE73(NPOS1:NPOS2) = ITEMP(S,M)(1:3)
                      NPOS1 = NPOS1 + 3
                  ELSE IF (M.GT.6) THEN
                      NPOS2 = NPOS1 + 1
                      LINE73(NPOS1:NPOS2) = ITEMP(S,M)(2:3)
                      NPOS1 = NPOS1 + 2
                  ENDIF
 5300         CONTINUE
C             PRINT *,(LINE73(II:II),II=2,NPOS2)
C...NXTSAV HOLDS BYTE COUNT IN O/P BULTN FOR RESTORING WXAI19 'NEXT'
C...  FIELD SO THAT WHEN 'NEXT' IS RETURNED AS -1, AN ADDITIONAL
C...  LINEFEED AND/OR ETB OR ETX CAN BE INSERTED
C
              IF (NEXT.GE.1207) THEN
                  CALL WXAI19 (ETB,1,BULTN,1280,NEXT)
                  LF = CHAR(10)
                  do ii=1,next
                     space(index) = bultn(ii)
                     if (index .eq. 1280) then
                        WRITE(51,REC=IREC) space, LF
                        IREC=IREC + 1
                        index = 0
                     endif
                     index = index + 1
                  enddo
 2103             format(1x,40z2)
 2104             format(1x,80a1)
C                 WRITE(51) BULTN, LF
                  NEXT   = 0
              ENDIF
              CALL WXAI19(LINE73,NPOS2,BULTN,1280,NEXT)
              CALL WXAI19(CRCRLF,3,BULTN,1280,NEXT)
C
C...AFTER LINE STORED IN O/P, GO TO CHECK BULTN END
C
C...................................
C
C...CHECK FOR LAST STN OF BULTN
              IF (ICK(1:1).NE.BEND(1:1)) GO TO 4150
C
C...END BULLETIN.  SET UP RETURN FOR NEXT STN AFTER WRITE O/P.
C...SAVE SEQ NR OF LAST STN FOR SUBSEQUENT SEARCH FOR STNS
C
              NXTSAV = NEXT
              ENDBUL = .TRUE.
C***********************************************************************
C
C...OUTPUT SECTION
C
              NEXT   = NXTSAV
              ETBETX = ETB
              IF (ENDBUL) ETBETX=ETX
C...END OF TRANSMIT BLOCK, OR END OF TRANSMISSION
C
              CALL WXAI19(ETBETX,1,BULTN,1280,NEXT)
C
C...OUTPUT TO HOLD FILES
              LF = CHAR(10)
              do ii=1,next
                  space(index) = bultn(ii)
                  if (index .eq. 1280) then
                     WRITE(51,REC=IREC) space, LF
                     IREC=IREC + 1
                     index = 0
                  endif
                  index = index + 1
               enddo
C
C...TRAN.
C
              NEXT=0
              ENDBUL=.FALSE.
C
C...RETURN TO START NEW BULTN, OR CONTINUE LINE FOR WHICH THERE WAS
C...  INSUFFICIENT SPACE IN BLOCK JUST WRITTEN
C
 6900     CONTINUE
C
C***********************************************************************
 7000 CONTINUE
C...END TAU LOOP
C
C...FT51 IS TRANSMISSION FILE
C     END FILE 51
C     REWIND 51
      if (index .gt. 0) then
                     WRITE(51,REC=IREC) space, LF
                     IREC=IREC+1
      endif
      KRET = 0

      CALL W3TAGE('BULLS_FDWNDTRX')
      STOP
      END

      SUBROUTINE WXAI19(LINE, L, NBLK, N, NEXT)
C$$$  SUBPROGRAM DOCUMENTATION  BLOCK
C                .      .    .                                       .  
C SUBPROGRAM:    WXAI19      LINE BLOCKER SUBROUTINE
C   AUTHOR: ALLARD, R.         ORG: W342          DATE: 01 FEB 74
C
C ABSTRACT: FILLS A RECORD BLOCK WITH LOGICAL RECORDS OR LINES
C   OF INFORMATION.
C
C PROGRAM HISTORY LOG:
C   74-02-01  BOB ALLARD
C   90-09-15  R.E.JONES   CONVERT FROM IBM370 ASSEMBLER TO MICROSOFT
C                         FORTRAN 5.0 
C   90-10-07  R.E.JONES   CONVERT TO SUN FORTRAN 1.3    
C   91-07-20  R.E.JONES   CONVERT TO SiliconGraphics 3.3 FORTRAN 77   
C   93-03-29  R.E.JONES   ADD SAVE STATEMENT
C   94-04-22  R.E.JONES   ADD XMOVEX AND XSTORE TO MOVE AND
C                         STORE CHARACTER DATA FASTER ON THE CRAY
C   96-07-18  R.E.JONES   CHANGE EBCDIC FILL TO ASCII FILL
C   96-11-18  R.E.JONES   CHANGE NAME W3AI19 TO WXAI19
C
C USAGE: CALL WXAI19 (LINE, L, NBLK, N, NEXT)
C   INPUT ARGUMENT LIST:
C     LINE       - ARRAY ADDRESS OF LOGICAL RECORD TO BE BLOCKED
C     L          - NUMBER OF CHARACTERS IN LINE TO BE BLOCKED
C     N          - MAXIMUM CHARACTER SIZE OF NBLK
C     NEXT       - FLAG, INITIALIZED TO 0
C
C   OUTPUT ARGUMENT LIST:
C     NBLK       - BLOCK FILLED WITH LOGICAL RECORDS
C     NEXT       - CHARACTER COUNT, ERROR INDICATOR
C
C   EXIT STATES:
C     NEXT = -1  LINE WILL NOT FIT INTO REMAINDER OF BLOCK;
C                OTHERWISE, NEXT IS SET TO (NEXT + L)
C     NEXT = -2  N IS ZERO OR LESS
C     NEXT = -3  L IS ZERO OR LESS
C
C   EXTERNAL REFERENCES: XMOVEX XSTORE
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 90
C
C$$$
C
C METHOD:
C
C     THE USER MUST SET NEXT = 0 EACH TIME NBLK IS TO BE FILLED WITH
C LOGICAL RECORDS.
C
C     WXAI19 WILL THEN MOVE THE LINE OF INFORMATION INTO NBLK, STORE
C BLANK CHARACTERS IN THE REMAINDER OF THE BLOCK, AND SET NEXT = NEXT
C + L.
C
C     EACH TIME WXAI19 IS ENTERED, ONE LINE IS BLOCKED AND NEXT INCRE-
C MENTED UNTIL A LINE WILL NOT FIT THE REMAINDER OF THE BLOCK.  THEN
C WXAI19 WILL SET NEXT = -1 AS A FLAG FOR THE USER TO DISPOSE OF THE
C BLOCK.  THE USER SHOULD BE AWARE THAT THE LAST LOGICAL RECORD WAS NOT
C BLOCKED.
C
         INTEGER       L
         INTEGER       N
         INTEGER       NEXT
         INTEGER       WBLANK
C
         CHARACTER * 1 LINE(*)
         CHARACTER * 1 NBLK(*)
         CHARACTER * 1 BLANK
C
         SAVE
C
         DATA  WBLANK/Z'2020202020202020'/
C         DATA  WBLANK/Z''/
C   
C TEST VALUE OF NEXT.
C
         IF (NEXT.LT.0) THEN 
           RETURN
C
C TEST N FOR ZERO OR LESS       
C
         ELSE IF (N.LE.0) THEN
           NEXT = -2
           RETURN
C
C TEST L FOR ZERO OR LESS       
C
         ELSE IF (L.LE.0) THEN
           NEXT = -3
           RETURN
C
C TEST TO SEE IF LINE WILL FIT IN BLOCK.
C        
         ELSE IF ((L + NEXT).GT.N) THEN
           NEXT = -1
           RETURN
C
C FILL BLOCK WITH BLANK CHARACTERS IF NEXT EQUAL ZERO.
C BLANK IS ASCII BLANK, 20 HEX, OR 32 DECIMAL
C
         ELSE IF (NEXT.EQ.0) THEN
           CALL W3FI01(LW)
           IWORDS = N / LW
           CALL XSTORE(NBLK,WBLANK,IWORDS)
           IF (MOD(N,LW).NE.0) THEN
             NWORDS = IWORDS * LW
             IBYTES = N - NWORDS
             DO I = 1,IBYTES
               NBLK(NWORDS+I) = CHAR(32)
             END DO
           END IF
         END IF 
C
C MOVE LINE INTO BLOCK.
C
         CALL XMOVEX(NBLK(NEXT+1),LINE,L)
C
C ADJUST VALUE OF NEXT.
C
        NEXT = NEXT + L
C
        RETURN           
C
        END
