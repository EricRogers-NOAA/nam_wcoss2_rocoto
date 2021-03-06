












MODULE MODULE_SF_URBAN

!===============================================================================
!     Single-Layer Urban Canopy Model for WRF Noah-LSM
!     Original Version: 2002/11/06 by Hiroyuki Kusaka
!     Last Update:      2006/08/24 by Fei Chen and Mukul Tewari (NCAR/RAL)  
!===============================================================================

   CHARACTER(LEN=4)                :: LU_DATA_TYPE

   INTEGER                         :: ICATE

   REAL, ALLOCATABLE, DIMENSION(:) :: ZR_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: Z0C_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: Z0HC_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: ZDC_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: SVF_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: R_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: RW_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: HGT_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: CDS_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: AS_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: AH_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: BETR_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: BETB_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: BETG_TBL
   REAL, ALLOCATABLE, DIMENSION(:) :: FRC_URB_TBL

   REAL                            :: CAPR_DATA, CAPB_DATA, CAPG_DATA
   REAL                            :: AKSR_DATA, AKSB_DATA, AKSG_DATA
   REAL                            :: ALBR_DATA, ALBB_DATA, ALBG_DATA
   REAL                            :: EPSR_DATA, EPSB_DATA, EPSG_DATA
   REAL                            :: Z0R_DATA,  Z0B_DATA,  Z0G_DATA
   REAL                            :: Z0HR_DATA, Z0HB_DATA, Z0HG_DATA
   REAL                            :: TRLEND_DATA, TBLEND_DATA, TGLEND_DATA

   INTEGER                         :: BOUNDR_DATA,BOUNDB_DATA,BOUNDG_DATA
   INTEGER                         :: CH_SCHEME_DATA, TS_SCHEME_DATA

   INTEGER                         :: allocate_status 

!   INTEGER                         :: num_roof_layers
!   INTEGER                         :: num_wall_layers
!   INTEGER                         :: num_road_layers

   CONTAINS

!===============================================================================
!
! Author:
!      Hiroyuki KUSAKA, PhD
!      University of Tsukuba, JAPAN
!      (CRIEPI, NCAR/MMM visiting scientist, 2002-2004)
!      kusaka@ccs.tsukuba.ac.jp
!
! Co-Researchers:
!     Fei CHEN, PhD
!      NCAR/RAP feichen@ucar.edu
!     Mukul TEWARI, PhD
!      NCAR/RAP mukul@ucar.edu
!
! Purpose:
!     Calculate surface temeprature, fluxes, canopy air temperature, and canopy wind
!
! Subroutines:
!     module_sf_urban
!       |- urban
!            |- read_param
!            |- mos or jurges
!            |- multi_layer or force_restore
!       |- urban_param_init <-- urban_param.tbl
!       |- urban_var_init
!
! Input Data from WRF [MKS unit]:
!
!     UTYPE  [-]     : Urban type. 1=urban, 2=suburban, 3=rural 
!     TA     [K]     : Potential temperature at 1st wrf level (absolute temp)
!     QA     [kg/kg] : Mixing ratio at 1st atmospheric level
!     UA     [m/s]   : Wind speed at 1st atmospheric level
!     SSG    [W/m/m] : Short wave downward radiation at a flat surface
!                      Note this is the total of direct and diffusive solar
!                      downward radiation. If without two components, the
!                      single solar downward can be used instead.
!                      SSG = SSGD + SSGQ
!     LSOLAR [-]     : Indicating the input type of solar downward radiation
!                      True: both direct and diffusive solar radiation 
!                      are available
!                      False: only total downward ridiation is available.
!     SSGD   [W/m/m] : Direct solar radiation at a flat surface
!                      if SSGD is not available, one can assume a ratio SRATIO
!                      (e.g., 0.7), so that SSGD = SRATIO*SSG 
!     SSGQ   [W/m/m] : Diffuse solar radiation at a flat surface
!                      If SSGQ is not available, SSGQ = SSG - SSGD
!     LLG    [W/m/m] : Long wave downward radiation at a flat surface 
!     RAIN   [mm/h]  : Precipitation
!     RHOO   [kg/m/m/m] : Air density
!     ZA     [m]     : First atmospheric level
!                      as a lowest boundary condition
!     DECLIN [rad]   : solar declination
!     COSZ           : = sin(fai)*sin(del)+cos(fai)*cos(del)*cos(omg)
!     OMG    [rad]   : solar hour angle
!     XLAT   [deg]   : latitude
!     DELT   [sec]   : Time step
!     ZNT    [m]     : Roughnes length
!
! Output Data to WRF [MKS unit]:
!
!     TS  [K]            : Surface potential temperature (absolute temp)
!     QS  [-]            : Surface humidity
!
!     SH  [W/m/m/]       : Sensible heat flux, = FLXTH*RHOO*CPP
!     LH  [W/m/m]        : Latent heat flux, = FLXHUM*RHOO*ELL
!     LH_INEMATIC [kg/m/m/sec]: Moisture Kinematic flux, = FLXHUM*RHOO
!     SW  [W/m/m]        : Upward shortwave radiation flux, 
!                          = SSG-SNET*697.7*60. (697.7*60.=100.*100.*4.186)
!     ALB [-]            : Time-varying albedo
!     LW  [W/m/m]        : Upward longwave radiation flux, 
!                          = LNET*697.7*60.-LLG
!     G   [W/m/m]        : Heat Flux into the Ground
!     RN  [W/m/m]        : Net radiation
!
!     PSIM  [-]          : Diagnostic similarity stability function for momentum
!     PSIH  [-]          : Diagnostic similarity stability function for heat
!
!     TC  [K]            : Diagnostic canopy air temperature
!     QC  [-]            : Diagnostic canopy humidity
!
!     TH2 [K]            : Diagnostic potential temperature at 2 m
!     Q2  [-]            : Diagnostic humidity at 2 m
!     U10 [m/s]          : Diagnostic u wind component at 10 m
!     V10 [m/s]          : Diagnostic v wind component at 10 m
!
!     CHS, CHS2 [m/s]    : CH*U at ZA, CH*U at 2 m (not used)
!
! Important parameters:
! Following parameter are assigned in run/urban_param.tbl
!
!  ZR  [m]             : roof level (building height)
!  Z0C [m]             : Roughness length above canyon for momentum (1/10 of ZR)
!  Z0HC [m]            : Roughness length above canyon for heat (1/10 of Z0C)
!  ZDC [m]             : Zero plane displacement height (1/5 of ZR)
!  SVF [-]             : sky view factor. Calculated again in urban_param_init
!  R   [-]             : building coverage ratio
!  RW  [-]             : = 1 - R
!  HGT [-]             : normalized building height
!  CDS [-]             : drag coefficient by buildings
!  AS  [1/m]           : buildings volumetric parameter
!  AH  [cal/cm/cm]     : anthropogenic heat
!  BETR [-]            : minimum moisture availability of roof
!  BETB [-]            : minimum moisture availability of building wall
!  BETG [-]            : minimum moisture availability of road
!  CAPR[cal/cm/cm/cm/degC]: heat capacity of roof
!  CAPB[cal/cm/cm/cm/degC]: heat capacity of building wall
!  CAPG[cal/cm/cm/cm/degC]: heat capacity of road
!  AKSR [cal/cm/sec/degC] : thermal conductivity of roof
!  AKSB [cal/cm/sec/degC] : thermal conductivity of building wall
!  AKSG [cal/cm/sec/degC] : thermal conductivity of road
!  ALBR [-]               : surface albedo of roof
!  ALBB [-]               : surface albedo of building wall
!  ALBG [-]               : surface albedo of road
!  EPSR [-]               : surface emissivity of roof
!  EPSB [-]               : surface emissivity of building wall
!  EPSG [-]               : surface emissivity of road
!  Z0R [m]                : roughness length for momentum of roof
!  Z0B [m]                : roughness length for momentum of building wall (only for CH_SCHEME = 1)
!  Z0G [m]                : roughness length for momentum of road (only for CH_SCHEME = 1)
!  Z0HR [m]               : roughness length for heat of roof
!  Z0HB [m]               : roughness length for heat of building wall (only for CH_SCHEME = 1)
!  Z0HG [m]               : roughness length for heat of roof
!  num_roof_layers        : number of layers within roof
!  num_wall_layers        : number of layers within building walls
!  num_road_layers        : number of layers within below road surface
!   NOTE: for now, these layers are defined as same as the number of soil layers in namelist.input
!  DZR [cm]               : thickness of each roof layer
!  DZB [cm]               : thickness of each building wall layer
!  DZG [cm]               : thickness of each ground layer
!  BOUNDR [integer 1 or 2] : Boundary Condition for Roof Layer Temp [1: Zero-Flux, 2: T = Constant]
!  BOUNDB [integer 1 or 2] : Boundary Condition for Building Wall Layer Temp [1: Zero-Flux, 2: T = Constant]
!  BOUNDG [integer 1 or 2] : Boundary Condition for Road Layer Temp [1: Zero-Flux, 2: T = Constant]
!  TRLEND [K]             : lower boundary condition of roof temperature
!  TBLEND [K]             : lower boundary condition of building temperature
!  TGLEND [K]             : lower boundary condition of gound temperature
!  CH_SCHEME [integer 1 or 2] : Sfc exchange scheme used for building wall and road
!                         [1: M-O Similarity Theory,  2: Empirical Form (recommend)]
!  TS_SCHEME [integer 1 or 2] : Scheme for computing surface temperature (for roof, wall, and road)
!                         [1: 4-layer model,  2: Force-Restore method]
!
!
! References:
!     Kusaka and Kimura (2004) J.Appl.Meteor., vol.43, p1899-1910
!     Kusaka and Kimura (2004) J.Meteor.Soc.Japan, vol.82, p45-65
!     Kusaka et al. (2001) Bound.-Layer Meteor., vol.101, p329-358
!
! History:
!     2006/06          modified by H. Kusaka (Univ. Tsukuba), M. Tewari 
!     2005/10/26,      modified by Fei Chen, Mukul Tewari
!     2003/07/21 WRF , modified  by H. Kusaka of CRIEPI (NCAR/MMM)
!     2001/08/26 PhD , modified  by H. Kusaka of CRIEPI (Univ.Tsukuba)
!     1999/08/25 LCM , developed by H. Kusaka of CRIEPI (Univ.Tsukuba)
!
!===============================================================================
!
!  subroutine urban:
!
!===============================================================================

   SUBROUTINE urban(LSOLAR,                                           & ! L
                    num_roof_layers,num_wall_layers,num_road_layers,  & ! I
                    DZR,DZB,DZG,                                      & ! I
                    UTYPE,TA,QA,UA,U1,V1,SSG,SSGD,SSGQ,LLG,RAIN,RHOO, & ! I
                    ZA,DECLIN,COSZ,OMG,XLAT,DELT,ZNT,                 & ! I
                    CHS, CHS2,                                        & ! I
                    TR, TB, TG, TC, QC, UC,                           & ! H
                    TRL,TBL,TGL,                                      & ! H
                    XXXR, XXXB, XXXG, XXXC,                           & ! H
                    TS,QS,SH,LH,LH_KINEMATIC,                         & ! O
                    SW,ALB,LW,G,RN,PSIM,PSIH,                         & ! O
                    GZ1OZ0,                                           & ! O
                    U10,V10,TH2,Q2,UST                                & ! O
                    )

   IMPLICIT NONE

   REAL, PARAMETER    :: CP=0.24          ! heat capacity of dry air  [cgs unit]
   REAL, PARAMETER    :: EL=583.          ! latent heat of vaporation [cgs unit]
   REAL, PARAMETER    :: SIG=8.17E-11     ! stefun bolzman constant   [cgs unit]
   REAL, PARAMETER    :: SIG_SI=5.67E-8   !                           [MKS unit]
   REAL, PARAMETER    :: AK=0.4           ! kalman const.                [-]
   REAL, PARAMETER    :: PI=3.14159       ! pi                           [-]
   REAL, PARAMETER    :: TETENA=7.5       ! const. of Tetens Equation    [-]
   REAL, PARAMETER    :: TETENB=237.3     ! const. of Tetens Equation    [-]
   REAL, PARAMETER    :: SRATIO=0.75      ! ratio between direct/total solar [-]

   REAL, PARAMETER    :: CPP=1004.5       ! heat capacity of dry air    [J/K/kg]
   REAL, PARAMETER    :: ELL=2.442E+06    ! latent heat of vaporization [J/kg]
   REAL, PARAMETER    :: XKA=2.4E-5

