       SUBROUTINE  FOUS4048H( IREC )
C$$$  SUBPROGRAM DOCUMENTATION BLOCK                       
C                                                          
C SUBPROGRAM: FOUS4048H      GENERATES THE FOUS40-43 BULLETINS 
C   PRGMMR: BOB HOLLERN      ORG: W/NMC41    DATE: 93-06-01
C                                                          
C ABSTRACT: FORMATS THE FOUS40-43 BULLETINS, WHICH CONTAIN STATION   
C   FORECASTS FOR THE HOURS 12, 18, 24, ..., 48 OF THE FREEZING LEVEL
C   HEIGHT AND THE RELATIVE HUMIDITY AT THE HEIGHT.  TABLES ARE USED 
C   TO DETERMINE WHICH STATION GOES IN A PARTICULAR BULLETIN.  WHEN  
C   THE FORMATTING OF A BULLETIN IS DONE, IT IS WRITTEN TO THE 
C   TRANSMISSION FILE.                                     
C                                                          
C PROGRAM HISTORY LOG:                                     
C   93-06-01  BOB HOLLERN, AUTHOR                          
C                                                          
C USAGE:  CALL FOUS4048H
C                                                          
C   INPUT ARGUMENT LIST:                                   
C     IGTIME   -   /BLOCKC/  INITIAL GMT HOUR OF THE DATA  
C     IDAYMO   -   /BLOCKC/  INITIAL GMT DAY OF THE MONTH OF THE DATA
C     IMONTH   -   /BLOCKC/, INITIAL GMT MONTH OF THE DATA 
C     IYEAR    -   /BLOCKC/, INITIAL GMT YEAR OF THE DATA  
C     STNS1    -   /BLOCKB/, ARRAY CONTAINING THE BULLETIN STATION IDS
C     LFRZRH   -   /BLOCKA/, ARRAY TO CONTAIN THE STATION BULLETIN
C                  DATA                                    
C                                                          
C   OUTPUT FILE:                                           
C     FT51F001 -   BULLETIN TRANSMISSION FILE.             
C                                                          
C   REMARKS:                                               
C                                                          
C ATTRIBUTES:                                              
C   LANGUAGE: FORTRAN 90                                   
C$$$                                                       
       COMMON  /BLOCKA/ LFRZRH
       COMMON  /BLOCKB/ NTOT1, NTOT2, SI, SJ, STNS1, STNS2
       COMMON  /BLOCKC/ IGTIME, IYEAR, IDAYMO, IMONTH
C                                                          
       REAL      SI(224),   SJ(224)
C                                                          
       INTEGER   IDAYFL(3),   IND1(4),   IND2(4),   LFRZRH(224,9,13)
       INTEGER   LOC1(28),    LOC2(30),  LOC3(27),  LOC4(26)
       INTEGER   MNDAYS(12),  NFLOC(111), LRH,      LFLV
C                                                          
       CHARACTER*2560   NBLK
C
       CHARACTER*68   IHED3
C
       CHARACTER*52   IHED1,   IHED2
C
       CHARACTER*20   REGION(4)
C
       CHARACTER*8   KRH,   KSLASH,   KFLV,   IVAL,   STA
C
       CHARACTER*5   STNS1(162),  STNS2(62)
C                                                          
       CHARACTER*3   JMONTH(12)
C                                                          
       CHARACTER*1  ENDB,   LF
C                                                          
       CHARACTER*4   FOUSNO(4),   IENDL,   JDAYFL(3),   NFDT(7)
C                                                          
       EQUIVALENCE   (KFLV,LFLV)
       EQUIVALENCE   (KRH,LRH)
       EQUIVALENCE   (NFLOC(1),LOC1(1))
       EQUIVALENCE   (NFLOC(29),LOC2(1))
       EQUIVALENCE   (NFLOC(59),LOC3(1))
       EQUIVALENCE   (NFLOC(86),LOC4(1))
