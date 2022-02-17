PROGRAM Prep_Hourly_Precip_Input
!
! PURPOSE: Perform long-term budget adjustment on merged Stage 2/4 hourly 
!   analysis; fill in missing area with NAM hourly forecast.
!  
! SUMMARY: 
!   1. Use a "water budget history" (cumulative differences between 
!      hourly precip input and verifying daily gauge analysis) file 
!      to adjust the analysis.
!   2. Use NAM hourly precipitation forecasts (from the 00Z cycle's 
!      12-36h forecast) to fill in missing data
!   3. Output the adjusted precipitation analyses in GRIB.  Also write it out
!      in simple binary (2005: difficult to get WRF to read GRIB).
! 
! INPUT FILES:
!   Unit 11 Merged Stage 2/4 analysis on B-grid
!   Unit 12 NAM hourly forecast
!   Unit 13 Long-term budget history array
! 
! OUTPUT FILES:
!   Unit 51 Adjusted, filled (O'ConUS and other no-obs area) hourly precip, 
!             ready to be used by NDAS
!   Unit 52 Grib'd version of Unit 51 file
!
! RECORD OF REVISIONS
!    Date     Programmer  Description of Change
! ==========  ==========  =====================================================
! 2001-06-11  Ying Lin    Original implementation using Stage 2 analysis.  
!                         Mapping to model grid is done using ipolate within
!                         this program.
!
! 2002-11-15    Y. Lin    Modifed to use both Stage II and IV
! 2002-12-23    Y. Lin    Use RFC domain mask to exclude NWRFC data in Stage 4
!                         domain, because the regional hourly analysis from 
!                         NWRFC has been problematic.
!
! 2003-04-15    Y. Lin    Use RFC domain mask to exclude CNRFC data in Stage 4 
!                         domain. CNRFC seldom sends hourly data, so the part 
!                         of the CNRFC grid that overlaps with the NWRFC grid 
!                         usually carries the (often) faulty NWRFC value.
!
! 2003-06-09    Y. Lin    Use RFC domain mask to exclude Stage IV data points 
!                         that
!                           1) are not in any RFC's domain proper, and
!                           2) have a zero value
!                         These are generally points in Canada or over water 
!                         (though some Canadian points are included in one or 
!                         more RFC domains).  Reason: some RFC's (e.g. SERFC) 
!                         do not mark these points as 'missing', even when they
!                         are outside of their range, so they end up with 
!                         values of zero, when they really should be designated
!                         as "missing".  We'll use Stage 2 instead of Stage 4
!                         for these points.
!
! 2003-06-09    Y. Lin    Added adjustment using cumulative h2o budget history
!
! 2005-03-16    Y. Lin    Changes made for WRF-NMM: read in model grid number 
!                         from unit 5, so a single program can be used for 
!                         multiple grids.
!
! 2007-01-30    Y. Lin    Fill in missing data (usually O'Conus) with hourly
!                         precip forecast from a 00Z NAM (12-36h forecast, 
!                         broken down into individual files each containing 
!                         one hour)
!
! 2009-04-16    Y. Lin    Take out the merging of the Stage 2/4 (spin off to
!                         "merge2n4.f") and the ipolate mapping to model grid
!                         (now handled by copygb)
! INPUT FILES:
!   Unit 11  Merged Stage 2/4 analysis on model B-grid
!   Unit 12  H2O budget history (read into array 'balance')
!   Unit 13  NAM precip forecast (from a 00Z cycle) for this hour
!
! OUTPUT FILES:  
!   Unit 51  Adjusted/filled precipitation analysis, simple binary
!   Unit 52  Adjusted precipitation analysis, GRIB
!
! LANGUAGE: Fortran 90/95
! 
IMPLICIT NONE

! Maximum 1-d dimension of model grid:
INTEGER, PARAMETER :: Lmax=2800000

! test point:
INTEGER, PARAMETER :: i0=194023

! Merged Stage 2/4 analysis on B-grid (Panl); NAM 1-hour pcp forecast (Pnam);
! final hourly product ready for use by NDAS (P); long-term precipitation
! budget array (balance)
REAL, DIMENSION(Lmax) :: Panl, Pnam, P, balance

! Beginning and ending date of the precip budget balance array (for info only,
! Not used in calculation)
INTEGER :: iday1, iday2

! For read status on budget history file:
INTEGER :: istat

! Increment (=-balance/12.) added to Panl
REAL :: pinc

! Bitmap for Panl (BIT; also used later for Pout); for Pnam (BITnam).  BITnam
! is a dummy array, since NAM native grid precip output does not include a 
! bitmap.
LOGICAL(KIND=1), DIMENSION(Lmax) :: BIT, BITnam

! GDS and PDS for 1) getgb ('jgds, jpds')
!                 2) merged ST2/4 analysis ('kgdsa, kpdsa')
!                 3) NAM 1-hour precip fcst amount ('kgdsn, kpdsn')
!                 5) Final product (kpds, kgds)