!-------------------------------------------------------------------------------
! C: configuration variables
!-------------------------------------------------------------------------------

   LOGICAL, INTENT(IN) :: LSOLAR  ! logical    [true=both, false=SSG only]

!  The following variables are also model configuration variables, but are 
!  defined in the URBAN.TBL and in the contains statement in the top of 
!  the module_urban_init, so we should not declare them here.

  INTEGER, INTENT(IN) :: num_roof_layers
  INTEGER, INTENT(IN) :: num_wall_layers
  INTEGER, INTENT(IN) :: num_road_layers


  REAL, INTENT(IN), DIMENSION(1:num_roof_layers) :: DZR ! grid interval of roof layers [cm]
  REAL, INTENT(IN), DIMENSION(1:num_wall_layers) :: DZB ! grid interval of wall layers [cm]
  REAL, INTENT(IN), DIMENSION(1:num_road_layers) :: DZG ! grid interval of road layers [cm]

!-------------------------------------------------------------------------------
! I: input variables from LSM to Urban
!-------------------------------------------------------------------------------

   INTEGER, INTENT(IN) :: UTYPE ! urban type [urban=1, suburban=2, rural=3]

   REAL, INTENT(IN)    :: TA   ! potential temp at 1st atmospheric level [K]
   REAL, INTENT(IN)    :: QA   ! mixing ratio at 1st atmospheric level  [kg/kg]
   REAL, INTENT(IN)    :: UA   ! wind speed at 1st atmospheric level    [m/s]
   REAL, INTENT(IN)    :: U1   ! u at 1st atmospheric level             [m/s]
   REAL, INTENT(IN)    :: V1   ! v at 1st atmospheric level             [m/s]
   REAL, INTENT(IN)    :: SSG  ! downward total short wave radiation    [W/m/m]
   REAL, INTENT(IN)    :: LLG  ! downward long wave radiation           [W/m/m]
   REAL, INTENT(IN)    :: RAIN ! precipitation                          [mm/h]
   REAL, INTENT(IN)    :: RHOO ! air density                            [kg/m^3]
   REAL, INTENT(IN)    :: ZA   ! first atmospheric level                [m]
   REAL, INTENT(IN)    :: DECLIN ! solar declination                    [rad]
   REAL, INTENT(IN)    :: COSZ ! sin(fai)*sin(del)+cos(fai)*cos(del)*cos(omg)
   REAL, INTENT(IN)    :: OMG  ! solar hour angle                       [rad]

   REAL, INTENT(IN)    :: XLAT ! latitude                               [deg]
   REAL, INTENT(IN)    :: DELT ! time step                              [s]
   REAL, INTENT(IN)    :: ZNT  ! roughness length                       [m]
   REAL, INTENT(IN)    :: CHS,CHS2 ! CH*U at za and 2 m             [m/s]

   REAL, INTENT(INOUT) :: SSGD ! downward direct short wave radiation   [W/m/m]
   REAL, INTENT(INOUT) :: SSGQ ! downward diffuse short wave radiation  [W/m/m]

!-------------------------------------------------------------------------------
! O: output variables from Urban to LSM 
!-------------------------------------------------------------------------------

   REAL, INTENT(OUT) :: TS     ! surface potential temperature    [K]
   REAL, INTENT(OUT) :: QS     ! surface humidity                 [K]
   REAL, INTENT(OUT) :: SH     ! sensible heat flux               [W/m/m]
   REAL, INTENT(OUT) :: LH     ! latent heat flux                 [W/m/m]
   REAL, INTENT(OUT) :: LH_KINEMATIC ! latent heat, kinetic     [kg/m/m/s]
   REAL, INTENT(OUT) :: SW     ! upward short wave radiation flux [W/m/m]
   REAL, INTENT(OUT) :: ALB    ! time-varying albedo            [fraction]
   REAL, INTENT(OUT) :: LW     ! upward long wave radiation flux  [W/m/m]
   REAL, INTENT(OUT) :: G      ! heat flux into the ground        [W/m/m]
   REAL, INTENT(OUT) :: RN     ! net radition                     [W/m/m]
   REAL, INTENT(OUT) :: PSIM   ! similality stability shear function for momentum
   REAL, INTENT(OUT) :: PSIH   ! similality stability shear function for heat
   REAL, INTENT(OUT) :: GZ1OZ0   
   REAL, INTENT(OUT) :: U10    ! u at 10m                         [m/s]
   REAL, INTENT(OUT) :: V10    ! u at 10m                         [m/s]
   REAL, INTENT(OUT) :: TH2    ! potential temperature at 2 m     [K]
   REAL, INTENT(OUT) :: Q2     ! humidity at 2 m                  [-]
!m   REAL, INTENT(OUT) :: CHS,CHS2 ! CH*U at za and 2 m             [m/s]
   REAL, INTENT(OUT) :: UST    ! friction velocity                [m/s]


!-------------------------------------------------------------------------------
! H: Historical (state) variables of Urban : LSM <--> Urban
!-------------------------------------------------------------------------------

! TR: roof temperature              [K];      TRP: at previous time step [K]
! TB: building wall temperature     [K];      TBP: at previous time step [K]
! TG: road temperature              [K];      TGP: at previous time step [K]
! TC: urban-canopy air temperature  [K];      TCP: at previous time step [K]
!                                                  (absolute temperature)
! QC: urban-canopy air mixing ratio [kg/kg];  QCP: at previous time step [kg/kg]
!
! XXXR: Monin-Obkhov length for roof          [dimensionless]
! XXXB: Monin-Obkhov length for building wall [dimensionless]
! XXXG: Monin-Obkhov length for road          [dimensionless]
! XXXC: Monin-Obkhov length for urban-canopy  [dimensionless]
!
! TRL, TBL, TGL: layer temperature [K] (absolute temperature)

   REAL, INTENT(INOUT):: TR, TB, TG, TC, QC, UC
   REAL, INTENT(INOUT):: XXXR, XXXB, XXXG, XXXC

   REAL, DIMENSION(1:num_roof_layers), INTENT(INOUT) :: TRL
   REAL, DIMENSION(1:num_wall_layers), INTENT(INOUT) :: TBL
   REAL, DIMENSION(1:num_road_layers), INTENT(INOUT) :: TGL

!-------------------------------------------------------------------------------
! L:  Local variables from read_param
!-------------------------------------------------------------------------------

   REAL :: ZR, Z0C, Z0HC, ZDC, SVF, R, RW, HGT, CDS, AS, AH
   REAL :: CAPR, CAPB, CAPG, AKSR, AKSB, AKSG, ALBR, ALBB, ALBG 
   REAL :: EPSR, EPSB, EPSG, Z0R,  Z0B,  Z0G,  Z0HR, Z0HB, Z0HG
   REAL :: TRLEND,TBLEND,TGLEND
   
   REAL :: TH2X                                                !m
   
   INTEGER :: BOUNDR, BOUNDB, BOUNDG
   INTEGER :: CH_SCHEME, TS_SCHEME

   LOGICAL :: SHADOW  ! [true=consider svf and shadow effects, false=consider svf effect only]

