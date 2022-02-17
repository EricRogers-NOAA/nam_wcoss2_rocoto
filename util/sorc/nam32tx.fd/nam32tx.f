C$$$  MAIN PROGRAM DOCUMENTATION BLOCK                       
C                                                            
C MAIN PROGRAM: NAM32TX
C   PRGMMR: VUONG            ORG: NP11        DATE: 2004-10-19
C                                                            
C ABSTRACT: GENERATES THE FOUS60-78 SET OF NWS BULLETINS.  THESE
C   BULLETINS CONTAIN THE INITIAL NAM MODEL ANALYSES AND FORECASTS FOR 
C   POINTS IN THE U.S., CANADA, AND OVER ADJACENT WATERS. 
C      THE FORECASTS ARE PROVIDED FOR 6-HOURLY INTERVALS FROM 6 TO 60
C   HOURS AFTER 00Z AND 12Z.  THE FORECAST ARE PROVIDED FOR 6-HOURLY 
C   INTERVAL FROM 6 TO 48 HOURS FOR THE 06Z AND 18Z.  THIRTEEN FORECAST
C   PARAMETERS ARE OUTPUTTED IN THE BULLETINS.                              
C      THE PROGRAM ALSO GENERATES THE FOUS40-43 SET OF NWS BULLETINS.  
C   THEY CONTAIN THE FORECASTS FOR THE FREEZING LEVELS AND THE RELATIVE
C   HUMIDITIES AT THESE LEVELS FOR THE SAME POINTS AS ARE IN THE
C   FOUS60-78 BULLETINS, EXCEPT FOR THREE LOCATIONS.
C      IF AN I/O ERROR OCCURS, AN ERROR MESSAGE IS GENERATED AND
C   PROCESSING OF THE FORECAST GRIB MESSAGE IS ENDED.
C      A ROUTINE EXISTS TO COMPUTE A TABLE CONTAINING THE NAM MODEL  
C   TERRAIN HEIGHT AND NORMAL SURFACE PRESSURE AT THE NAM STATION 
C   LOCATIONS.  THIS WILL BE EXECUTED WHEN NECESSARY BY THE PROGRAMMER 
C   IN A CHECKOUT RUN.                                       
C                                                            
C PROGRAM HISTORY LOG:                                       
C   93-06-01  BOB HOLLERN, AUTHOR OF THE NAM60TX PROGRAM.
C
C   93-11-10  BOB HOLLERN, MODIFIED THE PROGRAM TO PRINT THE RUN 
C             COMPLETION CODE.                                          
C
C   95-11-02  BOB HOLLERN, CONVERTED THE PROGRAM TO RUN ON THE CRAY
C
C   97-06-12  BOB HOLLERN, MODIFIED TO ACCOMMODATE LI PDS CHANGES
C
C   97-06-13  BOB HOLLERN, MODIFIED PROGRAM TO START PROBLEM MESSAGES
C             WITH THE PHRASE "ERROR RETURN CODE" TO ENABLE THE SPA
C             TO MORE QUICKLY FIND THE MESSAGES IN THE PRINT OUTPUT.
C             ALSO, REMOVED THE ICODE LOGIC.
C                                                            
C   97-10-17  BOB HOLLERN, MODIFIED PROGRAM TO CHANGE TO THE BULLETIN
C             ORIGINATOR KWNO STARTING ON NOVEMBER 18, 1997 AT 15Z
C                                                            
C   98-01-21  BOB HOLLERN, REMOVED THE LOGIC WHICH SWITCHED THE
C             BULLETIN ORIGINATOR FROM KWBC TO KWNO STARTING ON
C             NOV. 18, 1997 AT 15Z.  THE BULLETIN ORIGINATOR IS
C             NOW 'KWNO'.
C
C   98-03-27  BOB HOLLERN, MADE THE PROGRAM Y2K COMPLIANT
C
C   99-12-07  BOB HOLLERN, MODIFIED THE PROGRAM TO GET THE NAM 
C             FORECAST MODEL DATA FROM THE GRIB GRID 221 FILES,
C             INSTEAD OF THE CURRENT GRIB GRID 104 FILES. THIS
C             WAS A MAJOR CHANGE, SO THE PROGRAM WAS RENAMED TO
C             NAM32TX TO DISTINQUISH IT FROM THE NAM60TX PROGRAM.
C             ALSO, THE PROGRAM WAS SETUP TO RUN IN THE FOUR
C             CYCLES T00Z, T06Z, T12Z, AND T18Z. THE NAM60TX PROGRAM
C             RAN ONLY IN THE T00Z AND T12Z CYCLES.
C
C   00-03-27  BRILL/ROGERS REPLACED CALL TO W3FC02 TO NEW LOCAL
C             ROUTINE W3FC03 TO ROTATE WINDS FROM LAMBERT CONFORMAL
C             GRID TO EARTH LAT/LONS OF STATIONS
C
C   01-04-24  BOI VUONG, MODIFIED THE PROGRAM TO GET THE NAM FORECAST
C             FILES FROM THE GRIB GRID 221. THE FORECAST HOURS ARE 
C             PROVIDED FOR 6-HOURLY INTERVALS FROM 6 TO 60 HOURS
C             FOR THE 00Z AND 12Z AND FROM 6 TO 48 HOURS FOR THE 
C             06Z AND 18Z.
C
C   04-10-19  BOI VUONG, CHANGED PROGRAM NAME ETA32TX TO NAM32TX
C   06-11-27  BOI VUONG, CORRECTED VERITCAL VELOCITY VALUE IF VV
C             IS GREATER THAN 999 ENCODE IT AS 999 (MISSING)
C
C   2012-11-02  VUONG      CHANGED VARIABLE ENVVAR TO CHARACTER*6
C
C  INPUT FILES:                                              
C                                                            
C       NAM MODEL OPERATIONAL GRIB GRID 221 FORECAST FILES         
C
C    FORT.11    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3200.tm00
C    FORT.12    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3203.tm00
C    FORT.13    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3206.tm00
C    FORT.14    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3209.tm00
C    FORT.15    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3212.tm00
C    FORT.16    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3215.tm00
C    FORT.17    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3218.tm00
C    FORT.18    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3221.tm00
C    FORT.19    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3224.tm00
C    FORT.20    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3227.tm00
C    FORT.21    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3230.tm00
C    FORT.22    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3233.tm00
C    FORT.23    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3236.tm00
C    FORT.24    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3239.tm00
C    FORT.25    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3242.tm00
C    FORT.26    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3245.tm00
C    FORT.27    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3248.tm00
C    FORT.28    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3251.tm00
C    FORT.29    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3254.tm00
C    FORT.30    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3257.tm00
C    FORT.31    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip3260.tm00
C
C      NAM INDEX FILES FOR GRIB GRID 221 FORECAST FILES
C
C    FORT.41    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i00
C    FORT.42    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i03
C    FORT.43    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i06
C    FORT.44    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i09
C    FORT.45    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i12
C    FORT.46    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i15
C    FORT.47    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i18
C    FORT.48    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i21
C    FORT.49    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i24
C    FORT.50    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i27
C    FORT.51    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i30
C    FORT.52    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i33
C    FORT.53    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i36
C    FORT.54    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i39
C    FORT.55    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i42
C    FORT.56    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i45
C    FORT.57    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i48
C    FORT.58    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i51
C    FORT.59    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i54
C    FORT.60    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i57
C    FORT.61    /com/nam/prod/nam.${PDY}/nam.${cycle}.awip32i60
C
C   WHERE PDY = YYYYMMDD,  YYYY IS THE YEAR, MM IS THE MONTH,
C                          DD IS THE DAY OF THE MONTH
C
C     AND CYCLE IS T00Z, T06Z, T12Z, OR T18Z
C
C  OUTPUT FILES:                                             
C                                                            
C     FT06F001   &&TEMP06                                    
C
C              - TEMPORARY FILE TO CONTAIN ERROR MESSAGES    
C                                                            
C     FT51F001   BULLETIN TRAN FILE                          
C
C              - FILE TO WHICH THE FOUS60-78 AND FOUS40-43
C                BULLETINS ARE WRITTEN
C                                                            
C   SUBPROGRAMS CALLED:                                      
C
C     UNIQUE:                                                
C
C         STNIJ1  FOUS60      FOUS40     FRZLVL  PRECIP
C         GETGBS  FOUS6048H   FOUS4048H  FRZLVL48H
C                                                            
C     LIBRARY:
C
C         W3FC02   W3FT01   W3FM08
C                                                            
C   EXIT STATES:                                             
C
C     COND = 0   SUCCESSFUL RUN                              
C                                                            
C                ERROR MESSAGES ARE GENERATED IF PROBLEMS OCCUR.
C                INCOMPLETE BULLETINS WILL BE FILLED WITH SLASHES.
C                                                            
C ATTRIBUTES:                                                
C   LANGUAGE: FORTRAN 90                                     
C   MACHINE:  IBM RS600 SP
C$$$                                                         
       PROGRAM  NAM32TX
