

































! !REVISION HISTORY:
!
!  Jan 2016      Patrick Tripp - NUOPC/GSM merge: export/importFieldsList used always

module module_CPLFIELDS

  !-----------------------------------------------------------------------------
  ! ATM Coupling Fields: export and import
  !
  !-----------------------------------------------------------------------------


  use ESMF
  
  implicit none
  
  private
 
  integer, public, parameter :: NimportFields = 14
  integer, public, parameter :: NexportFields = 48
 

! PT: these are needed in non NUOPC 
! #ifdef WITH_NUOPC

  ! Export Fields ----------------------------------------
  type(ESMF_Field), public   :: exportFields(NexportFields)
  character(len=40), public, parameter :: exportFieldsList(NexportFields) = (/ &
      "mean_zonal_moment_flx                  ", &
      "mean_merid_moment_flx                  ", &
      "mean_sensi_heat_flx                    ", &
      "mean_laten_heat_flx                    ", &
      "mean_down_lw_flx                       ", &
      "mean_down_sw_flx                       ", &
      "mean_prec_rate                         ", &
      "inst_zonal_moment_flx                  ", &
      "inst_merid_moment_flx                  ", &
      "inst_sensi_heat_flx                    ", &
      "inst_laten_heat_flx                    ", &
      "inst_down_lw_flx                       ", &
      "inst_down_sw_flx                       ", &
      "inst_temp_height2m                     ", &
      "inst_spec_humid_height2m               ", &
      "inst_zonal_wind_height10m              ", &
      "inst_merid_wind_height10m              ", &
      "inst_temp_height_surface               ", &
      "inst_pres_height_surface               ", &
      "inst_surface_height                    ", &
      "mean_net_lw_flx                        ", &
      "mean_net_sw_flx                        ", &
      "inst_net_lw_flx                        ", &
      "inst_net_sw_flx                        ", &
      "mean_down_sw_ir_dir_flx                ", &
      "mean_down_sw_ir_dif_flx                ", &
      "mean_down_sw_vis_dir_flx               ", &
      "mean_down_sw_vis_dif_flx               ", &
      "inst_down_sw_ir_dir_flx                ", &
      "inst_down_sw_ir_dif_flx                ", &
      "inst_down_sw_vis_dir_flx               ", &
      "inst_down_sw_vis_dif_flx               ", &
      "mean_net_sw_ir_dir_flx                 ", &
      "mean_net_sw_ir_dif_flx                 ", &
      "mean_net_sw_vis_dir_flx                ", &
      "mean_net_sw_vis_dif_flx                ", &
      "inst_net_sw_ir_dir_flx                 ", &
      "inst_net_sw_ir_dif_flx                 ", &
      "inst_net_sw_vis_dir_flx                ", &
      "inst_net_sw_vis_dif_flx                ", &
!     "inst_ir_dir_albedo                     ", &
!     "inst_ir_dif_albedo                     ", &
!     "inst_vis_dir_albedo                    ", &
!     "inst_vis_dif_albedo                    ", &
      "inst_land_sea_mask                     ", &
      "inst_temp_height_lowest                ", &
      "inst_spec_humid_height_lowest          ", &
      "inst_zonal_wind_height_lowest          ", &
      "inst_merid_wind_height_lowest          ", &
      "inst_pres_height_lowest                ", &
      "inst_height_lowest                     ", &
      "mean_fprec_rate                        "  /)
  
  ! Import Fields ----------------------------------------
  type(ESMF_Field), public   :: importFields(NimportFields)
  character(len=40), public, parameter :: importFieldsList(NimportFields) = (/ &
      "land_mask                              ", &
      "surface_temperature                    ", &
      "sea_surface_temperature                ", &
      "ice_fraction                           ", &
      "inst_ice_ir_dif_albedo                 ", &
      "inst_ice_ir_dir_albedo                 ", &
      "inst_ice_vis_dif_albedo                ", &
      "inst_ice_vis_dir_albedo                ", &
      "mean_up_lw_flx                         ", &
      "mean_laten_heat_flx                    ", &
      "mean_sensi_heat_flx                    ", &
      "mean_evap_rate                         ", &
      "mean_zonal_moment_flx                  ", &
      "mean_merid_moment_flx                  "  /)
  
  ! Utility GSM members ----------------------------------
  public            :: global_lats_ptr
  integer, pointer  :: global_lats_ptr(:)
  public            :: lonsperlat_ptr
  integer, pointer  :: lonsperlat_ptr(:)

  ! Methods
  public fillExportFields
  public queryFieldList
  public setupGauss2d
  
  !-----------------------------------------------------------------------------
  contains
  !-----------------------------------------------------------------------------
  
  subroutine fillExportFields(data_a2oi, lonr, latr, rootPet, rc)
    real(kind=8)                                :: data_a2oi(:,:,:)
    integer, intent(in)                         :: lonr, latr, rootPet
    integer, optional                           :: rc
  end subroutine
  
  !-----------------------------------------------------------------------------

  subroutine setupGauss2d(lonr, latr, pi, colrad_a, lats_node_a, &
    global_lats_a, lonsperlat, rc)
    integer, intent(in)                         :: lonr, latr 
    real(kind=8), intent(in)                    :: pi, colrad_a(:)
    integer, intent(in)                         :: lats_node_a
    integer, intent(in), target                 :: global_lats_a(:)
    integer, intent(in), target                 :: lonsperlat(:)
    integer, optional                           :: rc
  end subroutine

  integer function queryFieldList(fieldlist, fieldname, abortflag, rc)
    ! returns integer index of first found fieldname in fieldlist
    ! by default, will abort if field not found, set abortflag to false 
    !   to turn off the abort.
    ! return value of < 1 means the field was not found
    character(len=*),intent(in) :: fieldlist(:)
    character(len=*),intent(in) :: fieldname
    logical, optional :: abortflag
    integer, optional :: rc

    integer :: n
    logical :: labort

    labort = .true.
    if (present(abortflag)) then
      labort = abortflag
    endif

    queryFieldList = 0
    n = 1
    do while (queryFieldList < 1 .and. n <= size(fieldlist))  
      if (trim(fieldlist(n)) == trim(fieldname)) then
        queryFieldList = n
      else
        n = n + 1
      endif
    enddo

    if (labort .and. queryFieldList < 1) then
! #ifdef WITH_NUOPC
     call ESMF_LogWrite('queryFieldList ABORT on fieldname '//trim(fieldname), ESMF_LOGMSG_INFO, line=343, file="module_CPLFIELDS.F90", rc=rc)
      CALL ESMF_Finalize(endflag=ESMF_END_ABORT)
! #endif
    endif
  end function queryFieldList
  !-----------------------------------------------------------------------------

end module