!-------------------------------------------------------------------------------
! L: Local variables
!-------------------------------------------------------------------------------

   REAL :: BETR, BETB, BETG
   REAL :: SX, SD, SQ, RX
   REAL :: UR, ZC, XLB, BB
   REAL :: Z, RIBR, RIBB, RIBG, RIBC, BHR, BHB, BHG, BHC
   REAL :: TSC, LNET, SNET, FLXUV, THG, FLXTH, FLXHUM, FLXG
   REAL :: W, VFGS, VFGW, VFWG, VFWS, VFWW
   REAL :: HOUI1, HOUI2, HOUI3, HOUI4, HOUI5, HOUI6, HOUI7, HOUI8
   REAL :: SLX, SLX1, SLX2, SLX3, SLX4, SLX5, SLX6, SLX7, SLX8
   REAL :: FLXTHR, FLXTHB, FLXTHG, FLXHUMR, FLXHUMB, FLXHUMG
   REAL :: SR, SB, SG, RR, RB, RG
   REAL :: SR1, SR2, SB1, SB2, SG1, SG2, RR1, RR2, RB1, RB2, RG1, RG2
   REAL :: HR, HB, HG, ELER, ELEB, ELEG, G0R, G0B, G0G
   REAL :: ALPHAC, ALPHAR, ALPHAB, ALPHAG
   REAL :: CHC, CHR, CHB, CHG, CDC, CDR, CDB, CDG
   REAL :: C1R, C1B, C1G, TE, TC1, TC2, QC1, QC2, QS0R, QS0B, QS0G,RHO,ES

   REAL :: DESDT
   REAL :: F
   REAL :: DQS0RDTR
   REAL :: DRRDTR, DHRDTR, DELERDTR, DG0RDTR
   REAL :: DTR, DFDT
   REAL :: FX, FY, GF, GX, GY
   REAL :: DTCDTB, DTCDTG
   REAL :: DQCDTB, DQCDTG
   REAL :: DRBDTB1,  DRBDTG1,  DRBDTB2,  DRBDTG2
   REAL :: DRGDTB1,  DRGDTG1,  DRGDTB2,  DRGDTG2
   REAL :: DRBDTB,   DRBDTG,   DRGDTB,   DRGDTG
   REAL :: DHBDTB,   DHBDTG,   DHGDTB,   DHGDTG
   REAL :: DELEBDTB, DELEBDTG, DELEGDTG, DELEGDTB
   REAL :: DG0BDTB,  DG0BDTG,  DG0GDTG,  DG0GDTB
   REAL :: DQS0BDTB, DQS0GDTG
   REAL :: DTB, DTG, DTC

   REAL :: THEATAZ    ! Solar Zenith Angle [rad]
   REAL :: THEATAS    ! = PI/2. - THETAZ
   REAL :: FAI        ! Latitude [rad]
   REAL :: CNT,SNT
   REAL :: PS         ! Surface Pressure [hPa]
   REAL :: TAV        ! Vertial Temperature [K] 

   REAL :: XXX, X, Z0, Z0H, CD, CH
   REAL :: XXX2, PSIM2, PSIH2, XXX10, PSIM10, PSIH10
   REAL :: PSIX, PSIT, PSIX2, PSIT2, PSIX10, PSIT10

   REAL :: TRP, TBP, TGP, TCP, QCP, TST, QST

   INTEGER :: iteration, K 

!-------------------------------------------------------------------------------
! Set parameters
!-------------------------------------------------------------------------------

   CALL read_param(UTYPE,ZR,Z0C,Z0HC,ZDC,SVF,R,RW,HGT,CDS,AS,AH,  &
                   CAPR,CAPB,CAPG,AKSR,AKSB,AKSG,ALBR,ALBB,ALBG,  &
                   EPSR,EPSB,EPSG,Z0R,Z0B,Z0G,Z0HR,Z0HB,Z0HG,     &
                   BETR,BETB,BETG,TRLEND,TBLEND,TGLEND,           &
                   BOUNDR,BOUNDB,BOUNDG,CH_SCHEME,TS_SCHEME)

   IF( ZDC+Z0C+2. >= ZA) THEN
    PRINT *, 'ZDC + Z0C + 2m is larger than the 1st WRF level' 
    PRINT *, 'Stop in the subroutine urban - change ZDC and Z0C'
    STOP
   END IF

   IF(.NOT.LSOLAR) THEN
     SSGD = SRATIO*SSG
     SSGQ = SSG - SSGD
   ENDIF
   SSGD = SRATIO*SSG   ! No radiation scheme has SSGD and SSGQ.
   SSGQ = SSG - SSGD

   W=2.*1.*HGT
   VFGS=SVF
   VFGW=1.-SVF
   VFWG=(1.-SVF)*(1.-R)/W
   VFWS=VFWG
   VFWW=1.-2.*VFWG

!-------------------------------------------------------------------------------
! Convert unit from MKS to cgs
! Renew surface and layer temperatures
!-------------------------------------------------------------------------------

   SX=(SSGD+SSGQ)/697.7/60.  ! downward short wave radition [ly/min]
   SD=SSGD/697.7/60.         ! downward direct short wave radiation
   SQ=SSGQ/697.7/60.         ! downward diffiusion short wave radiation
   RX=LLG/697.7/60.          ! downward long wave radiation
   RHO=RHOO*0.001            ! air density at first atmospheric level

   TRP=TR
   TBP=TB
   TGP=TG
   TCP=TC
   QCP=QC

   TAV=TA*(1.+0.61*QA)
   PS=RHOO*287.*TAV/100. ![hPa]

!-------------------------------------------------------------------------------
! Canopy wind
!-------------------------------------------------------------------------------

   IF ( ZR + 2. < ZA ) THEN
     UR=UA*LOG((ZR-ZDC)/Z0C)/LOG((ZA-ZDC)/Z0C)
     ZC=0.7*ZR
!     ZC=0.5*ZR
     XLB=0.4*(ZR-ZDC)
     BB=ZR*(CDS*AS/(2.*XLB**2.))**(1./3.)
     UC=UR*EXP(-BB*(1.-ZC/ZR))
   ELSE
     print *,'ZR=',ZR, 'ZA=',ZA
     PRINT *, 'Warning ZR + 2m  is larger than the 1st WRF level' 
     ZC=ZA/2.
     UC=UA/2.
   END IF

!-------------------------------------------------------------------------------
! Net Short Wave Radiation at roof, wall, and road
!-------------------------------------------------------------------------------

   SHADOW = .false.
!   SHADOW = .true.

   IF (SSG > 0.0) THEN

     IF(.NOT.SHADOW) THEN              ! no shadow effects model

       SR1=SX*(1.-ALBR)
       SG1=SX*VFGS*(1.-ALBG)
       SB1=SX*VFWS*(1.-ALBB)
       SG2=SB1*ALBB/(1.-ALBB)*VFGW*(1.-ALBG)
       SB2=SG1*ALBG/(1.-ALBG)*VFWG*(1.-ALBB)

     ELSE                              ! shadow effects model

       FAI=XLAT*PI/180.

       THEATAS=ABS(ASIN(COSZ))
       THEATAZ=ABS(ACOS(COSZ))

       SNT=COS(DECLIN)*SIN(OMG)/COS(THEATAS)
       CNT=(COSZ*SIN(FAI)-SIN(DECLIN))/COS(THEATAS)/COS(FAI)

       HOUI1=(SNT*COS(PI/8.)    -CNT*SIN(PI/8.))
       HOUI2=(SNT*COS(2.*PI/8.) -CNT*SIN(2.*PI/8.))
       HOUI3=(SNT*COS(3.*PI/8.) -CNT*SIN(3.*PI/8.))
       HOUI4=(SNT*COS(4.*PI/8.) -CNT*SIN(4.*PI/8.))
       HOUI5=(SNT*COS(5.*PI/8.) -CNT*SIN(5.*PI/8.))
       HOUI6=(SNT*COS(6.*PI/8.) -CNT*SIN(6.*PI/8.))
       HOUI7=(SNT*COS(7.*PI/8.) -CNT*SIN(7.*PI/8.))
       HOUI8=(SNT*COS(8.*PI/8.) -CNT*SIN(8.*PI/8.))

       SLX1=HGT*ABS(TAN(THEATAZ))*ABS(HOUI1)
       SLX2=HGT*ABS(TAN(THEATAZ))*ABS(HOUI2)
       SLX3=HGT*ABS(TAN(THEATAZ))*ABS(HOUI3)
       SLX4=HGT*ABS(TAN(THEATAZ))*ABS(HOUI4)
       SLX5=HGT*ABS(TAN(THEATAZ))*ABS(HOUI5)
       SLX6=HGT*ABS(TAN(THEATAZ))*ABS(HOUI6)
       SLX7=HGT*ABS(TAN(THEATAZ))*ABS(HOUI7)
       SLX8=HGT*ABS(TAN(THEATAZ))*ABS(HOUI8)

       IF(SLX1 > RW) SLX1=RW
       IF(SLX2 > RW) SLX2=RW
       IF(SLX3 > RW) SLX3=RW
       IF(SLX4 > RW) SLX4=RW
       IF(SLX5 > RW) SLX5=RW
       IF(SLX6 > RW) SLX6=RW
       IF(SLX7 > RW) SLX7=RW
       IF(SLX8 > RW) SLX8=RW

       SLX=(SLX1+SLX2+SLX3+SLX4+SLX5+SLX6+SLX7+SLX8)/8.

     END IF

     SR=SR1
     SG=SG1+SG2
     SB=SB1+SB2

     SNET=R*SR+W*SB+RW*SG

   ELSE

     SR=0.
     SG=0.
     SB=0.
     SNET=0.

   END IF

!-------------------------------------------------------------------------------
! Roof
!-------------------------------------------------------------------------------

!-------------------------------------------------------------------------------
! CHR, CDR, BETR
!-------------------------------------------------------------------------------

   Z=ZA-ZDC
   BHR=LOG(Z0R/Z0HR)/0.4
   RIBR=(9.8*2./(TA+TRP))*(TA-TRP)*(Z+Z0R)/(UA*UA)

   CALL mos(XXXR,ALPHAR,CDR,BHR,RIBR,Z,Z0R,UA,TA,TRP,RHO)

   CHR=ALPHAR/RHO/CP/UA

   IF(RAIN > 1.) BETR=0.7  

   IF (TS_SCHEME == 1) THEN 

!-------------------------------------------------------------------------------
! TR  Solving Non-Linear Equation by Newton-Rapson
! TRL Solving Heat Equation by Tri Diagonal Matrix Algorithm  
!-------------------------------------------------------------------------------
!      TSC=TRP-273.15                          
!      ES=EXP(19.482-4303.4/(TSC+243.5))        ! WMO
!      ES=6.11*10.**(TETENA*TSC/(TETENB+TSC))   ! Tetens
!      DESDT=( 6.1078*(2500.-2.4*TSC)/ &        ! Tetens
!            (0.46151*(TSC+273.15)**2.) )*10.**(7.5*TSC/(237.3+TSC)) 
!      ES=6.11*EXP((2.5*10.**6./461.51)*(TRP-273.15)/(273.15*TRP) ) ! Clausius-Clapeyron 
!      DESDT=(2.5*10.**6./461.51)*ES/(TRP**2.)                      ! Clausius-Clapeyron
!      QS0R=0.622*ES/(PS-0.378*ES) 
!      DQS0RDTR = DESDT*0.622*PS/((PS-0.378*ES)**2.) 
!      DQS0RDTR = 17.269*(273.15-35.86)/((TRP-35.86)**2.)*QS0R