C                                                          
       DATA  ENDB  / '%' /
       DATA  FOUSNO/  '40  ',  '41  ',  '42  ',  '43  '  /
       DATA  IENDL / '<<@ ' /
C                                                          
       DATA  IHED1(1:32) /  'FOUS   KWNO     00<<@OUTPUT FROM' /
       DATA  IHED1(33:52) / ' 1200Z          <<@ ' /
C                                                          
       DATA  IHED2(1:28) /  'NAM FOUS FREEZING LEVELS AND' /
       DATA  IHED2(29:52) / ' RELATIVE HUMIDITY FOR  ' /
C                                                          
       DATA  IHED3(1:20)  /  '  /00   /06   /12   ' /
       DATA  IHED3(21:44) /  '/18   /00   /06   /12   ' /
       DATA  IHED3(45:68) /  '/18   /00   /06   /12   ' /
C
C      IND1 AND IND2 CONTAIN DO-LOOP PARAMETERS            
       DATA  IND1  / 1, 29, 59, 86 /
       DATA  IND2  / 28, 58, 85, 111 /
C                                                          
       DATA  IOUT  / 71 /
       DATA  KSLASH/ '////////' /
       DATA  LCHAR / 69 /
C                                                          
C              FOUS40 LOCATIONS                            
C                                                          
       DATA  LOC1  /  42,  106,   30,  107,   92,   91,   26,   27,
     A                29,   28,   32,   33,   31,   99,   67,   68,
     B                95,   93,   23,   24,   22,   34,   25,   66,
     C                73,   74,   75,   76/
C                                                          
C              FOUS41 LOCATIONS                            
C                                                          
       DATA  LOC2  /  96,   61,   65,   64,  109,   63,   94,   60,
     A                40,   59,   56,   41,   57,   38,   98,   51,
     B                52,   53,   55,   54,   70,   50,   48,   49,
     C               100,  101,  102,  103,  104,  105/
C                                                          
C              FOUS42 LOCATIONS                            
C                                                          
       DATA  LOC3  /  58,   39,   36,   21,   20,   19,   16,   12,
     A                17,   18,   15,   62,   71,   13,   14,   47,
     B                10,   11,   37,    9,   69,   77,   78,   79,
     C                80,   82,   81/
C                                                          
C              FOUS43 LOCATIONS                            
C                                                          
       DATA  LOC4  /   1,    2,    5,    6,    8,  108,    3,    4,
     A                35,    7,   46,   45,  110,   43,  111,   44,
     B                97,   72,   84,   83,   85,   86,   87,   88,
     C                89,   90/
C                                                          
       DATA  JMONTH / 'JAN',  'FEB',  'MAR',  'APR',  'MAY',  'JUN',
     A                'JUL',  'AUG',  'SEP',  'OCT',  'NOV',  'DEC'/
C
       DATA  MNDAYS/ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 /
       DATA  NBULL / 4 /
C                                                          
C                                                          
       DATA  REGION/  'EASTERN REGION<<@   ',
     A                'SOUTHERN REGION<<@  ',
     B                'CENTRAL REGION<<@   ',
     C                'WESTERN REGION<<@   '/
C                                                          
       DATA  STA   / 'STA     ' /
C                                                          
100    FORMAT( 2(160A4) )
C                                                          
C              ADD DATE/TIME DATA TO BULLETIN HEADER 
C                                                
       WRITE( UNIT=IHED1(13:14),FMT='(I2.2)' ) IDAYMO
       WRITE( UNIT=IHED1(15:16),FMT='(I2.2)' ) IGTIME
       WRITE( UNIT=IHED1(34:35),FMT='(I2.2)' ) IGTIME
       IHED1(40:43) = JMONTH(IMONTH)
       WRITE( UNIT=IHED1(44:45),FMT='(I2.2)' ) IDAYMO
       WRITE( UNIT=IHED1(47:48),FMT='(I2.2)' ) IYEAR
