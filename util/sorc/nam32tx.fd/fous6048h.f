       SUBROUTINE  FOUS6048H( IREC )
C$$$  SUBPROGRAM DOCUMENTATION BLOCK                                  
C
C SUBPROGRAM: FOUS6048H      GENERATES THE FOUS60-78 BULLETINS        
C   PRGMMR: BOB HOLLERN      ORG: NMC411     DATE: 93-06-01           
C                                                                     
C ABSTRACT: FORMATS THE FOUS60 TO FOUS78 NAM BULLETINS.  EACH BULLETIN
C   CONTAINS THE FORECASTS, CONSISTING OF 13 PARAMETERS, FOR SIX      
C   STATIONS.  TABLES ARE USED TO DETERMINE WHICH STATION GOES IN A   
C   PARTICULAR BULLETIN.  WHEN THE FORMATTING OF A BULLETIN IS DONE,  
C   IT IS WRITTEN TO THE TRANSMISSION FILE.                           
C                                                                     
C PROGRAM HISTORY LOG:                                                
C   93-06-01  BOB HOLLERN, AUTHOR                                     
C                                                                     
C USAGE:    CALL FOUS6048H
C                                                                     
C   INPUT ARGUMENT LIST:                                              
C     IGTIME   -   /BLOCKC/  INITIAL GMT HOUR OF THE DATA             
C     IDAYMO   -   /BLOCKC/  INITIAL GMT DAY OF THE MONTH OF THE DATA 
C     IMONTH   -   /BLOCKC/, INITIAL GMT MONTH OF THE DATA            
C     IYEAR    -   /BLOCKC/, INITIAL GMT YEAR OF THE DATA             
C     STNS1    -   /BLOCKB/, ARRAY CONTAINING THE BULLETIN STATION IDS
C     LIME     -   /BLOCKA/, ARRAY TO CONTAIN THE STATION BULLETIN DATA
C                                                                     
C   OUTPUT FILE:                                                      
C     FT51F001 -   BULLETIN TRANSMISSION FILE.                        
C                                                                     
C   REMARKS:                                                          
C                                                                     
C ATTRIBUTES:                                                         
C   LANGUAGE: FORTRAN 90                                              
C$$$                                                                  
       COMMON  /BLOCKA/ LIME
       COMMON  /BLOCKB/ NTOT1, NTOT2, SI, SJ, STNS1, STNS2
       COMMON  /BLOCKC/ IGTIME, IYEAR, IDAYMO, IMONTH
C                                                                     
       REAL      SI(224),   SJ(224)
C                                                                     
       INTEGER   ISTA(120),   JSTA(44),    KSTA(164)
       INTEGER   LN(2,13),    LINE(64)
       INTEGER   KSL4
       INTEGER   LIME(224,11,13)
C
       CHARACTER*3840   NBLK
C
       CHARACTER*72   IHED3
C
       CHARACTER*32   IHED2
C                                                                     
       CHARACTER*24   IHED1
C
       CHARACTER*8    IVAL,   ISL4,   BLANKS
C                                                                     
       CHARACTER*5   STNS1(162),  STNS2(62)
C                                                                     
       CHARACTER*4   ITAB(27),   JTAB(27),   IENDL
       CHARACTER*4   BULTN(13)
C                                                                     
       CHARACTER*3   JMONTH(12)
C                                                                     
       CHARACTER*1   LINFD,       IEOT,   LF
C                                                                     
       EQUIVALENCE    (KSTA(1),ISTA(1)),   (KSTA(121),JSTA(1))
       EQUIVALENCE    (ISL4,KSL4)
C                                                                     
C              FOUS60 LOCATIONS                                       
       DATA  ISTA  / 42, 106, 30, 107, 92, 91,
C                                                                     
C              FOUS61 LOCATIONS                                       
     A   26,  27,  29,  28,  32,  33,
C                                                                     
C              FOUS62 LOCATIONS                                       
     B   31,  99,  67,  68,  95,  93,
C                                                                     
C              FOUS63 LOCATIONS                                       
     C   66,  96,  65,  64,  63,  94,
C                                                                     
C              FOUS64 LOCATIONS                                       
     D   23,  24,  22,  34,  25,  21,