!    TRP=350.

     DO ITERATION=1,20

       ES=6.11*EXP( (2.5*10.**6./461.51)*(TRP-273.15)/(273.15*TRP) )
       DESDT=(2.5*10.**6./461.51)*ES/(TRP**2.)
       QS0R=0.622*ES/(PS-0.378*ES) 
       DQS0RDTR = DESDT*0.622*PS/((PS-0.378*ES)**2.) 

       RR=EPSR*(RX-SIG*(TRP**4.)/60.)
       HR=RHO*CP*CHR*UA*(TRP-TA)*100.
       ELER=RHO*EL*CHR*UA*BETR*(QS0R-QA)*100.
       G0R=AKSR*(TRP-TRL(1))/(DZR(1)/2.)

       F = SR + RR - HR - ELER - G0R

       DRRDTR = (-4.*EPSR*SIG*TRP**3.)/60.
       DHRDTR = RHO*CP*CHR*UA*100.
       DELERDTR = RHO*EL*CHR*UA*BETR*DQS0RDTR*100.
       DG0RDTR =  2.*AKSR/DZR(1)

       DFDT = DRRDTR - DHRDTR - DELERDTR - DG0RDTR 
       DTR = F/DFDT

       TR = TRP - DTR
       TRP = TR

       IF( ABS(F) < 0.000001 .AND. ABS(DTR) < 0.000001 ) EXIT

     END DO

! multi-layer heat equation model

     CALL multi_layer(num_roof_layers,BOUNDR,G0R,CAPR,AKSR,TRL,DZR,DELT,TRLEND)

   ELSE

     ES=6.11*EXP( (2.5*10.**6./461.51)*(TRP-273.15)/(273.15*TRP) )
     QS0R=0.622*ES/(PS-0.378*ES)        

     RR=EPSR*(RX-SIG*(TRP**4.)/60.)
     HR=RHO*CP*CHR*UA*(TRP-TA)*100.
     ELER=RHO*EL*CHR*UA*BETR*(QS0R-QA)*100.
     G0R=SR+RR-HR-ELER

     CALL force_restore(CAPR,AKSR,DELT,SR,RR,HR,ELER,TRLEND,TRP,TR)

     TRP=TR

   END IF

   FLXTHR=HR/RHO/CP/100.
   FLXHUMR=ELER/RHO/EL/100.

!-------------------------------------------------------------------------------
!  Wall and Road 
!-------------------------------------------------------------------------------

!-------------------------------------------------------------------------------
!  CHC, CHB, CDB, BETB, CHG, CDG, BETG
!-------------------------------------------------------------------------------

   Z=ZA-ZDC
   BHC=LOG(Z0C/Z0HC)/0.4
   RIBC=(9.8*2./(TA+TCP))*(TA-TCP)*(Z+Z0C)/(UA*UA)

   CALL mos(XXXC,ALPHAC,CDC,BHC,RIBC,Z,Z0C,UA,TA,TCP,RHO)

   IF (CH_SCHEME == 1) THEN 

     Z=ZDC
     BHB=LOG(Z0B/Z0HB)/0.4
     BHG=LOG(Z0G/Z0HG)/0.4
     RIBB=(9.8*2./(TCP+TBP))*(TCP-TBP)*(Z+Z0B)/(UC*UC)
     RIBG=(9.8*2./(TCP+TGP))*(TCP-TGP)*(Z+Z0G)/(UC*UC)

     CALL mos(XXXB,ALPHAB,CDB,BHB,RIBB,Z,Z0B,UC,TCP,TBP,RHO)
     CALL mos(XXXG,ALPHAG,CDG,BHG,RIBG,Z,Z0G,UC,TCP,TGP,RHO)

   ELSE

     ALPHAB=RHO*CP*(6.15+4.18*UC)/1200.
     IF(UC > 5.) ALPHAB=RHO*CP*(7.51*UC**0.78)/1200.
     ALPHAG=RHO*CP*(6.15+4.18*UC)/1200.
     IF(UC > 5.) ALPHAG=RHO*CP*(7.51*UC**0.78)/1200.

   END IF

   CHC=ALPHAC/RHO/CP/UA
   CHB=ALPHAB/RHO/CP/UC
   CHG=ALPHAG/RHO/CP/UC

   BETB=0.0
   IF(RAIN > 1.) BETG=0.7

   IF (TS_SCHEME == 1) THEN

!-------------------------------------------------------------------------------
!  TB, TG  Solving Non-Linear Simultaneous Equation by Newton-Rapson
!  TBL,TGL Solving Heat Equation by Tri Diagonal Matrix Algorithm  
!-------------------------------------------------------------------------------

!    TBP=350.
!    TGP=350.

     DO ITERATION=1,20

       ES=6.11*EXP( (2.5*10.**6./461.51)*(TBP-273.15)/(273.15*TBP) ) 
       DESDT=(2.5*10.**6./461.51)*ES/(TBP**2.)
       QS0B=0.622*ES/(PS-0.378*ES) 
       DQS0BDTB=DESDT*0.622*PS/((PS-0.378*ES)**2.)

       ES=6.11*EXP( (2.5*10.**6./461.51)*(TGP-273.15)/(273.15*TGP) ) 
       DESDT=(2.5*10.**6./461.51)*ES/(TGP**2.)
       QS0G=0.622*ES/(PS-0.378*ES)        
       DQS0GDTG=DESDT*0.22*PS/((PS-0.378*ES)**2.) 

       RG1=EPSG*( RX*VFGS          &
       +EPSB*VFGW*SIG*TBP**4./60.  &
       -SIG*TGP**4./60. )

       RB1=EPSB*( RX*VFWS         &
       +EPSG*VFWG*SIG*TGP**4./60. &
       +EPSB*VFWW*SIG*TBP**4./60. &
       -SIG*TBP**4./60. )

       RG2=EPSG*( (1.-EPSB)*(1.-SVF)*VFWS*RX                  &
       +(1.-EPSB)*(1.-SVF)*VFWG*EPSG*SIG*TGP**4./60.          &
       +EPSB*(1.-EPSB)*(1.-SVF)*(1.-2.*VFWS)*SIG*TBP**4./60. )

       RB2=EPSB*( (1.-EPSG)*VFWG*VFGS*RX                          &
       +(1.-EPSG)*EPSB*VFGW*VFWG*SIG*(TBP**4.)/60.                &
       +(1.-EPSB)*VFWS*(1.-2.*VFWS)*RX                            &
       +(1.-EPSB)*VFWG*(1.-2.*VFWS)*EPSG*SIG*EPSG*TGP**4./60.     &
       +EPSB*(1.-EPSB)*(1.-2.*VFWS)*(1.-2.*VFWS)*SIG*TBP**4./60. )

       RG=RG1+RG2
       RB=RB1+RB2

       DRBDTB1=EPSB*(4.*EPSB*SIG*TB**3.*VFWW-4.*SIG*TB**3.)/60.
       DRBDTG1=EPSB*(4.*EPSG*SIG*TG**3.*VFWG)/60.
       DRBDTB2=EPSB*(4.*(1.-EPSG)*EPSB*SIG*TB**3.*VFGW*VFWG &
               +4.*EPSB*(1.-EPSB)*SIG*TB**3.*VFWW*VFWW)/60.
       DRBDTG2=EPSB*(4.*(1.-EPSB)*EPSG*SIG*TG**3.*VFWG*VFWW)/60.

       DRGDTB1=EPSG*(4.*EPSB*SIG*TB**3.*VFGW)/60.
       DRGDTG1=EPSG*(-4.*SIG*TG**3.)/60.
       DRGDTB2=EPSG*(4.*EPSB*(1.-EPSB)*SIG*TB**3.*VFWW*VFGW)/60.
       DRGDTG2=EPSG*(4.*(1.-EPSB)*EPSG*SIG*TG**3.*VFWG*VFGW)/60.

       DRBDTB=DRBDTB1+DRBDTB2
       DRBDTG=DRBDTG1+DRBDTG2
       DRGDTB=DRGDTB1+DRGDTB2
       DRGDTG=DRGDTG1+DRGDTG2

       HB=RHO*CP*CHB*UC*(TBP-TCP)*100.
       HG=RHO*CP*CHG*UC*(TGP-TCP)*100.

       DTCDTB=W*ALPHAB/(RW*ALPHAC+RW*ALPHAG+W*ALPHAB)
       DTCDTG=RW*ALPHAG/(RW*ALPHAC+RW*ALPHAG+W*ALPHAB)

       DHBDTB=RHO*CP*CHB*UC*(1.-DTCDTB)*100.
       DHBDTG=RHO*CP*CHB*UC*(0.-DTCDTG)*100.
       DHGDTG=RHO*CP*CHG*UC*(1.-DTCDTG)*100.
       DHGDTB=RHO*CP*CHG*UC*(0.-DTCDTB)*100.

       ELEB=RHO*EL*CHB*UC*BETB*(QS0B-QCP)*100.
       ELEG=RHO*EL*CHG*UC*BETG*(QS0G-QCP)*100.

       DQCDTB=W*ALPHAB*BETB*DQS0BDTB/(RW*ALPHAC+RW*ALPHAG*BETG+W*ALPHAB*BETB)
       DQCDTG=RW*ALPHAG*BETG*DQS0GDTG/(RW*ALPHAC+RW*ALPHAG*BETG+W*ALPHAB*BETB)

       DELEBDTB=RHO*EL*CHB*UC*BETB*(DQS0BDTB-DQCDTB)*100.
       DELEBDTG=RHO*EL*CHB*UC*BETB*(0.-DQCDTG)*100.
       DELEGDTG=RHO*EL*CHG*UC*BETG*(DQS0GDTG-DQCDTG)*100.
       DELEGDTB=RHO*EL*CHG*UC*BETG*(0.-DQCDTB)*100.

       G0B=AKSB*(TBP-TBL(1))/(DZB(1)/2.)
       G0G=AKSG*(TGP-TGL(1))/(DZG(1)/2.)

       DG0BDTB=2.*AKSB/DZB(1)
       DG0BDTG=0.
       DG0GDTG=2.*AKSG/DZG(1)
       DG0GDTB=0.

       F = SB + RB - HB - ELEB - G0B
       FX = DRBDTB - DHBDTB - DELEBDTB - DG0BDTB 
       FY = DRBDTG - DHBDTG - DELEBDTG - DG0BDTG

       GF = SG + RG - HG - ELEG - G0G
       GX = DRGDTB - DHGDTB - DELEGDTB - DG0GDTB
       GY = DRGDTG - DHGDTG - DELEGDTG - DG0GDTG 

       DTB =  (GF*FY-F*GY)/(FX*GY-GX*FY)
       DTG = -(GF+GX*DTB)/GY

       TB = TBP + DTB
       TG = TGP + DTG

       TBP = TB
       TGP = TG

       TC1=RW*ALPHAC+RW*ALPHAG+W*ALPHAB
       TC2=RW*ALPHAC*TA+RW*ALPHAG*TGP+W*ALPHAB*TBP
       TC=TC2/TC1

       QC1=RW*ALPHAC+RW*ALPHAG*BETG+W*ALPHAB*BETB
       QC2=RW*ALPHAC*QA+RW*ALPHAG*BETG*QS0G+W*ALPHAB*BETB*QS0B
       QC=QC2/QC1

       DTC=TCP - TC
       TCP=TC
       QCP=QC

       IF( ABS(F) < 0.000001 .AND. ABS(DTB) < 0.000001 &
        .AND. ABS(GF) < 0.000001 .AND. ABS(DTG) < 0.000001 &
        .AND. ABS(DTC) < 0.000001) EXIT

     END DO

     CALL multi_layer(num_wall_layers,BOUNDB,G0B,CAPB,AKSB,TBL,DZB,DELT,TBLEND)

     CALL multi_layer(num_road_layers,BOUNDG,G0G,CAPG,AKSG,TGL,DZG,DELT,TGLEND)

   ELSE

