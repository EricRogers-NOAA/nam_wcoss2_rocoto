 subroutine slope_type
!$$$ subroutine documentation block
!
! subprogram:  slope_type
!   prgmmr: gayno          org: w/np2           date: ????
!
! $Revision$
!
! abstract: driver routine to compute slope type
!   on the model grid and grib the result.
!
! program history log:
! ????        gayno     - initial version
!
! usage:  call routine with no arguments
!
! files: none
!
! condition codes: none
!
! remarks: none.
!
!$$$
 use program_setup, only         : slopetype_file, domain_name, grib2

 implicit none

 character*3                    :: interp_mask
 character*2                    :: interp_type
 character*256                  :: output_file

 integer                        :: grib_scale_fac
 integer                        :: iunit_out

 real                           :: default_value

!-----------------------------------------------------------------------
! initialize some variables, then call interp driver.
!-----------------------------------------------------------------------

 if (len_trim(slopetype_file) == 0) return

 print*,"- INTERPOLATE SLOPE INDEX DATA TO MODEL GRID"
 
 if (grib2) then
   output_file    = trim(domain_name)//"_slopeidx.grb2"   ! grib file of data on model grid.
 else
   output_file    = trim(domain_name)//"_slopeidx.grb"   ! grib file of data on model grid.
 endif
 iunit_out      = 47          ! unit # of above.
 grib_scale_fac =  0          ! # decimal places (-1 same as input data) 
 default_value  =  5.         ! if interp routine can not find data
                              ! at a model grid point, set to this value.
 interp_type    = "nn"        ! use nearest neighbor
 interp_mask    = "lnd"       ! a land field

 call interp_to_mdl(slopetype_file, output_file, iunit_out, &
                    interp_type, default_value, grib_scale_fac, &
                    interp_mask)

 return

 end subroutine slope_type
