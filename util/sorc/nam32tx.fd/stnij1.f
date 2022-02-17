       SUBROUTINE  STNIJ1
C$$$  SUBPROGRAM DOCUMENTATION BLOCK                                  
C                                                                     
C SUBPROGRAM: STNIJ1         COMPUTES STATION SUPER-C GRID COORDINATES
C   PRGMMR: BOB HOLLERN      ORG: NMC411     DATE: 92-11-18           
C                                                                     
C ABSTRACT: COMPUTES THE SUPER-C GRID COORDINATES FOR EACH FOUS       
C   STATION AND LOCATION USING THE LIBRARY ROUTINE W3FB04.  THE       
C   STATION LATITUDE AND LONGITUDE IS PASSED TO W3FB04 WHICH USES IT  
C   WITH OTHER PARAMETERS TO COMPUTE THE I,J COORDINATES.             
C                                                                     
C PROGRAM HISTORY LOG:                                                
C   92-11-18  BOB HOLLERN, AUTHOR                                     
C                                                                     
C USAGE:    CALL STNIJ1                                               
C                                                                     
C   OUTPUT ARGUMENT LIST:                                             
C     NTOT1    -   /BLOCKB/, VARIABLE SET TO THE NUMBER OF FOUS
C                  STATIONS AND LOCATIONS                             
C     STNS1    -   /BLOCKB/, C*5 ARRAY CONTAINING THE ID FOR EACH     
C                  FOUS STATION OR LOCATION                      
C     SI       -   /BLOCKB/, R*4 ARRAY CONTAINING THE SUPER-C GRID    
C                  I COORDINATE FOR EACH OF THE BULLETIN STATIONS     
C     SJ       -   /BLOCKB/, R*4 ARRAY CONTAINING THE SUPER-C GRID    
C                  J COORDINATE FOR EACH OF THE BULLETIN STATIONS     
C                                                                     
C     LIBRARY:  W3FB04                                                
C                                                                     
C     REMARKS:                                                        
C                                                                     
C ATTRIBUTES:                                                         
C   LANGUAGE: FORTRAN 90                                              
C$$$                                                                  
       COMMON  /BLOCKB/ NTOT1, NTOT2, SI, SJ, STNS1, STNS2
C                                                                     
       REAL     XLTLG1(2,45),  XLTLG2(2,45),  XLTLG3(2,45)
       REAL     XLTLG4(2,27),   SI(224),       SJ(224)
C
       COMMON /STALOC/ XLATLN(2,162)
C                                                                     
       CHARACTER*5   STNS1(162),  ISTNS1(90),  ISTNS2(72)
       CHARACTER*5   STNS2(62)
