       PROGRAM MAKEPRECIP

        USE GRIB_MOD

!                .      .    .                                       .
! SUBPROGRAM:   MAKEPRECIP 
!   PRGMMR: MANIKIN        ORG: W/NP22     DATE:  07-03-07

! ABSTRACT: PRODUCES 3,6 or 12-HOUR TOTAL AND CONVECTIVE PRECIPITATION BUCKETS
!              AS WELL AS SNOWFALL ON THE ETA NATIVE GRID FOR SMARTINIT 

! PROGRAM HISTORY LOG:
!   07-03-07  GEOFF MANIKIN 
!   10-25-12  JEFF MCQUEEN
!   15-03-16  E. Rogers uses this code for NAM makeprecip for GRIB2 input
!   19-03-07  E. Rogers revised for running on Dell, remove LSM fields 
!             since NAM grid that needed this was turned off in 2017.
! REMARKS:
!   10-25-12 JTM UNIFIED make and add precip for different accum hours
!                addprecip6, addprecip12 and makeprecip all combined in
!                smartprecip
!                To call, must set all 4 fhrs
!                for 3 or 6 hour buckets, set fhr3,fh4 to -99
!                For 12 hour buckets:
!                    smartprecip  fhr fhr-3 fhr-6 fhr-9
!  02-20-14 JTM Added DGEX option addsub to compute 6 hr precip
!               from 3 dgex files
!               fhr1 (fhr) 3 hr precip
!               fhr2 (fh3 old) 6 hr precip
!               fhr3 (fh6 old) 3 hr precip
!                 then mk6p=fhr+(fhr3-fhr6) for DGEX
!               Added DGEX 12 hr precip option
!               fhr1=fhr6 6hr precip
!               fhr2=fhr  6hr precip
!                 12hrp=fhr6 + fhr

! ATTRIBUTES:
!   LANGUAGE: FORTRAN-90
!   MACHINE:  WCOSS
!======================================================================
      INTEGER JPDS(200),JGDS(200),KPDS(200),KGDS(200)
      INTEGER FHR0,FHR1, FHR2, FHR3, FHR4, IARW, ISNOW, ILSM
      CHARACTER*80 FNAME
      LOGICAL*1 LSUB

!C grib2
      INTEGER :: LUGB,LUGI,J,JDISC,JPDTN,JGDTN
      integer,dimension(200) :: jids,jpdt,jgdt
      integer, allocatable :: pds_rain_hold_early(:), pds_rain_hold(:)
      integer, allocatable :: drt_rain_hold_early(:), drt_rain_hold(:)
      integer, allocatable :: gds_rain_hold_early(:), gds_rain_hold(:)
      integer, allocatable :: pds_snow_hold_early(:), pds_snow_hold(:)
      integer, allocatable :: drt_snow_hold_early(:), drt_snow_hold(:)
      integer, allocatable :: gds_snow_hold_early(:), gds_snow_hold(:)
      integer, allocatable :: pds_crain_hold_early(:), pds_crain_hold(:)
      integer, allocatable :: drt_crain_hold_early(:), drt_crain_hold(:)
      integer, allocatable :: gds_crain_hold_early(:), gds_crain_hold(:)
      LOGICAL :: UNPACK
      INTEGER :: K,IRET,SUBINTVL,SUBSTART,nbit
      TYPE(GRIBFIELD) :: GFLD
!C grib2

      REAL,     ALLOCATABLE :: GRID(:)
      REAL,     ALLOCATABLE :: APCP1(:),APCP2(:),APCP3(:),APCP4(:)
      REAL,     ALLOCATABLE :: CAPCP1(:),CAPCP2(:),CAPCP3(:),CAPCP4(:)
      REAL,     ALLOCATABLE :: SNOW1(:),SNOW2(:),SNOW3(:),SNOW4(:)
      REAL,     ALLOCATABLE :: APCPOUT(:),CAPCPOUT(:),SNOWOUT(:)
      LOGICAL,  ALLOCATABLE :: MASK(:)

