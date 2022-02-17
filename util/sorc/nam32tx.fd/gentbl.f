       SUBROUTINE  GENTBL( AR )
C$$$  SUBPROGRAM DOCUMENTATION BLOCK                                  
C                                                                     
C SUBPROGRAM: GENTBL         GENERATES TABLE OUTPUT                   
C   PRGMMR: BOB HOLLERN      ORG: NMC411     DATE: 92-11-18           
C                                                                     
C ABSTRACT: GENERATES A TABLE CONTAINING THE NAM MODEL TERRAIN       
C   HEIGHT AND NORMAL SURFACE PRESSURE AT THE LOCATIONS OF THE BULLETIN
C   STATIONS.  THE HEIGHT IS OBTAINED BY HORIZONTAL INTERPOLATION OF  
C   THE MODEL TERRAIN HEIGHT FROM THE FORECAST GRID-POINTS TO THE     
C   STATION LOCATION, FOLLOWED BY A CALCULATION OF THE PRESSURE AT    
C   THIS HEIGHT IN THE U.S. STANDARD ATMOSPHERE.  THIS TABLE IS FOR   
C   THE FOUS BULLETIN USERS AND WILL BE GENERATED ONLY WHEN NECESSARY.
C                                                                     
C PROGRAM HISTORY LOG:                                                
C   92-11-18  BOB HOLLERN, AUTHOR                                     
C                                                                     
C USAGE:    CALL GENTBL( AR )                                         
C                                                                     
C   INPUT ARGUMENT LIST:                                              
C     NTOT1    -   /BLOCKB/, TOTAL NUMBER OF BULLETIN STATIONS
C     NTOT2    -   /BLOCKB/, TOTAL NUMBER OF FOUS86-96 BULLETIN       
C                  STATIONS                                           
C     STNS1    -   /BLOCKB/, C*5 ARRAY CONTAINING THE ID FOR EACH     
C                  FOUS BULLETIN STATION                         
C     STNS2    -   /BLOCKB/, C*5 ARRAY CONTAINING THE ID FOR EACH     
C                  FOUS86-96 BULLETIN STATION                         
C     SI       -   /BLOCKB/, R*4 ARRAY CONTAINING THE SUPER-C GRID    
C                  I COORDINATE FOR EACH OF THE FOUS STATIONS         
C     SJ       -   /BLOCKB/, R*4 ARRAY CONTAINING THE SUPER-C GRID    
C                  J COORDINATE FOR EACH OF THE FOUS STATIONS         
C     AR       -   R*4 ARRAY CONTAINING THE SURFACE HEIGHT GRID POINT 
C                  DATA IN GPM UNITS.                                 
C                                                                     
C  OUTPUT FILES:                                                      
C                                                                     
C     FT06F001   &&TEMP06                                             
C                - PRINT FILE TO CONTAIN THE TABLE VALUES             
C                                                                     
C     LIBRARY:  W3FA04                                                
C                                                                     
C ATTRIBUTES:                                                         
C   LANGUAGE: FORTRAN 90                                              
C$$$                                                                  
       COMMON  /BLOCKB/ NTOT1, NTOT2, SI, SJ, STNS1, STNS2
C                                                                     
       REAL    SI(224),   SJ(224),   AR(349,277)
C                                                                     
       CHARACTER*5   STNS1(162),   STNS2(62)
C                                                                     
       DATA  IGRSZ / 349 /
       DATA  JGRSZ / 277 /
       DATA  LIN   / 0 /
       DATA  NCYCLK/ 0 /
C                                                                     
100    FORMAT(  T05, 'NAM  MODEL TERRAIN HEIGHT AND NORMAL',
     A      1X,'SURFACE PRESSURE', /1X, T15,
     B      'AT THE NAM STATION LOCATIONS', // )
C                                                                     
110    FORMAT (  T10, 'STATION', T25, 'HEIGHT IN', T43,
     A          'PRESSURE IN', /1X, T12, 'ID', T26, 'METERS',
     B          T44, 'MILLIBARS', /1X, T10, '-------', T25,
     C          '---------', T43, '-----------', / )
C                                                                     
120    FORMAT ( ' ', T12, A5, T26, F7.2, T44, F7.1 )
C                                                                     
C      TOTAL NUMBER OF STATIONS                                       
       NTOT = NTOT1 + NTOT2
C                                                                     
       M = 0
C                                                                     
       DO 1000  N = 1, NTOT
C                                                                     
         IF ( N .EQ. 1  .OR.  N .EQ. 53  .OR.
     A        N .EQ. 105 .OR. N .EQ. 157 ) THEN
CCC        WRITE(92,100)
CCC        WRITE(92,110)
         ENDIF
C                                                                     
C        INTERPOLATE GRIDPOINT DATA TO STATION.                       
         CALL W3FT01( SI(N),SJ(N),AR,HGT,IGRSZ,JGRSZ,NCYCLK,LIN )
C                                                                     
C        COMPUTE STANDARD PRESSURE                                    
         CALL W3FA04( HGT, PRESS, TEMP, THETA )
C                                                                     
         IF ( N .GT. NTOT1 ) THEN
           M = M + 1
CCC        WRITE(92,120) STNS2(M), HGT, PRESS
         ELSE
CCC        WRITE(92,120) STNS1(N), HGT, PRESS
         ENDIF
C                                                                     
1000   CONTINUE
C                                                                     
       RETURN
       END
