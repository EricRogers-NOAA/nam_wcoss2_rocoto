C      SUBROUTINE PROF(NHB,LRSTRT,ITAG,LCLAS1)
C      SUBROUTINE PROF(ITAG,LCLAS1)
      SUBROUTINE PROF_EM(filename,startdate,ITAG,INCR)
C
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .
C   SUBROUTINE:  PROF        PROFILE SOUNDINGS
C   PRGRMMR: BLACK           ORG: W/NP22     DATE: 99-04-22
C
C ABSTRACT:  THIS ROUTINE GENERATES THE RAW PROFILE SOUNDING
C            OUTPUT FILES FROM THE FORECAST RESTRT FILE AND
C            AUXILIARY FILES
C
C PROGRAM HISTORY LOG:
C   99-04-22  T BLACK - ORIGINATOR
C   02-07-01  G MANIKIN - FIXED PROBLEM WITH DHCNVC AND DHRAIN
C                          COMPUTATIONS - SEE COMMENTS BELOW
C   03-04-01  M PYLE - BEGAN CONVERTING FOR WRF
C   07-06-25  M PYLE - CONVERTED TO USE MPI-IO FOR BINARY READS
C
C USAGE:  CALL PROF FROM PROGRAM POST0
C
C   INPUT ARGUMENT LIST:
C     NHB    - THE UNIT NUMBER FOR READING THE NHB FILE
C     LRSTRT - THE UNIT NUMBER FOR READING THE RESTRT FILE
C     ITAG   - THE FORECAST HOUR WE ARE DEALING WITH
C     LCLAS1 - THE UNIT NUMBER FOR WRITING THE PROFILE DATA
C
C   OUTPUT ARGUMENT LIST:
C     NONE
C
C   SUBPROGRAMS CALLED:
C     UNIQUE:
C
C-----------------------------------------------------------------------
c      use vrbls3d
c      use vrbls2d
c      use soil
c      use masks
       use kinds, only             : i_llong
C
      include 'wrf_io_flags.h'
      include 'mpif.h'

      INCLUDE "parmsoil"
C-----------------------------------------------------------------------
                             P A R A M E T E R
     & (NSTAT=1400,LCL1ML=15,LCL1SL=52)


!       NWORDM=(LCL1ML+1)*LM+2*LCL1SL
!     &, LRECPR=4*(8+9+LCL1ML*LM+LCL1SL))

C-----------------------------------------------------------------------
C
C    PARMS FOR HOURLY PROFILER OUTPUT
C      NSTAT - MAX NUMBER OF STATIONS
C      NWORDM - DIMENSION OF OUTPUT ARRAY, MUST BE LARGE ENOUGH
C          TO HOLD ALL VARIABLES
C          (MAX NO MULTI-LAYER VARIABLES*LM + NO OF SINGLE LAYER VARS)
C      LCL1ML - NUMBER OF MULTI-LAYER VARIABLES OUTPUT FOR CLASS 1
C      LCL1SL - NUMBER OF SINGLE LAYER VARIABLES OUTPUT FOR CLASS 1
C
C------------------------------------------------------------------------
                             P A R A M E T E R
     & (ITB=76,JTB=134)
                             P A R A M E T E R
     & (A2=17.2693882,A3=273.16,A4=35.86,PQ0=379.90516,DTR=1.74532925E-2
     &, G=9.81,GI=1./G,RD=287.04,CP=1004.6,CAPA=RD/CP,RHCRIT=0.9999)
C
      PARAMETER (GAMMA=6.5/1000.,ZSL=0.0,D608=0.608)
      PARAMETER (TAUCR=RD*GI*290.66,CONST=0.005*G/RD)
C

C------------------------------------------------------------------------
!                             R E A L
!     & DETA(LM),RDETA(LM),AETA(LM),UL(2*LM)
C

       REAL, ALLOCATABLE:: 
     & RES(:),FIS(:),HBOT(:)
     &,CFRACL(:),CFRACM(:),CFRACH(:),SNO(:)
     &,SOILTB(:),SFCEXC(:),SMSTAV(:),SMSTOT(:)
     &,Z0(:),CZEN(:),CZMEAN(:),U00(:),SR(:)
     &,ACPREC(:),CUPREC(:),ACSNOW(:),ACSNOM(:)
     &,SSROFF(:),BGROFF(:),SFCSHX(:),SFCLHX(:)
     &,SUBSHX(:),SNOPCX(:),ASWIN(:),ASWOUT(:)
     &,ASWTOA(:),ALWIN(:),ALWOUT(:),ALWTOA(:)
     &,TSHLTR(:),QSHLTR(:),TH2_hold(:)
     &,TH10(:),Q10(:),U10(:),V10(:)
     &,TLMIN(:),TLMAX(:)
     &,SMC(:,:),CMC(:),STC(:,:),SH2O(:,:)
     &,VEGFRC(:),POTFLX(:),PSLP(:),PDSL1(:)
     &,EGRID2(:),SM(:),SICE(:)
     &,HBM2(:),FACTR(:)
     &,PTBL(:,:),TTBL(:,:)
     &,STATPR(:),STACPR(:),STAEVP(:)
     &,STAPOT(:),STASHX(:),STASUB(:),STAPCX(:)
     &,STASWI(:),STASWO(:),STALWI(:),STALWO(:)
     &,STALWT(:),STASWT(:),STASNM(:),STASRF(:)
     &,STABRF(:),STASNO(:)
     &,ACPREC0(:),CUPREC0(:),SFCLHX0(:),POTFLX0(:)
     &,SFCSHX0(:),SUBSHX0(:),SNOPCX0(:),ASWIN0(:)
     &,ASWOUT0(:),ALWIN0(:),ALWOUT0(:),ALWTOA0(:)
     &,ASWTOA0(:),ACSNOW0(:),ACSNOM0(:),SSROFF0(:)
     &,BGROFF0(:)

C

      REAL, ALLOCATABLE:: T(:,:),Q(:,:),U(:,:),V(:,:),Q2(:,:)
     &,                   OMGALF(:,:),CWM(:,:),TRAIN(:,:),TCUCN(:,:)
     &,F_RAIN(:,:),F_ICE(:,:),CLDFRA(:,:)
     &,F_RIMEF(:,:)
     &,                   RSWTT(:,:),RLWTT(:,:),CCR(:,:),RTOP(:,:)
     &,                   HTM(:,:),OMGA(:,:),p_hold(:,:),t_hold(:,:)
     &,                   PINT(:,:),UL(:),PVAPOR(:),ZINT(:,:)
C  

      REAL, ALLOCATABLE:: DHCNVC(:,:),DHRAIN(:,:),STADHC(:),STADHR(:),
     &                      TCUCN0(:,:),TRAIN0(:,:),CPRATE(:)

      REAL,ALLOCATABLE:: DUM(:,:,:),DUMMY(:,:),DUMMY2(:,:),
     &  DUM3D(:,:,:),DUM3D2(:,:,:),DUM3D3(:,:,:),GDLAT(:,:),GDLON(:,:),
     &  DUM3D_U(:,:,:),DUM3D_V(:,:,:),DUM3D_SOIL(:,:,:)

      REAL, ALLOCATABLE:: PRODAT(:),FPACK(:)

      INTEGER, ALLOCATABLE:: IDUM(:,:),LMH(:,:),IW(:,:)

!                             R E A L
!     & pint_part(NSTAT),PDS(NSTAT)

	
	REAL:: STNLAT(NSTAT),STNLON(NSTAT)


       REAL, ALLOCATABLE :: PMID(:,:), W(:,:), WH(:,:),
     &                      pint_part(:),PDS(:)

	
	real, allocatable:: CROT(:),SROT(:)
C------------------------------------------------------------------------
                             I N T E G E R
     & IDSTN(NSTAT),IHINDX(NSTAT),JHINDX(NSTAT)
     &,             IVINDX(NSTAT),JVINDX(NSTAT),IDAT(3)
	INTEGER:: GDS(200)
C------------------------------------------------------------------------
                             L O G I C A L
     & RUN,RESTRT,FRST,PRINT_DIAG
C------------------------------------------------------------------------
                             C H A R A C T E R
     & RSTFIL*90,RESTHR*4,LABEL*32,CISTAT*8,CIDSTN(NSTAT)*8
     &,FNAME*90,ENVAR*90,BLANK*4

	CHARACTER(LEN=8), ALLOCATABLE :: CIDSTN_SAVE(:)

C	new stuff
      character(len=31) :: VarName,varin
	character(len=90) :: fileName
	character(len=90) :: fileNamehold
      integer :: Status, DataHandle, hor_size, hor_size_u, hor_size_v
      character(len=19):: startdate,datestr,datestrold

	real:: rinc(5)
	integer:: IDATE(8),JDATE(8),IDATENEW(8)

      character*132, allocatable :: datestr_all(:)
      character*132, allocatable :: varname_all(:)
      integer, allocatable       :: domainend_all(:,:)
      integer, allocatable       :: start_block(:)
      integer, allocatable       :: end_block(:)
      integer, allocatable       :: start_byte(:)
      integer, allocatable       :: end_byte(:)
      integer(kind=i_llong), allocatable           :: file_offset(:)
      integer this_offset, this_length

C------------------------------------------------------------------------
      DATA BLANK/'    '/
C------------------------------------------------------------------------
C***
C***  READ IN THE INFORMATION FILE ABOUT THE SOUNDINGS
C***

	write(6,*) 'filename= ', filename
	write(6,*) 'startedate= ', startdate

	datestr=startdate

      REWIND 19
C
      READ(19)NUMSTA,IDSTN,STNLAT,STNLON
     1,       IHINDX,JHINDX,IVINDX,JVINDX,CIDSTN
	
	write(6,*) 'STNLAT(1), STNLON(1): ', STNLAT(1), STNLON(1)
	write(6,*) 'IHINDX(1),JHINDX(1): ', IHINDX(1),JHINDX(1)
	write(6,*) 'IVINDX(1),JVINDX(1): ', IVINDX(1),JVINDX(1)
      WRITE(6,20)NUMSTA
   20 FORMAT('INIT:  NUMBER OF PROFILE STATIONS ',I5)

!mp
	allocate(CIDSTN_SAVE(NUMSTA))
	DO N=1,NUMSTA
	CIDSTN_SAVE(N)=CIDSTN(N)
	ENDDO

!mp

	if (ITAG .eq. 0) then
      WRITE(6,30)(IDSTN(N),STNLAT(N)/DTR,STNLON(N)/DTR
     1,               IHINDX(N),JHINDX(N),IVINDX(N),JVINDX(N)
     2,               CIDSTN(N),N=1,NUMSTA)
	else
      WRITE(6,30)(IDSTN(N),STNLAT(N)/DTR,STNLON(N)/DTR
     1,               IHINDX(N),JHINDX(N),IVINDX(N),JVINDX(N)
     2,               CIDSTN_SAVE(N),N=1,NUMSTA,20)

	endif
   30 FORMAT(2X,I6,2F8.2,4I8,4X,A8)

c	if (ITAG .eq. 0) then
	  FRST=.TRUE.
c	else 
c	  FRST=.FALSE.
c	endif


!--------------------------------------------------------------------
!--------------------------------------------------------------------
!--------------------------------------------------------------------

       if ( frst ) then
         frst = .false.
         CALL ext_int_ioinit(Status)
          print*,'CALLed ioinit', Status
	write(6,*) 'filename early in PROF= ', filename
         CALL ext_int_open_for_read( trim(fileName), 0, 0, " ",
     &  DataHandle, Status)
          print*,'CALLed open for read', Status
       else
           Status = 0
       endif
       if ( Status /= 0 ) then
         print*,'error opening ',fileName, ' Status = ', Status ; stop
       endif

