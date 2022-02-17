      program bgrd2grb
c Convert precip budget file from B-grid (bin) to GRIB.
c JRC- converted to read b-grid and output b-grid grib

      parameter(im=954,jm=835)
      real budget(im,jm)
      logical*1 bitmap(im,jm)
      integer kpds(25), kgds(22)
c
      read(11) iday1, iday2, ((budget(i,j),i=1,im),j=1,jm)
      bitmap=.true.
    ! print*, iday1,iday2,maxval(budget),minval(budget)



c Set the date to 12Z 8 Sep 1752.      KPDS values were taken from the original code
      kpds( 1) =        7
      kpds( 2) =       89
      kpds( 3) =      255
      kpds( 4) =      128
c      kpds( 5) =      255  ! parameter number
      kpds( 5) =       61  ! parameter number
      kpds( 6) =        1
      kpds( 7) =        0
      kpds( 8) =       52  ! yy 
      kpds( 9) =        9  ! mm
      kpds(10) =        8  ! dd
      kpds(11) =       12
      kpds(12) =        0
      kpds(13) =        1
      kpds(14) =        0  ! Time range 1
      kpds(15) =       24  ! Time range 2
      kpds(16) =        4  ! Time range flag 
      kpds(17) =        0
      kpds(18) =        1
      kpds(19) =        2
      kpds(20) =        0
      kpds(21) =       18  ! 18th century
      kpds(22) =        0
      kpds(23) =        0
      kpds(24) =        0
      kpds(25) =       32
c
!

   !JRC - the numbers below were obtained from /scratch2/portfolios/NCEPDEV/meso/noscrub/Jacob.Carley/com/nam/para/ndas.20120924/ndas.t00z.bgrdsf03.tm03

      kgds( 1) =      205   !-JRC - I think this is map type and we want B-grid staggering
      kgds( 2) =      954
      kgds( 3) =      835
      kgds( 4) =    -7491
      kgds( 5) =  -144134
      kgds( 6) =      136
      kgds( 7) =    54000
      kgds( 8) =  -106000
      kgds( 9) =      126
      kgds(10) =      108
      kgds(11) =       64
      kgds(12) =    44540
      kgds(13) =    14802
      kgds(14) =        0
      kgds(15) =        0
      kgds(16) =        0
      kgds(17) =        0
      kgds(18) =        0
      kgds(19) =        0
      kgds(20) =      255
      kgds(21) =        0
      kgds(22) =        0
c
  

      call baopenw(51,'fort.51',iret) 
      write(6,*) 'baopenw on unit 51, iret=', iret
      call putgb(51,im*jm,kpds,kgds,bitmap,budget,iret)
      write(6,*) 'finished putgb for parent budget, iret=', iret
c
      stop
      end