C                                                                     
C                                                                     
C     1   SEA     SEATTLE, WASHINGTON                                 
C     2   GEG     SPOKANE, WASHINGTON                                 
C     3   GTF     GREAT FALLS, MONTANA                                
C     4   BIL     BILLINGS, MONTANA                                   
C     5   PDX     PORTLAND, OREGON                                    
C     6   MFR     MEDFORD, OREGON                                     
C     7   SFO     SAN FRANCISCO, CALIFORNIA                           
C     8   BOI     BOISE, IDAHO                                        
C     9   CYS     CHEYENNE, WYOMING                                   
C    10   BIS     BISMARK, NORTH DAKOTA                               
C    11   FSD     SIOUX FALLS, SOUTH DAKOTA                           
C    12   MSP     MINNEAPOLIS, MINNESOTA                              
C    13   OMA     OMAHA, NEBRASKA                                     
C    14   LBF     NORTH PLATTE, NEBRASKA                              
C    15   DSM     DES MOINES, IOWA                                    
C    16   MKE     MILWAUKEE, WISCONSIN                                
C    17   INL     INTERNATIONAL FALLS, MINNESOTA                      
C    18   ORD     CHICAGO, ILLINOIS                                   
C    19   SSM     SALTE ST. MARIE, MICHIGAN                           
C    20   DTW     DETROIT, MICHIGAN                                   
C    21   IND     INDIANAPOLIS, INDIANA                               
C    22   CLE     CLEVELAND, OHIO                                     
C    23   BUF     BUFFALO, NEW YORK                                   
C    24   PIT     PITTSBURG, PENNSYLVANIA                             
C    25   CRW     CHARLESTON, WEST VIRGINIA                           
C    26   ALB     ALBANY, NEW YORK                                    
C    27   BTV     BURLINGTON, VERMONT                                 
C    28   LGA     NEW YORK, NEW YORK                                  
C    29   BOS     BOSTON, MASSACHUSETTS                               
C    30   BGR     BANGOR, MAINE                                       
C    31   DCA     WASHINGTON, D. C.                                   
C    32   PHL     PHILADELPHIA, PENNSYLVANIA                          
C    33   IPT     WILLIAMSPORT, PENNSYLVANIA                          
C    34   DAY     DAYTON, OHIO                                        
C    35   MSO     MISSOULA, MONTANA                                   
C    36   TYS     KNOXVILLE, TENNESSEE                                
C    37   RAP     RAPID CITY, SOUTH DAKOTA                            
C    38   MEM     MEMPHIS, TENNESSEE                                  
C    39   SDF     LOUISVILLE, KENTUCKY                                
C    40   MOB     MOBILE, ALABAMA                                     
C    41   SHV     SHREVEPORT, LOUISIANA                               
C    42   PWM     PORTLAND, MAINE                                     
C    43   RNO     RENO, NEVADA                                        
C    44   SLC     SALT LAKE CITY, UTAH                                
C    45   LAX     LOS ANGELES, CALIFORNIA                             
C    46   FAT     FRESNO, CALIFORNIA                                  
C    47   BFF     SCOTTSBLUFF, NEBRASKA                               
C    48   ELP     EL PASO, TEXAS                                      
C    49   ABQ     ALBEQUERQUE, NEW MEXICO                             
C    50   LBB     LUBBOCK, TEXAS                                      
C    51   OKC     OKLAHOMA CITY, OKLAHOMA                             
C    52   DFW     FORT WORTH, TEXAS                                   
C    53   SAT     SAN ANTONIO, TEXAS                                  
C    54   BRO     BROWNSVILLE, TEXAS                                  
C    55   IAH     HOUSTON, TEXAS                                      
C    56   MSY     NEW ORLEANS, LOUISIANA                              
C    57   LIT     LITTLE ROCK, ARKANSAS                               
C    58   STL     ST. LOUIS, MISSOURI                                 
C    59   JAN     JACKSON, MISSISSIPPI                                
C    60   BHM     BIRMINGHAM, ALABAMA                                 
C    61   ATL     ATLANTA, GEORGIA                                    
C    62   TOP     TOPEKA, KANSAS                                      
C    63   TLH     TALLAHASSEE, FLORIDA                                
C    64   LAL     LAKELAND, FLORIDA                                   
C    65   MIA     MIAMI, FLORIDA                                      
C    66   CAE     COLUMBIA, SOUTH CAROLINA                            
C    67   RDU     RALEIGH, NORTH CAROLINA                             
C    68   HAT     HATTERAS, NORTH CAROLINA                            
C    69   DEN     DENVER, COLORADO                                    
C    70   DRT     DEL RIO, TEXAS                                      
C    71   DDC     DODGE CITY, KANSAS                                  
C    72   PHX     PHOENIX, ARIZONA                                    
C    73   YQB     QUEBEC         (CANADA)                             
C    74   YOW     OTTAWA         (CANADA)                             
C    75   YMW     MANIWAKI       (CANADA)                             
C    76   YYB     NORTH BAY      (CANADA)                             
C    77   YLH     LANSDOWNE HOUSE   (CANADA)                          
C    78   YQT     THUNDER BAY     (CANADA)                            
C    79   YWG     WINNIPEG        (CANADA)                            
C    80   YQD     THE PAS         (CANADA)                            
C    81   YQR     REGINA          (CANADA)                            
C    82   YPA     PRINCE ALBERT   (CANADA)                            
C    83   YYC     CALGARY         (CANADA)                            
C    84   YEG     EDMONTON        (CANADA)                            
C    85   MCD     MICA DAM        (CANADA)                            
C    86   YRV     REVELSTOKE      (CANADA)                            
C    87   YXC     CRANBROOK       (CANADA)                            
C    88   YCG     CASTELGAR       (CANADA)                            
C    89   YVR     VANCOUVER       (CANADA)                            
C    90   YXS     PRINCE GEORGE   (CANADA)                            
C    91   9B6     SEAWELL RIDGE   (ATLANTIC OCEAN)                    
C    92   AFA     CHALEUR BAY     (ATLANTIC OCEAN)                    
C    93   C7H     STATION HOTEL   (ATLANTIC OCEAN)                    
C    94   3J2     BLAKE PLATEAU   (ATLANTIC OCEAN)                    
C    95   ILM     WILMINGTON, NORTH CAROLINA                          
C    96   SAV     SAVANNAH, GEORGIA                                   
C    97   CDC     CEDAR CITY, UTAH                                    
C    98   BNA     NASHVILLE, TENNESSEE                                
C    99   ORF     NORFOLK, VIRGINIA                                   
C   100   G2GFA   GULF OF MEXICO                                      
C   101   G2GFB   GULF OF MEXICO                                      
C   102   G2GFC   GULF OF MEXICO                                      
C   103   G2GFD   GULF OF MEXICO                                      
C   104   G2GFE   GULF OF MEXICO                                      
C   105   G2GFF   GULF OF MEXICO                                      
C   106   CAR     CARIBOU, MAINE                                      
C   107   CON     CONCORD, NEW HAMPSHIRE                              
C   108   PIH     POCATELLO, IDAHO                                    
C   109   X68     KENNEDY SPACE CENTER        CAPE KENNEDY, FLORIDA   
C   110   EDW     EDWARDS AIR FORCE BASE       CALIFORNIA             
C   111   UCC     YUCCA FLAT, NEVEDA                                  
C   112   BTNM3       LAT:  41.5 DEG N   LONG:  69 DEG W              
C   113   LGIN6       LAT:  40 DEG N     LONG:  70 DEG W              
C   114   LWS     LEWISTON, IDAHO                                     
C   115   G2GFG   GULF OF MEXICO                                      
C   116   G2GFH   GULF OF MEXICO                                      
C   117   G2GFI   GULF OF MEXICO                                      
C   118   G2GFJ   GULF OF MEXICO                                      
C   119   G2GFK  GULF OF MEXICO                                       
C   120   SYR    SYRACUSE, NY                                         
C   121   AOO    ALTOONA, PA                                          
C   122   ROA    ROANOKE, VA                                          
C   123   AVL    ASHEVILLE, NC                                        
C   124   ZZV    ZANESVILLE, OH                                       
C   125   HC1    LAT:  39.3      LONG:   73.0                         
C   126   SGF    SPRINGFIELD, MO                                      
C   127   MLI    MOLINE, IL                                           
C   128   GRB    GREEN BAY, WI                                        
C   129   FAR    FARGO, ND                                            
C   130   GJT    GRAND JUNCTION, CO                                   
C   131   LND    LANDER, WY                                           
C   132   JKL    JACKSON, KY                                          
C   133   MAF    MIDLAND, TX                                          
C   134   DHT    DALHART, TX                                          
C   135   LCH    LAKE CHARLES, LA                                     
C   136   DHN    DOTHAN, AL                                           
C   137   TUL    TULSA, OK                                            
C   138   DAB    DAYTONA BEACH, FL                                    
C   139   GGW    GLASGOW, MT                                          
C   140   PDT    PENDLETON, OR                                        
C   141   RDD    REDDING, CA                                          
C   142   EKO    ELKO, NV                                             
C   143   LAS    LAS VEGAS, NV                                        
C   144   FLG    FLAGSTAFF, AZ                                        
C                                                                     
C   PUERTO RICAN STATIONS  (DEGREES,MINUTES)                          
C                                                                     
C   145   TJSJ   SAN JUAN, PUERTO RICO  18 26N   66 00W               
C   146   TJMZ   MAYAGUES, PUERTO RICO  18 15N   67 09W               
C   147   TJPS   PONCE, PUERTO RICO   18 01N   66 31W                 
C   148   TJBQ   AQUADILLA, PUERTO RICO   18 30N   67 08W             
C   149   TJGU   POINT  18 11N   64 44W                               
C   150   TJAD   POINT  18 15N   66 00W                               
C   151   TIST   ST. THOMAS  18 20N   64 55W                          
C   152   TISX   ST. CROIX   17 42N   64 48W                          
C   153   TISJ   ST. JOHN    18 20N   64 48W                          
C   154   TNCM   ST. MARTIN  18 03N   63 07W                          
C   155   TKPK   ST. KITTS   17 18N   62 41W                          
C   156   TJNR   CEIBA  18 15N   65 38W                               
C                                                                     
C   HAWAIIAN STATIONS   (DEGREES, TENTHS OF DEG)                      
C                                                                     
C   157   PHNL   HONOLULU    21.3N  157.9W (DEGREES,TENTHS OF DEG)    
C   158   PHLI   LIHUE       22.0N  159.3W                            
C   159   PHOG   KAHULUI     20.9N  156.4W                            
C   160   PHTO   HILO        19.7N  155.0W                            
C   161   HIB1   BUOY 1  (51001)  23.4N  162.3W                       
C   162   HIB4   BUOY 4  (51004)  17.4N  152.5W                       
C                                                                     
       DATA  ISTNS1/
     1   'SEA  ',  'GEG  ',  'GTF  ',  'BIL  ',  'PDX  ',  'MFR  ',
     2   'SFO  ',  'BOI  ',  'CYS  ',  'BIS  ',  'FSD  ',  'MSP  ',
     3   'OMA  ',  'LBF  ',  'DSM  ',  'MKE  ',  'INL  ',  'ORD  ',
     4   'SSM  ',  'DTW  ',  'IND  ',  'CLE  ',  'BUF  ',  'PIT  ',
     5   'CRW  ',  'ALB  ',  'BTV  ',  'LGA  ',  'BOS  ',  'BGR  ',
     6   'DCA  ',  'PHL  ',  'IPT  ',  'DAY  ',  'MSO  ',  'TYS  ',
     7   'RAP  ',  'MEM  ',  'SDF  ',  'MOB  ',  'SHV  ',  'PWM  ',
     8   'RNO  ',  'SLC  ',  'LAX  ',  'FAT  ',  'BFF  ',  'ELP  ',
     9   'ABQ  ',  'LBB  ',  'OKC  ',  'DFW  ',  'SAT  ',  'BRO  ',
     A   'IAH  ',  'MSY  ',  'LIT  ',  'STL  ',  'JAN  ',  'BHM  ',
     B   'ATL  ',  'TOP  ',  'TLH  ',  'LAL  ',  'MIA  ',  'CAE  ',
     C   'RDU  ',  'HAT  ',  'DEN  ',  'DRT  ',  'DDC  ',  'PHX  ',
     D   'YQB  ',  'YOW  ',  'YMW  ',  'YYB  ',  'YLH  ',  'YQT  ',
     E   'YWG  ',  'YQD  ',  'YQR  ',  'YPA  ',  'YYC  ',  'YEG  ',
     F   'MCD  ',  'YRV  ',  'YXC  ',  'YCG  ',  'YVR  ',  'YXS  '/