C Getting start time
      CALL ext_int_get_dom_ti_char(DataHandle
     1 ,'START_DATE',startdate, status )
        print*,'startdate= ',startdate

      jdate=0
      idate=0
      read(startdate,15)iyear,imn,iday,ihrst
         IDATE(2)=imn
         IDATE(3)=iday
         IDATE(1)=iyear
         IDATE(5)=ihrst

 15   format(i4,1x,i2,1x,i2,1x,i2)
      print*,'start yr mo day hr =',iyear,imn,iday,ihrst



      ifhr=ITAG
      print*,' in INITPOST ifhr fileName=',ifhr,fileName

        call ext_int_get_dom_ti_integer(DataHandle,
     &   'WEST-EAST_GRID_DIMENSION',itmp
     + ,1,ioutcount,istatus)

        write(6,*) 'west-east dimension: ', itmp
        IM=itmp-1

        call ext_int_get_dom_ti_integer(DataHandle,
     &   'SOUTH-NORTH_GRID_DIMENSION',itmp
     + ,1,ioutcount,istatus)

        write(6,*) 'south-north dimension: ', itmp
        JM=itmp-1
        call ext_int_get_dom_ti_integer(DataHandle,
     &   'BOTTOM-TOP_GRID_DIMENSION',itmp
     + ,1,ioutcount,istatus)

        write(6,*) 'bottom-top dimension: ', itmp
        LM=itmp-1

	write(6,*) 'to big allocate block'

       ALLOCATE(RES(NUMSTA),FIS(NUMSTA),HBOT(NUMSTA))
       ALLOCATE(CFRACL(NUMSTA),CFRACM(NUMSTA),CFRACH(NUMSTA))
       ALLOCATE(SNO(NUMSTA),SOILTB(NUMSTA),SFCEXC(NUMSTA))
       ALLOCATE(SMSTAV(NUMSTA),SMSTOT(NUMSTA))
       ALLOCATE(Z0(NUMSTA),CZEN(NUMSTA),CZMEAN(NUMSTA))
       ALLOCATE(U00(NUMSTA),SR(NUMSTA),ACPREC(NUMSTA))
       ALLOCATE(CUPREC(NUMSTA),ACSNOW(NUMSTA),ACSNOM(NUMSTA))
       ALLOCATE(SSROFF(NUMSTA),BGROFF(NUMSTA),SFCSHX(NUMSTA))
       ALLOCATE(SFCLHX(NUMSTA),SUBSHX(NUMSTA),SNOPCX(NUMSTA))
       ALLOCATE(ASWIN(NUMSTA),ASWOUT(NUMSTA),ASWTOA(NUMSTA))
       ALLOCATE(ALWIN(NUMSTA),ALWOUT(NUMSTA),ALWTOA(NUMSTA))
       ALLOCATE(TSHLTR(NUMSTA),QSHLTR(NUMSTA),TH2_hold(NUMSTA))
       ALLOCATE(TH10(NUMSTA),Q10(NUMSTA),U10(NUMSTA),V10(NUMSTA))
       ALLOCATE(TLMIN(NUMSTA),TLMAX(NUMSTA),SMC(NUMSTA,NSOIL))
       ALLOCATE(CMC(NUMSTA),STC(NUMSTA,NSOIL),SH2O(NUMSTA,NSOIL))
       ALLOCATE(VEGFRC(NUMSTA),POTFLX(NUMSTA),PSLP(NUMSTA))
       ALLOCATE(PDSL1(NUMSTA),EGRID2(NUMSTA),SM(NUMSTA),SICE(NUMSTA))
       ALLOCATE(HBM2(NUMSTA),FACTR(NUMSTA),PTBL(ITB,JTB),TTBL(JTB,ITB))
       ALLOCATE(STATPR(NUMSTA),STACPR(NUMSTA),STAEVP(NUMSTA))
       ALLOCATE(STAPOT(NUMSTA),STASHX(NUMSTA),STASUB(NUMSTA))
       ALLOCATE(STAPCX(NUMSTA),STASWI(NUMSTA),STASWO(NUMSTA))
       ALLOCATE(STALWI(NUMSTA),STALWO(NUMSTA),STALWT(NUMSTA))
       ALLOCATE(STASWT(NUMSTA),STASNM(NUMSTA),STASRF(NUMSTA))
       ALLOCATE(STABRF(NUMSTA),STASNO(NUMSTA),ACPREC0(NUMSTA))
       ALLOCATE(CUPREC0(NUMSTA),SFCLHX0(NUMSTA),POTFLX0(NUMSTA))
       ALLOCATE(SFCSHX0(NUMSTA),SUBSHX0(NUMSTA),SNOPCX0(NUMSTA))
       ALLOCATE(ASWIN0(NUMSTA),ASWOUT0(NUMSTA),ALWIN0(NUMSTA))
       ALLOCATE(ALWOUT0(NUMSTA),ALWTOA0(NUMSTA),ASWTOA0(NUMSTA))
       ALLOCATE(ACSNOW0(NUMSTA),ACSNOM0(NUMSTA),SSROFF0(NUMSTA))
       ALLOCATE(BGROFF0(NUMSTA))
       ALLOCATE(F_RAIN(NUMSTA,LM),F_ICE(NUMSTA,LM),CLDFRA(NUMSTA,LM))
       ALLOCATE(F_RIMEF(NUMSTA,LM))


	ALLOCATE(T(NUMSTA,LM))
	ALLOCATE(Q(NUMSTA,LM))
	ALLOCATE(U(NUMSTA,LM))
	ALLOCATE(V(NUMSTA,LM))
	ALLOCATE(Q2(NUMSTA,LM))
	ALLOCATE(OMGALF(NUMSTA,LM))
	ALLOCATE(CWM(NUMSTA,LM))
	ALLOCATE(TRAIN(NUMSTA,LM))
	ALLOCATE(TCUCN(NUMSTA,LM))
	ALLOCATE(RSWTT(NUMSTA,LM))
	ALLOCATE(RLWTT(NUMSTA,LM))
	ALLOCATE(CCR(NUMSTA,LM))
	ALLOCATE(RTOP(NUMSTA,LM))
	ALLOCATE(HTM(NUMSTA,LM))
	ALLOCATE(OMGA(NUMSTA,LM))
	ALLOCATE(p_hold(NUMSTA,LM))
	ALLOCATE(t_hold(NUMSTA,LM))
	ALLOCATE(PINT(NUMSTA,LM+1))
	ALLOCATE(W(NUMSTA,LM+1))
	ALLOCATE(WH(NUMSTA,LM))
	ALLOCATE(IW(NUMSTA,LM))

	ALLOCATE(STADHC(LM))
	ALLOCATE(STADHR(LM))
	ALLOCATE(CPRATE(LM))
	ALLOCATE(DHRAIN(LM,NUMSTA))
	ALLOCATE(DHCNVC(LM,NUMSTA))
	ALLOCATE(TCUCN0(LM,NUMSTA))
	ALLOCATE(TRAIN0(LM,NUMSTA))


! former parameter statements
        NWORDM=(LCL1ML+1)*LM+2*LCL1SL
        LRECPR=4*(8+9+LCL1ML*LM+LCL1SL)
! former parameter statements

	if (allocated(FPACK)) deallocate(FPACK); allocate(FPACK(NWORDM))
	if (allocated(PRODAT)) deallocate(PRODAT); 
     &                  allocate(PRODAT(NWORDM))

        write(6,*) 'allocate with IM, JM, LM: ', IM, JM, LM
        JS=1
        JE=JM
        JEV=JM+1

	if (ALLOCATED(DUM)) deallocate(DUM); 
     &                          allocate(DUM(IM,JM,4))
	if (ALLOCATED(DUMMY)) deallocate(DUMMY); 
     &				allocate(DUMMY(IM,JM))
	if (ALLOCATED(DUMMY2)) deallocate(DUMMY2); 
     &				allocate(DUMMY2(IM,JM))
	if (ALLOCATED(DUM3D)) deallocate(DUM3D); 
     &				allocate(DUM3D(IM,LM,JM))
	if (ALLOCATED(DUM3D_SOIL)) deallocate(DUM3D_SOIL); 
     &				allocate(DUM3D_SOIL(IM,NSOIL,JM))
	if (ALLOCATED(DUM3D_U)) deallocate(DUM3D_U); 
     &				allocate(DUM3D_U(IM+1,LM,JM))
	if (ALLOCATED(DUM3D_V)) deallocate(DUM3D_V); 
     &				allocate(DUM3D_V(IM,LM,JM+1))
	if (ALLOCATED(DUM3D2)) deallocate(DUM3D2); 
     &				allocate(DUM3D2(IM,LM+1,JM))
	if (ALLOCATED(DUM3D3)) deallocate(DUM3D3); 
     &				allocate(DUM3D3(IM,LM+1,JM))
	if (ALLOCATED(GDLAT)) deallocate(GDLAT); 
     &				allocate(GDLAT(IM,JM))
	if (ALLOCATED(GDLON)) deallocate(GDLON); 
     &				allocate(GDLON(IM,JM))
	if (ALLOCATED(IDUM)) deallocate(IDUM); 
     &				allocate(IDUM(IM,JM))
	if (ALLOCATED(LMH)) deallocate(LMH); 
     &				allocate(LMH(IM,JM))

        call ext_int_get_dom_ti_real(DataHandle,'DX',tmp
     + ,1,ioutcount,istatus)
        dxval=nint(tmp)
        write(6,*) 'dxval= ', dxval
        call ext_int_get_dom_ti_real(DataHandle,'DY',tmp
     + ,1,ioutcount,istatus)
        dyval=nint(tmp)
        write(6,*) 'dyval= ', dyval

!need to get DT
!	tmp=60 ! hardwire for safety

        call ext_int_get_dom_ti_real(DataHandle,'DT',tmp
     +    ,1,ioutcount,istatus)
	write(6,*) 'status from DT get: ', istatus
	write(6,*) 'returned value for DT: ', tmp
        DT=tmp
        print*,'DT= ',DT

        call ext_int_get_dom_ti_real(DataHandle,'CEN_LAT',tmp
     + ,1,ioutcount,istatus)
        cenlat=nint(1000.*tmp)
        write(6,*) 'cenlat= ', cenlat
        call ext_int_get_dom_ti_real(DataHandle,'CEN_LON',tmp
     + ,1,ioutcount,istatus)
        cenlon=nint(1000.*tmp)
        write(6,*) 'cenlon= ', cenlon
        call ext_int_get_dom_ti_real(DataHandle,'TRUELAT1',tmp
     + ,1,ioutcount,istatus)
        truelat1=nint(1000.*tmp)
        write(6,*) 'truelat1= ', truelat1
        call ext_int_get_dom_ti_real(DataHandle,'TRUELAT2',tmp
     + ,1,ioutcount,istatus)
        truelat2=nint(1000.*tmp)
        write(6,*) 'truelat2= ', truelat2
        call ext_int_get_dom_ti_integer(DataHandle,'MAP_PROJ',itmp
     + ,1,ioutcount,istatus)
        maptype=itmp
        write(6,*) 'maptype is ', maptype

c closing wrf io api

      call ext_int_ioclose ( DataHandle, Status )

