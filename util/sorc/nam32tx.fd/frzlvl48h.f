       SUBROUTINE  FRZLVL48H( IUNITS, JCYCLE, MERR )
C$$$  SUBPROGRAM DOCUMENTATION BLOCK                                  
C                                                                     
C SUBPROGRAM:  FRZLVL48H       GETS STN FREEZING LVL HGT AND RH AT HGT
C   AUTHOR: BOB HOLLERN        ORG: NMC411        DATE: 88-05-05      
C                                                                     
C ABSTRACT: GETS THE FREEZING LEVEL IN METERS AND THE RELATIVE HUMIDITY
C   AT THE FREEZING LEVEL FOR EACH OF THE GIVEN STATIONS.  THE TASK   
C   INVOLVES READING IN THE FIELDS THAT CONTAIN THESE QUANTITIES,     
C   UNPACKING THE FIELDS, AND INTERPOLATING THE GRID POINT DATA TO    
C   EACH OF THE THE STATION COORDINATES.  THIS IS DONE FOR THE 12, 18,
C   24, ..., 48 HOUR FORECAST FIELDS.  THE FREEEZING LEVEL VALUES ARE 
C   CONVERTED FROM METERS TO FEET AND THE RH IS ROUNDED TO THE        
C   NEAREST 5%.                                                       
C           IF AN I/O ERROR OCCURS, AN ERROR MESSAGE IS GENERATED     
C   AND PROCESSING OF THE FORECAST FIELD ENDS.                        
C                                                                     
C PROGRAM HISTORY LOG:                                                
C   88-05-05  BOB HOLLERN, AUTHOR                                     
C   95-??-??  BOB HOLLERN, CONVERTED THE PROGRAM TO RUN ON THE CRAY
C                                                                     
C USAGE:    CALL FRZLVL48H( IUNITS, JCYCLE, MERR )
C                                                                     
C   INPUT ARGUMENT LIST:                                              
C     IUNITS   -   FORTRAN UNIT NUMBERS USED TO ACCESS THE GRIB FILES
C     JCYCLE   -   FLAG SET TO 0, IF THIS IS THE 00Z OR 12Z CYCLE;
C                  SET TO 1, IF THIS IS THE 06Z OR 18Z CYCLE
C     SI       -   /BLOCKB/, R*4 ARRAY CONTAINING THE SUPER-C GRID    
C                  I COORDINATE FOR EACH OF THE BULLETIN STATIONS     
C     SJ       -   /BLOCKB/, R*4 ARRAY CONTAINING THE SUPER-C GRID    
C                  J COORDINATE FOR EACH OF THE BULLETIN STATIONS     
C                                                                     
C   OUTPUT ARGUMENT LIST:                                             
C     LFRZRH   -   /BLOCKA/, ARRAY TO CONTAIN THE STATION BULLETIN DATA
C     MERR     -  ERROR RETURN VARIABLE.  IF =0; NO ERROR;            
C                 IF =1, FIELDS NOT CURRENT.                          
C                                                                     
C  INPUT FILES:                                                       
C                                                                     
C       NAM MODEL OPERATIONAL GRIB FORECAST FILES         
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
C   WHERE PDY = yyyymmdd,  yyyy IS THE YEAR, mm IS THE MONTH,
C                          dd IS THE DAY OF THE MONTH
C
C     AND CYCLE IS t00z, t06z, t12z, or t18z
C
C  OUTPUT FILES:                                                      
C                                                                     
C     FT06F001   &&TEMP06                                             
C                - TEMPORARY FILE TO CONTAIN ERROR MESSAGES           
C                                                                     
C ATTRIBUTES:                                                         
C   LANGUAGE: FORTRAN  90                                             
C$$$                                                                  
       COMMON  /BLOCKA/ LFRZRH
       COMMON  /BLOCKB/ NTOT1, NTOT2, SI, SJ, STNS1, STNS2
C                                                                     
       REAL   AR(349,277),   FLDA(96673)
       REAL   SI(224),       SJ(224)
C                                                                     
       INTEGER   NFLAG(224),  JSLASH
       INTEGER   IDFRRH(6),   IDFRZL(6),     LFRZRH(224,9,13)
       INTEGER   IUNITS(42)
       INTEGER   JPDS(27),   KPDS(27)
       INTEGER   KF
       INTEGER   JGDS(100),   KGDS(100)
       INTEGER   PDSFLD(6)
C                                                            
       LOGICAL   IFIRST
       LOGICAL   LBM(96673)
C                                                            
       CHARACTER*8   ISLASH
C                                                            
       CHARACTER*5   STNS1(162),   STNS2(62)
C                                                            
       EQUIVALENCE   (FLDA(1),AR(1,1))
       EQUIVALENCE   (ISLASH,JSLASH)
C                                                                     
       DATA  PDSFLD / 
C
C         273.16 DEG HGT     273.16 DEG R.H.
     +      7,  4,  0,        52,  4,  0  /
C
       DATA  IGRSZ / 349 /
       DATA  IHOUR / 0 /
       DATA  JGRSZ / 277 /
       DATA  JJ    / 1 /
       DATA  KFLAG / 0 /
       DATA  NCYCLK/ 0 /
       DATA  ISLASH/ '////////' /
       DATA  LIN   / 0 / 
C                                                                     
100    FORMAT( ///5X,
     A         'ERROR RETURN CODE FROM ROUTINE GETGB = ', I3,
     B         ///5X, 'NOT ABLE TO PROCESS FOLLOWING',
     C         1X, 'GRIB DATA FIELD USING THE FOLLOWING PDS DATA: ',
     D         /5X, 10(I5,1X), /5X, 5(I5,1X) )