C                                                                     
       DATA   ISTNS2 /
     1   '9B6  ',  'AFA  ',  'C7H  ',  '3J2  ',  'ILM  ',  'SAV  ',
     2   'CDC  ',  'BNA  ',  'ORF  ',  'G2GFA',  'G2GFB',  'G2GFC',
     3   'G2GFD',  'G2GFE',  'G2GFF',  'CAR  ',  'CON  ',  'PIH  ',
     4   'X68  ',  'EDW  ',  'UCC  ',  'BTNM3',  'LGIN6',  'LWS  ',
     5   'G2GFG',  'G2GFH',  'G2GFI',  'G2GFJ',  'G2GFK',  'SYR  ',
     6   'AOO  ',  'ROA  ',  'AVL  ',  'ZZV  ',  'HC1  ',  'SGF  ',
     7   'MLI  ',  'GRB  ',  'FAR  ',  'GJT  ',  'LND  ',  'JKL  ',
     8   'MAF  ',  'DHT  ',  'LCH  ',  'DHN  ',  'TUL  ',  'DAB  ',
     9   'GGW  ',  'PDT  ',  'RDD  ',  'EKO  ',  'LAS  ',  'FLG  ',
     A   'TJSJ ',  'TJMZ ',  'TJPS ',  'TJBQ ',  'TJGU ',  'TJAD ',
     B   'TIST ',  'TISX ',  'TISJ ',  'TNCM ',  'TKPK ',  'TJNR ',
     C   'PHNL ',  'PHLI ',  'PHOG ',  'PHTO ',  'HIB1 ',  'HIB4 '/