c start calling mpi io

      iunit=33
      call count_recs_wrf_binary_file(iunit, fileName, nrecs)

      print*,'- FILE CONTAINS ',nrecs, ' RECORDS'
      allocate (datestr_all(nrecs))
      allocate (varname_all(nrecs))
      allocate (domainend_all(3,nrecs))
      allocate (start_block(nrecs))
      allocate (end_block(nrecs))
      allocate (start_byte(nrecs))
      allocate (end_byte(nrecs))
      allocate (file_offset(nrecs))

	if (ITAG .eq. 0) then
          PRINT_DIAG=.true.
        else
          PRINT_DIAG=.false.
	endif

      call inventory_wrf_binary_file(iunit, filename, nrecs,
     +                datestr_all,varname_all,domainend_all,
     +      start_block,end_block,start_byte,end_byte,file_offset,
     +      print_diag)


!     close(iunit)

      call mpi_init(ierr)
	write(6,*) 'ierr from mpi_init: ', ierr
      call mpi_comm_rank(MPI_COMM_WORLD,mype,ierr)
	write(6,*) 'ierr from mpi_comm_rank: ', ierr
      call mpi_comm_size(MPI_COMM_WORLD,npes,ierr)
	write(6,*) 'ierr from mpi_comm_size: ', ierr

      write(6,*) 'want to open: ', filename
      write(6,*) 'mpi_mode_rdonly: ', mpi_mode_rdonly

	write(6,*) 'call mpi_file_open: ', mpi_comm_world, filename
     + , mpi_mode_rdonly,mpi_info_null, iunit, ierr

      call mpi_file_open(mpi_comm_world, filename
     + , mpi_mode_rdonly,mpi_info_null, iunit, ierr)
      if (ierr /= 0) then
       print*,"Error opening file with mpi io ",iunit,ierr
       call mpi_abort(mpi_comm_world, 59, ierr)
!      stop
      end if

      hor_size=IM*JM
      hor_size_u=(IM+1)*(JM)
      hor_size_v=(IM)*(JM+1)



! get 3-D variables
      print*,'im,jm,lm= ',im,jm,lm
c
      VarName='U'

      call retrieve_index(index,VarName,varname_all,nrecs,iret)
      if (iret /= 0) then
        print*,VarName," not found in file-Assigned missing values"
        U=SPVAL
      else
	write(6,*) 'size of dum3d_u: ', size(dum3d_u)
	write(6,*) 'hor_size_u*lm: ', hor_size_u*lm
        call mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D_U,(hor_size_u*lm),mpi_real4
     + , mpi_status_ignore, ierr)
        if (ierr /= 0) then
          print*,"Error reading ", VarName,"Assigned missing values"
          U=SPVAL
        else
          DO L = 1,LM
           DO N=1,NUMSTA
            I=IVINDX(N)
            J=JVINDX(N)
            U(N,L) = DUM3D_U(I,L,J)
           END DO
          END DO
        endif
      endif

      VarName='V'
      call retrieve_index(index,VarName,varname_all,nrecs,iret)
      if (iret /= 0) then
        print*,VarName," not found in file-Assigned missing values"
        V=SPVAL
      else
        call mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D_V,(hor_size_v*lm),mpi_real4
     + , mpi_status_ignore, ierr)
        if (ierr /= 0) then
          print*,"Error reading ", VarName,"Assigned missing values"
          V=SPVAL
        else
          DO L = 1,LM
           DO N=1,NUMSTA
            I=IVINDX(N)
            J=JVINDX(N)
            V(N,L) = DUM3D_V(I,L,J)
           END DO
          END DO
        endif
      endif


	write(6,*) 'V: ', DUM3D_V(20,20,20)

      VarName='W'
      call retrieve_index(index,VarName,varname_all,nrecs,iret)
      if (iret /= 0) then
        print*,VarName," not found in file-Assigned missing values"
        W=SPVAL
      else
        call mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D2,(hor_size*(lm+1)),mpi_real4
     + , mpi_status_ignore, ierr)
        if (ierr /= 0) then
          print*,"Error reading ", VarName,"Assigned missing values"
          V=SPVAL
        else
          DO L = 1,LM+1
           DO N=1,NUMSTA
            I=IVINDX(N)
            J=JVINDX(N)
            W(N,L) = DUM3D2(I,L,J)
           END DO
          END DO
        endif
      endif

	write(6,*) 'W: ', DUM3D(20,20,20)

      DO L = 1,LM
      DO N=1,NUMSTA
	I=IHINDX(N)	
	J=JHINDX(N)
            WH(N,L) = (W(N,L)+W(N,L+1))*0.5
      END DO
      END DO



      VarName='T'
      call retrieve_index(index,VarName,varname_all,nrecs,iret)
      if (iret /= 0) then
        print*,VarName," not found in file-Assigned missing values"
        t_hold=SPVAL
      else
        call mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D,(hor_size*lm),mpi_real4
     + , mpi_status_ignore, ierr)
        if (ierr /= 0) then
          print*,"Error reading ", VarName,"Assigned missing values"
          t_hold=SPVAL
        else
          DO L = 1,LM+1
           DO N=1,NUMSTA
            I=IVINDX(N)
            J=JVINDX(N)
            t_hold(N,L) = DUM3D(I,L,J)
           END DO
          END DO
        endif
      endif

      do l = 1, lm
       do N = 1, NUMSTA
         I=IHINDX(N)
         J=JHINDX(N)
             t_hold ( N , L ) = dum3d ( i, l, j ) + 300.
        end do
       end do


! t_hold has potential temperature here

      VarName='MU'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + , mpi_status_ignore, ierr)


      VarName='MUB'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY2,hor_size,mpi_real4
     + , mpi_status_ignore, ierr)

  633	format(15(f6.0,1x))

	if (allocated(pint_part)) deallocate(pint_part)
	allocate(pint_part(NUMSTA))

	if (allocated(PDS)) deallocate(PDS)
	allocate(PDS(NUMSTA))

	DO N=1,NUMSTA
         I=IHINDX(N)
         J=JHINDX(N)
  	 pint_part(N)=DUMMY(I,J)+DUMMY2(I,J)
!	write(6,*) 'N, pint_part(N): ', N, pint_part(N)
	if (CIDSTN_SAVE(N) .eq. 'KOAK    ') then
	write(6,*) 'KOAK, MU,MUB,pint_part: ',DUMMY(I,J),DUMMY2(I,J),
     &         pint_part(N)
	endif
	if (CIDSTN_SAVE(N) .eq. 'BLU     ') then
	write(6,*) 'BLU, MU,MUB,pint_part: ',DUMMY(I,J),DUMMY2(I,J),
     &		pint_part(N)
	endif
	ENDDO

      VarName='P'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D,hor_size*lm,mpi_real4
     + ,mpi_status_ignore, ierr)

	DO L=1,LM
	DO N=1,NUMSTA
         I=IHINDX(N)
         J=JHINDX(N)
	 p_hold(N,L)=DUM3D(I,L,J)
	ENDDO
	ENDDO

      VarName='QVAPOR'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D,hor_size*lm,mpi_real4
     + ,mpi_status_ignore, ierr)

	DO L=1,LM
	DO N=1,NUMSTA
         I=IHINDX(N)
         J=JHINDX(N)
	 Q(N,L)=DUM3D(I,L,J)/(1.0+DUM3D(I,L,J))
	ENDDO
	ENDDO


      VarName='QCLOUD'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D,hor_size*lm,mpi_real4
     + ,mpi_status_ignore, ierr)

        DO L = 1, LM
        DO N=1,NUMSTA
          Q2(N,L)=0.
          CWM(N,L)=DUM3D(IHINDX(N),L,JHINDX(N))
        ENDDO
        ENDDO


      VarName='TSLB'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D_SOIL,hor_size*nsoil,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO L = 1, NSOIL
        DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
!            STC(N,L) = DUM3D_SOIL(I,NSOIL-L+1,J)
            STC(N,L) = DUM3D_SOIL(I,L,J)
        END DO
      END DO

      VarName='Q2'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        QSHLTR(N)=DUMMY(IHINDX(N),JHINDX(N))
      ENDDO

      VarName='TH2'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        TH2_hold(N)=DUMMY(IHINDX(N),JHINDX(N))
      ENDDO

      VarName='U10'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        U10(N)=DUMMY(IHINDX(N),JHINDX(N))
      ENDDO

      VarName='V10'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        V10(N)=DUMMY(IHINDX(N),JHINDX(N))
      ENDDO

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        TH10(N)=-9999.
        Q10(N)=-9999.
       END DO

      VarName='SMOIS'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D_SOIL,hor_size*nsoil,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO L = 1, NSOIL
        DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
!        SMC(N,L) = DUM3D_SOIL(I,NSOIL-L+1,J)
        SMC(N,L) = DUM3D_SOIL(I,L,J)
        ENDDO
      ENDDO

      VarName='SH2O'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D_SOIL,hor_size*nsoil,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO L = 1, NSOIL
        DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        CMC(N)   = DUM3D (I,1,J)  ! ??????
!        SH2O(N,L)= DUM3D_SOIL(I,NSOIL-L+1,J)
        SH2O(N,L)= DUM3D_SOIL(I,L,J)
        END DO
      END DO


	write(6,*) 'past soil'

c reading SMSTAV
      VarName='SMSTAV'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
	DUMMY=0.
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        SMSTAV(N)=DUMMY(I,J)
      ENDDO

      VarName='SMSTOT'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
	DUMMY=0.
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        SMSTOT(N)=DUMMY(I,J)
      ENDDO

	write(6,*) 'to VEGFRA'
      VarName='VEGFRA'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        VEGFRC(N)=DUMMY(I,J)
      ENDDO

      VarName='ACSNOW'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM(:,:,1),hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      VarName='ACSNOM'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM(:,:,2),hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        ACSNOW(N)=DUM(I,J,1)
        ACSNOM(N)=DUM(I,J,2)
      ENDDO
	write(6,*) 'past acsnom'

      VarName='SNOW'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        SNO(N)=DUMMY(I,J)
	if (SNO(N) .gt. 0) then	
	write(0,*) 'N, SNO(N): ', N, SNO(N)
	endif
      ENDDO

      VarName='PB'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D,hor_size*lm,mpi_real4
     + ,mpi_status_ignore, ierr)

	write(6,*) 'to PMID alloc statements'

	if (allocated(PMID)) deallocate(PMID)
	allocate(PMID(NUMSTA,LM))

	DO L=1,LM
	DO N=1,NUMSTA
         I=IHINDX(N)
         J=JHINDX(N)
	 PMID(N,L)=p_hold(N,L)+DUM3D(I,L,J)
         T(N,L)=t_hold(N,L)*(PMID(N,L)*1.e-5)**CAPA
	if (N .eq. NUMSTA/2) then
!	write(6,*) 'N,L,PMID,t_hold,T: ', N,L,PMID(N,L),t_hold(N,L),T(N,L)
	endif

	 OMGA(N,L)=-WH(N,L)*PMID(N,L)*G/
     &              (RD*T(N,L)*(1+.608*Q(N,L)))



!!!!! CONSTRAIN Q TO A PARTICULAR RH VALUE, FOLLOWING CALRH OF WRFPOST
           QC= (PQ0/PMID(N,L)) *EXP(A2*(T(N,L)-A3)/(T(N,L)-A4))
           RH=Q(N,L)/QC

           IF (RH .gt. RHCRIT) THEN
	   IF (RH .gt. 1.02) THEN
           write(6,*) 'reducing RH from: ', RH, ' at N,L: ', N,L
	   ENDIF
           Q(N,L)=0.999*RHCRIT*QC
           ENDIF
!!!!! END RH CONSTRAIN

	ENDDO
	ENDDO


      VarName='HGT'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        RES(N)=1.0
        FIS(N)=DUMMY(IHINDX(N),JHINDX(N))*G
      ENDDO