! Added for getbit
      real,     allocatable :: grnd(:)
      real :: gmin, gmax
!--------------------------------------------------------------------------

      FNAME='fort.  '
!====================================================================
!     FHR3 = -99 signals a 6 hour summation requested
!     FHR4 GE 00 signals a 12 hour summation requested
!     FHR1 GT FHR2 signals do a 3 hour subtraction of files
!     ISNOW = 1 do accumulated snow
      READ (5,*) FHR1, FHR2,FHR3,FHR4,IARW,ISNOW
!====================================================================

!==>  Make 3 hour buckets by subtracting fhr3 - fhr files
      LSUB=.FALSE.

        writE(0,*) 'enter FHR1, FHR2, FHR3, FHR4: ', &
                          FHR1, FHR2, FHR3, FHR4

      IF (FHR1.GT.FHR2) THEN
        write(0,*) 'subtracting'
        SUBINTVL=FHR1-FHR2
        SUBSTART=FHR2
       FHR0=FHR2
       FHR2=FHR1
       FHR1=FHR0
       LSUB=.TRUE.
        write(0,*) 'reset so FHR0, FHR1, FHR2 are: ', FHR0, FHR1, FHR2
       IF (MOD(FHR2,12).EQ. 0.) THEN
         FHR3=FHR2-12
        write(0,*) 'FHR3 defined(a): ', FHR3
        ELSE
         FHR3=FHR2-MOD(FHR2,12)
        write(0,*) 'FHR3 defined(b): ', FHR3
       ENDIF
      ELSE

        write(0,*) 'summing'

!==>  sum up precip files
        if (fhr3 .lt. 0) FHR3=FHR1-3

!==>    make 12 hr precip for NMMB
        if (fhr4 .ge. 0) then 
                FHR0=FHR1-3
        write(0,*) 'making 12 h precip'
        endif
       write(0,*) 'summing fhr0,fhr1 fhr2 fhr3 fhr4 ',FHR0, FHR1, FHR2, FHR3,FHR4
      ENDIF

        write(0,*) 'here with LSUB: ', LSUB

!       write(0,*) 'summing fhr0,fhr1 fhr2 fhr3 fhr4 ',FHR0, FHR1, FHR2, FHR3,FHR4

      LUGB=13;LUGI=14; LUGB2=15;LUGI2=16
      LUGB3=17;LUGI3=18;LUGB4=19;LUGI4=20
! LUGB5=accum precip
! LUGB6=accum conv precip
! LUGB7=accum snow
      LUGB5=50; LUGB6=51; LUGB7=52

      ISTAT = 0

! -== GET SURFACE FIELDS ==-

      allocate(gfld%ipdtmpl(29))
      allocate(gfld%igdtmpl(21))
      allocate (pds_rain_hold(29),pds_rain_hold_early(29))
      allocate (drt_rain_hold(5),drt_rain_hold_early(5))
      allocate (gds_rain_hold(21),gds_rain_hold_early(21))
      allocate (pds_crain_hold(29),pds_crain_hold_early(29))
      allocate (drt_crain_hold(5),drt_crain_hold_early(5))
      allocate (gds_crain_hold(21),gds_crain_hold_early(21))
      allocate (pds_snow_hold(29),pds_snow_hold_early(29))
      allocate (drt_snow_hold(5),drt_snow_hold_early(5))
      allocate (gds_snow_hold(21),gds_snow_hold_early(21))

        JIDS=-9999
        JPDTN=-1
        JPDT=-9999
        JGDTN=-1
        JGDT=-9999
        UNPACK=.false.

        WRITE(FNAME(6:7),FMT='(I2)')LUGB
        CALL BAOPENR(LUGB,FNAME,IRETGB)

        WRITE(FNAME(6:7),FMT='(I2)')LUGB2
        CALL BAOPENR(LUGB2,FNAME,IRETGB)

        write(0,*) 'trim(fname): ', trim(fname)

        write(0,*) 'IRETGB on BAOPEN: ', IRETGB

        call getgb2(LUGB2,LUGI2,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET)

        write(0,*) 'IRET from init getgb2 call: ', IRET

        NUMVAL=gfld%ngrdpts

        write(0,*) 'NUMVAL ', NUMVAL

        if (IRET .ne. 0) STOP

        UNPACK=.true.
        
      ALLOCATE (MASK(NUMVAL),GRID(NUMVAL),STAT=kret)
      ALLOCATE (APCP1(NUMVAL),CAPCP1(NUMVAL),SNOW1(NUMVAL),STAT=kret)
      IF(kret.ne.0)THEN
       WRITE(*,*)'ERROR allocation source location: ',numval
       STOP
      END IF