C                                                                     
C              FOUS65 LOCATIONS                                       
     E   58,  39,  38,  98,  36,  61,
C                                                                     
C              FOUS66 LOCATIONS                                       
     F   60,  40,  59,  56,  41,  57,
C                                                                     
C              FOUS67 LOCATIONS                                       
     G   20,  19,  16,  12,  17,  18,
C                                                                     
C              FOUS68 LOCATIONS                                       
     H   15,  62,  71,  13,  14,  47,
C                                                                     
C              FOUS69 LOCATIONS                                       
     I   51,  52,  53,  55,  54,  70,
C                                                                     
C              FOUS70 LOCATIONS                                       
     J   10,  11,  37,   3,   4,  35,
C                                                                     
C              FOUS71 LOCATIONS                                       
     K   50,  48,  49,  72,  69,   9,
C                                                                     
C              FOUS72 LOCATIONS                                       
     L    1,   2,   5,   6,   8, 108,
C                                                                     
C              FOUS73 LOCATIONS                                       
     M    7,  46,  45,  43,  44,  97,
C                                                                     
C              CANADIAN LOCATIONS                                     
C                                                                     
C              FOUS74 LOCATIONS                                       
     N   73,  74,  75,  76,  77,  78,
C                                                                     
C              FOUS75 LOCATIONS                                       
     O   79,  80,  81,  82,  83,  84,
C                                                                     
C              FOUS76 LOCATIONS                                       
     P   85,  86,  87,  88,  89,  90,
C                                                                     
C              GULF OF MEXICO LOCATIONS                               
C                                                                     
C              FOUS77 LOCATIONS                                       
     Q  100, 101, 102, 103, 104, 105,
C                                                                     
C              FOUS78 LOCATIONS                                       
     R  109, 110, 111, 112, 113, 114,
C                                                                     
C    ***   FOLLOWING DATA ARE CURRENTLY NOT USED   ***                 
C                                                                     
C          NGM FOUE80 LOCATIONS                                       
     S  120, 121, 122, 123, 124, 125 /
C                                                                     
C          NGM FOUM81 LOCATIONS                                       
       DATA  JSTA  / 126, 127, 128, 129, 130, 131, 132, 0,
C                                                                     
C          NGM FOUM82 LOCATIONS                                       
     A  133, 134, 135, 136, 137, 138,
C                                                                     
C          NGM FOUW83 LOCATIONS                                       
     B  139, 140, 141, 142, 143, 144,
C                                                                     
C          NGM FOUM84 LOCATIONS                                       
     C  115, 116, 117, 118, 119, 0,
C                                                                     
C          NGM FOCA51 KWNO (PUERTO RICAN HEADER)                      
     D  145, 146, 147, 148, 149, 150,
C                                                                     
C          NGM FOCA52 KWNO (PUERTO RICAN HEADER)                      
     E  151, 152, 153, 154, 155, 156,
C                                                                     
C           NGM FOHW50 KWNO (HAWAIIAN HEADER)                         
     F  157, 158, 159, 160, 161, 162/
C                                                                     
       DATA  ITAB  /  '60 K',   '61 K',   '62 K',   '63 K',   '64 K',
     A                '65 K',   '66 K',   '67 K',   '68 K',   '69 K',
     B                '70 K',   '71 K',   '72 K',   '73 K',   '74 K',
     C                '75 K',   '76 K',   '77 K',   '78 K',   '80 K',
     D                '81 K',   '82 K',   '83 K',   '84 K',   '51 K',
     E                '52 K',   '50 K'/
C                                                                     
       DATA  JTAB  /  19* 'FOUS',  'FOUE',  'FOUM',  'FOUM',  'FOUW',
     A                    'FOUM',  'FOCA',  'FOCA',  'FOHW'/
C                                                                     
       DATA  IHED1 / '       KWNO     00<<@   ' /
C                                                                     
       DATA  IHED2 / 'OUTPUT FROM NAM   Z          <<@' /
C                                                                     
       DATA  IHED3(1:36)  /  'TTPTTR1R2R3 VVVLI PSDDFF HHT1T3T5   ' /
       DATA  IHED3(37:72) /  'TTPTTR1R2R3 VVVLI PSDDFF HHT1T3T5<<@' /