C
       PARAMETER  (JF=96673)
       PARAMETER  (IIP=349,JJP=277)
C
       COMMON  /BLOCKA/ LIME
       COMMON  /BLOCKB/ NTOT1, NTOT2, SI, SJ, STNS1, STNS2
       COMMON  /BLOCKC/ IGTIME, IYEAR, IDAYMO, IMONTH
CER
       COMMON /STALOC/ XLATLN(2,162)
CER
C                                                            
       REAL    AR(IIP,JJP),     BR(IIP,JJP),   CR(IIP,JJP)
       REAL    FLDA(JF),    FLDB(JF)
       REAL    SI(224),         SJ(224)
C                                                            
       INTEGER   IUNITS(42)
       INTEGER   LIME(224,11,13),   JSLASH
       INTEGER   JPDS(27),   KPDS(27)
       INTEGER   KF
       INTEGER   JGDS(100),   KGDS(100)
       INTEGER   PDSFLD(45)
C                                                            
       LOGICAL   IGENTB,   IFIRST
       LOGICAL   LBM(JF)
C                                                            
       CHARACTER*8   DDNM,      KEYWD,   ISLASH
C                                                            
       CHARACTER*5   STNS1(162),   STNS2(62)
C
       CHARACTER*4   ICYCLE
       CHARACTER*6   ENVVAR
       CHARACTER*80  FILEB,FILEI,FILEO