!   PRECIP 

        write(0,*) 'have NUMVAL : ', NUMVAL

        write(0,*) 'allocate again?'
        allocate(gfld%fld(NUMVAL))
        allocate(gfld%bmap(NUMVAL))

        JIDS=-9999
        JPDTN=8
        JPDT=-9999
        JPDT(2)=8
        JGDTN=-1
        JGDT=-9999
        UNPACK=.true.

        call getgb2(LUGB,LUGI,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET_EARLY)

        write(0,*) 'IRET from GETGB2: ', IRET_EARLY

        if (IRET_EARLY .ne. 0) THEN
        
        write(0,*) 'set APCP1 to zero'
        APCP1=0.

        else
        
        write(0,*) 'size(APCP1): ', size(APCP1)
        write(0,*) 'size(gfld%fld): ', size(gfld%fld)

        APCP1=gfld%fld

        do K=1,29
          PDS_RAIN_HOLD_EARLY(K)=gfld%ipdtmpl(K)
        enddo
        do k=1,5
          drt_rain_hold_early(k)=gfld%idrtmpl(k)
        enddo
        do k=1,21
          gds_rain_hold_early(k)=gfld%igdtmpl(k)
        enddo

        endif

!  CONVECTIVE PRECIP
       J = 0;JPDS = -1;JPDS(3) = IGDNUM
       JPDS(5) = 063;JPDS(6) = 001
!      JPDS(13) = 1

        if (IARW .eq. 0) then

      JPDS(14) = FHR3
      JPDS(15) = FHR1
        write(0,*) 'FHR0: ', FHR0
      if (fhr4.gt.0) JPDS(14)=FHR0
        write(0,*) 'JPDS(14) for cpcp now: ', JPDS(14)

        endif

        JIDS=-9999
        JPDTN=8
        JPDT=-9999
        JPDT(2)=10
        JGDTN=-1
        JGDT=-9999
        UNPACK=.true.

        call getgb2(LUGB,0,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET)

        if (IRET .ne. 0) THEN

        write(0,*) 'set CAPCP1 to zero'
        CAPCP1=0.

        else

        CAPCP1=gfld%fld

        do K=1,29
          PDS_CRAIN_HOLD_EARLY(K)=gfld%ipdtmpl(K)
        enddo
        do k=1,5
          drt_crain_hold_early(k)=gfld%idrtmpl(k)
        enddo
        do k=1,21
          gds_crain_hold_early(k)=gfld%igdtmpl(k)
        enddo

        endif

      if (ISNOW .eq. 1) THEN
 