!-------------------------------------------------------------------------------
!  TB, TG  by Force-Restore Method 
!-------------------------------------------------------------------------------

       ES=6.11*EXP((2.5*10.**6./461.51)*(TBP-273.15)/(273.15*TBP) )
       QS0B=0.622*ES/(PS-0.378*ES)       

       ES=6.11*EXP((2.5*10.**6./461.51)*(TGP-273.15)/(273.15*TGP) )
       QS0G=0.622*ES/(PS-0.378*ES)        

       RG1=EPSG*( RX*VFGS             &
       +EPSB*VFGW*SIG*TBP**4./60.     &
       -SIG*TGP**4./60. )

       RB1=EPSB*( RX*VFWS &
       +EPSG*VFWG*SIG*TGP**4./60. &
       +EPSB*VFWW*SIG*TBP**4./60. &
       -SIG*TBP**4./60. )

       RG2=EPSG*( (1.-EPSB)*(1.-SVF)*VFWS*RX                   &
       +(1.-EPSB)*(1.-SVF)*VFWG*EPSG*SIG*TGP**4./60.           &
       +EPSB*(1.-EPSB)*(1.-SVF)*(1.-2.*VFWS)*SIG*TBP**4./60. )

       RB2=EPSB*( (1.-EPSG)*VFWG*VFGS*RX                          &
       +(1.-EPSG)*EPSB*VFGW*VFWG*SIG*(TBP**4.)/60.                &
       +(1.-EPSB)*VFWS*(1.-2.*VFWS)*RX                            &
       +(1.-EPSB)*VFWG*(1.-2.*VFWS)*EPSG*SIG*EPSG*TGP**4./60.     &
       +EPSB*(1.-EPSB)*(1.-2.*VFWS)*(1.-2.*VFWS)*SIG*TBP**4./60. )

       RG=RG1+RG2
       RB=RB1+RB2

       HB=RHO*CP*CHB*UC*(TBP-TCP)*100.
       ELEB=RHO*EL*CHB*UC*BETB*(QS0B-QCP)*100.
       G0B=SB+RB-HB-ELEB

       HG=RHO*CP*CHG*UC*(TGP-TCP)*100.
       ELEG=RHO*EL*CHG*UC*BETG*(QS0G-QCP)*100.
       G0G=SG+RG-HG-ELEG

       CALL force_restore(CAPB,AKSB,DELT,SB,RB,HB,ELEB,TBLEND,TBP,TB)
       CALL force_restore(CAPG,AKSG,DELT,SG,RG,HG,ELEG,TGLEND,TGP,TG)

       TBP=TB
       TGP=TG

       TC1=RW*ALPHAC+RW*ALPHAG+W*ALPHAB
       TC2=RW*ALPHAC*TA+RW*ALPHAG*TGP+W*ALPHAB*TBP
       TC=TC2/TC1

       QC1=RW*ALPHAC+RW*ALPHAG*BETG+W*ALPHAB*BETB
       QC2=RW*ALPHAC*QA+RW*ALPHAG*BETG*QS0G+W*ALPHAB*BETB*QS0B
       QC=QC2/QC1

       TCP=TC
       QCP=QC

   END IF

   FLXTHB=HB/RHO/CP/100.
   FLXHUMB=ELEB/RHO/EL/100.
   FLXTHG=HG/RHO/CP/100.
   FLXHUMG=ELEG/RHO/EL/100.

!-------------------------------------------------------------------------------
! Total Fulxes from Urban Canopy
!-------------------------------------------------------------------------------

   FLXUV  = ( R*CDR + RW*CDC )*UA*UA
   FLXTH  = ( R*FLXTHR  + W*FLXTHB  + RW*FLXTHG )
   FLXHUM = ( R*FLXHUMR + W*FLXHUMB + RW*FLXHUMG )
   FLXG =   ( R*G0R + W*G0B + RW*G0G )
   LNET =     R*RR + W*RB + RW*RG

!----------------------------------------------------------------------------
! Convert Unit: FLUXES and u* T* q*  --> WRF
!----------------------------------------------------------------------------

   SH    = FLXTH  * RHOO * CPP    ! Sensible heat flux          [W/m/m]
   LH    = FLXHUM * RHOO * ELL    ! Latent heat flux            [W/m/m]
   LH_KINEMATIC = FLXHUM * RHOO   ! Latent heat, Kinematic      [kg/m/m/s]
   LW    = LLG - (LNET*697.7*60.) ! Upward longwave radiation   [W/m/m]
   SW    = SSG - (SNET*697.7*60.) ! Upward shortwave radiation  [W/m/m]
   ALB   = 0.
   IF( ABS(SSG) > 0.0001) ALB = SW/SSG ! Effective albedo [-] 
   G = -FLXG*697.7*60.            ! [W/m/m]
   RN = (SNET+LNET)*697.7*60.     ! Net radiation [W/m/m]

   UST = SQRT(FLXUV)              ! u* [m/s]
   TST = -FLXTH/UST               ! T* [K]
   QST = -FLXHUM/UST              ! q* [-]

!------------------------------------------------------
!  diagnostic GRID AVERAGED  PSIM  PSIH  TS QS --> WRF
!------------------------------------------------------

   Z0 = Z0C 
   Z0H = Z0HC
   Z = ZA - ZDC

   XXX = 0.4*9.81*Z*TST/TA/UST/UST

   IF ( XXX >= 1. ) XXX = 1.
   IF ( XXX <= -5. ) XXX = -5.

   IF ( XXX > 0 ) THEN
     PSIM = -5. * XXX
     PSIH = -5. * XXX
   ELSE
     X = (1.-16.*XXX)**0.25
     PSIM = 2.*ALOG((1.+X)/2.) + ALOG((1.+X*X)/2.) - 2.*ATAN(X) + PI/2.
     PSIH = 2.*ALOG((1.+X*X)/2.)
   END IF

   GZ1OZ0 = ALOG(Z/Z0)
   CD = 0.4**2./(ALOG(Z/Z0)-PSIM)**2.
!
!m   CH = 0.4**2./(ALOG(Z/Z0)-PSIM)/(ALOG(Z/Z0H)-PSIH)
!m   CHS = 0.4*UST/(ALOG(Z/Z0H)-PSIH)
!m   TS = TA + FLXTH/CH/UA    ! surface potential temp (flux temp)
!m   QS = QA + FLXHUM/CH/UA   ! surface humidity
!
   TS = TA + FLXTH/CHS    ! surface potential temp (flux temp)
   QS = QA + FLXHUM/CHS   ! surface humidity

!-------------------------------------------------------
!  diagnostic  GRID AVERAGED  U10  V10  TH2  Q2 --> WRF
!-------------------------------------------------------

   XXX2 = (2./Z)*XXX
   IF ( XXX2 >= 1. ) XXX2 = 1.
   IF ( XXX2 <= -5. ) XXX2 = -5.

   IF ( XXX2 > 0 ) THEN
      PSIM2 = -5. * XXX2
      PSIH2 = -5. * XXX2
   ELSE
      X = (1.-16.*XXX2)**0.25
      PSIM2 = 2.*ALOG((1.+X)/2.) + ALOG((1.+X*X)/2.) - 2.*ATAN(X) + 2.*ATAN(1.)
      PSIH2 = 2.*ALOG((1.+X*X)/2.)
   END IF
!
!m   CHS2 = 0.4*UST/(ALOG(2./Z0H)-PSIH2)
!

   XXX10 = (10./Z)*XXX
   IF ( XXX10 >= 1. ) XXX10 = 1.
   IF ( XXX10 <= -5. ) XXX10 = -5.

   IF ( XXX10 > 0 ) THEN
      PSIM10 = -5. * XXX10
      PSIH10 = -5. * XXX10
   ELSE
      X = (1.-16.*XXX10)**0.25
      PSIM10 = 2.*ALOG((1.+X)/2.) + ALOG((1.+X*X)/2.) - 2.*ATAN(X) + 2.*ATAN(1.)
      PSIH10 = 2.*ALOG((1.+X*X)/2.)
   END IF

   PSIX = ALOG(Z/Z0) - PSIM
   PSIT = ALOG(Z/Z0H) - PSIH

   PSIX2 = ALOG(2./Z0) - PSIM2
   PSIT2 = ALOG(2./Z0H) - PSIH2

   PSIX10 = ALOG(10./Z0) - PSIM10
   PSIT10 = ALOG(10./Z0H) - PSIH10

   U10 = U1 * (PSIX10/PSIX)       ! u at 10 m [m/s]
   V10 = V1 * (PSIX10/PSIX)       ! v at 10 m [m/s]

!   TH2 = TS + (TA-TS)*(PSIT2/PSIT)   ! potential temp at 2 m [K]
!  TH2 = TS + (TA-TS)*(PSIT2/PSIT)   ! Fei: this seems to be temp (not potential) at 2 m [K]
!Fei: consistant with M-O theory
   TH2 = TS + (TA-TS) *(CHS/CHS2) 

   Q2 = QS + (QA-QS)*(PSIT2/PSIT)    ! humidity at 2 m       [-]

!   TS = (LW/SIG_SI/0.88)**0.25       ! Radiative temperature [K]

   RETURN

   END SUBROUTINE urban
!===============================================================================
!
!  mos
!
!===============================================================================
   SUBROUTINE mos(XXX,ALPHA,CD,B1,RIB,Z,Z0,UA,TA,TSF,RHO)