C
       DATA  JMONTH / 'JAN',  'FEB',  'MAR',  'APR',  'MAY',  'JUN',
     A                'JUL',  'AUG',  'SEP',  'OCT',  'NOV',  'DEC'/
C
       DATA  IOUT  / 71 /
       DATA  IEOT  / '%' /
       DATA  IENDL / '<<@ ' /
       DATA  NUMBUL/ 19 /
       DATA  LCHAR / 69 /
       DATA  LINFD / '@' /
       DATA  ISL4  / '////////' /
       DATA  BLANKS / '        ' /
C
C      ADD DATE/TIME DATA TO BULLETIN HEADER
C
       WRITE( UNIT=IHED2(17:18),FMT='(I2.2)' ) IGTIME
       IHED2(21:23) = JMONTH(IMONTH)
       WRITE( UNIT=IHED2(25:26),FMT='(I2.2)' ) IDAYMO
       WRITE( UNIT=IHED2(28:29),FMT='(I2.2)' ) IYEAR
C
       WRITE( UNIT=IHED1(13:14),FMT='(I2.2)' ) IDAYMO
       WRITE( UNIT=IHED1(15:16),FMT='(I2.2)' ) IGTIME
C
       MJ = 0
C                                                                     
       DO  40000  K = 1,NUMBUL
C
C        INITIALIZE NBLK TO BLANKS
C
         DO  IJ=1,3840
           NBLK(IJ:IJ) = ' '
         END DO