!  SNOWFALL 
      J = 0;JPDS = -1;JPDS(3) = IGDNUM
      JPDS(5) = 065;JPDS(6) = 001

        if (IARW .eq. 0) then

      JPDS(14) = FHR3
      JPDS(15) = FHR1
        write(0,*) 'FHR0: ', FHR0
      if (fhr4.gt.0) JPDS(14)=FHR0
        write(0,*) 'JPDS(14) for snow now: ', JPDS(14)

        endif

        JIDS=-9999
        JPDTN=8
        JPDT=-9999
        JPDT(2)=13
        JGDTN=-1
        JGDT=-9999
        UNPACK=.true.

        call getgb2(LUGB,0,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET)

        if (IRET .ne. 0) THEN
        
        write(0,*) 'set SNOW1 to zero'
        SNOW1=0.

        else

        SNOW1=gfld%fld

        do K=1,29
          PDS_SNOW_HOLD_EARLY(K)=gfld%ipdtmpl(K)
        enddo
        do k=1,5
          drt_snow_hold_early(k)=gfld%idrtmpl(k)
        enddo
        do k=1,21
          gds_snow_hold_early(k)=gfld%igdtmpl(k)
        enddo

        endif

!end ISNOW check
        ENDIF

!=======================================================
!  READ 2nd file
!=======================================================

      ALLOCATE (APCP2(NUMVAL),CAPCP2(NUMVAL),SNOW2(NUMVAL),STAT=kret)
      IF(kret.ne.0)THEN
       WRITE(*,*)'ERROR allocation source location: ',numval
       STOP
      END IF

!     ACCUMULATED PRECIP 

        JIDS=-9999
        JPDTN=8
        JPDT=-9999
        JPDT(2)=8
        JGDTN=-1
        JGDT=-9999

        call getgb2(LUGB2,0,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET)
        APCP2=gfld%fld

        do K=1,29
        PDS_RAIN_HOLD(K)=gfld%ipdtmpl(K)
        enddo

!     ACCUMULATED CONVECTIVE PRECIP
       J = 0;JPDS = -1;JPDS(3) = IGDNUM
       JPDS(5) = 063;JPDS(6) = 001
!      JPDS(13) = 1

        if (IARW .eq. 0) then
      JPDS(14) = FHR1
      JPDS(15) = FHR2
      IF (LSUB) JPDS(14)=FHR3
        endif

        JIDS=-9999
        JPDTN=8
        JPDT=-9999
        JPDT(2)=10
        JGDTN=-1
        JGDT=-9999

        call getgb2(LUGB2,0,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET)

        CAPCP2=gfld%fld

        do K=1,29
        PDS_CRAIN_HOLD(K)=gfld%ipdtmpl(K)
        enddo
!
      IF(ISNOW .eq. 1) then

!     SNOWFALL
      J = 0;JPDS = -1;JPDS(3) = IGDNUM
      JPDS(5) = 065;JPDS(6) = 001
        if (IARW .eq. 0) then
      JPDS(14) = FHR1
      JPDS(15) = FHR2
      IF (LSUB) JPDS(14)=FHR3
        endif

        JIDS=-9999
        JPDTN=8
        JPDT=-9999
        JPDT(2)=13
        JGDTN=-1
        JGDT=-9999

        call getgb2(LUGB2,0,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET)

        SNOW2=gfld%fld

        do K=1,29
        PDS_SNOW_HOLD(K)=gfld%ipdtmpl(K)
        enddo

! end ISNOW check
        endif

      IF (FHR4.GT.0 ) THEN

!=======================================================
!  READ 3rd file
!=======================================================
!      CALL RDHDRS(LUGB3,LUGI3,JPDS,JGDS,              &
!                  IGDNUM,IMAX,JMAX,KMAX,NUMVAL)

        WRITE(FNAME(6:7),FMT='(I2)')LUGB3
        CALL BAOPENR(LUGB3,FNAME,IRETGB)

      ALLOCATE (APCP3(NUMVAL),CAPCP3(NUMVAL),SNOW3(NUMVAL),STAT=kret)
      IF(kret.ne.0)THEN
       WRITE(*,*)'ERROR allocation source location: ',numval
       STOP
      END IF