C                                                            
130    FORMAT ( A )
C
       EQUIVALENCE   (FLDA(1),AR(1,1)),    (FLDB(1),BR(1,1))
       EQUIVALENCE   (ISLASH,JSLASH)
C                                                            
       DATA  DDNM  / 'FT51F001' /
       DATA  IFIRST/ .TRUE. /
       DATA  KEYWD / 'TRAN    ' /
C                                                            
       DATA  IGENTB / .FALSE. /
       DATA  IGRSZ / 349 /
       DATA  ISLASH/ '////////' /
       DATA  JGRSZ / 277 /
       DATA  LIN   / 0 / 
C                                                            
       DATA  NCYCLK/ 0 /
C
       DATA  PDSFLD / 
C
C      .98230 SIG R H     47 HSIG 96 HSIG R H      18 HSIG  47 HSIG
     A  52, 107, 9823,    52, 108, 12128,          52, 108, 4655,
C
C       700MB VER VEL     BEST LIFTED INDEX        MSL PRESSURE
     B  39, 100, 700,     132, 116, 46080,         2, 102, 0,
C
C       .98230 SIG U      .982330 SIG V            500 MB HGT 
     C  33, 107, 9823,    34, 107, 9823,           7, 100, 500,
C
C       1000 MB HGT       .9823 SIG TMP            .8967 SIG TMP
     D  7, 100, 1000,     11, 107, 9823,           11, 107, 8967,
C
C       .7848 SIG TMP     SFC A PCP                 SFC HGT
     E  11, 107, 7848,    61, 1, 0,                 7, 1, 0 /
C
       DATA  IUNITS /  11, 41,  12, 42,  13, 43,  14, 44,  15, 45,
     +                 16, 46,  17, 47,  18, 48,  19, 49,  20, 50,
     +                 21, 51,  22, 52,  23, 53,  24, 54,  25, 55,
     +                 26, 56,  27, 57,  28, 58,  29, 59,  30, 60,
     +                 31, 61/

C
100    FORMAT( ///5X, 
     A         'ERROR RETURN CODE FROM ROUTINE GETGB = ', I3,
     B         ///5X, 'NOT ABLE TO PROCESS FOLLOWING',
     C         1X, 'GRIB MESSAGE USING THE FOLLOWING PDS DATA: ',
     D         /5X, 10(I5,1X), /5X, 5(I5,1X) )