!  XXX:   z/L (requires iteration by Newton-Rapson method)
!  B1:    Stanton number
!  PSIM:  = PSIX of LSM
!  PSIH:  = PSIT of LSM

   IMPLICIT NONE

   REAL, PARAMETER     :: CP=0.24
   REAL, INTENT(IN)    :: B1, Z, Z0, UA, TA, TSF, RHO
   REAL, INTENT(OUT)   :: ALPHA, CD
   REAL, INTENT(INOUT) :: XXX, RIB
   REAL                :: XXX0, X, X0, FAIH, DPSIM, DPSIH
   REAL                :: F, DF, XXXP, US, TS, AL, XKB, DD, PSIM, PSIH
   INTEGER             :: NEWT
   INTEGER, PARAMETER  :: NEWT_END=10

   IF(RIB <= -15.) RIB=-15. 

   IF(RIB < 0.) THEN

      DO NEWT=1,NEWT_END

        IF(XXX >= 0.) XXX=-1.E-3

        XXX0=XXX*Z0/(Z+Z0)

        X=(1.-16.*XXX)**0.25
        X0=(1.-16.*XXX0)**0.25

        PSIM=ALOG((Z+Z0)/Z0) &
            -ALOG((X+1.)**2.*(X**2.+1.)) &
            +2.*ATAN(X) &
            +ALOG((X+1.)**2.*(X0**2.+1.)) &
            -2.*ATAN(X0)
        FAIH=1./SQRT(1.-16.*XXX)
        PSIH=ALOG((Z+Z0)/Z0)+0.4*B1 &
            -2.*ALOG(SQRT(1.-16.*XXX)+1.) &
            +2.*ALOG(SQRT(1.-16.*XXX0)+1.)

        DPSIM=(1.-16.*XXX)**(-0.25)/XXX &
             -(1.-16.*XXX0)**(-0.25)/XXX
        DPSIH=1./SQRT(1.-16.*XXX)/XXX &
             -1./SQRT(1.-16.*XXX0)/XXX

        F=RIB*PSIM**2./PSIH-XXX

        DF=RIB*(2.*DPSIM*PSIM*PSIH-DPSIH*PSIM**2.) &
          /PSIH**2.-1.

        XXXP=XXX
        XXX=XXXP-F/DF
        IF(XXX <= -10.) XXX=-10.

      END DO

   ELSE IF(RIB >= 0.142857) THEN

      XXX=0.714
      PSIM=ALOG((Z+Z0)/Z0)+7.*XXX
      PSIH=PSIM+0.4*B1

   ELSE

      AL=ALOG((Z+Z0)/Z0)
      XKB=0.4*B1
      DD=-4.*RIB*7.*XKB*AL+(AL+XKB)**2.
      IF(DD <= 0.) DD=0.
      XXX=(AL+XKB-2.*RIB*7.*AL-SQRT(DD))/(2.*(RIB*7.**2-7.))
      PSIM=ALOG((Z+Z0)/Z0)+7.*MIN(XXX,0.714)
      PSIH=PSIM+0.4*B1

   END IF

   US=0.4*UA/PSIM             ! u*
   IF(US <= 0.01) US=0.01
   TS=0.4*(TA-TSF)/PSIH       ! T*

   CD=US*US/UA**2.            ! CD
   ALPHA=RHO*CP*0.4*US/PSIH   ! RHO*CP*CH*U

   RETURN 
   END SUBROUTINE mos
!===============================================================================
!
!  louis79
!
!===============================================================================
   SUBROUTINE louis79(ALPHA,CD,RIB,Z,Z0,UA,RHO)

   IMPLICIT NONE

   REAL, PARAMETER     :: CP=0.24
   REAL, INTENT(IN)    :: Z, Z0, UA, RHO
   REAL, INTENT(OUT)   :: ALPHA, CD
   REAL, INTENT(INOUT) :: RIB
   REAL                :: A2, XX, CH, CMB, CHB

   A2=(0.4/ALOG(Z/Z0))**2.

   IF(RIB <= -15.) RIB=-15.

   IF(RIB >= 0.0) THEN
      IF(RIB >= 0.142857) THEN 
         XX=0.714
      ELSE 
         XX=RIB*LOG(Z/Z0)/(1.-7.*RIB)
      END IF 
      CH=0.16/0.74/(LOG(Z/Z0)+7.*MIN(XX,0.714))**2.
      CD=0.16/(LOG(Z/Z0)+7.*MIN(XX,0.714))**2.
   ELSE 
      CMB=7.4*A2*9.4*SQRT(Z/Z0)
      CHB=5.3*A2*9.4*SQRT(Z/Z0)
      CH=A2/0.74*(1.-9.4*RIB/(1.+CHB*SQRT(-RIB)))
      CD=A2*(1.-9.4*RIB/(1.+CHB*SQRT(-RIB)))
   END IF

   ALPHA=RHO*CP*CH*UA

   RETURN 
   END SUBROUTINE louis79
!===============================================================================
!
!  louis82
!
!===============================================================================
   SUBROUTINE louis82(ALPHA,CD,RIB,Z,Z0,UA,RHO)

   IMPLICIT NONE

   REAL, PARAMETER     :: CP=0.24
   REAL, INTENT(IN)    :: Z, Z0, UA, RHO
   REAL, INTENT(OUT)   :: ALPHA, CD
   REAL, INTENT(INOUT) :: RIB 
   REAL                :: A2, FM, FH, CH, CHH 

   A2=(0.4/ALOG(Z/Z0))**2.

   IF(RIB <= -15.) RIB=-15.

   IF(RIB >= 0.0) THEN 
      FM=1./((1.+(2.*5.*RIB)/SQRT(1.+5.*RIB)))
      FH=1./(1.+(3.*5.*RIB)*SQRT(1.+5.*RIB))
      CH=A2*FH
      CD=A2*FM
   ELSE 
      CHH=5.*3.*5.*A2*SQRT(Z/Z0)
      FM=1.-(2.*5.*RIB)/(1.+3.*5.*5.*A2*SQRT(Z/Z0+1.)*(-RIB))
      FH=1.-(3.*5.*RIB)/(1.+CHH*SQRT(-RIB))
      CH=A2*FH
      CD=A2*FM
   END IF

   ALPHA=RHO*CP*CH*UA

   RETURN
   END SUBROUTINE louis82
!===============================================================================
!
!  multi_layer
!
!===============================================================================
   SUBROUTINE multi_layer(KM,BOUND,G0,CAP,AKS,TSL,DZ,DELT,TSLEND)

   IMPLICIT NONE

   REAL, INTENT(IN)                   :: G0, CAP, AKS, DELT,TSLEND

   INTEGER, INTENT(IN)                :: KM, BOUND

   REAL, DIMENSION(KM), INTENT(IN)    :: DZ

   REAL, DIMENSION(KM), INTENT(INOUT) :: TSL

   REAL, DIMENSION(KM)                :: A, B, C, D, X, P, Q

   REAL                               :: DZEND

   INTEGER                            :: K

   DZEND=DZ(KM)

   A(1) = 0.0

   B(1) = CAP*DZ(1)/DELT &
          +2.*AKS/(DZ(1)+DZ(2))
   C(1) = -2.*AKS/(DZ(1)+DZ(2))
   D(1) = CAP*DZ(1)/DELT*TSL(1) + G0

   DO K=2,KM-1
      A(K) = -2.*AKS/(DZ(K-1)+DZ(K))
      B(K) = CAP*DZ(K)/DELT + 2.*AKS/(DZ(K-1)+DZ(K)) + 2.*AKS/(DZ(K)+DZ(K+1)) 
      C(K) = -2.*AKS/(DZ(K)+DZ(K+1))
      D(K) = CAP*DZ(K)/DELT*TSL(K)
   END DO 

   IF(BOUND == 1) THEN                  ! Flux=0
      A(KM) = -2.*AKS/(DZ(KM-1)+DZ(KM))
      B(KM) = CAP*DZ(KM)/DELT + 2.*AKS/(DZ(KM-1)+DZ(KM))  
      C(KM) = 0.0
      D(KM) = CAP*DZ(KM)/DELT*TSL(KM)
   ELSE                                 ! T=constant
      A(KM) = -2.*AKS/(DZ(KM-1)+DZ(KM))
      B(KM) = CAP*DZ(KM)/DELT + 2.*AKS/(DZ(KM-1)+DZ(KM)) + 2.*AKS/(DZ(KM)+DZEND) 
      C(KM) = 0.0
      D(KM) = CAP*DZ(KM)/DELT*TSL(KM) + 2.*AKS*TSLEND/(DZ(KM)+DZEND)
   END IF 

   P(1) = -C(1)/B(1)
   Q(1) =  D(1)/B(1)

   DO K=2,KM
      P(K) = -C(K)/(A(K)*P(K-1)+B(K))
      Q(K) = (-A(K)*Q(K-1)+D(K))/(A(K)*P(K-1)+B(K))
   END DO 

   X(KM) = Q(KM)

   DO K=KM-1,1,-1
      X(K) = P(K)*X(K+1)+Q(K)
   END DO 

   DO K=1,KM
      TSL(K) = X(K)
   END DO 

   RETURN 
   END SUBROUTINE multi_layer
!===============================================================================
!
!  subroutine read_param
!
!===============================================================================
   SUBROUTINE read_param(UTYPE,                                        & ! in
                         ZR,Z0C,Z0HC,ZDC,SVF,R,RW,HGT,CDS,AS,AH,       & ! out
                         CAPR,CAPB,CAPG,AKSR,AKSB,AKSG,ALBR,ALBB,ALBG, & ! out
                         EPSR,EPSB,EPSG,Z0R,Z0B,Z0G,Z0HR,Z0HB,Z0HG,    & ! out
                         BETR,BETB,BETG,TRLEND,TBLEND,TGLEND,          & ! out
                         BOUNDR,BOUNDB,BOUNDG,CH_SCHEME,TS_SCHEME)       ! out

   INTEGER, INTENT(IN)  :: UTYPE 

   REAL, INTENT(OUT)    :: ZR,Z0C,Z0HC,ZDC,SVF,R,RW,HGT,CDS,AS,AH,       &
                           CAPR,CAPB,CAPG,AKSR,AKSB,AKSG,ALBR,ALBB,ALBG, &
                           EPSR,EPSB,EPSG,Z0R,Z0B,Z0G,Z0HR,Z0HB,Z0HG,    &
                           BETR,BETB,BETG,TRLEND,TBLEND,TGLEND

   INTEGER, INTENT(OUT) :: BOUNDR,BOUNDB,BOUNDG,CH_SCHEME,TS_SCHEME

   ZR =     ZR_TBL(UTYPE)
   Z0C=     Z0C_TBL(UTYPE)
   Z0HC=    Z0HC_TBL(UTYPE)
   ZDC=     ZDC_TBL(UTYPE)
   SVF=     SVF_TBL(UTYPE)
   R=       R_TBL(UTYPE)
   RW=      RW_TBL(UTYPE)
   HGT=     HGT_TBL(UTYPE)
   CDS=     CDS_TBL(UTYPE)
   AS=      AS_TBL(UTYPE)
   AH=      AH_TBL(UTYPE)
   BETR=    BETR_TBL(UTYPE)
   BETB=    BETB_TBL(UTYPE)
   BETG=    BETG_TBL(UTYPE)

