      program lspasno24h
C$$$  MAIN PROGRAM DOCUMENTATION BLOCK
C
c MAIN PROGRAM: LSPASNO24H program does the following:
c  1. Reads in 24hrs' worth of (3-hourly) NDAS LSPA and CPOFP from the 
c     8 NDAS segments that goes into the NDAS cycle (from two 12-hr NDAS, 
c     if we are running 2 cycles per day; from the first 6 hours of each 
c     EDAS if we are running 4 cycles per day).
c       LSPA: land surface precipitation accumulation.  Same unit as APCP
c         (total accumulated precip; parm 61. mm or kg/m2)
c         Grib Table 130, parm 154.
c       CPOFP: Prob. of frozen precipitation [%].  Same as SR (Snow Ratio) 
c         in model code, except that WRF Post multiplied it by 100 to arrive
c         at the % numver for the probability.  
c         Grib Table 2, parm 194.
c  2. Sum up the precip into 24h totals (12Z-12Z).  Output it in grib format.
c  3. Create a 'daily snow mask' - at any horizontal grid point in the past 
c     24h, if there is a CPOFP value .ge. 90 during at least one hour, that 
c     point is maked as having had snow.  The mask is integer:
c       0 - no snow
c       1 - snowed sometime in the past 24h (12Z-12Z)
c     Output snow mask in binary format.
c
C   Programmer: Ying lin           ORG: NP22        Date: 2003-06-14
C
c Input:
c    unit 11-18: NDAS 03.tmxx output on egrid that contains LSPA and CPOFP
c                (snow flag determined from unit 5 input)
c Output: 
c    
c    Unit 51 - lspa.${day}12.24h (24h sum of LSPA ending ${day}12)
c    Unit 52 - snowmask.${day}12.24h (snow mask, considered valid between
c                 ${daym1}12 and ${day}12.
c
c PROGRAM HISTORY LOG:
c    2003/04/03  Y. Lin, created for off-line (no Eta/EDAS) retro experiments
c                using hourly precip input and model snow ratios from run
c                history
c    2003/06/14  Y. Lin, modified to compute budget using EDAS precip
c                (to be compared to daily gauge analysis)
c    2005/09/14  Y. Lin, modified for WRF/NMM
c    2013/02/20  J. Carley, modified for hourly updated NAM (NAMRR)
c                    -now use units 11-34 for the NAMRR.tmxx output on
c                     bgrid 
c
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 90
C   MACHINE : IBM SP
C
C$$$
c Lmax is the maximum B-grid dimension. Set it to 1600000.

      PARAMETER(Lmax=1600000)
c
      dimension p(Lmax), isnow(Lmax), p1(Lmax), s1(Lmax)
      integer jpds(25), jgds(22), kpds(25), kpds0(25), kgds(22)
      logical*1 bit1(Lmax)
      character fname*256
c
c       p         - daily sum of input precip on the egrid
c       isnow     - daily snow mask
c       bit       - bitmap for 24h sum of EDAS precip.  Set to True.
c       p1        - 1-hourly ndas LSPA
c       s1        - 1-hourly ndas CPOFP
c       bit1      - mask to p1 and s1 (use the same array for both, since
c                   all points would be .true. anyway)
c       kpds      - PDS for each 1-hourly ndas LSPA file; also used for CPOFP
c
      CALL W3TAGB('LSPASNO24H',2001,0151,0060,'NP22   ')
c
      p = 0.
      isnow = 0
      fname(1:5)='fort.'
c
c Each day is covered by 24 NAMRR catchup cycle segments.
      do 50 indas = 1,24 
        write(fname(6:7),'(i2.2)') 10+indas
        call baopenr(10+indas,fname,iret)
        print *,"iret from baopenr= ",iret
c
c First, read in NDAS LSPA:
        jpds = -1
c Set parm number and table number for LSPA:
        jpds(5)=154
        jpds(19)=130
c
        call getgb(10+indas,0,Lmax,0,jpds,jgds,nxny,k,kpds,kgds,
     &    bit1,p1,iret)
c
c The following quickie would not work for year 2000, 2100 etc..  Be sure 
c to fix this before the end of 2099:
        write(6,10) kpds(21)-1,kpds(8),kpds(9),kpds(10),kpds(11),iret
 10     format('Get NDAS precip for ', 5i2.2, ' iret=', i2)
c
        if (iret.ne.0) then
          write(6,*) 'getgb error, indas=',indas,' ihour=', ihour
          stop 1 
        endif
c
        if (indas.eq.1) kpds0 = kpds 
c
        do 20 i = 1, nxny
          p(i) = p(i) + p1(i)
 20     continue
c
c
c Second, read in NDAS CPOFP input:
        jpds = -1
c Set parm number and table number for CPOFP:
        jpds(5)=194
        jpds(19)=2
c
        call getgb(10+indas,0,Lmax,0,jpds,jgds,nxny,k,kpds,kgds,
     &    bit1,s1,iret)
c
c The following quickie would not work for year 2000, 2100 etc..  Be sure 
c to fix this before the end of 2099:
        write(6,30) kpds(21)-1,kpds(8),kpds(9),kpds(10),kpds(11),iret
 30     format('Get NDAS CPOFP for ', 5i2.2, ' iret=', i2)
c
        if (iret.ne.0) then
          write(6,*) 'getgb error, indas=',indas,' ihour=', ihour
          stop 2
        endif
c
        do 40 i = 1, nxny
          if (s1(i) .ge. 90.) isnow(i)=1
 40     continue
c
 50   continue
c
      kpds0(15)=24
c
!rv   call getenv("XLFUNIT_51",value=fname)
!     call getenv("XLFUNIT_51",fname)
      call baopen(51,'fort.51',iret)
      call putgb(51,nxny,kpds0,kgds,bit,p,iret)
c
      if (iret.ne.0) then
        write(6,*) 
     &     'Error outputing daily sum of precip input, iret=', iret,
     &     ', STOP'
        stop 3
      endif
c
      write(52) (isnow(i),i=1,nxny)
      CALL W3TAGE('PCP24HSUM')
      stop
c
      end