C                                                                     
C      THE STATION LATITUDE/LONGITUDE IN DEGREES                      
C                                                                     
       DATA  XLTLG1 /
     1     47.45,  122.30,    47.63,  117.53,    47.48,  111.37,
     2     45.80,  108.53,    45.60,  122.60,    42.37,  122.87,
     3     37.62,  122.38,    43.57,  116.22,    41.15,  104.82,
     4     46.77,  100.75,    43.57,   96.73,    44.88,   93.22,
     5     41.30,   95.90,    41.13,  100.68,    41.53,   93.65,
     6     42.95,   87.90,    48.57,   93.38,    41.98,   87.90,
     7     46.47,   84.37,    42.23,   83.33,    39.73,   86.28,
     8     41.40,   81.85,    42.93,   78.73,    40.50,   80.22,
     9     38.37,   81.60,    42.75,   73.80,    44.47,   73.15,
     A     40.77,   73.90,    42.37,   71.03,    44.80,   68.82,
     B     38.85,   77.03,    39.88,   75.25,    41.25,   76.92,
     C     39.90,   84.22,    46.92,  114.08,    35.82,   83.98,
     D     44.05,  103.07,    35.05,   90.00,    38.18,   85.73,
     E     30.68,   88.25,    32.47,   93.82,    43.65,   70.32,
     F     39.50,  119.78,    40.77,  111.97,    33.93,  118.40/