!HERENOW

      VarName='P_TOP'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,pt,1,mpi_real4
     + ,mpi_status_ignore, ierr)

	write(6,*) 'returned P_TOP into PT as : ', PT


!!!! need to do the qvapor fix - integrated contribution of
!!!! moisture to the surface pressure

	allocate(PVAPOR(NUMSTA))
	allocate(ZINT(NUMSTA,LM+1))

      VarName='PHB'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D2,hor_size*(lm+1),mpi_real4
     + ,mpi_status_ignore, ierr)

      VarName='PH'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM3D3,hor_size*(lm+1),mpi_real4
     + ,mpi_status_ignore, ierr)

      DO L=1,LM+1
      DO N=1,NUMSTA
         I=IHINDX(N)
         J=JHINDX(N)
         ZINT(N,L)=(DUM3D2(I,L,J)+DUM3D3(I,L,J))/G
       ENDDO
      ENDDO

       DO N=1,NUMSTA
         I=IHINDX(N)
         J=JHINDX(N)
	 PVAPOR(N)=0.
       do L=1,LM
       dz=ZINT(N,L+1)-ZINT(N,L)
       rho=PMID(N,L)/(RD*T(N,L))

        if (L .le. LM-1) then
        QMEAN=0.5*(Q(N,L)+Q(N,L+1))
        else
        QMEAN=Q(N,L)
        endif

!	if (mod(L,5) .eq. 0 .and. mod(N,20) .eq. 0) then
!        write(0,*) 'N, L, dz, rho, qmean, increm: ', 
!     &        N, L, dz, rho, qmean, G*rho*dz*QMEAN
!	endif
	
       pvapor(N)=pvapor(N)+G*rho*dz*QMEAN
       enddo

        ENDDO

!!!! end vapor fix

!!! what is the vertical order of fields??
!!!
!!! PINT has ground at LM+1, but temp appears to have ground at L=1
!!!
!!! make PINT(1)=sfc
!!!
!!! ?????????????????????
!!!
        DO N=1,NUMSTA
         I=IHINDX(N)
         J=JHINDX(N)
         PINT (N,LM+1)=PT
         PINT (N,1)=pint_part(N)+PT+PVAPOR(N)

	PDS(N)=pint_part(N)+PT+PVAPOR(N)
        TSHLTR(N)=TH2_hold(N)*(PINT(N,1)/100000.)**CAPA

        HBOT(N)=-9999.
        CFRACL(N)=-9999.

!!! constrain surface RH

           QC=(PQ0/PINT(N,1))*EXP(A2*(TSHLTR(N)-A3)/(TSHLTR(N)-A4))
           RH=QSHLTR(N)/QC
           IF (RH .gt. RHCRIT) THEN
           write(6,*) 'reducing surface RH from: ', RH, ' at N: ', N
           QSHLTR(N)=0.999*RHCRIT*QC
           ENDIF


        ENDDO

C
C** Compute PSLP using NMC reduction
C
      DO N=1,NUMSTA
       PSFC = PDS(N)
       ZSFC = FIS(N)*GI
       PSLP(N) = PSFC
C
C    COMPUTE LAYER TAU (VIRTUAL TEMP*RD/G).
       TVRT = T(N,1)*(1.0+D608*Q(N,1))
!	if (mod(N,50) .eq. 0) then
!	write(0,*) 'N, T(N,1), Q(N,1), TVRT: ', 
!     &          N, T(N,1), Q(N,1), TVRT
!	endif
       TAU  = TVRT*RD*GI
C
C    COMPUTE TAU AT THE GROUND (Z=ZSFC) AND SEA LEVEL (Z=0)
C    ASSUMING A CONSTANT LAPSE RATE OF GAMMA=6.5DEG/KM.
       TVRSFC = TVRT + (ZSFC- ZSL)*GAMMA
       TAUSFC = TVRSFC*RD*GI
       TVRSL  = TVRT + (ZSFC- ZSL)*GAMMA
       TAUSL  = TVRSL*RD*GI
C
C    IF NEED BE APPLY SHEULL CORRECTION.
       IF ((TAUSL.GT.TAUCR).AND.(TAUSFC.LE.TAUCR)) THEN
          TAUSL=TAUCR
       ELSEIF ((TAUSL.GT.TAUCR).AND.(TAUSFC.GT.TAUCR)) THEN
          TAUSL = TAUCR-CONST*(TAUSFC-TAUCR)**2
       ENDIF
C
C    COMPUTE MEAN TAU.
       TAUAVG = 0.5*(TAUSL+TAUSFC)
C
C    COMPUTE SEA LEVEL PRESSURE.
       IF (FIS(N).GT.1.0) PSLP(N) = PSFC*EXP(ZSFC/TAUAVG)
c      print *,n,idstn(n),pslp(n),tvrt
	if (mod(N,20) .eq. 0) then
	write(0,*) 'N, PDS(N), PSLP(N): ', N, PDS(N), PSLP(N)
	endif

      ENDDO


CC
CC RAINC is "ACCUMULATED TOTAL CUMULUS PRECIPITATION"
CC RAINNC is "ACCUMULATED TOTAL GRID SCALE PRECIPITATION"

      VarName='RAINC'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM(:,:,1),hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      VarName='RAINNC'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM(:,:,2),hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

!	write(6,*)  'RAIN over domain'

!	do J=JE,JS,-(JE-JS)/37
!	write(6,635) ( (DUM(I,J,1)+DUM(I,J,2)), I=1,IM,IM/23)
!	enddo
  635	format(30(f4.1,1x))

!	write(6,*) 'RAINC, RAINNC (160,124): ', DUM(160,124,1),
!     &                    DUM(160,124,2)

      DO N=1,NUMSTA
        CUPREC(N)=DUM(IHINDX(N),JHINDX(N),1)*.001
        ACPREC(N)=( DUM(IHINDX(N),JHINDX(N),1)+
     &              DUM(IHINDX(N),JHINDX(N),2) )*.001

!	if (ACPREC(N) .gt. 0) then
!	write(6,*) 'CIDSTN, ACPREC: ', CIDSTN_SAVE(N),ACPREC(N)
!	endif

      ENDDO

      VarName='XLAT'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      do j = 1, jm
        do i = 1, im
            GDLAT ( i, j ) = DUMMY ( i, j )
        end do
       end do


      VarName='XLONG'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

       do j = 1, jm
        do i = 1, im
            GDLON ( i, j ) = DUMMY ( i, j )
        end do
       end do


      VarName='TMN'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM(:,:,1),hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

! XLAND 1 land 2 sea
      VarName='XLAND'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        SM(N)=DUMMY(I,J)-1.0
        SOILTB(N)=DUM(I,J,1) ! NOT 100% sure on this definition
      ENDDO

      VarName='HFX'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        SFCSHX(N)=DUMMY(I,J)
      ENDDO

      VarName='LH'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        SFCLHX(N)=DUMMY(I,J)
      ENDDO

      VarName='SFCEXC'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        SFCEXC(N)=DUMMY(I,J)
      ENDDO

      VarName='SWDOWN'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

	write(6,*) 'max SWDOWN: ', maxval(DUMMY)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        ASWIN(N)=DUMMY(I,J)
      ENDDO

      VarName='GSW'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        ASWOUT(N)=ASWIN(N)-DUMMY(I,J)
      ENDDO

!!! GSW is net (down - up)
!!!
!!! SW up = down - net

      VarName='GLW'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

	write(6,*) 'max GLW: ', maxval(DUMMY)
      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        ALWIN(N)=DUMMY(I,J)
	if (IDSTN(N) .eq. 832) then
	write(6,*) 'for station 832, found ASWIN, ASWOUT: ', 
     &                             ASWIN(N), ASWOUT(N)
	endif
      ENDDO

      VarName='UDROFF'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)

	if (iret .eq. 0) then

      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        BGROFF(N)=DUMMY(I,J)
!	if (DUMMY(I,J) .gt. 0.5) then
!	write(0,*) 'non-zero BGROFF:: ', N, BGROFF(N)
!	endif

	if (N .eq. 256) then
	write(0,*) 'N, BGROFF:: ', N, BGROFF(N)
	endif

      ENDDO

	else

      DO N=1,NUMSTA
        BGROFF(N)=0.
      ENDDO

	endif

      VarName='SFROFF'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        SSROFF(N)=DUMMY(I,J)
      ENDDO

      VarName='Z0'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        Z0(N)=DUMMY(I,J)
      ENDDO

      VarName='TSK'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        EGRID2(N)=DUMMY(I,J)
      ENDDO


!!!!!!!!!!!!!!!!! END INSERT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!1

C------------------------------------------------------------------------
C***
C***  READ QUANTITIES NEEDED FROM THE NHB FILE
C***

      DO N=1,NUMSTA
!       HBM2(N)=DUM(IHINDX(N),JHINDX(N),1)
       HBM2(N)=1.0
      ENDDO
C

!!	ICE available in wrfinput file...zero out for now
      VarName='XICE'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
	SICE(N)=DUMMY(I,J)
      ENDDO

      call mpi_file_close(iunit,ierr)
        deallocate (datestr_all)
        deallocate (varname_all)
        deallocate (domainend_all)
        deallocate (start_block)
        deallocate (end_block)
        deallocate (start_byte)
        deallocate (end_byte)
        deallocate (file_offset)

C
      DO L=1,LM
       DO N=1,NUMSTA
         HTM(N,L)=1.0
       ENDDO
      ENDDO

	write(6,*) 'set LMH to : ', LM
	write(6,*) 'IM,jm: ', Im,jm
	do J=1,JM
	 do I=1,IM
	   LMH(I,J)=LM
	 enddo
	enddo
C
C       Define a GDS, then use GDSWIZ to find N.N. point


        GDS=-1
        if(maptype .eq. 1)THEN  ! Lambert conformal
          GDS(1)=3
          GDS(2)=im
          GDS(3)=jm
          GDS(4)=int(GDLAT(1,1)*1000)
          GDS(5)=int(GDLON(1,1)*1000)
          GDS(6)=8
          GDS(7)=CENLON
          GDS(8)=DXVAL
          GDS(9)=DYVAL
          GDS(10)=0
          GDS(11)=64
          GDS(12)=TRUELAT2
          GDS(13)=TRUELAT1
        ELSE IF(MAPTYPE .EQ. 2)THEN  !Polar stereographic
          GDS(1)=5
          GDS(2)=im
          GDS(3)=jm
          GDS(4)=int(GDLAT(1,1)*1000)
          GDS(5)=int(GDLON(1,1)*1000)
          GDS(6)=8
          GDS(7)=CENLON
          GDS(8)=DXVAL
          GDS(9)=DYVAL
          GDS(10)=0
          GDS(11)=64
        ELSE IF(MAPTYPE .EQ. 3)THEN  !Mercator
          GDS(1)=1
          GDS(2)=im
          GDS(3)=jm
          GDS(4)=int(GDLAT(1,1)*1000)
          GDS(5)=int(GDLON(1,1)*1000)
          GDS(6)=8
          GDS(7)=int(GDLAT(IM,JM)*1000)
          GDS(8)=int(GDLON(IM,JM)*1000)
          GDS(9)=TRUELAT1
          GDS(10)=0
          GDS(11)=64
          GDS(12)=DXVAL
          GDS(13)=DYVAL
        END IF

	write(6,*) 'GDS= ', (GDS(NN),NN=1,13)