C
       CALL W3TAGB('NAM32TX',2004,0293,0293,'NP11')
C                                                            
       LUGO=71
       ENVVAR='FORT  '
       WRITE(ENVVAR(5:6),FMT='(I2)') LUGO
       CALL GETENV(ENVVAR,FILEO)
       OPEN(LUGO,FILE=FILEO,ACCESS='DIRECT',RECL=1280)
C
       IREC = 0
C
C      CONVERT STATION LAT/LONG TO SUPER C-GRID I,J COORDINATES
       CALL  STNIJ1
C                                                            
       IHOUR = 0
C                                                            
C      INITIALIZE LIME ARRAY TO SLASHES, WHICH WILL BE OUTPUTTED
C      FOR MISSING DATA IN ETS BULLETINS                    
C                                                            
C      TOTAL NUMBER OF STATIONS                              
       NTOT = NTOT1 + NTOT2
C                                                            
       DO  I = 1,NTOT
         DO  J = 1,11
           DO  K = 1,13
             LIME(I,J,K) = JSLASH
           END DO
         END DO
       END DO
C                                                            
C  LOOP FOR THE RF FILES:  00 HR - 60 HR                     
C                                                            
       READ( 5,130) ICYCLE
C
       WRITE(6,'(A,1X,A)') ' ICYCLE = ', ICYCLE
C
C      SET JCYCLE TO 0 IF THIS IS THE 00Z OR 12Z CYCLE, SET IT TO 1 IF
C      THIS IS THE 06Z OR 18Z CYCLE.
C
       IF ( ICYCLE .EQ. 't00z' .OR. ICYCLE .EQ. 't12z' .OR.
     +      ICYCLE .EQ. 'T00Z' .OR. ICYCLE .EQ. 'T12Z' ) THEN
         JCYCLE = 0
         NFL = 21
       ELSE
         JCYCLE = 1
         NFL = 17
       END IF
C
       WRITE(6,'(A,I0)') ' MAIN:  JCYCLE = ', JCYCLE
C
       IU = 0
C
       DO  40000  K = 1,NFL
C
C        FILE UNIT NUMBERS
         IU = IU + 1
         LUGB = IUNITS(IU)
         WRITE(ENVVAR(5:6),FMT='(I2)') LUGB
         CALL GETENV(ENVVAR,FILEB)
C
         IU = IU + 1
         LUGI = IUNITS(IU)
         WRITE(ENVVAR(5:6),FMT='(I2)') LUGI
         CALL GETENV(ENVVAR,FILEI)
C                                                            
         IR2 = MOD(K,2)
C
C        SKIP 03Z, 09Z, AND .ETC FILES IF 00Z OR 12Z CYCLE
C
         IF ( JCYCLE .EQ. 0 .AND. IR2 .EQ. 0 ) GO TO 40000
C                                                            
         CALL  BAOPENR( LUGB, FILEB, IRET )
C
         WRITE(6,'(A,I0)')' BAOPENR: LUGB = ', LUGB
         WRITE(6,'(A,A)')' BAOPENR: FILE NAME = ', FILEB
         WRITE(6,'(A,I0)')' BAOPENR: IRET = ', IRET
C
         CALL  BAOPENR( LUGI, FILEI, IRET )
C
         WRITE(6,'(A,I0)')' BAOPENR: LUGI = ', LUGI
         WRITE(6,'(A,A)')' BAOPENR: FILE NAME = ', FILEI
         WRITE(6,'(A,I0)')' BAOPENR: IRET = ', IRET
C
C  LOOP FOR 12 VARIABLES                                     
C
       JJ = 0
C                                                            
C      SHOULD SPECIAL CHECKOUT RUN BE MADE TO GENERATE THE ETS MODEL  
C      TERRAIN HEIGHT AND NORMAL SURFACE PRESSURE AT THE LOCATIONS OF  
C      THE FOUS STATIONS?                                    
C                                                            
       IF ( IGENTB ) THEN
C        WANT SURFACE HEIGHTS                                
         JJ = 42
       ENDIF
C                                                            
       IF ( IR2 .EQ. 1 ) THEN
         IHOUR = IHOUR + 1
       END IF
C                                                            
C      FORECAST PARAMTERS' LOOP                    
C
       DO  35000  NVAR = 1,12
