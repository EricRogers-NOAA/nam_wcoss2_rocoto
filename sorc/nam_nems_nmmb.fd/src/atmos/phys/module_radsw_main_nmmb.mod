  ?(  T   k820309    w          19.1        >~?a                                                                                                          
       radsw_main_nmmb.f MODULE_RADSW_MAIN_NMMB              SWRAD RSWINIT BUGGAL BUGGALON BUGGALOFF CHK                                                     
                                                           
                                                           
       ISWRATE ISWRGAS ISWCLIQ ISWCICE ISUBCSW ICLDFLG IOVRSW IVFLIP ISWMODE KIND_PHYS KIND_TAUM                                                     
       CON_G CON_CP CON_AVGD CON_AMD CON_AMW CON_AMO3                      @                              
       RANDOM_SETSEED RANDOM_NUMBER RANDOM_STAT                                                     
       PREFLOG TREF               @?                                      u #RANDOM_SETSEED_S    #RANDOM_SETSEED_T 	   #         @     @                                                #INSEED              
                                             #         @     @                           	                    #INSEED 
   #STAT              
                                  
                                                           ?	              #RANDOM_STAT                  @?                                      u #RANDOM_NUMBER_I    #RANDOM_NUMBER_S    #RANDOM_NUMBER_T    #         @     @                                                #HARVEST    #INSEED                                                                  
               &                                                     
                                             #         @     @                                                #HARVEST                                                                  
               &                                           #         @     @                                               #HARVEST    #STAT                                                                 
               &                                                     
                                      ?	              #RANDOM_STAT                   ?  @                               '?	                   #MTI    #MT    #ISET    #GSET                ? D                                                                        ?                                         q                               ? D  ?                                 p                         p           & p         p o          p p                                     ? D                                   ?	                         ? D                                   ?	         
                 @  @                                '                    #UPFXC    #DNFXC    #UPFX0                 ?                                              
                ?                                             
                ?                                             
                 @  @                                '                     #UPFXC    #DNFXC    #UPFX0     #DNFX0 !                ?                                              
                ?                                             
                ?                                              
                ?                              !               
                 @  @                           "     '                     #UPFXC #   #DNFXC $   #UPFX0 %   #DNFX0 &                ?                              #                
                ?                              $               
                ?                              %               
                ?                              &               
                 @  @                           '     '0                    #UVBFC (   #UVBF0 )   #NIRBM *   #NIRDF +   #VISBM ,   #VISDF -                ?                              (                
                ?                              )               
                ?                              *               
                ?                              +               
                ?                              ,                
                ?                              -     (          
                                                .                                                      8           @                                 /            #         @                                   0                    #PLYR 1   #PLVL 3   #TLYR 5   #TLVL 6   #QLYR 7   #OLYR 8   #GASVMR 9   #CLOUDS :   #ICSEED ;   #AEROSOLS <   #SFCALB =   #COSZ >   #SOLCON ?   #NDAY @   #IDXDAY A   #NPTS B   #NLAY 2   #NLP1 4   #LPRNT C   #HSWC D   #TOPFLX E   #SFCFLX F   #HSW0 G   #HSWB H   #FLXPRF I   #FDNCMP J   #ITS K   #JTS L            
                                 1                    
 
   p 	         p          5 ? p        r 2       p          5 ? p        r 2                              
                                 3                    
    p 	         p          5 ? p        r 4       p          5 ? p        r 4                              
                                 5                    
    p 	         p          5 ? p        r 2       p          5 ? p        r 2                              
                                 6                    
 	   p 	         p          5 ? p        r 4       p          5 ? p        r 4                              
                                 7                    
    p 	         p          5 ? p        r 2       p          5 ? p        r 2                              
                                 8                    
    p 	         p          5 ? p        r 2       p          5 ? p        r 2                              
                                 9                    
        p        5 ? p        r 2   p        p        p          p          5 ? p        r 2     p 	           p          5 ? p        r 2     p 	                                  
                                 :                    
        p        5 ? p        r 2   p        p        p          p          5 ? p        r 2     p 	           p          5 ? p        r 2     p 	                                   
                                  ;                                 &                                                    
                                 <                    
          p        p        p        5 ? p        r 2   p        p        p          p          5 ? p        r 2     p          p            p          5 ? p        r 2     p          p                                    
                                 =                    
    p 	         p          p            p          p                                    
                                 >                   
    p          p            p                                    
                                 ?     
                
  @                               @                     
                                  A                                 &                                                     
                                  B                     
  @                               2                     
  @                               4                     
                                  C                    D                                D                    
     p 	         p          5 ? p        r 2       p          5 ? p        r 2                               D                                 E                         p          p            p                          #TOPFSW_TYPE              D                                 F                          p          p            p                          #SFCFSW_TYPE             F @                              G                    
     p 	         p          5 ? p        r 2       p          5 ? p        r 2                              F @                              H                    
         p        5 ? p        r 2   p        p        p          p          5 ? p        r 2     p            p          5 ? p        r 2     p                                   F @                               I                           p 	         p          5 ? p        r 4       p          5 ? p        r 4                     #PROFSW_TYPE "             F @                               J            0             p          p            p                          #CMPFSW_TYPE '             
                                 K                     
                                 L           #         @                                   M                    #ME N             
                                  N           #         @                                   O                     #         @                                   P                        ?   1      fn#fn ,   ?   <   b   uapp(MODULE_RADSW_MAIN_NMMB (     @   J  MODULE_RADSW_PARAMETERS #   M  @   J  MODULE_RADSW_SFLUX    ?  ?   J  PHYSPARAM    '  o   J  PHYSCONS !   ?  i   J  MERSENNE_TWISTER !   ?  M   J  MODULE_RADSW_REF 4   L  l       gen@RANDOM_SETSEED+MERSENNE_TWISTER 2   ?  T      RANDOM_SETSEED_S+MERSENNE_TWISTER 9     @   a   RANDOM_SETSEED_S%INSEED+MERSENNE_TWISTER 2   L  ^      RANDOM_SETSEED_T+MERSENNE_TWISTER 9   ?  @   a   RANDOM_SETSEED_T%INSEED+MERSENNE_TWISTER 7   ?  Y   a   RANDOM_SETSEED_T%STAT+MERSENNE_TWISTER 3   C         gen@RANDOM_NUMBER+MERSENNE_TWISTER 1   ?  a      RANDOM_NUMBER_I+MERSENNE_TWISTER 9   #  ?   a   RANDOM_NUMBER_I%HARVEST+MERSENNE_TWISTER 8   ?  @   a   RANDOM_NUMBER_I%INSEED+MERSENNE_TWISTER 1   ?  U      RANDOM_NUMBER_S+MERSENNE_TWISTER 9   D  ?   a   RANDOM_NUMBER_S%HARVEST+MERSENNE_TWISTER 1   ?  _      RANDOM_NUMBER_T+MERSENNE_TWISTER 9   /  ?   a   RANDOM_NUMBER_T%HARVEST+MERSENNE_TWISTER 6   ?  Y   a   RANDOM_NUMBER_T%STAT+MERSENNE_TWISTER -   	  u       RANDOM_STAT+MERSENNE_TWISTER 5   ?	  ?   %   RANDOM_STAT%MTI+MERSENNE_TWISTER=MTI 3   -
  ?   %   RANDOM_STAT%MT+MERSENNE_TWISTER=MT 7   ?
  H   %   RANDOM_STAT%ISET+MERSENNE_TWISTER=ISET 7   !  H   %   RANDOM_STAT%GSET+MERSENNE_TWISTER=GSET 4   i  q      TOPFSW_TYPE+MODULE_RADSW_PARAMETERS :   ?  H   a   TOPFSW_TYPE%UPFXC+MODULE_RADSW_PARAMETERS :   "  H   a   TOPFSW_TYPE%DNFXC+MODULE_RADSW_PARAMETERS :   j  H   a   TOPFSW_TYPE%UPFX0+MODULE_RADSW_PARAMETERS 4   ?  |      SFCFSW_TYPE+MODULE_RADSW_PARAMETERS :   .  H   a   SFCFSW_TYPE%UPFXC+MODULE_RADSW_PARAMETERS :   v  H   a   SFCFSW_TYPE%DNFXC+MODULE_RADSW_PARAMETERS :   ?  H   a   SFCFSW_TYPE%UPFX0+MODULE_RADSW_PARAMETERS :     H   a   SFCFSW_TYPE%DNFX0+MODULE_RADSW_PARAMETERS 4   N  |      PROFSW_TYPE+MODULE_RADSW_PARAMETERS :   ?  H   a   PROFSW_TYPE%UPFXC+MODULE_RADSW_PARAMETERS :     H   a   PROFSW_TYPE%DNFXC+MODULE_RADSW_PARAMETERS :   Z  H   a   PROFSW_TYPE%UPFX0+MODULE_RADSW_PARAMETERS :   ?  H   a   PROFSW_TYPE%DNFX0+MODULE_RADSW_PARAMETERS 4   ?  ?      CMPFSW_TYPE+MODULE_RADSW_PARAMETERS :   |  H   a   CMPFSW_TYPE%UVBFC+MODULE_RADSW_PARAMETERS :   ?  H   a   CMPFSW_TYPE%UVBF0+MODULE_RADSW_PARAMETERS :     H   a   CMPFSW_TYPE%NIRBM+MODULE_RADSW_PARAMETERS :   T  H   a   CMPFSW_TYPE%NIRDF+MODULE_RADSW_PARAMETERS :   ?  H   a   CMPFSW_TYPE%VISBM+MODULE_RADSW_PARAMETERS :   ?  H   a   CMPFSW_TYPE%VISDF+MODULE_RADSW_PARAMETERS    ,  q       CHK    ?  @       BUGGAL    ?  w      SWRAD    T  ?   a   SWRAD%PLYR    (  ?   a   SWRAD%PLVL    ?  ?   a   SWRAD%TLYR    ?  ?   a   SWRAD%TLVL    ?  ?   a   SWRAD%QLYR    x  ?   a   SWRAD%OLYR    L  D  a   SWRAD%GASVMR    ?  D  a   SWRAD%CLOUDS    ?  ?   a   SWRAD%ICSEED    `  ?  a   SWRAD%AEROSOLS    ?  ?   a   SWRAD%SFCALB    ?  ?   a   SWRAD%COSZ    ,  @   a   SWRAD%SOLCON    l  @   a   SWRAD%NDAY    ?  ?   a   SWRAD%IDXDAY    8   @   a   SWRAD%NPTS    x   @   a   SWRAD%NLAY    ?   @   a   SWRAD%NLP1    ?   @   a   SWRAD%LPRNT    8!  ?   a   SWRAD%HSWC    "  ?   a   SWRAD%TOPFLX    ?"  ?   a   SWRAD%SFCFLX    V#  ?   a   SWRAD%HSW0    *$  D  a   SWRAD%HSWB    n%  ?   a   SWRAD%FLXPRF    S&  ?   a   SWRAD%FDNCMP    ?&  @   a   SWRAD%ITS    8'  @   a   SWRAD%JTS    x'  P       RSWINIT    ?'  @   a   RSWINIT%ME    (  H       BUGGALON    P(  H       BUGGALOFF 