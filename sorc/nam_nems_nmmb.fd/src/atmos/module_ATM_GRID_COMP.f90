

































!-----------------------------------------------------------------------
!
      MODULE module_ATM_GRID_COMP
!
!-----------------------------------------------------------------------
!***  This module contains codes directly related to the ATM component.
!-----------------------------------------------------------------------
!
!***  The ATM component lies in the hierarchy seen here:
!
!          Main program
!               |
!               |
!          NEMS component
!               |     |________________________.
!               |                              |
!          EARTH component        Ensemble Coupler component
!              /|!             / | !          ATM/OCN/ICE components
!          |    |
!          |    |
!          |    |
!          |    (MOM5, HYCOM, etc.)
!          |
!          CORE component (GSM, NMM, FIM, GEN, etc.)
!
!-----------------------------------------------------------------------
!  2011-05-11  Theurich & Yang  - Modified for using the ESMF 5.2.0r_beta_snapshot_07.
!  2011-10/04  Yang  - Modified for using the ESMF 5.2.0r library.
!  2013-07     Theurich - NUOPC option to be compliant with ESMF 6.2.0 reference.
!-----------------------------------------------------------------------
!
      USE ESMF


!
      USE module_ATM_INTERNAL_STATE,ONLY: ATM_INTERNAL_STATE            &
                                         ,WRAP_ATM_INTERNAL_STATE
!
      USE module_NMM_GRID_COMP,ONLY: NMM_REGISTER
      USE module_GFS_GRID_COMP,ONLY: GFS_REGISTER
      USE module_FIM_GRID_COMP,ONLY: FIM_REGISTER
      USE module_GEN_GRID_COMP,ONLY: GEN_REGISTER   ! For the "Generic Core" gridded component.
!
      USE module_ERR_MSG,ONLY: ERR_MSG,MESSAGE_CHECK
!
!-----------------------------------------------------------------------
!
      IMPLICIT NONE
!
!-----------------------------------------------------------------------
!
      PRIVATE
!
      PUBLIC :: ATM_REGISTER
!
!-----------------------------------------------------------------------
!
      TYPE(ATM_INTERNAL_STATE),POINTER,SAVE :: ATM_INT_STATE
      TYPE(WRAP_ATM_INTERNAL_STATE)   ,SAVE :: WRAP
!
      TYPE(ESMF_Clock),SAVE :: CLOCK_ATM                                   !<-- The Clock of the ATM component
!

!-----------------------------------------------------------------------
!
      CONTAINS
!
!-----------------------------------------------------------------------
!#######################################################################
!-----------------------------------------------------------------------
!
      SUBROUTINE ATM_REGISTER(ATM_GRID_COMP,RC_REG)
!
!-----------------------------------------------------------------------
!***  Register the Init, Run, and Finalize routines of 
!***  the ATM component.
!-----------------------------------------------------------------------
!
!------------------------
!***  Argument Variables
!------------------------
!
      TYPE(ESMF_GridComp)               :: ATM_GRID_COMP                   !<-- The ATM component
      INTEGER            ,INTENT(OUT)   :: RC_REG                          !<-- Error return code
!
!---------------------
!***  Local Variables
!---------------------
!
      INTEGER :: RC
!
!-----------------------------------------------------------------------
!***********************************************************************
!-----------------------------------------------------------------------


!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Set Entry Point for ATM Initialize"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      CALL ESMF_GridCompSetEntryPoint(ATM_GRID_COMP                     &  !<-- The ATM component
                                     ,ESMF_METHOD_INITIALIZE            &  !<-- Subroutine type (Initialize)
                                     ,ATM_INITIALIZE                    &  !<-- User's subroutine name
                                     ,phase=1                           &
                                     ,rc=RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_REG)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Set Entry Point for ATM Run"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!

      CALL ESMF_GridCompSetEntryPoint(ATM_GRID_COMP                     &  !<-- The ATM component
                                     ,ESMF_METHOD_RUN                   &  !<-- Subroutine type (Run)
                                     ,ATM_RUN                           &  !<-- User's subroutine name
                                     ,phase=1                           &
                                     ,rc=RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_REG)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Set Entry Point for ATM Finalize"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      CALL ESMF_GridCompSetEntryPoint(ATM_GRID_COMP                     &  !<-- The ATM component
                                     ,ESMF_METHOD_FINALIZE              &  !<-- Subroutine type (Finalize)
                                     ,ATM_FINALIZE                      &  !<-- User's subroutine name
                                     ,phase=1                           &
                                     ,rc=RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_REG)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!
      IF(RC_REG==ESMF_SUCCESS)THEN
