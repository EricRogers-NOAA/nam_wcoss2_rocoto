PROGRAM Merge_Stage2_Stage4
!
! PURPOSE: Merge Stage 2/4 analyses, to be used as input for NDAS hourly
!   precipitation input for soil moisture.  
! 
! INPUT FILES:
!   Unit 11  Stage 2 analysis
!   Unit 12  Stage 4 analysis
!   Unit 13  River Forecast Center (RFC) domain mask
!   Unit 14  MISBIN (radar effective coverage) composite mask for CONUS
!
! OUTPUT FILE:
!   Unit 51  Merged Stage 2/4
! 
! SUMMARY:
!   Merge the Stage 2/4 analyses: use Stage 4 as first choice, fill in missing 
!   points with Stage 2, with the exceptions of CNRFC, NWRFC and zero-values of
!   Stage 4 data outside of CONUS.  If any grid point has a value > 1", set
!   it to "missing".
!
! RECORD OF REVISIONS
!    Date     Programmer  Description of Change
! ==========  ==========  ====================================================
! 2009-04-15  Ying Lin    Separated "merge Stage II/IV" from the original
!                         "pcpprep.f"
! 2016-07-18  Y. Lin 1) Use Stage II and Stage IV only within the RFC domains, 
!                       as determined by stage3_mask.grb (val > 1).  Previously
!                       Stage IV outside of the above domain was used if it has
!                       positive precip; and if Stage IV was not used, Stage II
!                       was used to fill in wherever it was available
!                    2) Only the Stage II on grids with MISBIN > 0 is used.
!               
! LANGUAGE: Fortran 90/95
! 
IMPLICIT NONE

! Dimension of Stage 2/4 analysis files (on the 4km HRAP grid):
INTEGER, PARAMETER :: nx=1121, ny=881

! Maximum hourly amount allowed is 1":
REAL, PARAMETER :: pmax=25.4

! Stage 2/4 precipitation files and their bit masks; merged file and bit 
! mask; RFC domains mask (real array) and its bitmask (bitr); composite
! MISBIN array (real) and its bitmask (bitm)
REAL,    DIMENSION(nx,ny) :: p2, p4, p24, rfcmask, cmisbin
LOGICAL(KIND=1), DIMENSION(nx,ny) :: bit2, bit4, bit24, bitr, bitm

! RFC mask file, converted to integer (just a scalar variable); 
! cmisbin converted to integer
INTEGER :: imask, misbin

! GDS and PDS for 1) getgb ('j')
!                 2) Stage 2 ('2')
!                 3) Stage 4 ('4')
!                 4) Stage 2/4 merged ('24')
!                 5) RFC mask ('r')
!                 6) MISBIN composite mask ('m')

INTEGER, DIMENSION(200) :: jgds, kgds2, kgds4, kgds24, kgdsr, kgdsm 
INTEGER, DIMENSION(200) :: jpds, kpds2, kpds4, kpds24, kpdsr, kpdsm

! For do loop index:
INTEGER :: i, j

! Misc for baopenr and getgb:
INTEGER :: kf, k, iret, iret2, iret4

! For 'getgb' searches:
    jpds = -1
 
! Read in Stage II:
    call baopenr(11,'fort.11',iret) 
    write(*,*) 'baopenr on unit 11, iret=', iret
    call getgb(11,0,nx*ny,0,jpds,jgds,kf,k,kpds2,kgds2,bit2,p2,iret2)
    write(*,10) 'ST2', kpds2(21)-1,kpds2(8),kpds2(9),kpds2(10),kpds2(11),iret2
 10 format('GETGB for ',a3,x, 5i2.2, ' iret=', i2)

! Read in Stage IV:
    call baopenr(12,'fort.12',iret) 
    write(*,*) 'baopenr on unit 12, iret=', iret
    call getgb(12,0,nx*ny,0,jpds,jgds,kf,k,kpds4,kgds4,bit4,p4,iret4)
    write(*,10) 'st4', kpds4(21)-1,kpds4(8),kpds4(9),kpds4(10),kpds4(11),iret4