!m   FRC_URB= FRC_URB_TBL(UTYPE)

   CAPR=    CAPR_DATA
   CAPB=    CAPB_DATA
   CAPG=    CAPG_DATA
   AKSR=    AKSR_DATA
   AKSB=    AKSB_DATA
   AKSG=    AKSG_DATA
   ALBR=    ALBR_DATA
   ALBB=    ALBB_DATA
   ALBG=    ALBG_DATA
   EPSR=    EPSR_DATA
   EPSB=    EPSB_DATA
   EPSG=    EPSG_DATA
   Z0R=     Z0R_DATA
   Z0B=     Z0B_DATA
   Z0G=     Z0G_DATA
   Z0HR=    Z0HR_DATA
   Z0HB=    Z0HB_DATA
   Z0HG=    Z0HG_DATA
   TRLEND=  TRLEND_DATA
   TBLEND=  TBLEND_DATA
   TGLEND=  TGLEND_DATA
   BOUNDR=  BOUNDR_DATA
   BOUNDB=  BOUNDB_DATA
   BOUNDG=  BOUNDG_DATA
   CH_SCHEME = CH_SCHEME_DATA
   TS_SCHEME = TS_SCHEME_DATA

   RETURN
   END SUBROUTINE read_param
!===============================================================================
!
! subroutine urban_param_init: Read parameters from urban_param.tbl
!
!===============================================================================
   SUBROUTINE urban_param_init(DZR,DZB,DZG,num_soil_layers &
                               )
!                              num_roof_layers,num_wall_layers,num_road_layers)

   IMPLICIT NONE

   INTEGER, INTENT(IN) :: num_soil_layers

!   REAL, DIMENSION(1:num_roof_layers), INTENT(INOUT) :: DZR
!   REAL, DIMENSION(1:num_wall_layers), INTENT(INOUT) :: DZB
!   REAL, DIMENSION(1:num_road_layers), INTENT(INOUT) :: DZG
   REAL, DIMENSION(1:num_soil_layers), INTENT(INOUT) :: DZR
   REAL, DIMENSION(1:num_soil_layers), INTENT(INOUT) :: DZB
   REAL, DIMENSION(1:num_soil_layers), INTENT(INOUT) :: DZG

   INTEGER :: INDEX, LC, K
   INTEGER :: IOSTATUS, ALLOCATE_STATUS
   INTEGER :: num_roof_layers
   INTEGER :: num_wall_layers
   INTEGER :: num_road_layers
   INTEGER :: dummy 
   REAL    :: DHGT, HGT, VFWS, VFGS

   OPEN (UNIT=11,                &
         FILE='urban_param.tbl', &
         ACCESS='SEQUENTIAL',    &
         STATUS='OLD',           &
         ACTION='READ',          &
         POSITION='REWIND',      &
         IOSTAT=IOSTATUS)

   IF (IOSTATUS > 0) STOP 'ERROR OPEN urban_param.tbl'

   READ(11,*)
   READ(11,'(A4)') LU_DATA_TYPE

   READ(11,*) ICATE
   ALLOCATE( ZR_TBL(ICATE), stat=allocate_status )
   if(allocate_status == 0) THEN
   ALLOCATE( Z0C_TBL(ICATE), stat=allocate_status )
    if(allocate_status /= 0) stop 'error allocate Z0C_TBL in urban_param_init'
   IF( .NOT. ALLOCATED( Z0HC_TBL ) ) &
   ALLOCATE( Z0HC_TBL(ICATE), stat=allocate_status ) 
    if(allocate_status /= 0) stop 'error allocate Z0HC_TBL in urban_param_init'
   IF( .NOT. ALLOCATED( ZDC_TBL ) ) &
   ALLOCATE( ZDC_TBL(ICATE), stat=allocate_status )
    if(allocate_status /= 0) stop 'error allocate ZDC_TBL in urban_param_init'
   IF( .NOT. ALLOCATED( SVF_TBL ) ) &
   ALLOCATE( SVF_TBL(ICATE), stat=allocate_status ) 
    if(allocate_status /= 0) stop 'error allocate SVF_TBL in urban_param_init'
   IF( .NOT. ALLOCATED( R_TBL ) ) &
   ALLOCATE( R_TBL(ICATE), stat=allocate_status )
    if(allocate_status /= 0) stop 'error allocate R_TBL in urban_param_init'
   IF( .NOT. ALLOCATED( RW_TBL ) ) &
   ALLOCATE( RW_TBL(ICATE), stat=allocate_status )
    if(allocate_status /= 0) stop 'error allocate RW_TBL in urban_param_init'
   IF( .NOT. ALLOCATED( HGT_TBL ) ) &
   ALLOCATE( HGT_TBL(ICATE), stat=allocate_status )
    if(allocate_status /= 0) stop 'error allocate HGT_TBL in urban_param_init'
   IF( .NOT. ALLOCATED( CDS_TBL ) ) &
   ALLOCATE( CDS_TBL(ICATE), stat=allocate_status )
    if(allocate_status /= 0) stop 'error allocate CDS_TBL in urban_param_init'
   IF( .NOT. ALLOCATED( AS_TBL ) ) &
   ALLOCATE( AS_TBL(ICATE), stat=allocate_status )
    if(allocate_status /= 0) stop 'error allocate AS_TBL in urban_param_init'
   IF( .NOT. ALLOCATED( AH_TBL ) ) &
   ALLOCATE( AH_TBL(ICATE), stat=allocate_status )
    if(allocate_status /= 0) stop 'error allocate AH_TBL in urban_param_init'
   IF( .NOT. ALLOCATED( BETR_TBL ) ) &
   ALLOCATE( BETR_TBL(ICATE), stat=allocate_status )
    if(allocate_status /= 0) stop 'error allocate BETR_TBL in urban_param_init'
   IF( .NOT. ALLOCATED( BETB_TBL ) ) &
   ALLOCATE( BETB_TBL(ICATE), stat=allocate_status )
    if(allocate_status /= 0) stop 'error allocate BETB_TBL in urban_param_init'
   IF( .NOT. ALLOCATED( BETG_TBL ) ) &
   ALLOCATE( BETG_TBL(ICATE), stat=allocate_status )
    if(allocate_status /= 0) stop 'error allocate BETG_TBL in urban_param_init'
   ALLOCATE( FRC_URB_TBL(ICATE), stat=allocate_status )
    if(allocate_status /= 0) stop 'error allocate FRC_URB_TBL in urban_param_init'

ENDIF

   DO LC = 1, ICATE
      READ(11,*) INDEX,        &
                 ZR_TBL(LC),   &
                 Z0C_TBL(LC),  &
                 Z0HC_TBL(LC), &
                 ZDC_TBL(LC),  &
                 SVF_TBL(LC),  &
                 R_TBL(LC),    &
                 RW_TBL(LC),   &
                 HGT_TBL(LC),  &
                 CDS_TBL(LC),  &
                 AS_TBL(LC),   &
                 AH_TBL(LC),   &
                 BETR_TBL(LC), &
                 BETB_TBL(LC), &
                 BETG_TBL(LC), &
                 FRC_URB_TBL(LC)  
   END DO

   READ(11,*)
   READ(11,*) CAPR_DATA
   READ(11,*)
   READ(11,*) CAPB_DATA
   READ(11,*)
   READ(11,*) CAPG_DATA
   READ(11,*)
   READ(11,*) AKSR_DATA
   READ(11,*)
   READ(11,*) AKSB_DATA
   READ(11,*)
   READ(11,*) AKSG_DATA
   READ(11,*)
   READ(11,*) ALBR_DATA
   READ(11,*)
   READ(11,*) ALBB_DATA
   READ(11,*)
   READ(11,*) ALBG_DATA
   READ(11,*)
   READ(11,*) EPSR_DATA
   READ(11,*)
   READ(11,*) EPSB_DATA
   READ(11,*)
   READ(11,*) EPSG_DATA
   READ(11,*)
   READ(11,*) Z0R_DATA
   READ(11,*)
   READ(11,*) Z0B_DATA
   READ(11,*)
   READ(11,*) Z0G_DATA
   READ(11,*)
   READ(11,*) Z0HR_DATA
   READ(11,*)
   READ(11,*) Z0HB_DATA
   READ(11,*)
   READ(11,*) Z0HG_DATA
   READ(11,*)
!   READ(11,*) num_roof_layers
   READ(11,*) dummy 
   READ(11,*)
!   READ(11,*) num_wall_layers
   READ(11,*) dummy 
   READ(11,*)
!   READ(11,*) num_road_layers
   READ(11,*) dummy 

   num_roof_layers = num_soil_layers
   num_wall_layers = num_soil_layers
   num_road_layers = num_soil_layers

   DO K=1,num_roof_layers
      READ(11,*)
      READ(11,*) DZR(K)
   END DO

   DO K=1,num_wall_layers
      READ(11,*)
      READ(11,*) DZB(K)
   END DO

   DO K=1,num_road_layers
      READ(11,*)
      READ(11,*) DZG(K)
   END DO

   READ(11,*)
   READ(11,*) BOUNDR_DATA
   READ(11,*)
   READ(11,*) BOUNDB_DATA
   READ(11,*)
   READ(11,*) BOUNDG_DATA
   READ(11,*)
   READ(11,*) TRLEND_DATA
   READ(11,*)
   READ(11,*) TBLEND_DATA
   READ(11,*)
   READ(11,*) TGLEND_DATA
   READ(11,*)
   READ(11,*) CH_SCHEME_DATA
   READ(11,*)
   READ(11,*) TS_SCHEME_DATA

   CLOSE(11)