!     ACCUMULATED PRECIP 

        JIDS=-9999
        JPDTN=8
        JPDT=-9999
        JPDT(2)=8
        JGDTN=-1
        JGDT=-9999

        call getgb2(LUGB3,0,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET)
        APCP3=gfld%fld

        do K=1,29
        PDS_RAIN_HOLD(K)=gfld%ipdtmpl(K)
        enddo

!     ACCUMULATED CONVECTIVE PRECIP
       J = 0;JPDS = -1;JPDS(3) = IGDNUM
       JPDS(5) = 063;JPDS(6) = 001
!      JPDS(13) = 1

        if (IARW .eq. 0) then
        JPDS(14) = FHR2
        JPDS(15) = FHR3
        endif

        JIDS=-9999
        JPDTN=8
        JPDT=-9999
        JPDT(2)=10
        JGDTN=-1
        JGDT=-9999

        call getgb2(LUGB3,0,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET)
        CAPCP3=gfld%fld

        do K=1,29
        PDS_CRAIN_HOLD(K)=gfld%ipdtmpl(K)
        enddo

      IF(ISNOW .eq. 1) then

!     SNOWFALL
      J = 0 ;JPDS = -1;JPDS(3) = IGDNUM
      JPDS(5) = 065;JPDS(6) = 001
        if (IARW .eq. 0) then
        JPDS(14) = FHR2
        JPDS(15) = FHR3
        endif

        JIDS=-9999
        JPDTN=8
        JPDT=-9999
        JPDT(2)=13
        JGDTN=-1
        JGDT=-9999

        call getgb2(LUGB3,0,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET)
        SNOW3=gfld%fld

        do K=1,29
        PDS_SNOW_HOLD(K)=gfld%ipdtmpl(K)
        enddo

!end ISNOW check
        endif

!=======================================================
!  READ 4th file
!=======================================================

        WRITE(FNAME(6:7),FMT='(I2)')LUGB4
        CALL BAOPENR(LUGB4,FNAME,IRETGB)

      ALLOCATE (APCP4(NUMVAL),CAPCP4(NUMVAL),SNOW4(NUMVAL),STAT=kret)
      IF(kret.ne.0)THEN
       WRITE(*,*)'ERROR allocation source location: ',numval
       STOP
      END IF
!     ACCUMULATED PRECIP 
      J = 0;JPDS = -1;JPDS(3) = IGDNUM
      JPDS(5) = 061;JPDS(6) = 001
      JPDS(13) = 1

        JIDS=-9999
        JPDTN=8
        JPDT=-9999
        JPDT(2)=8
        JGDTN=-1
        JGDT=-9999

        call getgb2(LUGB4,0,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET)
        APCP4=gfld%fld

        do K=1,29
        PDS_RAIN_HOLD(K)=gfld%ipdtmpl(K)
        enddo


!     ACCUMULATED CONVECTIVE PRECIP
       J = 0;JPDS = -1;JPDS(3) = IGDNUM
       JPDS(5) = 063;JPDS(6) = 001
!      JPDS(13) = 1
        if (IARW .eq. 0) then
        JPDS(14) = FHR2
        JPDS(15) = FHR3
        endif

      if(ISNOW .eq. 1) then     

!     SNOWFALL
      J = 0 ;JPDS = -1;JPDS(3) = IGDNUM
      JPDS(5) = 065;JPDS(6) = 001
        if (IARW .eq. 0) then
        JPDS(14) = FHR2
        JPDS(15) = FHR3
        endif
  
      endif

!     ACCUMULATED CONVECTIVE PRECIP
       J = 0;JPDS = -1;JPDS(3) = IGDNUM
       JPDS(5) = 063;JPDS(6) = 001