C
C  FIND AND UNPACK DESIRED GRIB FIELD              
C
C        DEFINE THE INFORMATION NEEDED BY GETGB TO READ IN AND UNPACK
C        THE DESIRED GRIB DATA FIELD
C
         JSKIP = 0
C
C        INITIALIZE ALL OF JPDS TO -1
         JPDS = -1
C
C        SEE DESCRIPTION OF ARRAY KPDS IN W3FI63 FOR JPDS DEFINITIONS
         JPDS(3) = 221
         JJ = JJ + 1
         JPDS(5) = PDSFLD(JJ)
         JJ = JJ + 1
         JPDS(6) = PDSFLD(JJ)
         JJ = JJ + 1
         JPDS(7) = PDSFLD(JJ)
C
C###################################################
CCC      WRITE(6,118) JPDS
118      FORMAT( 1X, 'JPDS: ', 3(/1x,10(1x,I5)))
C###################################################
C
C        READ IN AND UNPACK THE REQUESTED GRIB DATA FIELD
C
         CALL  GETGB( LUGB, LUGI, JF, JSKIP, JPDS, JGDS, KF,
     A                KMSGNO, KPDS, KGDS, LBM, FLDA, IRET )
C
C
C###################################################
CCC    WRITE(6,113) KPDS
113    FORMAT( 1X, 'MAIN: KPDS:',  3(/1X,10(I5,2X) ) )
CCC    PRINT *, 'MAIN: 1: NVAR = ', NVAR    
CCC    WRITE(6,107) (FLDA(II),II=1,10)
107    FORMAT( 1X, 'FLDA: ',5(/1X, 4(Z16.16,1X) ))
C###################################################
C
       IF ( IRET .NE. 0 ) THEN
         WRITE(6,100) IRET, (JPDS(II),II=1,15)
C
         IF ( NVAR .EQ. 7 .OR. NVAR .EQ. 8 ) THEN
             JJ = JJ + 3
         END IF
         GO TO 35000
       ENDIF
C                                                  
       IF ( IFIRST ) THEN
         IFIRST = .FALSE.
C
C        GET DATE/TIME DATA FROM PDS
         IYEAR = KPDS(8)
C
C        IYEAR = 100 FOR YEAR 2000
C        IYEAR = 1 FOR YEAR 2001
C
         IF ( IYEAR .EQ. 100 ) IYEAR = 0
         IMONTH = KPDS(9)
         IDAYMO = KPDS(10)
         IGTIME = KPDS(11)
C
         WRITE(*,'(A,I0)') ' MAIN: IGTIME = ', IGTIME
C
       ENDIF
C
       IF ( IGENTB ) THEN
         CALL  GENTBL( FLDA )
         GO TO 50000
       ENDIF
C
       IF ( NVAR .EQ. 12 ) THEN
C        COMPUTE 6 AND 12 HOURLY STATION ACCUMULATED PRECIP AMOUNTS
         IF ( K .GT. 1 ) THEN
           IF (JCYCLE .EQ. 0) CALL PRECIP(JCYCLE, K, IIP, JJP, AR)
           IF (JCYCLE .EQ. 1) CALL PRECIP48H(JCYCLE, K, IIP, JJP, AR)
         ELSE
           GO TO 35000
         ENDIF
C
       ENDIF
C
C      READ IN SECOND DATA FIELD FOR WINDS AND THICKNESS PROCESSING
C      NVAR = 7 OR NVAR = 8
C                                                  
       IF ( NVAR .NE. 7 .AND. NVAR .NE. 8 )  GO TO 5000 
C
         JSKIP = 0
C
C        INITIALIZE ALL OF JPDS TO -1
         JPDS = -1
C
C        SEE DESCRIPTION OF ARRAY KPDS IN W3FI63 FOR JPDS DEFINITIONS
         JPDS(3) = 221
         JJ = JJ + 1
         JPDS(5) = PDSFLD(JJ)
         JJ = JJ + 1
         JPDS(6) = PDSFLD(JJ)
         JJ = JJ + 1
         JPDS(7) = PDSFLD(JJ)
C
         CALL  GETGB( LUGB, LUGI, JF, JSKIP, JPDS, JGDS, KF,
     A                KMSGNO, KPDS, KGDS, LBM, FLDB, IRET )