! Calculate Sky View Factor

   DO LC = 1, ICATE
      DHGT=HGT_TBL(LC)/100.
      HGT=0.
      VFWS=0.
      HGT=HGT_TBL(LC)-DHGT/2.
      do k=1,99
         HGT=HGT-DHGT
         VFWS=VFWS+0.25*(1.-HGT/SQRT(HGT**2.+RW_TBL(LC)**2.))
      end do

     VFWS=VFWS/99.
     VFWS=VFWS*2.

     VFGS=1.-2.*VFWS*HGT_TBL(LC)/RW_TBL(LC)
     SVF_TBL(LC)=VFGS
   END DO

   END SUBROUTINE urban_param_init
!===========================================================================
!
! subroutine urban_var_init: initialization of urban state variables
!
!===========================================================================
   SUBROUTINE urban_var_init(TSURFACE0_URB,TLAYER0_URB,TDEEP0_URB,IVGTYP,     & ! in
                             ims,ime,jms,jme,num_soil_layers,                 & ! in
!                             num_roof_layers,num_wall_layers,num_road_layers, & ! in
                             XXXR_URB2D,XXXB_URB2D,XXXG_URB2D,XXXC_URB2D,  & ! inout
                             TR_URB2D,TB_URB2D,TG_URB2D,TC_URB2D,QC_URB2D, & ! inout
                             TRL_URB3D,TBL_URB3D,TGL_URB3D,                & ! inout
                             SH_URB2D,LH_URB2D,G_URB2D,RN_URB2D,           & ! inout
                             TS_URB2D, FRC_URB2D, UTYPE_URB2D)               ! inout
   IMPLICIT NONE

   INTEGER, INTENT(IN) :: ims,ime,jms,jme,num_soil_layers
!   INTEGER, INTENT(IN) :: num_roof_layers, num_wall_layers, num_road_layers

   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(IN)                    :: TSURFACE0_URB
   REAL, DIMENSION( ims:ime, 1:num_soil_layers, jms:jme ), INTENT(IN) :: TLAYER0_URB
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(IN)                    :: TDEEP0_URB
   INTEGER, DIMENSION( ims:ime, jms:jme ), INTENT(IN)                 :: IVGTYP
 
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: TR_URB2D
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: TB_URB2D
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: TG_URB2D
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: TC_URB2D
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: QC_URB2D
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: XXXR_URB2D
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: XXXB_URB2D
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: XXXG_URB2D
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: XXXC_URB2D

!   REAL, DIMENSION(ims:ime, 1:num_roof_layers, jms:jme), INTENT(INOUT) :: TRL_URB3D
!   REAL, DIMENSION(ims:ime, 1:num_wall_layers, jms:jme), INTENT(INOUT) :: TBL_URB3D
!   REAL, DIMENSION(ims:ime, 1:num_road_layers, jms:jme), INTENT(INOUT) :: TGL_URB3D
   REAL, DIMENSION(ims:ime, 1:num_soil_layers, jms:jme), INTENT(INOUT) :: TRL_URB3D
   REAL, DIMENSION(ims:ime, 1:num_soil_layers, jms:jme), INTENT(INOUT) :: TBL_URB3D
   REAL, DIMENSION(ims:ime, 1:num_soil_layers, jms:jme), INTENT(INOUT) :: TGL_URB3D

   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: SH_URB2D
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: LH_URB2D
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: G_URB2D
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: RN_URB2D
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: TS_URB2D
!
   REAL, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: FRC_URB2D
   INTEGER, DIMENSION( ims:ime, jms:jme ), INTENT(INOUT) :: UTYPE_URB2D
   INTEGER                                            :: UTYPE_URB

   INTEGER :: I,J,K

   DO I=ims,ime
    DO J=jms,jme

      XXXR_URB2D(I,J)=0.
      XXXB_URB2D(I,J)=0.
      XXXG_URB2D(I,J)=0.
      XXXC_URB2D(I,J)=0.

      SH_URB2D(I,J)=0.
      LH_URB2D(I,J)=0.
      G_URB2D(I,J)=0.
      RN_URB2D(I,J)=0.
!m
      FRC_URB2D(I,J)=0.
      UTYPE_URB2D(I,J)=0.

            IF( IVGTYP(I,J) == 1)  THEN
               UTYPE_URB2D(I,J) = 2  ! for default. high-density
               UTYPE_URB = UTYPE_URB2D(I,J)  ! for default. high-density
               FRC_URB2D(I,J) = FRC_URB_TBL(UTYPE_URB)
            ENDIF
            IF( IVGTYP(I,J) == 31) THEN
               UTYPE_URB2D(I,J) = 3  ! low-density residential
               UTYPE_URB = UTYPE_URB2D(I,J)  ! low-density residential
               FRC_URB2D(I,J) = FRC_URB_TBL(UTYPE_URB) 
            ENDIF
            IF( IVGTYP(I,J) == 32) THEN
               UTYPE_URB2D(I,J) = 2  ! high-density
               UTYPE_URB = UTYPE_URB2D(I,J)  ! high-density
               FRC_URB2D(I,J) = FRC_URB_TBL(UTYPE_URB) 
            ENDIF
            IF( IVGTYP(I,J) == 33) THEN
               UTYPE_URB2D(I,J) = 1  !  Commercial/Industrial/Transportation
               UTYPE_URB = UTYPE_URB2D(I,J)  !  Commercial/Industrial/Transportation
               FRC_URB2D(I,J) = FRC_URB_TBL(UTYPE_URB) 
            ENDIF


      QC_URB2D(I,J)=0.01

      TC_URB2D(I,J)=TSURFACE0_URB(I,J)+0.
      TR_URB2D(I,J)=TSURFACE0_URB(I,J)+0.
      TB_URB2D(I,J)=TSURFACE0_URB(I,J)+0.
      TG_URB2D(I,J)=TSURFACE0_URB(I,J)+0.
!
      TS_URB2D(I,J)=TSURFACE0_URB(I,J)+0.

!      DO K=1,num_roof_layers
!     DO K=1,num_soil_layers
!         TRL_URB3D(I,1,J)=TLAYER0_URB(I,1,J)+0.
!         TRL_URB3D(I,2,J)=TLAYER0_URB(I,2,J)+0.
!         TRL_URB3D(I,3,J)=TLAYER0_URB(I,3,J)+0.
!         TRL_URB3D(I,4,J)=TLAYER0_URB(I,4,J)+0.

          TRL_URB3D(I,1,J)=TLAYER0_URB(I,1,J)+0.
          TRL_URB3D(I,2,J)=0.5*(TLAYER0_URB(I,1,J)+TLAYER0_URB(I,2,J))
          TRL_URB3D(I,3,J)=TLAYER0_URB(I,2,J)+0.
          TRL_URB3D(I,4,J)=TLAYER0_URB(I,2,J)+(TLAYER0_URB(I,3,J)-TLAYER0_URB(I,2,J))*0.29
!     END DO

!      DO K=1,num_wall_layers
!      DO K=1,num_soil_layers
!m        TBL_URB3D(I,1,J)=TLAYER0_URB(I,1,J)+0.
!m        TBL_URB3D(I,2,J)=TLAYER0_URB(I,2,J)+0.
!m        TBL_URB3D(I,3,J)=TLAYER0_URB(I,3,J)+0.
!m        TBL_URB3D(I,4,J)=TLAYER0_URB(I,4,J)+0.

        TBL_URB3D(I,1,J)=TLAYER0_URB(I,1,J)+0.
        TBL_URB3D(I,2,J)=0.5*(TLAYER0_URB(I,1,J)+TLAYER0_URB(I,2,J))
        TBL_URB3D(I,3,J)=TLAYER0_URB(I,2,J)+0.
        TBL_URB3D(I,4,J)=TLAYER0_URB(I,2,J)+(TLAYER0_URB(I,3,J)-TLAYER0_URB(I,2,J))*0.29
!      END DO

!      DO K=1,num_road_layers
      DO K=1,num_soil_layers
        TGL_URB3D(I,K,J)=TLAYER0_URB(I,K,J)+0.
      END DO

    END DO
   END DO

   RETURN
   END SUBROUTINE urban_var_init
!===========================================================================
!
!  force_restore
!
!===========================================================================
   SUBROUTINE force_restore(CAP,AKS,DELT,S,R,H,LE,TSLEND,TSP,TS)

     REAL, INTENT(IN)  :: CAP,AKS,DELT,S,R,H,LE,TSLEND,TSP
     REAL, INTENT(OUT) :: TS
     REAL              :: C1,C2

     C2=24.*3600./2./3.14159
     C1=SQRT(0.5*C2*CAP*AKS)

     TS = TSP + DELT*( (S+R-H-LE)/C1 -(TSP-TSLEND)/C2 )

   END SUBROUTINE force_restore
!===========================================================================
!
!  bisection (not used)
!
!============================================================================== 
   SUBROUTINE bisection(TSP,PS,S,EPS,RX,SIG,RHO,CP,CH,UA,QA,TA,EL,BET,AKS,TSL,DZ,TS) 

     REAL, INTENT(IN) :: TSP,PS,S,EPS,RX,SIG,RHO,CP,CH,UA,QA,TA,EL,BET,AKS,TSL,DZ
     REAL, INTENT(OUT) :: TS
     REAL :: ES,QS0,R,H,ELE,G0,F1,F

     TS1 = TSP - 5.
     TS2 = TSP + 5.

     DO ITERATION = 1,22

       ES=6.11*EXP( (2.5*10.**6./461.51)*(TS1-273.15)/(273.15*TS1) )
       QS0=0.622*ES/(PS-0.378*ES)
       R=EPS*(RX-SIG*(TS1**4.)/60.)
       H=RHO*CP*CH*UA*(TS1-TA)*100.
       ELE=RHO*EL*CH*UA*BET*(QS0-QA)*100.
       G0=AKS*(TS1-TSL)/(DZ/2.)
       F1= S + R - H - ELE - G0

       TS=0.5*(TS1+TS2)

       ES=6.11*EXP( (2.5*10.**6./461.51)*(TS-273.15)/(273.15*TS) )
       QS0=0.622*ES/(PS-0.378*ES) 
       R=EPS*(RX-SIG*(TS**4.)/60.)
       H=RHO*CP*CH*UA*(TS-TA)*100.
       ELE=RHO*EL*CH*UA*BET*(QS0-QA)*100.
       G0=AKS*(TS-TSL)/(DZ/2.)
       F = S + R - H - ELE - G0

       IF (F1*F > 0.0) THEN
         TS1=TS
        ELSE
         TS2=TS
       END IF

     END DO

     RETURN
END SUBROUTINE bisection
!===========================================================================
END MODULE MODULE_SF_URBAN