!       WRITE(0,*)' ATM_REGISTER succeeded'
      ELSE
        WRITE(0,*)' ATM_REGISTER failed  RC_REG=',RC_REG
      ENDIF
!
!-----------------------------------------------------------------------
!
      END SUBROUTINE ATM_REGISTER
!
!-----------------------------------------------------------------------
!&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
!-----------------------------------------------------------------------
!

      SUBROUTINE ATM_INITIALIZE(ATM_GRID_COMP                           &
                               ,IMP_STATE                               &
                               ,EXP_STATE                               &
                               ,CLOCK_EARTH                             &
                               ,RC_INIT)
!
!-----------------------------------------------------------------------
!***  The Initialize step of the ATM component.
!-----------------------------------------------------------------------
!
!------------------------
!***  Argument Variables
!------------------------
!
      TYPE(ESMF_GridComp)               :: ATM_GRID_COMP                   !<-- The ATM component
      TYPE(ESMF_State)                  :: IMP_STATE                       !<-- The ATM import state
      TYPE(ESMF_State)                  :: EXP_STATE                       !<-- The ATM export state
      TYPE(ESMF_Clock)                  :: CLOCK_EARTH                     !<-- The Clock of the EARTH component
      INTEGER            ,INTENT(OUT)   :: RC_INIT                         !<-- Error return code
!
!---------------------
!***  Local Variables
!---------------------
!
      INTEGER :: RC
!
      TYPE(ESMF_Config)       :: CF
!
!-----------------------------------------------------------------------
!***********************************************************************
!-----------------------------------------------------------------------
!
      RC_INIT = ESMF_SUCCESS
!
!-----------------------------------------------------------------------

!
!-----------------------------------------------------------------------
!***  Allocate the ATM component's internal state, point at it,
!***  and attach it to the ATM component.
!-----------------------------------------------------------------------
!
      ALLOCATE(ATM_INT_STATE,stat=RC)
      wrap%ATM_INT_STATE=>ATM_INT_STATE
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Set the ATM Internal State"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      CALL ESMF_GridCompSetInternalState(ATM_GRID_COMP                  &
                                        ,WRAP                           &
                                        ,RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_INIT)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!
!-----------------------------------------------------------------------
!***  Create the configure object for the ATM configure file which
!***  specifies the dynamic core.
!-----------------------------------------------------------------------
!
      CF=ESMF_ConfigCreate(rc=RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Load the ATM configure file"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      CALL ESMF_ConfigLoadFile(config=CF ,filename='atmos.configure' ,rc=RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_INIT)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!***  Attach the configure object to the ATM component.
!-----------------------------------------------------------------------
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Attach the configure file to the ATM component"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      CALL ESMF_GridCompSet(gridcomp=ATM_GRID_COMP                      &  !<-- The ATM component
                           ,config  =CF                                 &  !<-- The associated configure object
                           ,rc      =RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_INIT)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!
!-----------------------------------------------------------------------
!***  For the moment, use a direct copy of the EARTH Clock within
!***  the ATM component.
!-----------------------------------------------------------------------
!

      atm_int_state%CLOCK_ATM=CLOCK_EARTH


!-----------------------------------------------------------------------
!***  Extract the dynamic core name from the configure file.
!-----------------------------------------------------------------------
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Extract dynamic core from the ATM configure file"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      CALL ESMF_ConfigGetAttribute(config=CF                            &  !<-- The ATM configure object
                                  ,value =atm_int_state%CORE            &  !<-- The dynamic core name
                                  ,label ='core:'                       &  !<-- The label in the configure file
                                  ,rc    =RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_INIT)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!***  Create the ATM subcomponent and its associated import/export
!***  states for the core name that was extracted.
!-----------------------------------------------------------------------
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Create the CORE component"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      atm_int_state%CORE_GRID_COMP=ESMF_GridCompCreate(name=TRIM(atm_int_state%CORE)//' component' &
                                                      ,rc  =RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_INIT)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!***  Attach the configure object to the CORE component.