C                                                                     
       DATA  XLTLG2 /
     1     36.77,  119.72,    41.87,  103.60,    31.80,  106.40,
     2     35.05,  106.62,    33.65,  101.82,    35.40,   97.60,
     3     32.90,   97.03,    29.53,   98.47,    25.90,   97.43,
     4     29.97,   95.35,    29.98,   90.25,    34.73,   92.23,
     5     38.75,   90.38,    32.32,   90.08,    33.57,   86.75,
     6     33.65,   84.43,    39.07,   95.63,    30.38,   84.37,
     7     28.03,   81.95,    25.80,   80.27,    33.95,   81.12,
     8     35.87,   78.78,    35.27,   75.55,    39.75,  104.87,
     9     29.37,  100.92,    37.77,   99.97,    33.43,  112.02,
     A     46.80,   71.38,    45.32,   75.67,    46.37,   75.98,
     B     46.37,   79.42,    52.23,   87.88,    48.37,   89.32,
     C     49.90,   97.23,    53.97,  101.10,    50.43,  104.67,
     D     53.22,  105.68,    51.12,  114.02,    53.32,  113.58,
     E     52.07,  118.57,    50.97,  118.18,    49.60,  115.78,
     F     49.30,  117.63,    49.18,  123.17,    53.88,  122.67/
C                                                                     
       DATA  XLTLG3 /
     1     43.00,   68.00,    48.00,   65.00,    38.00,   71.00,
     2     31.00,   79.00,    34.27,   77.92,    32.13,   81.20,
     3     37.70,  113.10,    36.12,   86.68,    36.90,   76.20,
     4     24.00,   85.00,    26.00,   86.00,    28.00,   87.00,
     5     26.00,   90.00,    26.00,   93.50,    22.00,   94.00,
     6     46.87,   68.02,    43.20,   71.50,    42.92,  112.60,
     7     28.62,   80.68,    34.90,  117.87,    36.95,  116.05,
     8     41.50,   69.00,    40.00,   70.00,    46.38,  117.02,
     9     28.00,   95.90,    28.20,   93.70,    28.50,   92.30,
     A     27.90,   91.00,    28.00,   89.00,    43.12,   76.12,
     B     40.30,   78.32,    37.32,   79.97,    35.43,   82.53,
     C     39.95,   81.90,    39.30,   73.00,    37.23,   93.38,
     E     41.45,   90.52,    44.48,   88.12,    46.90,   96.80,
     F     39.12,  108.53,    42.82,  108.73,    37.60,   83.32,
     G     31.95,  102.18,    36.02,  102.55,    30.12,   93.22/
