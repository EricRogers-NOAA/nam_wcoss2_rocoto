      program get1236hpcp
c
c Extract hourly precip forecast from the 12-36h 00Z cycle NAM output (with
c 3-h precip bucket).
c
c  Lmax: the maximum E-grid dimension. Set it to 1000000.
c  nxny: actual length of the data array, read in by getgb
c  pcp1hr: array holding the 1-hourly precip file
c  pcpnam2, pcpnam1: NAM precip output for two consecutive hours; 
c     pcp1hr=pcpnam2-pcpnam1 except for hours 13 and 25 (since the precip
c     bucket is emptied every 12 hours)
c  kpds2, kgds2: PDS and GDS for pcpnam2.  After producing the 1-hourly
c     amount, kpds2's time section is tweaked to be used for pcp1hr.
c  idate1, idate2: yyyymmddhh.  idate1 is the starting time of the n-hour
c     accumulation, idate2 is the ending time.  
c  outfname: name of the file containing the 1-hour NAM precip.  
c     format: nampcp.yyyymmddhh, where yyyymmddhh is the ending time of the
c     1-hour forecast.
c
c  Example: yyyymmdd=20070416
c  NAM runcycle: 2007041500
c  Time stamp (reference time) in NAM file: 2007041500 (T0 of forecast)
c  
c  outfile                        Time ranges in first model file: 
c  pfix: nampcp   Value from      range 1      range 2
c   2007041513       f13             12          13
c   2007041514     f14-f13           12          14
c   2007041515     f15-f14           12          15
c   2007041516       f16             15          16
c   2007041517     f17-f16           15          17
c   2007041518     f18-f17           15          18
c   2007041519       f19             18          19
c   2007041520     f20-f19           18          20
c   2007041521     f21-f20           18          21
c   2007041522       f22             21          22
c   2007041523     f23-f22           21          23
c   2007041600     f24-f23           21          24
c   2007041601       f25             24          25
c   2007041602     f26-f25           24          26
c   2007041603     f27-f26           24          27
c   2007041604       f28             27          28
c   2007041605     f29-f28           27          29
c   2007041606     f30-f29           27          30
c   2007041607       f31             30          31
c   2007041608     f32-f31           30          32
c   2007041609     f33-f32           30          33
c   2007041610       f34             33          34
c   2007041611     f35-f34           33          35
c   2007041612     f36-f35           33          36
c
c File name and PDF time elements for output file: 
c   nampcp.yyyymmddhh: yyyymmddhh is the ending time of the 1-hour 
c     accumulation:
c     yyyymmddhh = ref time in pcpnam2 + timerange2 in pcpnam2
c   Reference time: starting time of 1-hour accumulation:
c       time label in file name - 1hr
c
      PARAMETER(Lmax=2800000)
      dimension pcp1hr(Lmax), pcpnam2(Lmax), pcpnam1(Lmax)
      logical*1 bitmap(Lmax)
      character infile*7, outfname*17, cdate1*10
c
      integer jpds(25), jgds(22), 
     &        kpds2(25), kgds2(22), kpds1(25), kgds1(22),
     &        idate1, idate2
c
      infile(1:5)='fort.'
      outfname(1:7)='nampcp.'
c
      jpds=-1
      jpds(5)=61
      write(6,*) 'check 1'
      call baopenr(36,'fort.36',ierrb)
      write(6,*) 'check 2, ierrb=', ierrb
      call getgb(36,0,Lmax,0,jpds,jgds,nxny,k,kpds2,kgds2,
     &  bitmap,pcpnam2,iret)
      write(6,*) 'get pcp for hour 36, ierrb, iret=', ierrb, iret, 
     &  'yyyymmddhh=', kpds2(21), kpds2(8),kpds2(9),kpds2(10),kpds2(11),
     &  ' p1,p2=', kpds2(14),kpds2(15)
c   
      do 100 ihr=36, 13, -1
        if (ihr-1 .gt. 12) then
          write(infile(6:7),'(i2)') ihr-1
          call baopenr(ihr-1,infile, ierrb)
          call getgb(ihr-1,0,Lmax,0,jpds,jgds,nxny,k,kpds1,kgds1,
     &      bitmap,pcpnam1,iret)
          write(6,*) 'get pcp for hour', ihr-1, 
     &      'ierrb, iret=', ierrb, iret,
     &      'yyyymmddhh=', 
     &      kpds1(21),kpds1(8),kpds1(9),kpds1(10),kpds1(11), 
     &      ' p1 p2=', kpds1(14),kpds1(15)
     &      , 'nxny=', nxny
        endif
c
        if (ihr.eq.34 .or. ihr.eq.31 .or. ihr.eq.28 .or. ihr.eq.25 .or.
     &      ihr.eq.22 .or. ihr.eq.19 .or. ihr.eq.16 .or. ihr.eq.13) then
          pcp1hr = pcpnam2
        else
          pcp1hr = pcpnam2-pcpnam1
        endif
c
c  Find the reference time in pcpnam2 (i.e. model run cycle)
        idate0 = (kpds2(21)-1)*100000000 + kpds2(8) *1000000
     &          + kpds2(9) *10000     + kpds2(10)*100+ kpds2(11)
c Note that (kpds(21)-1) would not work on year 2100.  Be sure to fix
c the code by then.  
c
c  Find the ending time of the 1-hour accumulation:
        call movdat(idate0, idate2, ihr)
c  Find the beginning time of the 1-hour accumulation:
        call movdat(idate2, idate1, -1)
        write(6,*) 'ihr, idate1, idate2=', ihr, idate1, idate2
c
        write(outfname(8:17),'(i10)') idate2
c  
c  Reference time for the 1-hr accumulation:
        write(cdate1,'(i10)') idate1
        read(cdate1,'(5i2)') 
     &     kpds2(21),kpds2(8),kpds2(9),kpds2(10),kpds2(11)
        kpds2(21)=kpds2(21)+1
c  Redefine time ranges:
c
        kpds2(14)=0 ! Time range 1
        kpds2(15)=1 ! Time range 2
        kpds2(16)=4 ! Time range indicator: 4=accumulation
c
c  Decimal scale factor: set to 1, otherwise the numbers are in integer
        kpds2(22)=1
c
        call baopen(51,outfname,ierrb)
        write(6,*) 'check 3, nxny, outfname, ierrb=', nxny,
     &     outfname, ierrb
        call putgb(51,nxny,kpds2,kgds2,bitmap,pcp1hr,iret)
        write(6,*) 'BAOPEN and PUTGB for ', idate2, ' iretb, iret=', 
     &    iretb, iret
        call baclose(51,iret)
c        
        pcpnam2=pcpnam1
        kpds2=kpds1
        kgds2=kgds1
 100  continue
      stop
      end