INTEGER, DIMENSION(200) :: jgds, kgdsa, kgdsn, kgds
INTEGER, DIMENSION(200) :: jpds, kpdsa, kpdsn, kpds

! For do loop index:
INTEGER :: i

! Misc for baopenr and getgb.  kfa and kfn are the lengths of the merged ST2/4
! array and the NAM 1-hour precip array.  They should be the same length (the
! size of the B-grid).
INTEGER :: kfa, kfn, k, iret, iretanl, iretnam

! For 'getgb' searches:
    jpds = -1

! Read in merged Stage 2/4 analysis on B-grid
    CALL BAOPENR(11,'fort.11',iret) 
    write(*,*) 'baopenr on unit 11, iret=', iret
    CALL GETGB(11,0,Lmax,0,jpds,jgds,kfa,k,kpdsa,kgdsa,BIT,Panl,iretanl)
    write(*,10) 'st2n4', kpdsa(21)-1,kpdsa(8),kpdsa(9), kpdsa(10),kpdsa(11),  &
   &             iretanl, kfa
 10 format('GETGB for ',a5,x,5i2.2, ' iret=', i2, ' kf=',i8)

! Read in NAM precip forecast for this hour:
    CALL BAOPENR(12,'fort.12',iret) 
    write(*,*) 'baopenr on unit 12, iret=', iret
    CALL GETGB(12,0,Lmax,0,jpds,jgds,kfn,k,kpdsn,kgdsn,BITnam,Pnam,iretnam)
    write(*,10) 'NAM1h', kpdsn(21)-1,kpdsn(8),kpdsn(9),kpdsn(10),kpdsn(11),  &
   &             iretnam, kfn

! Read in cumulative precip budget balance history file.  If the file does not
! exist, or if the end of file is reached, assume perfect balance 
!  ("INQUIRE(UNIT=13,EXIST=bexist,ERR=50)" does not work).  
    READ(13,IOSTAT=istat) iday1,iday2,(balance(i),i=1,kfa)
    IF( istat == 0 ) then
      WRITE(*,*) 'Precip budget balance is from', iday1,' to', iday2
    else
      WRITE(*,*) 'Error reading precip budget history, make no adjustment.'
      balance=0.
    endif 
!
    IF (iretanl == 0 ) THEN 
!     If the merged ST2/4 and NAM 1-hour forecast exists, adjust the values
!     using the long-term budget balance array (if available), then fill in
!     with NAM hourly forecast (if available).

      kgds=kgdsa    
      kpds=kpdsa    
      DO i = 1, kfa
        IF (BIT(i)) THEN
          pinc = -balance(i)/12.
          pinc = min(pinc, 0.2*Panl(i))
          pinc = max(pinc,-0.2*Panl(i))
          P(i) = Panl(i) + pinc
        ELSE IF (iretnam == 0 ) THEN 
          BIT(i) = .TRUE.
          P(i) = Pnam(i)
        ELSE
          P(i) = 999.
          BIT(i) = .FALSE.
        END IF
      END DO

    ELSE IF (iretanl /= 0 .and. iretnam == 0) then
!     The merged Stage 2/4 file does not exist, but there is a valid NAM 1hr 
!     forecast.  Use NAM 1hr forecast.
      write(6,*) 'st2n4 file does not exist, use model hourly only.'
      P = Pnam
      kgds=kgdsn
      kpds=kpdsn
      kfa = kfn
    ELSE
!     Neither merged Stage 2/4 nor the NAM 1-hour precip file exists.  Make up
!     a dummy file.  No use specifying bitmap or PDS/GDS: we won't know what
!     the GDS would be (since neither B-grid file exists) and we want to keep
!     this code non-grid-specific
      write(6,*) 'st2n4 and model 1hr fcst both missing, set input to 999.'
! Set kfa to Lmax to for binary output:
      kfa = Lmax
    ENDIF

! Output precip in binary format:
    write(51) (P(i), i=1, kfa)

! NAM native-grid precip does not come with a bitmap.  For some reason, when
! it is putgb'd with a bitmap (all .true., and with kpds(4)=192), things go
! awry.  This is the case for both the B-grid and E-grid files.  For now,
! Only output bitmap if NAM precip is not involved.
! 
    IF (iretnam == 0) THEN
      kpds(4) = 128
    END IF

! Output a GRIB version, if either the merged ST2/4 or the NAM 1-hourly existed
    IF (iretanl == 0  .OR. iretnam == 0) THEN
      CALL BAOPEN(52,'fort.52',iret) 
      write(*,*) 'BAOPEN on unit 52, iret=', iret
      CALL PUTGB(52,kfa,kpds,kgds,BIT,P,iret)
      WRITE(*,*) 'FINISHED PUTGB for processed precip, iret=', iret
    ENDIF

    STOP
    END PROGRAM Prep_Hourly_Precip_Input
