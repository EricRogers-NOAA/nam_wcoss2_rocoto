       SUBROUTINE  PRECIP( JCYCLE, K, IIP, JJP, FLDC )
C$$$  SUBPROGRAM DOCUMENTATION BLOCK                                  
C                                                                     
C SUBPROGRAM:  PRECIP          COMPUTES 6 HOURLY PRECIP AMOUNTS
C   AUTHOR: BOB HOLLERN        ORG: NMC411        DATE: 88-05-05      
C                                                                     
C ABSTRACT: COMPUTES 6-HOURLY PRECIPITATION AMOUNTS AT EACH GRID POINT.
C   THE PRECIP FIELD READ FROM THE 6, 18, 30, and 42 HOUR FORECAST  
C   FILES CONTAIN THE PRECIP AMOUNTS FOR THE FIRST 6 HOURS OF THE 12
C   HOUR PERIOD.  THE 12, 24, 36, AND 48 HOUR FORECAST FILES CONTAIN
C   THE ACCUMULATED PRECIP AMOUNTS FOR THE ENTIRE 12 HOURS.
C   SUBTRACTING OUT THE PRECIP AMOUNTS FOR THE FIRST 6 HOURS OF THE
C   12 HOUR PERIOD GIVES THE ACCUMULATED AMOUNT FOR THE LAST 6 HOURS
C   OF THE PERIOD.  TINY AMOUNTS ARE SET TO ZERO.  THE PRECIP DATA
C   IS SMOOTHED TO MAKE IT AGREE WITH THE AFOS PRECIP GRAPHICS
C   PRODUCT.
C                                                                     
C PROGRAM HISTORY LOG:
C   88-05-06  BOB HOLLERN, AUTHOR
C   92-11-18  BOB HOLLERN, MODIFIED THE ROUTINE TO GET THE ACCUMULATED
C             PRECIP AMOUNTS FROM THE SUPER-C GRID PRECIP FIELD RATHER
C             THAN FROM THE 113X91 C-GRID PRECIP FIELD.               
C   01-04-24  BOI VUONG, MODIFIED THE ROUTINE TO EXTEND THE FOUS PRODUCT
C             GENERATION TO 60 HOURS AT 00Z and 12Z.
C
C USAGE:    CALL PRECIP( FILE, IDTBL, IHOUR, K )                      
C   INPUT ARGUMENT LIST:                                              
C     K        -   REPRESENTS ONE OF THE 9 INPUT FILES                
C     IIP      -   VARIABLE SET TO THE MAXIMUM NUMBER OF I-ROWS IN
C                  GRIB FIELD
C     JJP      -   VARIABLE SET TO THE MAXIMUM NUMBER OF J-COLUMNS
C                  IN GRIB FIELD
C     FLDC     -   REAL ARRAY CONTAINING THE 6 OR 12-HOURLY PRECIP
C                  GRIB DATA.  UNITS ARE KG/M**2.
C
C   OUTPUT ARGUMENT LIST:                                             
C                                                                     
C     FLDC     -   REAL ARRAY CONTAINING THE 6-HOURLY PRECIP GRIB
C                  DATA FOR THE FIRST OR SECOND HALF OF THE 12-HOUR
C                  PERIOD.  DATA HAS BEEN SMOOTHED AND IS IN INCHES.
C                                                                     
C  OUTPUT FILES:                                                      
C                                                                     
C     FT06F001   &&TEMP06                                             
C                - TEMPORARY FILE TO CONTAIN ERROR MESSAGES           
C                                                                     
C ATTRIBUTES:                                                         
C   LANGUAGE: FORTRAN 90
C$$$                                                                  
       REAL   FX(349,277)
       REAL   FLDC(IIP,JJP),   PRCP(349,277)
       REAL   TINY,   DIFFER,   DEEP,   CRZERO
C                                                                     
       INTEGER   IPREC
C                                                                     
C      NOTE:   .0000254M = 0.001 IN                                   
       DATA  CRZERO / 0.001 /
C                                                                     
       DATA  TINY / 5.0E-7 /
C                                                                     
C      NOTE:   -.000762 M = -.03 IN                                   
       DATA  DEEP / -.03 /
C                                                                     
C      WATER DENSITY IS 1G/CM**3
C
C      1 CM = .3937 IN
C
C      NOTE:  UNITS OF PRECIP IS KG/M**2
C
C      SO WATER 1 CM DEEP OVER 1 M**2 WEIGHS 10000 G, OR 10 KG
C
C      THE DEPTH OF THE WATER IN CM CAN BE COMPUTED AT A POINT
C      BY TAKING THE VALUE AT THE POINT, SAY X, AND DIVIDING IT BY 10.
C
       SAVE PRCP, IPREC