C
C	GET ROTATION ANGLES FOR WIND
C

	write(6,*) 'numsta= ', numsta

	ALLOCATE(CROT(NUMSTA),SROT(NUMSTA))

	write(6,*) 'allocated crot, srot'
	CROT=0.	
	SROT=0.

	DO N=1,NUMSTA
	I=IHINDX(N)
	J=JHINDX(N)
	RLATX=GDLAT(I,J)
	RLONX=GDLON(I,J)
	
        CALL GDSWIZ(GDS,-1,1,-9999.,xout,yout,
     &                  RLONX,RLATX,NRET,1,CROT(N),SROT(N))

	ENDDO

      NTSPH=INT(3600./DT+0.50)

	write(6,*) 'rot angles defined, and ntsph= ', ntsph


C
C------------------------------------------------------------------------
C

	DO L=1,LM
        DO N=1,NUMSTA
	  TRAIN(N,L)=-9999.
	  TCUCN(N,L)=-9999.
        ENDDO
        ENDDO

      DO N=1,NUMSTA
        HBOT(N)=-9999.
        CFRACL(N)=-9999.
        CFRACM(N)=-9999.
	CZEN(N)=-9999.
      ENDDO


      DO N=1,NUMSTA
	CFRACH(N)=-9999.
	CZMEAN(N)=-9999.
	U00(N)=-9999.
	SR(N)=-9999.
      ENDDO

      DO N=1,NUMSTA
       SUBSHX(N)=-9999.
       SNOPCX(N)=-9999.
      ENDDO

      DO N=1,NUMSTA
        ASWTOA(N)=-9999.
        ALWOUT(N)=-9999.
        ALWTOA(N)=-9999.
      ENDDO

      DO N=1,NUMSTA
	POTFLX(N)=-9999.
	TLMIN(N)=-9999.
	TLMAX(N)=-9999.
      ENDDO
C------------------------------------------------------------------------
C***
C***  READ RADIATIVE TEMPERATURE TENDENCIES
C***
      DO L=1,LM
        DO N=1,NUMSTA
         RSWTT(N,L)=-9999.
         RLWTT(N,L)=-9999.
        ENDDO
      ENDDO
C
c     CLOSE(LRSTRT)
C------------------------------------------------------------------------
C***
C***  THE FORECAST HOUR
C***  
c     IFHR=NTSD/NTSPH

	write(6,*) 'past block of code'
	IFHR=ITAG
	write(6,*) 'IFHR: ', IFHR
C------------------------------------------------------------------------
      IF(ITAG.GT.0)THEN
	write(6,*) 'working on preceding file'
C***
C***  GENERATE THE NAME OF THE PRECEDING RESTRT FILE
C***
        ITAG0=ITAG-INCR


        RINC(1)=0.
        RINC(2)=float(ITAG0)
        RINC(3)=0.
        RINC(4)=0.
        RINC(5)=0.

	write(6,*) 'RINC(2): ', rinc(2)
        call w3movdat(rinc,idate,jdate)
        write(DateStrold,301) JDATE(1),JDATE(2),JDATE(3),JDATE(5)
 301  format(i4,'-',i2.2,'-',i2.2,'_',i2.2,':00:00')

	write(6,*) 'filename later in PROF: ', filename, '_END'
        len=lnblnk(filename)

	write(6,*) 'LEN= ', LEN
	write(6,*) 'carried over part: ', filename(1:len-19)
        filename=filename(1:len-19)//DateStrold

	write(6,*) 'old filename is ', trim(filename)
	write(6,*) 'date for old file is: ', datestrold


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! INSERT READ FROM ABOVE ONCE WORK OUT KINKS
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

         CALL ext_int_ioinit(Status)
          print*,'CALLed ioinit', Status
	write(6,*) 'filename early in PROF= ', filename
         CALL ext_int_open_for_read( trim(fileName), 0, 0, " ",
     &  DataHandle, Status)
          print*,'CALLed open for read', Status

       if ( Status /= 0 ) then
         print*,'error opening ',fileName, ' Status = ', Status ; stop
       endif

C Getting start time
      CALL ext_int_get_dom_ti_char(DataHandle
     1 ,'START_DATE',startdate, status )
        print*,'startdate= ',startdate

!      ifhr=nint(rinc(2))
!      print*,' in INITPOST ifhr fileName=',ifhr,fileName


        call ext_int_get_dom_ti_real(DataHandle,'DX',tmp
     + ,1,ioutcount,istatus)
        dxval=nint(tmp)
        write(6,*) 'dxval= ', dxval
        call ext_int_get_dom_ti_real(DataHandle,'DY',tmp
     + ,1,ioutcount,istatus)
        dyval=nint(tmp)
        write(6,*) 'dyval= ', dyval

!need to get DT
	tmp=-99 ! hardwire for safety
        call ext_int_get_dom_ti_real(DataHandle,'DT',tmp
     +    ,1,ioutcount,istatus)
	write(6,*) 'istatus from ext_int_get_dom_ti_real for DT: ', 
     &      istatus
	write(6,*) 'returned a value of  ', tmp
	write(6,*) 'setting to 60'
	tmp=60

        DT=tmp
        print*,'DT= ',DT

        call ext_int_get_dom_ti_real(DataHandle,'CEN_LAT',tmp
     + ,1,ioutcount,istatus)
        cenlat=nint(1000.*tmp)
        write(6,*) 'cenlat= ', cenlat
        call ext_int_get_dom_ti_real(DataHandle,'CEN_LON',tmp
     + ,1,ioutcount,istatus)
        cenlon=nint(1000.*tmp)
        write(6,*) 'cenlon= ', cenlon
        call ext_int_get_dom_ti_real(DataHandle,'TRUELAT1',tmp
     + ,1,ioutcount,istatus)
        truelat1=nint(1000.*tmp)
        write(6,*) 'truelat1= ', truelat1
        call ext_int_get_dom_ti_real(DataHandle,'TRUELAT2',tmp
     + ,1,ioutcount,istatus)
        truelat2=nint(1000.*tmp)
        write(6,*) 'truelat2= ', truelat2
        call ext_int_get_dom_ti_integer(DataHandle,'MAP_PROJ',itmp
     + ,1,ioutcount,istatus)
        maptype=itmp
        write(6,*) 'maptype is ', maptype

      call ext_int_ioclose ( DataHandle, Status )

c start calling mpi io
      iunit=33
      call count_recs_wrf_binary_file(iunit, fileName, nrecs)

      print*,'- FILE CONTAINS ',nrecs, ' RECORDS'

      allocate (datestr_all(nrecs))
      allocate (varname_all(nrecs))
      allocate (domainend_all(3,nrecs))
      allocate (start_block(nrecs))
      allocate (end_block(nrecs))
      allocate (start_byte(nrecs))
      allocate (end_byte(nrecs))
      allocate (file_offset(nrecs))

      call inventory_wrf_binary_file(iunit, filename, nrecs,
     +                datestr_all,varname_all,domainend_all,
     +      start_block,end_block,start_byte,end_byte,file_offset, 
     +      print_diag)


	write(6,*) 'call mpi_file_open: ', mpi_comm_world, filename
     + , mpi_mode_rdonly,mpi_info_null, iunit, ierr

      call mpi_file_open(mpi_comm_world, filename
     + , mpi_mode_rdonly,mpi_info_null, iunit, ierr)
      if (ierr /= 0) then
       print*,"Error opening file with mpi io ",iunit,ierr
       call mpi_abort(mpi_comm_world, 59, ierr)
!      stop
      end if



      VarName='ACSNOW'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

        DO N=1,NUMSTA
          ACSNOW0(N)=DUMMY(IHINDX(N),JHINDX(N))
	ENDDO

      VarName='ACSNOM'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

        DO N=1,NUMSTA
          ACSNOM0(N)=DUMMY(IHINDX(N),JHINDX(N))
	ENDDO

CC
CC RAINC is "ACCUMULATED TOTAL CUMULUS PRECIPITATION"
CC RAINNC is "ACCUMULATED TOTAL GRID SCALE PRECIPITATION"

        write(6,*) 'getting RAINC'
      VarName='RAINC'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM(:,:,1),hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      write(6,*) 'getting RAINNC'
      VarName='RAINNC'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUM(:,:,2),hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)


      DO N=1,NUMSTA
        CUPREC0(N)=DUM(IHINDX(N),JHINDX(N),1)*.001
        ACPREC0(N)=( DUM(IHINDX(N),JHINDX(N),1)+
     &                  DUM(IHINDX(N),JHINDX(N),2) )*.001
      ENDDO

      VarName='HFX'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        SFCSHX0(N)=DUMMY(I,J)
      ENDDO

      VarName='LH'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        SFCLHX0(N)=DUMMY(I,J)
      ENDDO

      VarName='UDROFF'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        BGROFF0(N)=DUMMY(I,J)
	if (N .eq. 256) then
	write(0,*) 'N, BGROFF0: ', N, BGROFF0(N)
	endif
      ENDDO

      VarName='SFROFF'
      CALL retrieve_index(index,VarName,varname_all,nrecs,iret)
      CALL mpi_file_read_at(iunit,file_offset(index+1)
     + ,DUMMY,hor_size,mpi_real4
     + ,mpi_status_ignore, ierr)

      DO N=1,NUMSTA
        I=IHINDX(N)
        J=JHINDX(N)
        SSROFF0(N)=DUMMY(I,J)
      ENDDO

      call mpi_file_close(iunit,ierr)
        deallocate (datestr_all)
        deallocate (varname_all)
        deallocate (domainend_all)
        deallocate (start_block)
        deallocate (end_block)
        deallocate (start_byte)
        deallocate (end_byte)
        deallocate (file_offset)

	write(6,*) 'done reading old file'


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! END INSERT READ 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


C
	do L=1,LM
          DO N=1,NUMSTA
	TRAIN0(N,L)=-9999.
	TCUCN0(N,L)=-9999.
          ENDDO
        enddo

        DO N=1,NUMSTA
         SUBSHX0(N)=-9999.
         SNOPCX0(N)=-9999.
        ENDDO
C
        DO N=1,NUMSTA
        ASWTOA0(N)=-9999.
        ALWOUT0(N)=-9999.
        ALWTOA0(N)=-9999.
          POTFLX0(N)=-9999.
        ENDDO
C
C
      ENDIF
C
c     CLOSE(LRSTRT)

!	write(6,*) 'down to here (a)'
C
C
Cmp 	IDEALLY, WON'T NEED MANY MODS BELOW THIS POINT
C
C

C------------------------------------------------------------------------
C***
C***  ALL THE DATA IS NOW IN.
C***  CALCULATE CLOUD FRACTION AND CLOUD WATER/ICE ID NUMBER.
C***
C------------------------------------------------------------------------
      UTIM=1.
      US=1.
      CCLIMIT=1.E-3
      CLIMIT =1.E-20
C-----------------------------------------------------------------------
!$OMP parallel do 
      DO N=1,NUMSTA
        IW(N,1)=-9999
        CCR(N,1)=-9999.
!        PDSL1(N)=PD(IHINDX(N),JHINDX(N))*RES(N)
        PDSL1(N)=pint_part(N)*RES(N)
      ENDDO

!	write(6,*) 'here b'
C
C------------------QW, QI AND QINT--------------------------------------
C

!!!
!!! skip section for now
!!!
!	goto 221

      DO 220 L=2,LM
      DO 210 N=1,NUMSTA


        IW(N,L)=-9999
        CCR(N,L)=-9999.