!      JPDS(13) = 1

        if (IARW .eq. 0) then
        JPDS(14) = FHR3
        JPDS(15) = FHR4
        endif


        JIDS=-9999
        JPDTN=8
        JPDT=-9999
        JPDT(2)=10
        JGDTN=-1
        JGDT=-9999

        call getgb2(LUGB4,0,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET)
        CAPCP4=gfld%fld

        do K=1,29
        PDS_CRAIN_HOLD(K)=gfld%ipdtmpl(K)
        enddo
!
      if(ISNOW .eq. 1) then

!     SNOWFALL
      J = 0 ;JPDS = -1;JPDS(3) = IGDNUM
      JPDS(5) = 065;JPDS(6) = 001
        if (IARW .eq. 0) then
        JPDS(14) = FHR3
        JPDS(15) = FHR4
        endif


        JIDS=-9999
        JPDTN=8
        JPDT=-9999
        JPDT(2)=13
        JGDTN=-1
        JGDT=-9999

        call getgb2(LUGB4,0,0,0,JIDS,JPDTN,JPDT,JGDTN,JGDT, &
                    UNPACK,K,GFLD,IRET)
        SNOW4=gfld%fld

        do K=1,29
        PDS_SNOW_HOLD(K)=gfld%ipdtmpl(K)
        enddo

!end ISNOW check
        endif

      ENDIF 

!=======================================================
!      OUTPUT 3, 6 or 12 hr PRECIP BUCKETS
!=======================================================
      ALLOCATE (APCPOUT(NUMVAL),CAPCPOUT(NUMVAL),SNOWOUT(NUMVAL),STAT=kret)
      allocate (grnd(numval))
      IF(kret.ne.0)THEN
       WRITE(*,*)'ERROR allocation source location: ',numval
       STOP
      END IF
   
!! LSUB --> 3 h total
!! FHR4 > 0 --> 12 h total
!! nothing --> 6 h total

      IF (LSUB) THEN
       APCPOUT=APCP2-APCP1
       CAPCPOUT=CAPCP2-CAPCP1
       if(isnow.eq.1) then
         SNOWOUT=SNOW2-SNOW1
       endif
      ELSE
       APCPOUT=APCP2+APCP1
       CAPCPOUT=CAPCP2+CAPCP1
       if(isnow.eq.1) then
         SNOWOUT=SNOW2+SNOW1
       endif
 
       IF (FHR4 .GT.0 )THEN
          APCPOUT=APCPOUT+APCP3+APCP4
          CAPCPOUT=CAPCPOUT+CAPCP3+CAPCP4
          if(isnow.eq.1) then
             SNOWOUT=SNOWOUT+SNOW3+SNOW4
          endif
       ENDIF
      ENDIF

! convert these to GRIB2 equivs

!      KPDS(14)=FHR3
!      KPDS(15)=FHR2
        
        if (IRET_EARLY .ne. 0) then
          gfld%ipdtmpl=PDS_RAIN_HOLD
        else
          gfld%ipdtmpl=PDS_RAIN_HOLD_EARLY
        endif

! need to initialize grid specs
        gfld%idrtmpl=drt_rain_hold_early
        gfld%igdtmpl=gds_rain_hold_early

!       gfld%ipdtmpl(9)=ihrs1
        gfld%ipdtmpl(9)=0

        do J=16,21
        gfld%ipdtmpl(J)=PDS_RAIN_HOLD(J)
        enddo

        gfld%ipdtmpl(22)=1

! default as a 6 h accumulation?
        write(0,*) 'here FHR3, FHR2: ', FHR3, FHR2

!        if (LSUB) then

!       gfld%ipdtmpl(27)=SUBINTVL
!       gfld%ipdtmpl(9)=SUBSTART
        gfld%ipdtmpl(27)= FHR2-FHR1 ! 3 hr accum
        gfld%ipdtmpl(9)=FHR1

!! use of (27) here looks wrong!

!        write(0,*) 'gfld%ipdtmpl(27) bef: ', &
!                    gfld%ipdtmpl(27)
!        write(0,*) 'gfld%ipdtmpl(9) bef: ', &
!                    gfld%ipdtmpl(9)

