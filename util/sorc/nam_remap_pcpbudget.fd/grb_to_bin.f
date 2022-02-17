      program readgrib
c
c the program reads in a grib file, and print out its pds and gds
c To compile: 
c xlf -o bgrid_to_bin.x bgrid_to_bin.f /nwprod/lib/libbacio_4.a /global/save/wx20gg/bgrids/w3mods/w3/lib/libw3_4.a
c
      parameter(lmax=2800000) !JRC  - increase this size a bit - lotta points in the conus nest
c
      dimension budget(lmax)
      integer jpds(25), jgds(22), kpds(25), kgds(22)
      logical*1 bitmap(lmax)
      character*80 infile
c
c Read in iday1, iday2 from the original budget file
      read(11) iday1, iday2
      call baopenr(12,'fort.12',iret) 
      write(6,*) 'baopenr for unit 12, iret=', iret
      jpds = -1
      call getgb
     &   (12,0,lmax,-1,jpds,jgds,kf,k,kpds,kgds,bitmap,budget,iret)
      write(6,*) 'finished getgb, iret=', iret, ' kf=', kf
c
      write(51) iday1, iday2, (budget(i), i=1,kf)
      stop
      end
