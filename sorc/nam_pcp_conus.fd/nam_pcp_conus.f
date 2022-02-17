      program nam_pcp_conus
!
!$$$  MAIN PROGRAM DOCUMENTATION BLOCK
!
! MAIN PROGRAM: NAM_PCP_CONUS uses River Forecast Center domain mask 
!   to modify a precipitation GRIB file's bitmap so that areas outside of 
!   ConUS are marked as "missing" (bitmap=false).  This is to be used on
!   e.g. Stage IV or CCPA, where large areas outside of ConUS has bitmap=T
!   but actually does not have valid precipitation data (as of Apr 2012, the 
!   RFCs have not activated a data/no data mask on their precipitation 
!   analyses, and simply left bitmap=true for their entire domains).  
! 
!   Programmer: Ying lin           ORG: NP22        Date: 2012-05-02
!
! Input:
!    unit 11  : /nwprod/fix/stage3_mask.grb
!    unit 12  : precipitation analysis
! Output:
!    unit 51  : precipitation analysis (read in from unit 11) with a modified
!               bitmap.
!
! File format:
!   unit 11, 12, 51 are grib files.  
! PROGRAM HISTORY LOG:
!    2012/05/02 Y. Lin
!
! ATTRIBUTES:
!   LANGUAGE: FORTRAN 90
!   MACHINE : IBM SP
!
!$$$
! Lmax is the maximum E-grid dimension. Set it to 1000000.
      PARAMETER(Lmax=2000000)
      dimension panl(Lmax), rfcmask(Lmax)
      logical*1 bitmap(Lmax)
      character fname*80
!
      integer jpds(25), jgds(22), kpds(25), kpds0(25), kgds(22)
!
! Read in the daily and 24h sum of precip files, both in grib:
      jpds=-1
      call baopenr(11,'fort.11',iretba)
      call getgb(11,0,Lmax,0,jpds,jgds,nxny,k,kpds,kgds,     &
            bitmap,rfcmask,iret)
!
      write(6,10) kgds(2),kgds(3),iretba,iret
 10   format('Get Stage 3 mask, nx,ny=', 2i5, ' iretba, iret=',2(i2,x))
!
      call baopenr(12,'fort.12',iretba)
      call getgb(12,0,Lmax,0,jpds,jgds,nxny,k,kpds,kgds,     &
            bitmap,panl,iret)
      write(6,20) kpds(21)-1,kpds(8),kpds(9),kpds(10),kpds(11),  &
            iretba,iret
 20   format('Get precip anl file, ', 5i2.2, ' iretba, iret=',2(i2,x))
!
      do 30 i = 1, nxny
        if (rfcmask(i) .lt. 150) bitmap(i) = .false.
 30   continue
!
      call baopen(51,'fort.51',iretba)
      call putgb(51,nxny,kpds,kgds,bitmap,panl,iret)
      write(6,40) iretba,iret
 40   format('Write precip anl file w/ modified bitmap, iretba, & 
              iret=',2(i2,x))
      stop
      end
        
          
     
