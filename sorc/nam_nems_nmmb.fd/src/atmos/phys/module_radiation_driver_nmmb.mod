  ?S  ?   k820309    w          19.1        L~?a                                                                                                          
       grrad_nmmb.f MODULE_RADIATION_DRIVER_NMMB              RADINIT_NMMB RADUPDATE_NMMB GRRAD_NMMB DAYPARTS                                                     
                            @                              
       FPVS FPKAPX                                                     
       EPSQ                      @                              
       SOL_INIT_NMMB SOL_UPDATE_NMMB COSZMN_NMMB                      @                              
       NF_VGAS GETGASES GETOZN GAS_INIT GAS_UPDATE                      @                              
       NF_AESW NF_AELW SETAER AER_INIT AER_UPDATE                      @                              
       NF_ALBD SFC_INIT SETALB SETEMIS                      @                              
       NF_CLDS CLD_INIT PROGCLD1 PROGCLD2 DIAGCLD1 PROGCLD8                                                	     
       TOPFSW_TYPE SFCFSW_TYPE PROFSW_TYPE CMPFSW_TYPE NBDSW                      @                         
     
       RSWINIT SWRAD                                                     
       TOPFLW_TYPE SFCFLW_TYPE PROFLW_TYPE NBDLW                      @                              
       RLWINIT LWRAD                                                     
      PI CON_PI CON_EPS CON_EPSM1 CON_FVIRT               @  @                                '                    #UPFXC    #DNFXC    #UPFX0                 ?                                              
                ?                                             
                ?                                             
                 @  @                                '                     #UPFXC    #DNFXC    #UPFX0    #DNFX0                 ?                                              
                ?                                             
                ?                                             
                ?                                             
                  @  @                                '                     #UPFXC    #DNFXC    #UPFX0    #DNFX0                 ?                                              
                ?                                             
                ?                                             
                ?                                             
                  @  @                                '0                    #UVBFC    #UVBF0    #NIRBM    #NIRDF     #VISBM !   #VISDF "                ?                                              
                ?                                             
                ?                                             
                ?                                              
                ?                              !                
                ?                              "     (          
                 @  @                           #     '                    #UPFXC $   #UPFX0 %                ?                              $                
                ?                              %               
                 @  @                           &     '                     #UPFXC '   #UPFX0 (   #DNFXC )   #DNFX0 *                ?                              '                
                ?                              (               
                ?                              )               
                ?                              *               
                  @  @                           +     '                     #UPFXC ,   #DNFXC -   #UPFX0 .   #DNFX0 /                ?                              ,                
                ?                              -               
                ?                              .               
                ?                              /               
   #         @                                   0                    #SI 1   #NLAY 2   #ME 3             
  @                              1                   
              &                                                     
  @                               2                     
  @                               3           #         @                                   4                 
   #IDATE 5   #JDATE 6   #DELTSW 7   #DELTIM 8   #LSSWR 9   #ME :   #SLAG ;   #SDEC <   #CDEC =   #SOLCON >             
                                  5                                 &                                                     
  @                               6                                 &                                                     
  @                              7     
                
  @                              8     
                
                                  9                     
  @                               :                     D @                              ;     
                 D @                              <     
                 D @                              =     
                 D @                              >     
       #         @                                   ?                 L   #PRSI @   #PRSL C   #PRSLK D   #TGRS E   #QGRS F   #TRACER G   #VVL I   #SLMSK J   #XLON K   #XLAT L   #TSFC M   #SNOWD N   #SNCOVR O   #SNOALB P   #ZORL Q   #HPRIM R   #SALBEDO S   #SM T   #FICE U   #TISFC V   #SINLAT W   #COSLAT X   #SOLHR Y   #JDATE Z   #SOLCON [   #DTSWAV \   #NRADS ]   #CV ^   #CVT _   #CVB `   #FCICE a   #FRAIN b   #RRIME c   #FLGMIN d   #ICSDSW e   #ICSDLW f   #NTCW g   #NCLD h   #NTOZ i   #NTRAC H   #NFXR j   #CPATHFAC4LW k   #DTLW l   #DTSW m   #LSSWR n   #LSLWR o   #LSSAV p   #ITS q   #JTS r   #IX A   #IM s   #LM B   #ISDAY t   #ME u   #LPRNT v   #IPT w   #KDT x   #TAUCLOUDS y   #CLDF z   #CLD_FRACTION {   #HTRSW |   #TOPFSW }   #SFCFSW ~   #SFALB    #COSZEN ?   #COSZDG ?   #HTRLW ?   #TOPFLW ?   #SFCFLW ?   #TSFLW ?   #SEMIS ?   #CLDCOV ?   #CLDSA ?   #FLUXR ?   #HTRSWB ?   #HTRLWB ?            
                                 @                    
      p        5 ? p 2       r A   p          5 ? p 2       r A      5 ? p 4       r B   n                                       1    5 ? p 2       r A      5 ? p 4       r B   n                                      1                                    
                                 C                    
      p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                              
                                 D                    
      p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                              
  @                              E                    
      p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                              
                                 F                    
      p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                              
                                 G                    
 )       p        5 ? p 4       r B   p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B     5 ? p (       r H       5 ? p 2       r A     5 ? p 4       r B     5 ? p (       r H                              
                                 I                    
      p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                              
  @                              J                    
    p          5 ? p 2       r A       5 ? p 2       r A                              
  @                              K                    
    p          5 ? p 2       r A       5 ? p 2       r A                              
  @                              L                    
    p          5 ? p 2       r A       5 ? p 2       r A                              
                                 M                    
    p          5 ? p 2       r A       5 ? p 2       r A                              
  @                              N                    
    p          5 ? p 2       r A       5 ? p 2       r A                              
  @                              O                    
 %   p          5 ? p 2       r A       5 ? p 2       r A                              
  @                              P                    
 &   p          5 ? p 2       r A       5 ? p 2       r A                              
  @                              Q                    
    p          5 ? p 2       r A       5 ? p 2       r A                              
  @                              R                    
    p          5 ? p 2       r A       5 ? p 2       r A                              
                                 S                    
 *   p          5 ? p 2       r A       5 ? p 2       r A                              
                                 T                    
 +   p          5 ? p 2       r A       5 ? p 2       r A                              
  @                              U                    
 #   p          5 ? p 2       r A       5 ? p 2       r A                              
  @                              V                    
 $   p          5 ? p 2       r A       5 ? p 2       r A                              
  @                              W                    
 '   p          5 ? p 2       r A       5 ? p 2       r A                              
  @                              X                    
 (   p          5 ? p 2       r A       5 ? p 2       r A                               
  @                              Y     
                
                                  Z                       p          p            p                                    
  @                              [     
                
  @                              \     
                
  @                               ]                    
  @                              ^                    
     p          5 ? p 2       r A       5 ? p 2       r A                              
                                 _                    
 !   p          5 ? p 2       r A       5 ? p 2       r A                              
                                 `                    
 "   p          5 ? p 2       r A       5 ? p 2       r A                              
                                 a                    
      p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                              
                                 b                    
      p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                              
                                 c                    
      p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                              
  @                              d                    
    p          5 ? p 2       r A       5 ? p 2       r A                              
                                  e                        p          5 ? p 2       r A       5 ? p 2       r A                              
  @                               f                        p          5 ? p 2       r A       5 ? p 2       r A                               
                                  g                     
                                  h                     
                                  i                     
                                  H                     
                                  j                     
                                  k     
                
  @                              l     
                
  @                              m     
                
  @                               n                     
  @                               o                     
                                  p                     
  @                               q                     
  @                               r                     
                                  A                     
  @                               s                     
  @                               B                     
                                  t                     
  @                               u                     
  @                               v                     
                                  w                     
                                  x                    
                                 y                    
 ,     p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                              
                                 z                    
 -     p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                               
  @                               {                    D                                |                    
 .      p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                              D                                 }                    7      p          5 ? p 2       r A       5 ? p 2       r A                     #TOPFSW_TYPE             D                                 ~                     8      p          5 ? p 2       r A       5 ? p 2       r A                     #SFCFSW_TYPE             D                                                    
 3    p          5 ? p 2       r A       5 ? p 2       r A                              D                                ?                    
 5    p          5 ? p 2       r A       5 ? p 2       r A                              D @                              ?                    
 6    p          5 ? p 2       r A       5 ? p 2       r A                              D                                ?                    
 /      p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                              D @                               ?                    9      p          5 ? p 2       r A       5 ? p 2       r A                     #TOPFLW_TYPE #            D @                               ?                     :      p          5 ? p 2       r A       5 ? p 2       r A                     #SFCFLW_TYPE &            D                                ?                    
 2    p          5 ? p 2       r A       5 ? p 2       r A                              D                                ?                    
 4    p          5 ? p 2       r A       5 ? p 2       r A                              D                                ?                    
 0      p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B       5 ? p 2       r A     5 ? p 4       r B                              D @                              ?                    
 1      p        5 ? p 2       r A   p          5 ? p 2       r A     p            5 ? p 2       r A     p                                   
D                                ?                    
 ;      p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p )       r j       5 ? p 2       r A     5 ? p )       r j                              F @                              ?                    
 <        p        5 ? p 4       r B   p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B     p            5 ? p 2       r A     5 ? p 4       r B     p                                   F @                              ?                    
 =        p        5 ? p 4       r B   p        5 ? p 2       r A   p          5 ? p 2       r A     5 ? p 4       r B     p            5 ? p 2       r A     5 ? p 4       r B     p                          #         @                                   ?                    #XLON ?   #SINLAT ?   #COSLAT ?   #SOLHR ?   #MYPE ?   #DTSWAV ?   #NRADS ?   #VECLEN ?   #DP_START ?   #DP_LEN ?   #DP_DAY ?   #NDAYPARTS ?            
  @                              ?                    
    p          5 ? p        r ?       5 ? p        r ?                              
  @                              ?                    
    p          5 ? p        r ?       5 ? p        r ?                              
  @                              ?                    
    p          5 ? p        r ?       5 ? p        r ?                               
  @                              ?     
                
  @                               ?                     
  @                              ?     
                
  @                               ?                     
  @                               ?                    D                                 ?                         p          5 ? p        r ?       5 ? p        r ?                              D                                 ?                         p          5 ? p        r ?       5 ? p        r ?                              D                                 ?                     	    p          5 ? p        r ?       5 ? p        r ?                               D                                 ?               ?   2      fn#fn 2   ?   @   b   uapp(MODULE_RADIATION_DRIVER_NMMB      @   J  PHYSPARAM    R  L   J  FUNCPHYS !   ?  E   J  MODULE_CONSTANTS 0   ?  j   J  MODULE_RADIATION_ASTRONOMY_NMMB ,   M  l   J  MODULE_RADIATION_GASES_NMMB /   ?  k   J  MODULE_RADIATION_AEROSOLS_NMMB .   $  `   J  MODULE_RADIATION_SURFACE_NMMB -   ?  u   J  MODULE_RADIATION_CLOUDS_NMMB (   ?  v   J  MODULE_RADSW_PARAMETERS '   o  N   J  MODULE_RADSW_MAIN_NMMB (   ?  j   J  MODULE_RADLW_PARAMETERS '   '  N   J  MODULE_RADLW_MAIN_NMMB    u  f   J  PHYSCONS 4   ?  q      TOPFSW_TYPE+MODULE_RADSW_PARAMETERS :   L  H   a   TOPFSW_TYPE%UPFXC+MODULE_RADSW_PARAMETERS :   ?  H   a   TOPFSW_TYPE%DNFXC+MODULE_RADSW_PARAMETERS :   ?  H   a   TOPFSW_TYPE%UPFX0+MODULE_RADSW_PARAMETERS 4   $  |      SFCFSW_TYPE+MODULE_RADSW_PARAMETERS :   ?  H   a   SFCFSW_TYPE%UPFXC+MODULE_RADSW_PARAMETERS :   ?  H   a   SFCFSW_TYPE%DNFXC+MODULE_RADSW_PARAMETERS :   0  H   a   SFCFSW_TYPE%UPFX0+MODULE_RADSW_PARAMETERS :   x  H   a   SFCFSW_TYPE%DNFX0+MODULE_RADSW_PARAMETERS 4   ?  |      PROFSW_TYPE+MODULE_RADSW_PARAMETERS :   <	  H   a   PROFSW_TYPE%UPFXC+MODULE_RADSW_PARAMETERS :   ?	  H   a   PROFSW_TYPE%DNFXC+MODULE_RADSW_PARAMETERS :   ?	  H   a   PROFSW_TYPE%UPFX0+MODULE_RADSW_PARAMETERS :   
  H   a   PROFSW_TYPE%DNFX0+MODULE_RADSW_PARAMETERS 4   \
  ?      CMPFSW_TYPE+MODULE_RADSW_PARAMETERS :   ?
  H   a   CMPFSW_TYPE%UVBFC+MODULE_RADSW_PARAMETERS :   6  H   a   CMPFSW_TYPE%UVBF0+MODULE_RADSW_PARAMETERS :   ~  H   a   CMPFSW_TYPE%NIRBM+MODULE_RADSW_PARAMETERS :   ?  H   a   CMPFSW_TYPE%NIRDF+MODULE_RADSW_PARAMETERS :     H   a   CMPFSW_TYPE%VISBM+MODULE_RADSW_PARAMETERS :   V  H   a   CMPFSW_TYPE%VISDF+MODULE_RADSW_PARAMETERS 4   ?  f      TOPFLW_TYPE+MODULE_RADLW_PARAMETERS :     H   a   TOPFLW_TYPE%UPFXC+MODULE_RADLW_PARAMETERS :   L  H   a   TOPFLW_TYPE%UPFX0+MODULE_RADLW_PARAMETERS 4   ?  |      SFCFLW_TYPE+MODULE_RADLW_PARAMETERS :     H   a   SFCFLW_TYPE%UPFXC+MODULE_RADLW_PARAMETERS :   X  H   a   SFCFLW_TYPE%UPFX0+MODULE_RADLW_PARAMETERS :   ?  H   a   SFCFLW_TYPE%DNFXC+MODULE_RADLW_PARAMETERS :   ?  H   a   SFCFLW_TYPE%DNFX0+MODULE_RADLW_PARAMETERS 4   0  |      PROFLW_TYPE+MODULE_RADLW_PARAMETERS :   ?  H   a   PROFLW_TYPE%UPFXC+MODULE_RADLW_PARAMETERS :   ?  H   a   PROFLW_TYPE%DNFXC+MODULE_RADLW_PARAMETERS :   <  H   a   PROFLW_TYPE%UPFX0+MODULE_RADLW_PARAMETERS :   ?  H   a   PROFLW_TYPE%DNFX0+MODULE_RADLW_PARAMETERS    ?  b       RADINIT_NMMB     .  ?   a   RADINIT_NMMB%SI "   ?  @   a   RADINIT_NMMB%NLAY     ?  @   a   RADINIT_NMMB%ME    :  ?       RADUPDATE_NMMB %   ?  ?   a   RADUPDATE_NMMB%IDATE %   y  ?   a   RADUPDATE_NMMB%JDATE &     @   a   RADUPDATE_NMMB%DELTSW &   E  @   a   RADUPDATE_NMMB%DELTIM %   ?  @   a   RADUPDATE_NMMB%LSSWR "   ?  @   a   RADUPDATE_NMMB%ME $     @   a   RADUPDATE_NMMB%SLAG $   E  @   a   RADUPDATE_NMMB%SDEC $   ?  @   a   RADUPDATE_NMMB%CDEC &   ?  @   a   RADUPDATE_NMMB%SOLCON      ?      GRRAD_NMMB     ?  ?  a   GRRAD_NMMB%PRSI       $  a   GRRAD_NMMB%PRSL !   A  $  a   GRRAD_NMMB%PRSLK     e  $  a   GRRAD_NMMB%TGRS     ?  $  a   GRRAD_NMMB%QGRS "   ?  ?  a   GRRAD_NMMB%TRACER    A!  $  a   GRRAD_NMMB%VVL !   e"  ?   a   GRRAD_NMMB%SLMSK     #  ?   a   GRRAD_NMMB%XLON     ?#  ?   a   GRRAD_NMMB%XLAT     ?$  ?   a   GRRAD_NMMB%TSFC !   5%  ?   a   GRRAD_NMMB%SNOWD "   ?%  ?   a   GRRAD_NMMB%SNCOVR "   ?&  ?   a   GRRAD_NMMB%SNOALB     Q'  ?   a   GRRAD_NMMB%ZORL !   (  ?   a   GRRAD_NMMB%HPRIM #   ?(  ?   a   GRRAD_NMMB%SALBEDO    m)  ?   a   GRRAD_NMMB%SM     !*  ?   a   GRRAD_NMMB%FICE !   ?*  ?   a   GRRAD_NMMB%TISFC "   ?+  ?   a   GRRAD_NMMB%SINLAT "   =,  ?   a   GRRAD_NMMB%COSLAT !   ?,  @   a   GRRAD_NMMB%SOLHR !   1-  ?   a   GRRAD_NMMB%JDATE "   ?-  @   a   GRRAD_NMMB%SOLCON "   .  @   a   GRRAD_NMMB%DTSWAV !   E.  @   a   GRRAD_NMMB%NRADS    ?.  ?   a   GRRAD_NMMB%CV    9/  ?   a   GRRAD_NMMB%CVT    ?/  ?   a   GRRAD_NMMB%CVB !   ?0  $  a   GRRAD_NMMB%FCICE !   ?1  $  a   GRRAD_NMMB%FRAIN !   ?2  $  a   GRRAD_NMMB%RRIME "   4  ?   a   GRRAD_NMMB%FLGMIN "   ?4  ?   a   GRRAD_NMMB%ICSDSW "   u5  ?   a   GRRAD_NMMB%ICSDLW     )6  @   a   GRRAD_NMMB%NTCW     i6  @   a   GRRAD_NMMB%NCLD     ?6  @   a   GRRAD_NMMB%NTOZ !   ?6  @   a   GRRAD_NMMB%NTRAC     )7  @   a   GRRAD_NMMB%NFXR '   i7  @   a   GRRAD_NMMB%CPATHFAC4LW     ?7  @   a   GRRAD_NMMB%DTLW     ?7  @   a   GRRAD_NMMB%DTSW !   )8  @   a   GRRAD_NMMB%LSSWR !   i8  @   a   GRRAD_NMMB%LSLWR !   ?8  @   a   GRRAD_NMMB%LSSAV    ?8  @   a   GRRAD_NMMB%ITS    )9  @   a   GRRAD_NMMB%JTS    i9  @   a   GRRAD_NMMB%IX    ?9  @   a   GRRAD_NMMB%IM    ?9  @   a   GRRAD_NMMB%LM !   ):  @   a   GRRAD_NMMB%ISDAY    i:  @   a   GRRAD_NMMB%ME !   ?:  @   a   GRRAD_NMMB%LPRNT    ?:  @   a   GRRAD_NMMB%IPT    );  @   a   GRRAD_NMMB%KDT %   i;  $  a   GRRAD_NMMB%TAUCLOUDS     ?<  $  a   GRRAD_NMMB%CLDF (   ?=  @   a   GRRAD_NMMB%CLD_FRACTION !   ?=  $  a   GRRAD_NMMB%HTRSW "   ?  ?   a   GRRAD_NMMB%TOPFSW "   ??  ?   a   GRRAD_NMMB%SFCFSW !   ?@  ?   a   GRRAD_NMMB%SFALB "   SA  ?   a   GRRAD_NMMB%COSZEN "   B  ?   a   GRRAD_NMMB%COSZDG !   ?B  $  a   GRRAD_NMMB%HTRLW "   ?C  ?   a   GRRAD_NMMB%TOPFLW "   ?D  ?   a   GRRAD_NMMB%SFCFLW !   iE  ?   a   GRRAD_NMMB%TSFLW !   F  ?   a   GRRAD_NMMB%SEMIS "   ?F  $  a   GRRAD_NMMB%CLDCOV !   ?G    a   GRRAD_NMMB%CLDSA !   ?H  $  a   GRRAD_NMMB%FLUXR "   J  t  a   GRRAD_NMMB%HTRSWB "   ?K  t  a   GRRAD_NMMB%HTRLWB    M  ?       DAYPARTS    ?M  ?   a   DAYPARTS%XLON     ?N  ?   a   DAYPARTS%SINLAT     DO  ?   a   DAYPARTS%COSLAT    ?O  @   a   DAYPARTS%SOLHR    8P  @   a   DAYPARTS%MYPE     xP  @   a   DAYPARTS%DTSWAV    ?P  @   a   DAYPARTS%NRADS     ?P  @   a   DAYPARTS%VECLEN "   8Q  ?   a   DAYPARTS%DP_START     ?Q  ?   a   DAYPARTS%DP_LEN     ?R  ?   a   DAYPARTS%DP_DAY #   TS  @   a   DAYPARTS%NDAYPARTS 