!      LML=LM-LMH(IHINDX(N),JHINDX(N))
!       write(6,*) 'LML, IHINDX,JHINDX,LMH: ', IHINDX(N),
!     &            JHINDX(N),LMH(IHINDX(N),JHINDX(N))
!      HH=HTM(N,L)*HBM2(N)
!      TKL=T(N,L)
!      QKL=Q(N,L)
!      CWMKL=CWM(N,L)
!      TMT0=(TKL-273.16)*HH
!      TMT15=AMIN1(TMT0,-15.)*HH
!      AI=0.008855
!      BI=1.
C
!      IF(TMT0.LT.-20.)THEN
!        AI=0.007225
!        BI=0.9674
!      ENDIF
C
Cmp      PP=PDSL1(N)*AETA(L)+PT
!      PP=PMID(N,L)
!      QW=HH*PQ0/PP*EXP(HH*A2*(TKL-A3)/(TKL-A4))
!      QI=QW*(BI+AI*AMIN1(TMT0,0.))
!      QINT=QW*(1.-0.00032*TMT15*(TMT15+15.))
!      IF(TMT0.LE.-40.)QINT=QI
C
C-------------------ICE-WATER ID NUMBER IW------------------------------
C

!       no defs for U00 or UL
!
!       so no U00KL,FIQ,IW,CWM
!
!       write(6,*) 'here c'
!       write(6,*) 'L+LML: ', L+LML
!       write(6,*) 'U00(N): ', U00(N)
!       write(6,*) 'UL(L+LML): ', UL(L+LML)

!      U00KL=U00(N)+UL(L+LML)*(0.95-U00(N))*UTIM
!      IF(TMT0.LT.-15.)THEN
!        FIQ=QKL-U00KL*QI
!        IF(FIQ.GT.0..OR.CWMKL.GT.CLIMIT)THEN
!          IW(N,L)=1
!        ELSE
!          IW(N,L)=0
!        ENDIF
!      ENDIF
C
!      IF(TMT0.GE.0.)THEN
!        IW(N,L)=0
!      ENDIF
C
!      IF(TMT0.LT.0..AND.TMT0.GE.-15.)THEN
!        IW(N,L)=0
!        IF(IW(N,L-1).EQ.1.AND.CWMKL.GT.CLIMIT)IW(N,L)=1
!      ENDIF
C
!      IWKL=IW(N,L)
C----------------THE SATUATION SPECIFIC HUMIDITY------------------------
!      FIW=FLOAT(IWKL)
!      QC=(1.-FIW)*QINT+FIW*QI
C----------------THE RELATIVE HUMIDITY----------------------------------
!      IF(QC.LE.0.)THEN
!         RQKL=0.
!       ELSE
!         RQKL=QKL/QC
!      ENDIF
C----------------CLOUD COVER RATIO CCR----------------------------------
!      IF(RQKL.GE.0.9999)THEN
!        CCR(N,L)=AMIN1(US,RQKL)
!      ELSE
!        ARG=-1000.*CWMKL/(US-RQKL)
!        ARG=AMAX1(ARG,-25.)
!        CCR(N,L)= RQKL*(1.-EXP(ARG))
!      ENDIF
C----------------------------------------------------------------------
!       write(6,*) 'here d'
  210                 CONTINUE
  220                 CONTINUE
  221                 continue
C----------------------------------------------------------------------
C----------------------------------------------------------------------
C***
C***  BEGIN THE PROFILE POSTING CODE.
C***
C----------------------------------------------------------------------
C----------------------------------------------------------------------
C***
C***  USE ZERO IN ACCUMULATION ARRAYS AT APPROPRIATE TIMES
C***
       IF(ITAG .eq. 0) THEN

!	write(6,*) 'here (2)'
C
C
C what would appropriate if test be here?
C
C
        DO N=1,NUMSTA
C
C*** ZERO ACCUMLATION ARRAYS.
C
          STATPR(N)=0.
          STACPR(N)=0.
          STAEVP(N)=0.
          STAPOT(N)=0.
          STASHX(N)=0.
          STASUB(N)=0.
          STAPCX(N)=0.
          STASWI(N)=0.
          STASWO(N)=0.
          STALWI(N)=0.
          STALWO(N)=0.
          STALWT(N)=0.
          STASWT(N)=0.
          STASNM(N)=0.
          STASNO(N)=0.
          STASRF(N)=0.
          STABRF(N)=0.
          DO L=1,LM
            DHCNVC(L,N)=0.
            DHRAIN(L,N)=0.
          ENDDO
        ENDDO
C
        GO TO 300
       ENDIF
C---------------------------------------------------------------------
C***
C***  WE MUST CHECK TO SEE IF WE ARE 1 HOUR AFTER ANY OF THE 
C***  ACCUMULATION BUCKETS HAVE BEEN EMPTIED.  IF WE ARE AT SUCH A 
C***  TIME THEN WE NEED TO SET TO ZERO THE VARIABLES USED TO HOLD
C***  THE PRECEDING HOUR'S VALUES.
C***
C---------------------------------------------------------------------
C
C
C 	At this point, accumulation buckets are a foreign concept in
C	the WRF model.  
C
C
c     TIME=(NTSD-1)*DT
c     RESET0=TIME-(NTSD/NPREC)*NPREC*DT
c     RESET1=(NPHS-1)*DT+3600.

	TIME=IFCST
!	write(6,*) 'here (3)'

	RESET0=1.  ! designed to prevent resets.  Reconsider later


C
c      IF(MOD(NTSD,NPREC).GE.NPHS.AND.RESET0.LE.RESET1)THEN
c        DO N=1,NUMSTA
c          STATPR(N)=0.
c          STACPR(N)=0.
c          STASNM(N)=0.
c          STASNO(N)=0.
c          STASRF(N)=0.
c          STABRF(N)=0.
c        ENDDO
c      ELSE
!	write(6,*) 'set STATPR'

        DO N=1,NUMSTA
          STATPR(N)=ACPREC0(N)*1.E3
	if (ACPREC0(N) .gt. 0) then
	write(6,*) 'N,ACPREC0(N),STATPR(N): ', N,
     &			ACPREC0(N),STATPR(N)
	endif
          STACPR(N)=CUPREC0(N)*1.E3
          STASNM(N)=ACSNOM0(N)*1.E3
          STASNO(N)=ACSNOW0(N)*1.E3
!          STASRF(N)=SSROFF0(N)*1.E3
!          STABRF(N)=BGROFF0(N)*1.E3
          STASRF(N)=SSROFF0(N)
          STABRF(N)=BGROFF0(N)
	
	if (N .eq. 256) then
	write(0,*) 'N, STABRF(N): ', N, STABRF(N)
	endif

        ENDDO

!	write(6,*) 'past set'
c      ENDIF          
C
c     RESET0=TIME-(NTSD/NRDSW)*NRDSW*DT
c     IF(MOD(NTSD,NRDSW).GE.NPHS.AND.RESET0.LE.RESET1)THEN
c       DO N=1,NUMSTA
c         STASWI(N)=0.
c         STASWO(N)=0.
c         STASWT(N)=0.
c       ENDDO
c     ELSE
        DO N=1,NUMSTA
          STASWI(N)=ASWIN0(N)
          STASWO(N)=ASWOUT0(N)
          STASWT(N)=ASWTOA0(N)
        ENDDO
c     ENDIF
C
c     RESET0=TIME-(NTSD/NRDLW)*NRDLW*DT
c     IF(MOD(NTSD,NRDLW).GE.NPHS.AND.RESET0.LE.RESET1)THEN
c       DO N=1,NUMSTA
c         STALWI(N)=0.
c         STALWO(N)=0.
c         STALWT(N)=0.
c       ENDDO
c     ELSE
        DO N=1,NUMSTA
          STALWI(N)=ALWIN0(N)
          STALWO(N)=ALWOUT0(N)
          STALWT(N)=-ALWTOA0(N)
        ENDDO
c     ENDIF
C
c     RESET0=TIME-(NTSD/NSRFC)*NSRFC*DT
c     IF(MOD(NTSD,NSRFC).GE.NPHS.AND.RESET0.LE.RESET1)THEN
c       DO N=1,NUMSTA
c         STAEVP(N)=0.
c         STAPOT(N)=0.
c         STASHX(N)=0.
c         STASUB(N)=0.
c         STAPCX(N)=0.
c       ENDDO
c     ELSE
        DO N=1,NUMSTA
          STAEVP(N)=SFCLHX0(N)
          STAPOT(N)=POTFLX0(N)
          STASHX(N)=SFCSHX0(N)
          STASUB(N)=SUBSHX0(N)
          STAPCX(N)=SNOPCX0(N)
        ENDDO
c     ENDIF
C
c     RESET0=TIME-(NTSD/NHEAT)*NHEAT*DT
c     IF(MOD(NTSD,NHEAT).GE.NCNVC.AND.RESET0.LE.RESET1)THEN
c       DO N=1,NUMSTA
c         DO L=1,LM
c           DHCNVC(L,N)=0.
c           DHRAIN(L,N)=0.
c         ENDDO
c       ENDDO
c     ELSE
c       DO N=1,NUMSTA
c         DO L=1,LM
            DHCNVC(L,N)=TCUCN0(N,L)
            DHRAIN(L,N)=TRAIN0(N,L)
c         ENDDO
c       ENDDO
c     ENDIF
 
C------------------------------------------------------------------
  300 CONTINUE
C------------------------------------------------------------------
C
C***  FOR ROTATION OF WINDS FROM E-GRID TO GEODETIC ORIENTATION
C***  WE NEED THE TWO QUANTITIES BELOW.
C
c      SINPH0=SIN(TPH0D*DTR)
c      COSPH0=COS(TPH0D*DTR)
C
C***  INITIAL CALCULATIONS/PREPARATIONS.  WE LOAD SEVERAL
C***  ARRAYS WITH PROFILE VARIABLES.
C
!$OMP parallel do
      DO N=1,NUMSTA
        IF(CZMEAN(N).GT.0.)THEN
          FACTR(N)=CZEN(N)/CZMEAN(N)
        ELSE
          FACTR(N)=0.
        ENDIF
      ENDDO
C
C***  ADJUST SHORTAVE TENDENCIES TO ACCOUNT FOR CHANGE OF SOLAR POSITION
C***  BETWEEN CALLS TO RADIATION
C
!$OMP parallel do
      DO L=1,LM
        DO N=1,NUMSTA
          RSWTT(N,L)=RSWTT(N,L)*FACTR(N)
        ENDDO
      ENDDO
C
C***  COMPUTE RTOP
C
!$OMP parallel do
      DO L=1,LM
        DO N=1,NUMSTA
!          APEL=PT+AETA(L)*PDSL1(N)
          APEL=PMID(N,L)
          RTOP(N,L)=RD*T(N,L)*(1.+0.608*Q(N,L))/APEL
        ENDDO
      ENDDO
C
C***  PDS IS SURFACE PRESSURE.
C
!$OMP parallel do 
	DO N=1,NUMSTA
	I=IHINDX(N)	
	J=JHINDX(N)
        PDS(N)=pint_part(N)+PT
	ENDDO
C
C
!$OMP parallel do 
      DO N=1,NUMSTA
        IF(ACPREC(N).LT.0.)ACPREC(N)=0.
        IF(CUPREC(N).LT.0.)CUPREC(N)=0.
      ENDDO


C
C***  SET CYCLE, DATE, AND FORECAST TIME.
C
c      IHR  =NTSD/NTSPH+0.5

!MAYBE      read(datestr,15)iyear,imn,iday,ihrst
         IDATE(2)=imn
         IDATE(3)=iday
         IDATE(1)=iyear
         IDATE(5)=ihrst

	IDAT(3)=IDATE(1)
	IDAT(1)=IDATE(2)
	IDAT(2)=IDATE(3)
	
      IYR  =IDAT(3)
      IMNTH=IDAT(1)
      IDAY =IDAT(2)
c      IFCST=(NTSD-1)*DT