C
       IF ( IRET .NE. 0 ) THEN
         WRITE(6,100) IRET, (JPDS(II),II=1,15)
         GO TO 35000
       ENDIF
C                                                  
       IF ( NVAR  .EQ.   7 ) GO TO 5000
C
C      COMPUTE 1000-500 MB THICKNESS                   
C                                                  
       DO  I=1,IGRSZ                         
         DO  J=1,JGRSZ                         
           AR(I,J) = AR(I,J) - BR(I,J)             
         END DO
       END DO
C                                                  
 5000  CONTINUE                                    
C
C      IN 06Z AND 18Z CYCLE, AT FORECAST HOURS 03, 09, 15, ..., ETC,
C      ONLY THE 3-HOURLY PRECIPITATION BUCKET IS GOTTEN.
C                                                  
       IF ( JCYCLE .EQ. 1 .AND. IR2 .EQ. 0 ) GO TO 35000
C
C      FILL LIME ARRAY FOR OUTPUT.                     
C
       DO  20000  NSTA = 1,NTOT                    
C                                                  
C         INTERPOLATE GRIDPOINT DATA TO STATION.          
C                                                  
          CALL W3FT01( SI(NSTA),SJ(NSTA),AR,X,IGRSZ,JGRSZ,NCYCLK,LIN )
C
C#################################################################
CCC       WRITE(6,830) NSTA,SI(NSTA),SJ(NSTA),X
830       FORMAT(1X,'NSTA = ', I3,3X,'SI,SJ = ', 2(F5.1,2X), 1X,
     a       'X = ', F10.0)
C#################################################################
C                                                  
          IF  ( NVAR .EQ. 7 .OR. NVAR .EQ. 8 ) THEN
           CALL W3FT01( SI(NSTA),SJ(NSTA),BR,V,IGRSZ,JGRSZ,NCYCLK,LIN )
          END IF
C                                                  
C         COMPUTED GO TO STATEMENT FOR ENTERING DATA INTO THE LIME ARRAY
C                                                            
          GO TO (  6000, 7000, 8000, 9000, 10000, 11000,
     A             12000, 14000, 15000, 16000, 17000, 18000 ), NVAR
C                                                            
C         CHANGE DATA'S UNITS, ROUND TO NEAREST INTEGER,      
C         LIMIT DATA'S RANGE, AND/OR CHANGE THE SIGN          
C         OF DATA.  THEN ENTER DATA INTO LIME ARRAY.          
C                                                            
C         SIGMA LEVEL 1 RELATIVE HUMIDITY                     
C                                                            
 6000     CONTINUE
          L1 = X + .5
          IF ( L1 .GT. 99 ) L1 = 99
          IF ( L1 .LT. 1 ) L1 = 1
          LIME(NSTA,IHOUR,2) = L1
          GO TO 20000
C                                                            
C         SIGMA LEVEL 2 RELATIVE HUMIDITY                     
C                                                            
 7000     CONTINUE
          L1 = X + .5
          IF ( L1 .GT. 99 ) L1 = 99
          IF ( L1 .LT. 1 ) L1 = 1
          LIME(NSTA,IHOUR,3) = L1
          GO TO 20000
C                                                            
C         SIGMA LEVEL 3 RELATIVE HUMIDITY                     
C                                                            
 8000     CONTINUE
          L1 = X + .5
          IF ( L1 .GT. 99 ) L1 = 99
          IF ( L1 .LT. 1 ) L1 = 1
          LIME(NSTA,IHOUR,4) = L1
          GO TO 20000
C                                                            
C         700MB VERTICAL VELOCITY                             
C                                                            
 9000     CONTINUE
          VV = -100. * X
          L1 = VV + SIGN(.5,VV)
C         IF VV IS LESS THAN -9.9MB, ENCODE IT AS -99         
          IF ( L1 .GT. 999 ) L1 = 999
          IF ( L1 .LT. -99 ) L1 = -99
          LIME(NSTA,IHOUR,5) = L1
          GO TO 20000
C                                                            
C         4-LEVEL LIFTED INDEX                                
C                                                            
10000     CONTINUE
          L1 = X + SIGN(.5,X)