!-----------------------------------------------------------------------
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!     MESSAGE_CHECK="Attach the configure file to the CORE component"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!     CALL ESMF_GridCompSet(gridcomp=atm_int_state%CORE_GRID_COMP       &  !<-- The ATM component
!                          ,config  =CF                                 &  !<-- The associated configure object
!                          ,rc      =RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!     CALL ERR_MSG(RC,MESSAGE_CHECK,RC_INIT)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!***  Register the subcomponent's Init, Run, and Finalize subroutines.
!-----------------------------------------------------------------------
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Register the CORE component's Init, Run, and Finalize steps"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      SELECT CASE(atm_int_state%CORE)
!
        CASE('nmm')
          CALL ESMF_GridCompSetServices (atm_int_state%CORE_GRID_COMP   &
                                        ,NMM_REGISTER                   &
                                        ,rc=RC)
!
        CASE('gfs')
          CALL ESMF_GridCompSetServices (atm_int_state%CORE_GRID_COMP   &
                                        ,GFS_REGISTER                   &
                                        ,rc=RC)
!
        CASE('gsm')
          CALL ESMF_GridCompSetServices (atm_int_state%CORE_GRID_COMP   &
                                        ,GFS_REGISTER                   &
                                        ,rc=RC)
!
        CASE('fim')
          CALL ESMF_GridCompSetServices (atm_int_state%CORE_GRID_COMP   &
                                        ,FIM_REGISTER                   &
                                        ,rc=RC)

        CASE('gen')
          CALL ESMF_GridCompSetServices (atm_int_state%CORE_GRID_COMP   &
                                        ,GEN_REGISTER                   &
                                        ,rc=RC)
        CASE DEFAULT
          write(0,*)' ATM_INITIALIZE requires unknown core: ',TRIM(atm_int_state%CORE)                      
!
      END SELECT
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_INIT)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!***  Create the Core component's import/export states.
!-----------------------------------------------------------------------
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Create the CORE import state"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      atm_int_state%CORE_IMP_STATE=ESMF_StateCreate(name   = "CORE Import"            &
                                                   ,stateintent = ESMF_STATEINTENT_IMPORT  &
                                                   ,rc          = RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_INIT)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Create the CORE export state"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      atm_int_state%CORE_EXP_STATE=ESMF_StateCreate(name   = "CORE Export"            &
                                                   ,stateintent = ESMF_STATEINTENT_EXPORT  &
                                                   ,rc          = RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_INIT)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!***  Nest the import/export states of the CORE component into the
!***  analgous states of the ATM component.
!-----------------------------------------------------------------------
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK= "Add the CORE states into the ATMOS states"
!     CALL ESMF_LogWrite(MESSAGE_CHECK, ESMF_LOGMSG_INFO, rc = RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
! - Cannot bring these items out through the ATM Import and Export States 
! - under NUOPC, because NUOPC requires a minumum of Field metadata for 
! - anything that is going in/out of a component (e.g. to timestamp).
      CALL ESMF_StateAddReplace(IMP_STATE,(/atm_int_state%CORE_IMP_STATE/),rc = RC)
      CALL ESMF_StateAddReplace(EXP_STATE,(/atm_int_state%CORE_EXP_STATE/),rc = RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_INIT)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!***  Initialize the CORE component.
!-----------------------------------------------------------------------
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Initialize the CORE component"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      CALL ESMF_GridCompInitialize(gridcomp   =atm_int_state%CORE_GRID_COMP &
                                  ,importState=atm_int_state%CORE_IMP_STATE &
                                  ,exportState=atm_int_state%CORE_EXP_STATE &
                                  ,clock      =atm_int_state%CLOCK_ATM      &
                                  ,rc         =RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_INIT)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!
      IF(RC_INIT==ESMF_SUCCESS)THEN
!       WRITE(0,*)' ATM_INITIALIZE succeeded'
      ELSE
        WRITE(0,*)' ATM_INITIALIZE failed  RC_INIT=',RC_INIT
      ENDIF
!
!-----------------------------------------------------------------------
!
!
!-----------------------------------------------------------------------
!

      END SUBROUTINE ATM_INITIALIZE
!
!-----------------------------------------------------------------------
!#######################################################################
!-----------------------------------------------------------------------
!


!
!-----------------------------------------------------------------------
!#######################################################################
!-----------------------------------------------------------------------
!

      SUBROUTINE ATM_RUN(ATM_GRID_COMP                                  &
                        ,IMP_STATE                                      &
                        ,EXP_STATE                                      &
                        ,CLOCK_EARTH                                    &
                        ,RC_RUN)
!
!-----------------------------------------------------------------------
!***  The Run step of the ATM component.
!-----------------------------------------------------------------------
!
!------------------------
!***  Argument Variables
!------------------------
! 
      TYPE(ESMF_GridComp)               :: ATM_GRID_COMP                   !<-- The ATM component
      TYPE(ESMF_State)                  :: IMP_STATE                       !<-- The ATM import state
      TYPE(ESMF_State)                  :: EXP_STATE                       !<-- The ATM export state
      TYPE(ESMF_Clock)                  :: CLOCK_EARTH                     !<-- The Clock of the EARTH component
      INTEGER            ,INTENT(OUT)   :: RC_RUN                          !<-- Error return code
!
!---------------------
!***  Local Variables
!---------------------
!
      INTEGER :: RC