C
C      IF LEAP YEAR, SET NUMBER OF DAYS IN FEBRUARY TO 29  
       LREM = MOD(IYEAR,4)
       IF ( LREM .EQ. 0 ) MNDAYS(2) = 29
C                                                          
C      NUMBER OF DAYS IN MONTH                             
       NDMN = MNDAYS(IMONTH)
C
       IF ( IGTIME .EQ. 0 ) THEN
C
C         DETERMINE FORCAST DATES WHEN INPUT IS 00Z DATA      
C                                                          
          IDAY = IDAYMO
          IDAYFL(1) = IDAY
C                                                          
          DO I = 2,3
             IDAY = IDAY + 1
             IF ( IDAY .GT. NDMN ) IDAY = 1
             IDAYFL(I) = IDAY
          END DO
C                                                          
          DO  I=1,3  
             WRITE( UNIT=JDAYFL(I)(1:4),FMT='(I2.2)') IDAYFL(I)
          END DO
C
C         SET NFDT TO THE DATES FOR THE SEVEN FORCAST PERIODS 
C                                                          
          NFDT(1) = JDAYFL(1)
          NFDT(2) = JDAYFL(1)
          NFDT(7) = JDAYFL(3)
C                                                          
          DO  I = 3,6
             NFDT(I) = JDAYFL(2)
          END DO
C                                                          
          LL = 13
C                                                          
       ELSE IF ( IGTIME .EQ. 6 ) THEN
C                                                          
          IDAY = IDAYMO
          IDAYFL(1) = IDAY
C                                                          
          DO  I = 2,3
             IDAY = IDAY + 1
             IF ( IDAY .GT. NDMN ) IDAY = 1
             IDAYFL(I) = IDAY
          END DO
C                                                          
          DO  I = 1,3  
             WRITE( UNIT=JDAYFL(I)(1:4),FMT='(I2.2)') IDAYFL(I)
          END DO
C
          DO  I = 1,7
             IF ( I .EQ. 1 ) NFDT(I) = JDAYFL(1)
             IF ( I .GT. 1 ) NFDT(I) = JDAYFL(2)
             IF ( I .GT. 5 ) NFDT(I) = JDAYFL(3)
          END DO
C                                                          
          LL = 19
C
       ELSE IF ( IGTIME .EQ. 12 ) THEN
C                                                          
          IDAY = IDAYMO
C                                                          
          DO  I = 1,3
             IDAY = IDAY + 1
             IF ( IDAY .GT. NDMN ) IDAY = 1
             IDAYFL(I) = IDAY
          END DO
C                                                          
          DO  I = 1,3  
             WRITE( UNIT=JDAYFL(I)(1:4),FMT='(I2.2)') IDAYFL(I)
          END DO
C
          DO  I = 1,7
             NFDT(I) = JDAYFL(1)
             IF ( I .GT. 4 ) NFDT(I) = JDAYFL(2)
          END DO
C                                                          
          LL = 1
       ELSE IF ( IGTIME .EQ. 18 ) THEN
C                                                          
          IDAY = IDAYMO
C                                                          
          DO  I = 1,3
             IDAY = IDAY + 1
             IF ( IDAY .GT. NDMN ) IDAY = 1
             IDAYFL(I) = IDAY
          END DO
C                                                          
          DO  I = 1,3  
             WRITE( UNIT=JDAYFL(I)(1:4),FMT='(I2.2)') IDAYFL(I)
          END DO
C
          DO  I = 1,7
             NFDT(I) = JDAYFL(1)
             IF ( I .GT. 3 ) NFDT(I) = JDAYFL(2)
          END DO
C                                                          
          LL = 7
       ELSE
          RETURN
       END IF
C                                                          
C      INSERT FORECAST DATES INTO IHED3 HEADING            
C                                                          
       DO  I = 1,7
          IHED3(LL:LL+1) = NFDT(I)(1:2)
          LL = LL + 6
       END DO   