!      IFCST=NTSPH*ITAG
      IFCST=3600*ITAG
	IHR=ITAG
	write(6,*) 'IFCST: ', IFCST
C
      WRITE(6,*)' POST PROFILE FOR ',
     1                       IYR,IMNTH,IDAY,IHR
	write(6,*) 'IHRST= ', IHRST
C
C***  SET RTSPH,RTSCU,RTSRA TO 1. OVER THE NUMBER OF TIMES THE
C***  VARIOUS PHYSICS ROUTINES HAVE BEEN
C***  CALLED SINCE LAST OUTPUT OF PROFILER DATA.  NECESSARY FOR
C***  CORRECT AVERAGING OF VARIABLES.
C

	write(6,*) 'APHTIM, ACUTIM, ARATIM were: ', 
     &                               APHTIM, ACUTIM, ARATIM
	APHTIM=0.
	ACUTIM=0.
	ARATIM=0.

      IF(APHTIM.GT.0.)THEN
        RTSPH=1./APHTIM
      ELSE
        RTSPH=1.
      ENDIF
C
      IF(ACUTIM.GT.0.)THEN
        RTSCU=1./ACUTIM
      ELSE
        RTSCU=1.
      ENDIF
C
      IF(ARATIM.GT.0.)THEN
        RTSRA=1./ARATIM
      ELSE
        RTSRA=1.
      ENDIF

	write(6,*) 'RTSPH, RTSCU, RTSRA: ', RTSPH, RTSCU, RTSRA
C
C--------------------------------------------------------------------------
C--------------------------------------------------------------------------
C***
C***  OUTPUT PROFILE DATA.  THE FOLLOWING LOOP IS OVER ALL PROFILE SITES.
C***
C--------------------------------------------------------------------------
	LCLAS1=79


	write(6,*) 'open output file with RECL: ', LRECPR
      OPEN(UNIT=LCLAS1,ACCESS='DIRECT',RECL=LRECPR,IOSTAT=IER)
C--------------------------------------------------------------------------
	write(6,*) 'RECORD LENGTH = ', LRECPR

	
      DO 1000 N=1,NUMSTA
C
C***  ZERO OUTPUT ARRAY.
C
      DO K=1,NWORDM
        PRODAT(K)=0.
        FPACK(K) =0.
      ENDDO
C
C***  CONSTRUCT HEADER FOR CURRENT PROFILE SITE.  THE HEADER CONTAINS
C***  THE FOLLOWING INFORMATION:  PACKED CYCLE-DATE, FORECAST TIME,
C***  INTEGER STATION ID, STATION LATITUDE, STATION LONGITUDE, STATION
C***  ELEVATION, NUMBER OF VERTICAL LEVELS IN PROFILE, NUMBER OF MULTI-
C***  LEVEL PARAMETERS, NUMBER OF SINGLE LEVEL PARAMETERS, TOTAL LENGTH
C***  (IN WORDS) OF MULTI- AND SINGLE LEVEL DATA, PROFILE CLASS FLAG,
C***  AND A DUMMY WORD FOR FUTURE USE.
C
      IH=IHINDX(N)
      JH=JHINDX(N)
      LMHK     = LMH(IH,JH)
      NWORD2   = 2*LMHK
      NWORD3   = 3*LMHK
      NWORD4   = 4*LMHK
      NWORD5   = 5*LMHK
      NWORD6   = 6*LMHK
      NWORD7   = 7*LMHK
      NWORD8   = 8*LMHK
      NWORD9   = 9*LMHK
      NWORD10  = 10*LMHK
      NWORD11  = 11*LMHK
      NWORD12  = 12*LMHK
      NWORD13  = 13*LMHK
      NWORD14  = 14*LMHK
      NWORD15  = 15*LMHK
      ISTAT    = IDSTN(N)
      CISTAT   = CIDSTN_SAVE(N)
!	write(6,*) 'CISTAT: ', CISTAT
C
      FPACK(1) = STNLAT(N)/DTR
!mp      FPACK(2) = -STNLON(N)/DTR
      FPACK(2) = STNLON(N)/DTR
      IF(FPACK(2).LT.-180.)FPACK(2)=FPACK(2)+360.
      FPACK(3) = FIS(N)*GI
      FPACK(4) = FLOAT(LMHK)
      FPACK(5) = LCL1ML
      FPACK(6) = LCL1SL
      FPACK(7) = 9+FPACK(5)*FPACK(4)+FPACK(6)
      FPACK(8) = 999.
      FPACK(9) = 999.

C
C***  WIND ROTATION SINES AND COSINES
C

      SINALP = SROT(N)
      COSALP = CROT(N)
C
C------------------------------------------------------------------
C***  EXTRACT PRESSURE AND TEMPERATURE PROFILES.
C***  EXTRACT/ROTATE U AND V WIND COMPONENT PROFILES.
C***  EXTRACT SPECIFIC HUMIDITY AND TEMPERATURE TENDENCY.
C***  EXTRACT CLOUD WATER, HEATING DUE TO CONVECTION, LARGE
C***  SCALE RAIN, SHORT WAVE RADIATION, LONG WAVE RADIATION,
C***  AND CLOUD FRACTION.
C------------------------------------------------------------------
C
      DO LV=1,LMHK
        LVL=LMHK-LV+1
!        PRODAT(LVL)      = PDSL1(N)*AETA(LV)+PT
        PRODAT(LVL)      = PMID(N,LV)
	if (mod(LV,15) .eq. 0 .and. mod(N,50) .eq. 0) then
	write(6,*) 'PRODAT definition, PMID: ', N,L,PMID(N,LV)
	endif
	
	if (LVL .eq. 1 .and. mod(N,25) .eq. 0) then
	write(6,*) 'N, PSFC: ', N,PRODAT(1)
	endif

        PRODAT(LMHK+LVL) = T(N,LV)

C***  ROTATE WINDS
C
        UT     = U(N,LV)
        VT     = V(N,LV)
        PRODAT(NWORD2+LVL) = UT*COSALP+VT*SINALP
        PRODAT(NWORD3+LVL) = VT*COSALP-UT*SINALP

	if (N .eq. 1) THEN
c	WRITE(6,*) 'orig U,V: ', UT,VT	
c	write(6,*) 'COSALP,SINALP: ', COSALP,SINALP
c	WRITE(6,*) 'rotat U,V: ', PRODAT(NWORD2+LVL),PRODAT(NWORD3+LVL)
c	write(6,*) '-----------------'
	endif

C
        PRODAT(NWORD4+LVL) = Q(N,LV)
C
        IF(RTOP(N,LV).GT.1.E-12) THEN
           PRODAT(NWORD5+LVL) = OMGA(N,LV)
Cmp     1   PRODAT(NWORD5+LVL) = OMGALF(N,LV)*CP/(RTOP(N,LV)*DT)
	ENDIF

!
!--- Separate posting of cloud water (NWORD6), rain (NWORD14), and
!    ice (cloud ice + snow, NWORD13).  The ice and rain fields are
!    *APPENDED* at the end of the section dealing with vertical
!    profile fields  (Ferrier/Manikin 11/30/04)
!

        QLIQ = (1.-F_ice(N,LV))*CWM(N,LV)
        PRODAT(NWORD13+LVL) = F_rain(N,LV)*QLIQ
        PRODAT(NWORD6+LVL) = QLIQ-PRODAT(NWORD7+LVL)
        PRODAT(NWORD14+LVL) = F_ice(N,LV)*CWM(N,LV)
        PRODAT(NWORD7+LVL) = TCUCN(N,LV)
        PRODAT(NWORD8+LVL) = TRAIN(N,LV)
        PRODAT(NWORD9+LVL) = RSWTT(N,LV)
        PRODAT(NWORD10+LVL)= RLWTT(N,LV)
        PRODAT(NWORD11+LVL)= CLDFRA(N,LV)*100.


!        IF(IW(N,LV).GT.0.5)THEN
!          PRODAT(NWORD6+LVL) = -CWM(N,LV)
!        ELSE
!          PRODAT(NWORD6+LVL) = CWM(N,LV)
!        ENDIF

C
!        PRODAT(NWORD7+LVL) = TCUCN(N,LV)
!        PRODAT(NWORD8+LVL) = TRAIN(N,LV)
!        PRODAT(NWORD9+LVL) = RSWTT(N,LV)
!        PRODAT(NWORD10+LVL)= RLWTT(N,LV)
!        PRODAT(NWORD11+LVL)= CCR(N,LV)*100.

C
        IF(LV.EQ.1)THEN
          PRODAT(NWORD12+LVL)=Q2(N,LV)
        ELSE
          PRODAT(NWORD12+LVL)=(Q2(N,LV)+Q2(N,LV-1))*0.5
        ENDIF
      ENDDO

C
C***  MODIFY ACCUMLATIONS SO AS TO REPRESENT ACCUMULATED
C***  CHANGE SINCE LAST PROFILE OUTPUT TIME.
C
CGSM  MODIFIED CODE TO ACCOUNT FOR DHCNVC AND DHRAIN BEING
C       COMPUTED FROM TOP DOWN WHILE PRODAT IS FILLED FROM
C       BOTTOM UP 
C

      DO LL=1,LMHK
        LVL=LMHK-LL+1
        STADHC(LL) = PRODAT(NWORD7+LL) - DHCNVC(LVL,N)
        STADHR(LL) = PRODAT(NWORD8+LL) - DHRAIN(LVL,N)
C
        DHCNVC(LVL,N) = PRODAT(NWORD7+LL)
        DHRAIN(LVL,N) = PRODAT(NWORD8+LL)
C
Ctmp        IF(MOD(NTSD,NHEAT).LT.NCNVC)THEN
          DHCNVC(LVL,N) = 0.
          DHRAIN(LVL,N) = 0.
Ctmp        ENDIF
      ENDDO
C
C***  EXTRACT SINGLE LEVEL DATA.   EGRID2 IS SURFACE TEMPERATURE.
C
      PRODAT(NWORD15+1)  = PSLP  (N)
      PRODAT(NWORD15+2)  = PDS   (N)
      PRODAT(NWORD15+3)  = EGRID2(N)
      PRODAT(NWORD15+4)  = TLMIN (N)
      PRODAT(NWORD15+5)  = TLMAX (N)
      PRODAT(NWORD15+6)  = SMSTAV(N)*100.
	if (mod(N,50) .eq. 0) then
	write(0,*) 'NWORD15+6, PRODAT(NWORD15+6) for SMSTAV(%): ', 
     &                     NWORD15+6, PRODAT(NWORD15+6)
	endif
      PRODAT(NWORD15+7)  = ACPREC(N)*1000.
      PRODAT(NWORD15+8)  = CUPREC(N)*1000.
      PRODAT(NWORD15+27) = Z0    (N)
C
      STAPRX=PRODAT(NWORD15+7)-STATPR(N)
      STACRX=PRODAT(NWORD15+8)-STACPR(N)

!	if (STAPRX .gt. 0) then
!	write(6,*) '1hr precip: ',  N,STAPRX
!	endif
C
C***  ROTATE WINDS
C
      UT     = U10(N)
      VT     = V10(N)
      PRODAT(NWORD15+28) = UT*COSALP+VT*SINALP
      PRODAT(NWORD15+29) = VT*COSALP-UT*SINALP
C
      PRODAT(NWORD15+30) = TH10  (N)
      PRODAT(NWORD15+31) = Q10   (N)
      PRODAT(NWORD15+32) = TSHLTR(N)
      PRODAT(NWORD15+33) = QSHLTR(N)