C                                                                     
       DATA  XLTLG4 /
     1     31.32,   85.45,    36.20,   95.90,    29.18,   81.05,
     2     48.22,  106.62,    45.68,  118.85,    40.50,  122.30,
     3     40.83,  115.78,    36.08,  115.17,    35.13,  111.67,
     4     18.43,   66.00,    18.25,   67.15,    18.01,   66.51,
     5     18.50,   67.13,    18.18,   64.73,    18.25,   66.00,
     6     18.33,   64.91,    17.70,   64.80,    18.33,   64.80,
     7     18.05,   63.11,    17.30,   62.68,    18.25,   65.63,
     8     21.30,  157.90,    22.00,  159.30,    20.90,  156.40,
     9     19.70,  155.00,    23.40,  162.30,    17.40,  152.50/
C                                                                     
100    FORMAT ( '1', 'STNS1', 6X, 'LAT',10X, 'LON', 8X, 'I', 11X, 'J')
C                                                                     
110    FORMAT ( ' ', A5, 4X, F7.2, 4X, F7.2, 4X, F7.3, 4X, F8.3)
C                                                                     
C      NUMBER OF FOUS STATIONS                                   
       NTOT1 = 162
C                                                                     
C      MOVE STATION IDS TO JSTN                                       
C                                                                     
       DO  1200  I = 1,90
         STNS1(I) = ISTNS1(I)
1200   CONTINUE
C                                                                     
       DO  1400  I = 1,72
         STNS1(I+90) = ISTNS2(I)
1400   CONTINUE
C                                                                     
C      MOVE STATION LAT/LONG LOCATION TO XLATLN                       
C                                                                     
       DO  1600  I = 1,45
         XLATLN(1,I) = XLTLG1(1,I)
         XLATLN(2,I) = XLTLG1(2,I)
         XLATLN(1,I+45) = XLTLG2(1,I)
         XLATLN(2,I+45) = XLTLG2(2,I)
         XLATLN(1,I+90) = XLTLG3(1,I)
         XLATLN(2,I+90) = XLTLG3(2,I)
1600   CONTINUE
C                                                                     
       DO  1800  I = 1,27
         XLATLN(1,I+135) = XLTLG4(1,I)
         XLATLN(2,I+135) = XLTLG4(2,I)
1800   CONTINUE
C                                                                     
CCC    PRINT  100                                                     
C                                                                     
c      ORIENT = 105.0
c      XMESHL = 90.75464
C                                                                     
       DO 3000  N = 1, NTOT1
         ALAT = XLATLN(1,N)
         ALONG = - XLATLN(2,N)
C
C        CONVERT THE LAT/LONG COORDINATES OF STATION TO LAMBERT
C        CONFORMAL PROJECTION I,J COORDINATES FOR GRID 221
C
C        LATITUDE OF LOWER LEFT POINT OF GRID (POINT (1,1)
         ALAT1 = 1.0
C
C        EAST LONGITUDE OF OF LOWER LEFT POINT OF GRID (POINT (1,1)
         ELON1 = 214.5
C
C        MESH LENGTH OF GRID IN METERS AT TANGENT LATITUDE
         DX = 32463.41
C
C        THE ORIENTATION OF THE GRID
         ELONV = 253.0
C
C        THE LATITUDE AT WHICH THE LAMBERT CONE IS TANGENT TO 
C        THE SPHERICAL EARTH
C
         ALATAN = 50.0
C
         CALL W3FB11( ALAT, ALONG, ALAT1, ELON1, DX, ELONV, ALATAN,
     +                XI, XJ )
C
         SI(N) = XI
         SJ(N) = XJ
C                                                                     
CCC      PRINT 110, STNS1(N), ALAT, ALONG, SI(N), SJ(N)               
C
3000   CONTINUE
C                                                                     
       RETURN
       END