C                                                          
       NN = 1
C                                                          
       DO  20000  K = 1,NBULL
C                                                          
C        INITIALIZE NBLK TO BLANKS
C
         DO  IJ=1,2560
           NBLK(IJ:IJ) = ' '
         END DO
C
C        DEFINE THE 40-CHARACTER BULLETIN COMMUNICATION PREFIX
C
         NBLK(1:1) = ''''
         NBLK(2:7) = '100000'
C
C        INSERT FOUS BULLETIN NUMBER INTO HEADING          
         IHED1(5:6) = FOUSNO(K)(1:2)
C
         JM = 41
         JN = 91
         NBLK(JM:JN) = IHED1(1:51)
         JM = JN + 1
         JN = JN + 51
         NBLK(JM:JN) = IHED2(1:51)
C
         LEN = 17
         IF ( K .EQ. 2 ) LEN = 18
         JM = JN + 1
         JN = JN + LEN
         NBLK(JM:JN) = REGION(NN)(1:LEN)
C                                                          
         NN = NN + 1
C                                                          
         NA = 4
         IF ( K .EQ. 2 ) NA = 5
         JM = JN + 1
         JN = JN + NA
         NBLK(JM:JN) = STA(1:NA)
C                                                          
         IF ( IGTIME .EQ.  0 ) THEN
             LC = 13
         ELSE IF ( IGTIME .EQ.  6 ) THEN
             LC = 19
         ELSE IF ( IGTIME .EQ.  12 ) THEN
             LC = 1
         ELSE IF ( IGTIME .EQ.  18 ) THEN
             LC = 7
         ENDIF
C
         JM = JN + 1
         JN = JN + 41
         NBLK(JM:JN) = IHED3(LC:LC+40)
         NBLK(JN+1:JN+3) = IENDL
         JN = JN + 3
C                                                          
C        GET NUMBER OF FOUS LOCATIONS IN BULLETIN          
         LA = IND1(K)
         LB = IND2(K)
C                                                          
         DO  15000  IN = LA,LB
C                                                          
           N = NFLOC(IN)
           NCH = 4
           IF ( K .EQ. 2 ) NCH = 5
           JM = JN + 1
           JN = JN + NCH
           NBLK(JM:JN) = STNS1(N)(1:NCH)
C                                                          
           DO  12000  IHOUR = 1, 7
C                                                          
             LFLV = LFRZRH(N,IHOUR,1)
C
             IF ( KFLV .EQ. KSLASH ) THEN
               JM = JN + 1
               JN = JN + 3
               NBLK(JM:JN) = KSLASH(1:3)
             ELSE
               WRITE( UNIT=IVAL(1:3), FMT='(I3.3)' ) LFLV
               JM = JN + 1
               JN = JN + 3
               NBLK(JM:JN) = IVAL(1:3)
             ENDIF
C                                                          
             LRH = LFRZRH(N,IHOUR,2)
C
             IF ( KRH .EQ. KSLASH ) THEN
               JM = JN + 1
               JN = JN + 2
               NBLK(JM:JN) = KSLASH(1:2)
             ELSE
               WRITE( UNIT=IVAL(1:2), FMT='(I2.2)' ) LRH
               JM = JN + 1
               JN = JN + 2
               NBLK(JM:JN) = IVAL(1:2)
             ENDIF
C                                                          
             JN = JN + 1
C                                                          
12000      CONTINUE
C                                                          
C          INSERT END OF LINE CHARACTERS                   
           JM = JN + 1
           JN = JN + 3
           NBLK(JM:JN) = IENDL(1:3)
C
15000    CONTINUE
C                                                          
C        INSERT END OF BULLETIN CHARACTER                  
           JM = JN + 1
           JN = JN + 1
           NBLK(JM:JN) = ENDB(1:1)
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
20000  CONTINUE
C                                                          
       RETURN
       END