!      write(6,*) 'N, TSHLTR, QSHLTR into PRODAT: ', N, 
!     &                          TSHLTR(N),QSHLTR(N)
      PRODAT(NWORD15+34) = SFCEXC(N)
      PRODAT(NWORD15+35) = VEGFRC(N)
      PRODAT(NWORD15+36) = CMC   (N)*1000.
      PRODAT(NWORD15+37) = SMC   (N,1)
      PRODAT(NWORD15+38) = SMC   (N,2)
      PRODAT(NWORD15+39) = SMC   (N,3)
      PRODAT(NWORD15+40) = SMC   (N,4)
      PRODAT(NWORD15+41) = STC   (N,1)
      PRODAT(NWORD15+42) = STC   (N,2)
      PRODAT(NWORD15+43) = STC   (N,3)
      PRODAT(NWORD15+44) = STC   (N,4)
      PRODAT(NWORD15+45) = SM    (N) + SICE(N)
      PRODAT(NWORD15+46) = CFRACL(N)*100.
      PRODAT(NWORD15+47) = CFRACM(N)*100.
      PRODAT(NWORD15+48) = CFRACH(N)*100.
      PRODAT(NWORD15+49) = SR    (N)*100.
      PRODAT(NWORD15+50) = NINT(HBOT(N))
      PRODAT(NWORD15+51) = CPRATE(N)
      PRODAT(NWORD15+52) = F_RIMEF(N,LMHK)
C
      PRODAT(NWORD15+9)   = SFCLHX(N)
      PRODAT(NWORD15+10)  = POTFLX(N)
      PRODAT(NWORD15+11)  = SFCSHX(N)
      PRODAT(NWORD15+12)  = SUBSHX(N)
      PRODAT(NWORD15+13)  = SNOPCX(N)
      PRODAT(NWORD15+14)  = ASWIN (N)
      PRODAT(NWORD15+15)  = ASWOUT(N)
      PRODAT(NWORD15+16)  = ALWIN (N)
      PRODAT(NWORD15+17)  = ALWOUT(N)
      PRODAT(NWORD15+18)  =-ALWTOA(N)
      PRODAT(NWORD15+19)  = ASWTOA(N)
      PRODAT(NWORD15+20)  = ACSNOW(N)*1000.
      PRODAT(NWORD15+21)  = SMSTOT(N)*1.
      PRODAT(NWORD15+22)  = SNO   (N)*1000.
      PRODAT(NWORD15+23)  = ACSNOM(N)*1000.
!      PRODAT(NWORD15+24)  = SSROFF(N)*1000.
!      PRODAT(NWORD15+25)  = BGROFF(N)*1000.
      PRODAT(NWORD15+24)  = SSROFF(N)
      PRODAT(NWORD15+25)  = BGROFF(N)
      PRODAT(NWORD15+26)  = SOILTB(N)
C
C***  ACCUMULATED CHANGE SINCE LAST PROFILE OUTPUT TIME.
C
      PSFCEVP  = PRODAT(NWORD15+9 ) - STAEVP(N)
      PPOTEVP  = PRODAT(NWORD15+10) - STAPOT(N)
      PSFCSHX  = PRODAT(NWORD15+11) - STASHX(N)
      PSFCSUB  = PRODAT(NWORD15+12) - STASUB(N)
      PSNOPCX  = PRODAT(NWORD15+13) - STAPCX(N)
      PRSWIN   = PRODAT(NWORD15+14) - STASWI(N)
      PRSWOUT  = PRODAT(NWORD15+15) - STASWO(N)
      PRLWIN   = PRODAT(NWORD15+16) - STALWI(N)
      PRLWOUT  = PRODAT(NWORD15+17) - STALWO(N)
      PRLWTOA  = PRODAT(NWORD15+18) - STALWT(N)
      PRSWTOA  = PRODAT(NWORD15+19) - STASWT(N)
      PACSNOW  = PRODAT(NWORD15+20) - STASNO(N)
      PACSNOM  = PRODAT(NWORD15+23) - STASNM(N)
      PSSROFF  = PRODAT(NWORD15+24) - STASRF(N)
      PBGROFF  = PRODAT(NWORD15+25) - STABRF(N)
	if (N .eq. 256) then
	write(0,*) 'N, PRODAT(NWORD15+25), STABRF(N), PBGROFF: ', N, 
     &                 PRODAT(NWORD15+25), STABRF(N), PBGROFF
	endif
C***
C***  TRANSFER STATION PROFILE DATA TO "PACKED" OUTPUT ARRAY.
C***
      NN   = 0
      NLEN = FPACK(7)
C	write(6,*) 'NWORD13+41,NWORD13+32 ', NWORD13+41,NWORD13+32
C	write(6,*) 'SOIL TEMP ', PRODAT(NWORD13+41)
C        write(6,*) 'SHELT TEMP ', PRODAT(NWORD13+32) 
C
      DO NL = 10,NLEN
        NN = NL-9
        FPACK(NL) = PRODAT(NN)
      ENDDO
C
C***  REPLACE ACCUMULATED QUANTITIES WITH ACCUMULATION
C***  SINCE LAST PROFILE OUTPUT TIME.
C
      DO LL = 1,LMHK
!        FPACK(9+NWORD7+LL) = STADHC(LL)*RTSCU
!        FPACK(9+NWORD8+LL) = STADHR(LL)*RTSRA
        FPACK(9+NWORD7+LL) = -9999.
        FPACK(9+NWORD8+LL) = -9999.
      ENDDO
C
      FPACK(9+NWORD15+7)  = STAPRX
!	write(6,*) 'precip written to FPACK element: ', 9+NWORD13+7
      FPACK(9+NWORD15+8)  = STACRX
      FPACK(9+NWORD15+9)  = PSFCEVP * RTSPH
      FPACK(9+NWORD15+10) = PPOTEVP * RTSPH
      FPACK(9+NWORD15+11) = PSFCSHX * RTSPH
      FPACK(9+NWORD15+12) = PSFCSUB * RTSPH
      FPACK(9+NWORD15+13) = PSNOPCX * RTSPH
      FPACK(9+NWORD15+14) = PRSWIN  * RTSPH
      FPACK(9+NWORD15+15) = PRSWOUT * RTSPH
      FPACK(9+NWORD15+16) = PRLWIN  * RTSPH
	write(6,*) 'SW, LW in in FPACK: ', 
     &        FPACK(9+NWORD15+14), FPACK(9+NWORD15+16)
      FPACK(9+NWORD15+17) = PRLWOUT * RTSPH
      FPACK(9+NWORD15+18) = PRLWTOA * RTSPH
      FPACK(9+NWORD15+19) = PRSWTOA * RTSPH
      FPACK(9+NWORD15+20) = PACSNOW
      FPACK(9+NWORD15+23) = PACSNOM
      FPACK(9+NWORD15+24) = PSSROFF
      FPACK(9+NWORD15+25) = PBGROFF
C
!      IF(RESTRT)THEN
      IF(ITAG .eq. 0)THEN
        DO LL = 1,LMHK
          FPACK(9+NWORD7+LL) = 0.
          FPACK(9+NWORD8+LL) = 0.
        ENDDO
C
        FPACK(9+NWORD15+7)  = 0.
        FPACK(9+NWORD15+8)  = 0.
        FPACK(9+NWORD15+9)  = 0.
        FPACK(9+NWORD15+10) = 0.
        FPACK(9+NWORD15+11) = 0.
        FPACK(9+NWORD15+12) = 0.
        FPACK(9+NWORD15+13) = 0.
        FPACK(9+NWORD15+14) = 0.
        FPACK(9+NWORD15+15) = 0.
        FPACK(9+NWORD15+16) = 0.
        FPACK(9+NWORD15+17) = 0.
        FPACK(9+NWORD15+18) = 0.
        FPACK(9+NWORD15+19) = 0.
        FPACK(9+NWORD15+20) = 0.
        FPACK(9+NWORD15+23) = 0.
        FPACK(9+NWORD15+24) = 0.
        FPACK(9+NWORD15+25) = 0.
      ENDIF
C---------------------------------------------------------------------
C***
C***  WRITE PROFILE DATA
C***
      
!	write(6,*) 'IFHR, NUMSTA, N, NREC: ', IFHR, NUMSTA, N, 
!     &                      IFHR*NUMSTA+N

!normal       NREC=IFHR*NUMSTA+N
!       NREC=(IFHR/INCR)*NUMSTA+N
       NREC=N

!	write(6,*) 'NREC, NLEN, FPACK: ', NREC, NLEN,
!     &                       (FPACK(NNN),NNN=1,NLEN,NLEN/5)


	if (mod(NREC,20) .eq. 0) then
	write(6,*) 'NREC, IHRST, IDAT, IFCST, ISTAT, CISTAT: ', 
     &	NREC, IHRST, IDAT, IFCST, ISTAT, CISTAT
	endif

!	if (NREC .eq. 15) then
!	do NL=1,NLEN
!	write(6,*) 'NL, FPACK(NL): ', NL, FPACK(NL)
!	enddo
!	endif

      WRITE(LCLAS1,REC=NREC)IHRST,IDAT,IFCST,ISTAT,CISTAT
     1,                    (FPACK(NL),NL=1,NLEN)


C---------------------------------------------------------------------
 1000 CONTINUE
      CLOSE(LCLAS1)
	DEALLOCATE(T,Q,U,V,Q2,OMGALF,CWM,TRAIN,TCUCN)
	DEALLOCATE(RSWTT,RLWTT,CCR,RTOP,HTM,OMGA,p_hold)
	DEALLOCATE(t_hold,PINT)

	DEALLOCATE(DHCNVC,DHRAIN,STADHC,STADHR,TCUCN0,TRAIN0)
	DEALLOCATE(DUM,DUMMY,DUMMY2,DUM3D,DUM3D2,DUM3D3,GDLAT)
	DEALLOCATE(GDLON,PRODAT,FPACK,IDUM,LMH)

	DEALLOCATE(
     & RES,FIS,HBOT
     &,CFRACL,CFRACM,CFRACH,SNO
     &,SOILTB,SFCEXC,SMSTAV,SMSTOT
     &,Z0,CZEN,CZMEAN,U00,SR
     &,ACPREC,CUPREC,ACSNOW,ACSNOM
     &,SSROFF,BGROFF,SFCSHX,SFCLHX
     &,SUBSHX,SNOPCX,ASWIN,ASWOUT
     &,ASWTOA,ALWIN,ALWOUT,ALWTOA
     &,TSHLTR,QSHLTR,TH2_hold
     &,TH10,Q10,U10,V10
     &,TLMIN,TLMAX
     &,SMC,CMC,STC,SH2O
     &,VEGFRC,POTFLX,PSLP,PDSL1
     &,EGRID2,SM,SICE
     &,HBM2,FACTR
     &,PTBL,TTBL
     &,STATPR,STACPR,STAEVP
     &,STAPOT,STASHX,STASUB,STAPCX
     &,STASWI,STASWO,STALWI,STALWO
     &,STALWT,STASWT,STASNM,STASRF
     &,STABRF,STASNO
     &,ACPREC0,CUPREC0,SFCLHX0,POTFLX0
     &,SFCSHX0,SUBSHX0,SNOPCX0,ASWIN0
     &,ASWOUT0,ALWIN0,ALWOUT0,ALWTOA0
     &,ASWTOA0,ACSNOW0,ACSNOM0,SSROFF0
     &,BGROFF0,PVAPOR,ZINT)

C
C***  END OF PROFILE SITE LOOP
C
C***  END PROFILE POSTING CODE.
      call mpi_file_close(iunit,ierr)
      call mpi_finalize(mpi_comm_world, ierr)

C---------------------------------------------------------------------
      RETURN
      END