!
      TYPE(ESMF_Time) :: CURRTIME                                       &
                        ,STARTTIME
!
      TYPE(ESMF_TimeInterval) :: RUNDURATION
!
!-----------------------------------------------------------------------
!***********************************************************************
!-----------------------------------------------------------------------
!
!-----------------------------------------------------------------------
!***  For the moment, use a direct copy of the EARTH Clock within
!***  the ATM component.
!-----------------------------------------------------------------------
!
      atm_int_state%CLOCK_ATM=CLOCK_EARTH
!
!-----------------------------------------------------------------------
!***  Execute the Run step of the selected dynamic core.
!-----------------------------------------------------------------------
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Execute the Run step of the CORE component"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      CALL ESMF_GridCompRun(gridcomp   =atm_int_state%CORE_GRID_COMP    &
                           ,importState=atm_int_state%CORE_IMP_STATE    &
                           ,exportState=atm_int_state%CORE_EXP_STATE    &
                           ,clock      =atm_int_state%CLOCK_ATM         &
                           ,rc         =RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_RUN)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!***  Update the ATMOS clock.
!-----------------------------------------------------------------------

! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK = "Update the current time of the ATMOS clock"
!     CALL ESMF_LogWrite(MESSAGE_CHECK, ESMF_LOGMSG_INFO, rc = RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      CALL ESMF_ClockGet(clock      =atm_int_state%CLOCK_ATM            &
                        ,startTime  =STARTTIME                          &
                        ,runDuration=RUNDURATION                        &
                        ,rc         =RC)
!
      CURRTIME=STARTTIME+RUNDURATION
!
      CALL ESMF_ClockSet(clock   =atm_int_state%CLOCK_ATM               &
                        ,currTime=CURRTIME                              &
                        ,rc      =RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      CALL ERR_MSG(RC,MESSAGE_CHECK,RC_RUN)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!
      IF(RC_RUN==ESMF_SUCCESS)THEN
!       WRITE(0,*)' ATM_RUN succeeded'
      ELSE
        WRITE(0,*)' ATM_RUN failed  RC_RUN=',RC_RUN
      ENDIF
!
!-----------------------------------------------------------------------
!
      END SUBROUTINE ATM_RUN
!
!-----------------------------------------------------------------------
!#######################################################################
!-----------------------------------------------------------------------
!


      SUBROUTINE ATM_FINALIZE(ATM_GRID_COMP                             &
                             ,IMP_STATE                                 &
                             ,EXP_STATE                                 &
                             ,CLOCK_EARTH                               &
                             ,RC_FINALIZE)
!
!-----------------------------------------------------------------------
!***  Finalize the ATM component.
!-----------------------------------------------------------------------
!
!------------------------
!***  Argument Variables
!------------------------
!
      TYPE(ESMF_GridComp)               :: ATM_GRID_COMP                   !<-- The ATM component
      TYPE(ESMF_State)                  :: IMP_STATE                       !<-- The ATM import state
      TYPE(ESMF_State)                  :: EXP_STATE                       !<-- The ATM import state
      TYPE(ESMF_Clock)                  :: CLOCK_EARTH                     !<-- The Clock of the EARTH component
      INTEGER            ,INTENT(OUT)   :: RC_FINALIZE                     !<-- Error return code
!
!---------------------
!***  Local Variables
!---------------------
!
      INTEGER :: RC
!
!-----------------------------------------------------------------------
!***********************************************************************
!-----------------------------------------------------------------------
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
      MESSAGE_CHECK="Execute the Finalize step of the CORE component"
!     CALL ESMF_LogWrite(MESSAGE_CHECK,ESMF_LOGMSG_INFO,rc=RC)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
      CALL ESMF_GridCompFinalize(gridcomp   =atm_int_state%CORE_GRID_COMP &
                                ,importState=atm_int_state%CORE_IMP_STATE &
                                ,exportState=atm_int_state%CORE_EXP_STATE &
                                ,clock      =atm_int_state%CLOCK_ATM      &
                                ,rc         =RC)
!
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
        CALL ERR_MSG(RC,MESSAGE_CHECK,RC_FINALIZE)
! ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!
!-----------------------------------------------------------------------
!

      IF(RC_FINALIZE==ESMF_SUCCESS)THEN
!       WRITE(0,*)' ATM_FINALIZE succeeded'
      ELSE
        WRITE(0,*)' ATM_FINALIZE failed  RC_FINALIZE=',RC_FINALIZE
      ENDIF
!
!-----------------------------------------------------------------------
!
      END SUBROUTINE ATM_FINALIZE
!
!-----------------------------------------------------------------------
!
      END MODULE module_ATM_GRID_COMP
!
!-----------------------------------------------------------------------