C
C        DEFINE THE 40-CHARACTER BULLETIN COMMUNICATION PREFIX
C
         NBLK(1:1) = ''''
         NBLK(2:7) = '100000'
C
         IHED1(1:4) = JTAB(K)
         IHED1(5:8) = ITAB(K)
C                                                                     
         JM = 41
         JN = 61
         NBLK(JM:JN) = IHED1(1:21)
         JM = JN + 1
         JN = JN + 32
         NBLK(JM:JN) = IHED2(1:32)
         JM = JN + 1
         JN = JN + 72
         NBLK(JM:JN) = IHED3(1:72)
C
C        6 STATIONS PER BULLETIN, EXCEPT FOR BULLETINS FOUM81         
C        AND FOUM84 WHICH CONTAIN 7 AND 5 STATIONS, RESPECTIVELY      
C                                                                     
         NST = 6
         IF ( K .EQ. 21 ) NST = 8
C                                                                     
         DO  36000  NJ = 1,NST,2
C                                                                     
           ITIME = -6
C                                                                     
C              TWO STATIONS PER BULLETIN LINE                         
           MJ = MJ + 1
           NSTA1 = KSTA(MJ)
           MJ = MJ + 1
           NSTA2 = KSTA(MJ)
C                                                                     
           IF ( K .EQ. 18 .OR. K .EQ. 19 .OR.K .GE. 24 ) THEN
C                                                                     
C              SECTION TO INSERT GULF OF MEXICO LOCATION NAMES        
C              INTO BULLETIN LINE                                     
C                                                                     
             JM = JN + 1
             JN = JN + 5
             NBLK(JM:JN) = STNS1(NSTA1)(1:5)
             IF ( NSTA2 .EQ. 0 ) THEN
               JM = JN + 1
               JN = JN + 3
               NBLK(JM:JN) = IENDL(1:3)
               GO TO 23000
             ENDIF
             JN = JN + 31
             JM = JN + 1
             JN = JN + 5
             NBLK(JM:JN) = STNS1(NSTA2)(1:5)
             JM = JN + 1
             JN = JN + 3
             NBLK(JM:JN) = IENDL(1:3)
             GO TO 23000
           ENDIF
C                                                                     
C              SEVEN FORECAST PERIODS                                 
23000      CONTINUE
C                                                                     
           DO  33000  IHOUR = 1,9
C                                                                     
             NSTA = NSTA1
             ITIME = ITIME + 6
C                                                                     
C              LOOP TO INSERT INTO BULLETIN LINE THE FORECAST         
C              DATA FOR THE TWO STATIONS                              
C                                                                     
             DO  30000  M = 1,2
C
C              CONVERT FROM INTEGER TO CHARACTER DATA                 
C                                                                     
               DO  26000  NVAR = 1,13
C                                                                     
                 LI = LIME(NSTA,IHOUR,NVAR)
C
                 IF  ( LI .EQ. KSL4 )  THEN
                    IVAL = ISL4
                    GO TO 25000
                 END IF
C                                                                     
                 IVAL = BLANKS
C
                 IF ( NVAR .EQ. 1 .OR. NVAR .EQ. 5 ) THEN
                    IF ( LI .GE. 0 ) THEN
                      WRITE( UNIT=IVAL(1:3), FMT='(I3.3)' ) LI
                    ELSE
                      WRITE( UNIT=IVAL(1:3), FMT='(I3.2)' ) LI
                    END IF
                 ELSE 
                     WRITE( UNIT=IVAL(1:2), FMT='(I2.2)' ) LI
                 END IF
C                                                                     
25000            CONTINUE
                 BULTN(NVAR) = IVAL(1:4)
C                                                                     
26000          CONTINUE
C                                                                     
               IVAL = BLANKS
               WRITE( UNIT=IVAL(1:2), FMT='(I2.2)' ) ITIME
C
               IF ( IHOUR .GT. 1 ) GO TO 27000
               IF ( K .EQ. 18 .OR. K .EQ. 19 .OR.
     A              K .GE. 24 ) GO TO 27000
               JM = JN + 1
               JN = JN + 3
               NBLK(JM:JN) = STNS1(NSTA)(1:3)
               JM = JN + 1
               JN = JN + 2
               NBLK(JM:JN) = BULTN(1)(1:2)
               GO TO 27100
C                                                                     
27000          CONTINUE
               JM = JN + 1
               JN = JN + 2
               NBLK(JM:JN) = IVAL(1:2)
               JM = JN + 1
               JN = JN + 3
               NBLK(JM:JN) = BULTN(1)(1:3)
C                                                                     
27100          CONTINUE
C
               DO IL = 2,13
C
                   IF ( IL .EQ. 5 .OR. IL .EQ. 7 .OR.
     +                  IL .EQ. 10 ) THEN
C
C                      INSERT A SPACE AT THIS POSTION IN LINE
                       JN = JN + 1
                   END IF
C
                   JM = JN + 1
C
                   IF ( IL .EQ. 5 ) THEN
                       MB = 3
                       JN = JN + 3
                   ELSE
                       MB = 2
                       JN = JN + 2
                   END IF
C
                   NBLK(JM:JN) = BULTN(IL)(1:MB)
C
               END DO
C
               IF ( M .EQ. 2 ) GO TO 30000
               IF ( NSTA2 .EQ. 0 ) GO TO 31000
C
               JN = JN + 3
               NSTA = NSTA2
C
30000        CONTINUE
C
31000       CONTINUE
            JM = JN + 1
            JN = JN + 3
            NBLK(JM:JN) = IENDL(1:3)
C                                                                     
33000     CONTINUE
C                                                                     
          JM = JN + 1
          JN = JN + 1
          NBLK(JM:JN) = LINFD(1:1)
C                                                                     
36000   CONTINUE
C                                                                     
C              PUT IN END OF BULLETIN CHARACTER                       
         JM = JN + 1
         JN = JN + 1
         NBLK(JM:JN) = IEOT(1:1)
C                                                                     
C##########################################
CCC      WRITE(6,17) (NBLK(NW:NW),NW=1,JN)
17       FORMAT(200(/1X,60A1))
C##########################################
C
         IREC = IREC + 1
C
         WRITE( IOUT, REC=IREC ) NBLK(1:1280)
C
         IF ( JN .GT. 1280 ) THEN
           IREC = IREC + 1
           WRITE( IOUT, REC=IREC ) NBLK(1281:2560)
         ENDIF
C                                                
C
         IF ( JN .GT. 2560 ) THEN
           IREC = IREC + 1
           WRITE( IOUT, REC=IREC ) NBLK(2561:3840)
         ENDIF
C                                                
40000  CONTINUE
C                                                                     
       RETURN
       END