C         ADD VALUE TO 100 IF LIFTED INDEX IS NEGATIVE        
          IF ( L1 .LT. 0 ) L1 = 100 + L1
          LIME(NSTA,IHOUR,6) = L1
          GO TO 20000
C                                                            
C         MEAN SEA LEVEL PRESSURE, IN MILLIBARS,              
C         WITH HUNDREDS POSITION OMITTED                      
C                                                            
11000    CONTINUE
         L1 =  .01*X + .5
         LIME(NSTA,IHOUR,7) = MOD(L1,100)
         GO TO 20000
C                                                            
C        CALCULATE WIND SPEED AND DIRECTION ( 850 MB )       
C                                                            
12000    CONTINUE
         GU = X
         GV = V
         XLAT1 = 50.0
         CENLON = -107.0
C                                                            
         CALL W3FC03( -XLATLN(2,NSTA),GU,GV,CENLON,XLAT1,
     1            DIR, SPEED )
c        CALL W3FC02( FID, FJD, GU, GV, DIR, SPEED )
C                                                            
         LIME(NSTA,IHOUR,9) = 1.94 * SPEED + .5
         IF ( LIME(NSTA,IHOUR,9) .EQ. 0 ) GO TO 13000
         LIME(NSTA,IHOUR,8) = .1 * DIR + .5
         IF ( LIME(NSTA,IHOUR,8) .EQ. 0 ) LIME(NSTA,IHOUR,8) = 36
         GO TO 20000
13000    LIME(NSTA,IHOUR,8)= 0
         GO TO 20000
C                                                            
C        1000-500 MB THICKNESS                               
C                                                            
14000    CONTINUE
         L1 = .1 * X + .5
         LIME(NSTA,IHOUR,10) = MOD(L1,100)
         GO TO 20000
C                                                            
C        SIGMA LEVEL 1 TEMPERATURE ( IN DEGREES CELSIUS )    
C                                                            
15000    CONTINUE
         L1 = X - 273.16 + .5
         IF ( L1 .LT. 0 ) L1 = 100 + L1
         LIME(NSTA,IHOUR,11) = L1
         GO TO 20000
C                                                            
C        SIGMA LEVEL 3 TEMPERATURE ( IN DEGREES CELSIUS )    
C                                                            
16000    CONTINUE
         L1 = X - 273.16 + .5
         IF ( L1 .LT. 0 ) L1 = 100 + L1
         LIME(NSTA,IHOUR,12) = L1
         GO TO 20000
C                                                            
C        SIGMA LEVEL 5 TEMPERATURE ( IN DEGREES CELSIUS )    
C                                                            
17000    CONTINUE
         L1 = X - 273.16 + .5
         IF ( L1 .LT. 0 ) L1 = 100 + L1
         LIME(NSTA,IHOUR,13) = L1
         GO TO 20000
C                                                            
C        6-HOURLY PRECIPITATION AMOUNTS IN HUNDREDTHS OF INCHES
C
18000    CONTINUE
         IF ( X .LT. 0.0 ) X = 0.0
         LIME(NSTA,IHOUR,1) = 100.*X + .5
C
20000  CONTINUE
C                                                            
35000  CONTINUE
C                                                            
40000  END DO
C                                                            
C      GENERATE THE FOUS60-78 BULLETINS                      
       IF ( JCYCLE .EQ. 0 ) CALL FOUS60 ( IREC )
       IF ( JCYCLE .EQ. 1 ) CALL FOUS6048H ( IREC )
C                                                            
C      GET THE STATION FREEZING LEVEL HEIGHT AND RH AT THE HEIGHT 
       IF ( JCYCLE .EQ. 0 ) CALL  FRZLVL( IUNITS, JCYCLE, MERR )
       IF ( JCYCLE .EQ. 1 ) CALL  FRZLVL48H ( IUNITS, JCYCLE, MERR )
C
       IF ( MERR .EQ. 1 ) THEN
         GO TO 50000
       ENDIF
C                                                            
C      GENERATE THE FOUS40-43 BULLETINS                      
       IF ( JCYCLE .EQ. 0 ) CALL FOUS40 ( IREC )
       IF ( JCYCLE .EQ. 1 ) CALL FOUS4048H ( IREC )
C                                                            
50000  CONTINUE
       CALL W3TAGE('NAM32TX')
C                                                            
       STOP
       END