C
       IR2 = MOD(K,2)
C
       DO  I = 1,IIP
          DO  J = 1,JJP
C                                                                     
C           CONVERT PRECIPTIATION AMOUNTS FROM  KG/M**2 TO INCHES
C
            FLDC(I,J) = (FLDC(I,J)/10.) * (.3937)
C
          END DO  
       END DO  
C
       IREM = MOD (K,2) 
C
       IF ( K .EQ. 3 .OR. K .EQ. 7 .OR.
     A      K .EQ. 11 .OR. K .EQ. 15 .OR. K .EQ. 19 ) THEN
C        SET FLAG TO INDICATE THE 6, 18, 30, 42 AND 54-HOURLY
C        PRECIPITATION BUCKETS
         IPREC = 0
       ELSE IF ( K .EQ. 5 .OR. K .EQ. 9 .OR.
     A      K .EQ. 13 .OR. K .EQ. 17 .OR. K .EQ. 21) THEN
C        SET FLAG TO INDICATE THE 12, 24, 36, 48 AND 60-HOURLY
C        PRECIPITATION BUCKETS
         IPREC = 1
       ELSE IF ( IREM .EQ. 0 ) THEN
C        SET FLAG TO INDICATE THE 3, 9, 15, 21, 27, 33, 39, 45 AND 
C        51-HOURLY PRECIPITATION BUCKETS
         IPREC = 2
       ELSE
         RETURN
       ENDIF
C                                                                     
       IF ( (JCYCLE .EQ. 0 .AND. IPREC .EQ. 0) .OR.
     +      (JCYCLE .EQ. 1 .AND. IPREC .EQ. 2 ) ) THEN
C                                                                     
         DO  I = 1,IIP
           DO  J = 1,JJP
C            SAVE THE 3- OR 6-HOURLY PRECIPITATION AMOUNTS IN PRCP
             PRCP(I,J) = FLDC(I,J)
             IF ( PRCP(I,J) .LT. TINY ) PRCP(I,J) = 0.0
           END DO  
         END DO  
C                                                                     
         IF ( JCYCLE .EQ. 1 .AND. IPREC .EQ. 2 ) RETURN
C
       END IF
C
       IF ( JCYCLE .EQ. 0 .AND. IPREC .EQ. 1 ) THEN
C
C        00Z OR 12Z CYCLE
C
C        COMPUTE 6-HOURLY PRECIP AMOUNTS BY SUBRTRACTING              
C        THE PREVIOUS 6-HOURLY PRECIP AMOUNTS FROM THE CURRENT        
C        12-HOURLY PRECIP AMOUNTS                                     
C                                                                     
         DO  I = 1,IIP
            DO  J = 1,JJP
C                                                                     
              IF ( FLDC(I,J) .LT. TINY ) THEN
                DIFFER = 0.0
              ELSE 
                DIFFER = FLDC(I,J) - PRCP(I,J)
              END IF
C                                                                     
              IF ( DIFFER .LT. TINY ) DIFFER = 0.0
C
              FLDC(I,J) = DIFFER
C                                                                     
            END DO  
         END DO  
C                                                                     
       ENDIF
C                                                                     
       IF ( JCYCLE .EQ. 1 .AND. IR2 .EQ. 1 ) THEN
C
C        06Z OR 18Z CYCLE
C
C        COMPUTE 6-HOURLY PRECIP AMOUNTS BY ADDING THE TWO
C        3-HOURLY PRECIPITATION BUCKETS
C                                                                     
         DO  I = 1,IIP
            DO  J = 1,JJP
C                                                                     
              XXX = FLDC(I,J) + PRCP(I,J)
C                                                                     
              IF ( XXX .LT. TINY ) XXX = 0.0
C
              FLDC(I,J) = XXX
C                                                                     
            END DO  
         END DO  
C                                                                     
       ENDIF
C                                                                     
C  PREPARE FLDC FOR SMOOTHING (AFOS GRAPHICS PROGRAM USES THIS METHOD)
C                                                                     
       DO  I = 1,IIP
         DO  J = 1,JJP
           IF ( FLDC(I,J) .LE. CRZERO ) FLDC(I,J) = DEEP
         END DO 
       END DO 
C                                                                     
       CALL  W3FM08( FLDC, FX, IIP, JJP )
C                                                                     
       RETURN
       END