C                                                            
       JF = 96673
C
C      INITIALIZE ERROR RETURN VARIABLE TO NO PROBLEMS                
       MERR = 0
C                                                                     
C      INITIALIZE TO SLASHES, WHICH WILL BE OUTPUTTED
C      FOR MISSING DATA IN NAM BULLETINS                    
C                                                            
       DO  I = 1,111
         DO  J = 1,7
           DO  K = 1,2
             LFRZRH(I,J,K) = JSLASH
           END DO
         END DO  
       END DO
C                                                                     
C                                                            
C  LOOP FOR THE NAM FILES:  00 HR - 48 HR                     
C                                                            
       NFL = 17
       IU = 8
C
       DO  50000  K = 5,NFL
C        FILE UNIT NUMBERS
         IU = IU + 1
         LUGB = IUNITS(IU)
         IU = IU + 1
         LUGI = IUNITS(IU)
C                                                            
         IR2 = MOD(K,2)
C
C        SKIP 03Z, 09Z, ... FILES
C
         IF ( IR2 .EQ. 0 ) GO TO 50000
C                                                            
C  LOOP FOR 2 VARIABLES                                     
C
         JJ = 0
C                                                            
         IHOUR = IHOUR + 1
C                                                            
         DO  42000  NVAR = 1,2
C
C          DEFINE THE INFORMATION NEEDED BY GETGB TO GET AND
C          UNPACK THE DESIRED GRIB MESSAGE
C
           JSKIP = 0
C
C          INITIALIZE ALL OF JPDS TO -1
           JPDS = -1
C
C          SEE DESCRIPTION OF ARRAY KPDS IN W3FI63 FOR
C          JPDS DEFINITIONS
           JPDS(3) = 221
           JJ = JJ + 1
           JPDS(5) = PDSFLD(JJ)
           JJ = JJ + 1
           JPDS(6) = PDSFLD(JJ)
           JJ = JJ + 1
           JPDS(7) = PDSFLD(JJ)
C
C########################################################
CCC        WRITE(6,118) JPDS
118        FORMAT( 1X, 'FRZLVL: JPDS: ', 3(/1x,10(1x,I5)))
C########################################################
C
C          READ IN AND UNPACK THE REQUESTED GRIB DATA FIELD
C
           CALL  GETGB( LUGB, LUGI, JF, JSKIP, JPDS, JGDS, KF,
     A                  KMSGNO, KPDS, KGDS, LBM, FLDA, IRET )
C
C###########################################################
CCC    PRINT *, 'FRZLVL: GETGB: IRET = ', IRET
CCC    WRITE(6,113) KPDS
113    FORMAT( 1X, 'FRZLVL: KPDS:',  5(/1X, 7(I7,2X) ) )
CCC    PRINT *, 'KMSGNO = ', KMSGNO
CCC    PRINT *, 'FRZLVL: KF = ', KF
CCC    WRITE(6,107) (FLDA(II),II=1,4)
107    FORMAT( 1X, 'FLDA: ', 4(Z16,1X), 4(Z16,1X) )
C###########################################################
C
           IF ( IRET .NE. 0 ) THEN
             WRITE(6,100) IRET, (JPDS(II),II=1,15)
             GO TO 42000
           ENDIF
C                                                  
           JSKIP = 0
C                                                                     
           DO  40000  NSTA = 1,111
C                                                                     
             CALL W3FT01(SI(NSTA),SJ(NSTA),AR,X,IGRSZ,JGRSZ,NCYCLK,LIN)
C
             IF  ( NVAR .EQ. 2 )  GO TO 32000
C                                                                     
C            THE X-VALUE FROM THE INTERPOLATION ROUTINE (W3FT01) IS   
C            THE FREEZING LEVEL (RELATIVE TO SEA LEVEL) IN METERS     
C            AT THE FOUS LOCATION                                     
C                                                                     
             IF  ( X .LT. 0.0 )  GO TO 28000
C            CONVERT FROM METERS TO FEET                              
             FRLVL = 3.28 * X
C            ROUND VALUE TO THE NEAREST HUNDREDS OF FEET              
             LFRZRH(NSTA,IHOUR,1) = .01 * FRLVL + .5
             NFLAG(NSTA) = 0
C
             GO TO 40000
C                                                                     
C            IF FREEZING LEVEL IS NEGATIVE, SET IT TO ZERO            
28000        CONTINUE
             LFRZRH(NSTA,IHOUR,1) = 0
C                                                                     
C            WHEN FREEZING LEVEL IS BELOW MEAN SEA LEVEL              
C            HUMIDITY VALUE WILL BE SET TO SLASHES                    
             NFLAG(NSTA) = 1
             GO TO 40000
C                                                                     
C            RELATIVE HUMIDITY AT THE FREEZING LEVEL                  
C                                                                     
32000        CONTINUE
             IF  ( NFLAG(NSTA) .EQ. 1 )  GO TO 40000
             KRH = X + .5
C                                                                     
C            RELATIVE HUMIDITY IS ROUNDED TO THE                      
C            NEAREST 5% (RANGE: 5% TO 95%)                            
C                                                                     
             KR5 = MOD(KRH,5)
             KQT5 = KRH / 5
             IF  ( KR5 .GT. 2 ) KQT5 = KQT5 + 1
             KRH = 5 * KQT5
             IF ( KRH .LT. 5 ) KRH = 5
             IF ( KRH .GT. 95 ) KRH = 95
             LFRZRH(NSTA,IHOUR,2) = KRH
C                                                                     
40000      CONTINUE
C                                                                     
C                                                                     
42000    CONTINUE
C                                                                     
50000  CONTINUE
C                                                                     
90000  CONTINUE
       RETURN
       END
