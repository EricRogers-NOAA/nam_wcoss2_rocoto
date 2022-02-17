      program pcpbudget
C
C$$$  MAIN PROGRAM DOCUMENTATION BLOCK
C
c MAIN PROGRAM: PCPBUDGET computes the difference between 
c   1) 24h sum (12Z-12Z) of edas precip input
c   2) Analysis of daily gauge data, copygb'd from 1/8 deg 
c      grid to e-grid (the factor of 110% is to account for the under-catch,
c      i.e. 'wind-blown slanted rain', problem, in daily gauges)
c in areas that didn't see snow.  Output the day's difference.  Add they
c difference to long-term history file (if available).
c
C   Programmer: Ying lin           ORG: NP22        Date: 2003-04-03
C
c Input:
c    unit 5   : $day, history (whether there exists an old budget 
c               history file - unit 14)
c    unit 11  : rfc8.$day.g96
c    unit 12  : edaspcp.${day}12.24h
c    unit 13  : snowmask.$day (integer array, non-grib. 0 - snow; 1 - no snow)
c    unit 14  : pcpbudget_history.old (budget history from the day before),
c               if unit 5 indicates that there is an existing budget history
c               file
c Output:
c    unit 51  : pcpbudget.$day
c    unit 52  : pcpbudget_history
c    unit 53  : average budget imbalance (pcpbudget_history averaged over
c               valid points)
c
c File format:
c   unit 11, 12 are grib files.  
c   pcpbudget.$day is binary; $day followed by the day's budget array.
c   pcpbudget_history[.old] is binary: $day0, $day[m1] followed by
c     the cumulative history.
c     
c PROGRAM HISTORY LOG:
c    2004/04/03 Y. Lin
c    2005/10/08 Lin: eliminated the 110% inflation factor on pcp analysis
c    2005/10/11 Lin: changed array dimension to Lmax of 1000000.  Output 
c                    budget file length is the same as input pcp anl and
c                    24h LSPA length (nxny)
c    2006/03/09 Lin: added back an inflation factor of 104% (for test in NAMY)
c    2006/04/17 Lin: changed inflation factor back to 110%
c    2016/03/11 Lin: eliminated the inflation factor.  
c
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 90
C   MACHINE : IBM SP
C
C$$$
c Lmax is the maximum E-grid dimension. Set it to 1000000.
      PARAMETER(Lmax=1600000)
      dimension prfc(Lmax), p24hsum(Lmax), isnow(Lmax), 
     &    budget(Lmax), budgetsum(Lmax)
      logical*1 history, bitrfc(Lmax),bit24hsum(Lmax)
      character fname*80
c
c day: current day, read in through unit 5
c day1 and day2: beginning and ending date in the budget history file.
c Normally 'day2' would be $daym1 in budget_history.old and 
c $day in budget_history.
      integer iday, iday1, iday2
c
      integer jpds(25), jgds(22), kpds(25), kpds0(25), kgds(22)
c
      CALL W3TAGB('PCPBUDGET',2001,0151,0060,'NP22   ')
c
      read(55,'(i8)') iday
      read(55,'(a7)') fname
c
      if (fname(1:7).eq.'history' .or. fname(1:7).eq.'HISTORY') then
        history=.true.
      else
        history=.false.
      endif
c
c Read in the daily and 24h sum of precip files, both in grib:
      jpds=-1
c     call getenv("XLFUNIT_11",fname)
      call baopenr(11,'fort.11',iret)
      call getgb(11,0,Lmax,0,jpds,jgds,nxny,k,kpds,kgds,
     &      bitrfc,prfc,iret)
c
      write(6,10) kpds(21)-1,kpds(8),kpds(9),kpds(10),kpds(11),iret
 10   format('Get prfc for 24h starting ', 5i2.2, ' iret=', i2)
c
c     call getenv("XLFUNIT_12",fname)
      call baopenr(12,'fort.12',iret)
      call getgb(12,0,Lmax,0,jpds,jgds,nxny,k,kpds,kgds,
     &      bit24hsum,p24hsum,iret)
      write(6,20) kpds(21)-1,kpds(8),kpds(9),kpds(10),kpds(11),iret
 20   format('Get edaspcp for 24h starting ', 5i2.2, ' iret=', i2)
c
      read(13) (isnow(i),i=1,nxny)
      if (history) then
        read(14) iday1, iday2, (budgetsum(i),i=1,nxny)
        write(6,*) 'read in budget history spanning', iday1, iday2
      else
        budgetsum=0.
        iday1=iday
        write(6,*) 'old budget history not available.'
      endif
c
c Compute today's budget:
      budget = 0.
      do 30 i = 1, nxny
        if (isnow(i).eq.0 .and. bitrfc(i)) 
     &    budget(i)=p24hsum(i)-prfc(i)
 30   continue
c
      budgetsum=budgetsum+budget
      iday2=iday
c
c Compute the average cumulative budget imbalance (averaged over all points
c where bitrfc is true, i.e. roughly the ConUS.
c
      avgbudsum=0.
      nconuspts=0
      do 40 i = 1, nxny
        if (bitrfc(i)) then
          nconuspts = nconuspts + 1
          avgbudsum = avgbudsum + budgetsum(i)
        endif
 40   continue
      if (nconuspts .gt. 0) then
        avgbudsum = avgbudsum/float(nconuspts)
      else
        avgbudsum = -9999.
      endif
c
      write(51) iday, (budget(i),i=1,nxny)
      write(52) iday1, iday2, (budgetsum(i),i=1,nxny)
      write(53,50) iday1, iday2, nconuspts, avgbudsum
 50   format(i10,3x,i10,5x,i8,5x,f10.3)
c
      CALL W3TAGE('PCPBUDGET')
c
      stop
      end
        
          
     