! Read in RFC mask (real array), borrow the bitmap, kpds, kgds from ST2:
    call baopenr(13,'fort.13',iret) 
    write(*,*) 'baopenr on unit 13 for RFC mask, iret=', iret
    call getgb(13,0,nx*ny,0,jpds,jgds,kf,k,kpdsr,kgdsr,bitr,rfcmask,iret)
    write(*,*) 'getgb for RFC mask, iret=', iret

! Read in MISBIN mask (real array), borrow the bitmap, kpds, kgds from ST2:
    call baopenr(14,'fort.14',iret) 
    write(*,*) 'baopenr on unit 14 for MISBIN composit mask, iret=', iret
    call getgb(14,0,nx*ny,0,jpds,jgds,kf,k,kpdsm,kgdsm,bitm,cmisbin,iret)
    write(*,*) 'getgb for MISBIN composite mask, iret=', iret
! Now merge Stage II/Stage IV: 
    IF (iret2 == 0 .AND. iret4 == 0) THEN   ! both analyses exist
      kgds24=kgds4
      kpds24=kpds4

      DO j = 1, ny
      DO i = 1, nx
        imask  = INT(rfcmask(i,j))
        misbin = INT(cmisbin(i,j))

!       Use Stage IV if all the following criteria are met:
!         1) Stage IV mask indicate that it has valid data
!         2) If this point is outside of any of the RFC's domain proper (i.e. 
!            in Canada or over water), it's precip value is not zero
!         3) This point is not in CNRFC or NWRFC

        IF (bit4(i,j) .AND.imask /= 153 .AND. imask /= 159 .AND. imask > 1)   &
     &  THEN
          p24(i,j)=p4(i,j)
          bit24(i,j)=bit4(i,j)
        ELSEIF (misbin > 0 .AND. imask > 1) THEN
          p24(i,j)=p2(i,j)
          bit24(i,j)=bit2(i,j)
        ENDIF
      END DO
      END DO

    ELSE IF (iret2 == 0 .AND. iret4 /= 0) THEN
!     Only Stage II analysis exists.  Use Stage II.
      kgds24 = kgds2
      kpds24 = kpds2

      DO j = 1, ny
      DO i = 1, nx
        imask  = INT(rfcmask(i,j))
        misbin = INT(cmisbin(i,j))
        IF (imask > 1 .and. misbin > 0) THEN
          p24(I,J) = p2(I,J)
          bit24(I,J) = bit2(i,J)
        ENDIF
      END DO
      END DO

    ELSE IF (iret2 /=0 .AND. iret4 == 0) THEN
!     Only Stage IV analysis exists.  Use Stage IV in areas outside of 
!     CNRFC and NWRFC.  "No data" for CNRFC and NWRFC.

      kgds24 = kgds4
      kpds24 = kpds4

      DO j = 1, ny
      DO i = 1, nx
        imask = int(rfcmask(i,j))
        IF (bit4(i,j) .AND. imask > 1 .AND. imask /= 153 .AND. imask /= 159 ) &
     &  THEN
          p24(i,j) = p4(i,j)
          bit24(i,j) = bit4(i,j)
        ELSE
          bit24(i,j) = .FALSE.
        ENDIF
      END DO
      END DO 

    ELSE  
      write(*,*) 'Neither Stage 2/4 file exists.  Exit merge2n4.'
      STOP
    END IF 

! Output the merged Stage 2/4 file:
    call baopen(51,'fort.51',iret) 
    write(*,*) 'baopen for merged Stage 2/4, iret=', iret
    call putgb(51,nx*ny,kpds24,kgds24,bit24,p24,iret)
    write(*,*) 'PUTGB for merged Stage 2/4, iret=', iret
!
STOP
END PROGRAM Merge_Stage2_Stage4