!        gfld%ipdtmpl(27)=3
!        gfld%ipdtmpl(9)=FHR1

       write(0,*) 'gfld%ipdtmpl(27) aft: ', &
                   gfld%ipdtmpl(27)
       write(0,*) 'gfld%ipdtmpl(9) aft: ', &
                   gfld%ipdtmpl(9)

!        endif

        if (FHR4 .GT.0) then
        gfld%ipdtmpl(27)=12
        gfld%ipdtmpl(9)=FHR0
        endif

        if (FHR4 .LT. 0 .and. .not.(LSUB)) then
        gfld%ipdtmpl(27)=6
        gfld%ipdtmpl(9)=FHR3
        endif
        
        gfld%fld=APCPOUT

      IF (LSUB) KPDS(14)=FHR1
      IF (FHR4.GT.0)THEN
        KPDS(14)=FHR0
        KPDS(15)=FHR4
      ENDIF

      gfld%discipline=0

!  compute nbits

! force binary scaling of adequate precision
      gfld%idrtmpl(2)=-4

      call getbit(0,abs(gfld%idrtmpl(2)), &
        gfld%idrtmpl(3),numval,0,apcpout, &
        grnd,gmin,gmax,nbit)

      gfld%idrtmpl(4)=nbit

! end nbits mod

      gfld%discipline=0

      KPDS(5)=61
      write(0,*)'writing precip', KPDS(5),KPDS(14),KPDS(15),LUGB5,MAXVAL(APCPOUT)
      WRITE(FNAME(6:7),FMT='(I2)')LUGB5
      print*,'fname,lugb5=',fname,lugb5
      CALL BAOPEN(LUGB5,FNAME,IRETGB)
      print*,'opened file'
      gfld%ipdtmpl(2)=8
      gfld%fld=APCPOUT
      print*,'calling putgb2'
      call putgb2(LUGB5,GFLD,IRET)
      print*,'calling baclose'
      CALL BACLOSE(LUGB5,IRET)

! force binary scaling of adequate precision
      gfld%idrtmpl(2)=-4

      call getbit(0,abs(gfld%idrtmpl(2)), &
        gfld%idrtmpl(3),numval,0,capcpout, &
        grnd,gmin,gmax,nbit)

      gfld%idrtmpl(4)=nbit

! end nbits mod

      gfld%discipline=0
      gfld%ipdtmpl(2)=10
      gfld%fld=CAPCPOUT

      KPDS(5)=63
      write(0,*)'writing CAPCP', KPDS(5),KPDS(14),KPDS(15),LUGB6 , MAXVAL(CAPCPOUT)
      WRITE(FNAME(6:7),FMT='(I2)')LUGB6
      CALL BAOPEN(LUGB6,FNAME,IRETGB)
      call putgb2(LUGB6,GFLD,IRET)
      CALL BACLOSE(LUGB6,IRET)

      if(ISNOW.eq.1) then

! force binary scaling of adequate precision
      gfld%idrtmpl(2)=-4

      call getbit(0,abs(gfld%idrtmpl(2)), &
        gfld%idrtmpl(3),numval,0,snowout, &
        grnd,gmin,gmax,nbit)

      gfld%idrtmpl(4)=nbit

! end nbits mod

      gfld%discipline=0
      gfld%ipdtmpl(2)=13
      gfld%fld=SNOWOUT

      KPDS(5)=65
      write(0,*)'writing SNOW', KPDS(5),KPDS(14),KPDS(15),LUGB7, MAXVAL(SNOWOUT)
      WRITE(FNAME(6:7),FMT='(I2)')LUGB7
      CALL BAOPEN(LUGB7,FNAME,IRETGB)
      call putgb2(LUGB7,GFLD,IRET)
      CALL BACLOSE(LUGB7,IRET)

!end ISNOW check
      endif

      STOP
      END
