!################################################################
!     Author: Shun Liu
!     Purpose: read REF mosaic and interpolate to model grid
 
!     Record of revisions:
!     Date            Programmer       Descrition of Change
!     =====================================================
!     01/02/2010      Shun Liu         Create from Jun Wang sample NEMSIO code
!     12/08/2012      Shun Liu         Modified to use simplified REF simulator
!     09/10/2013      Shun Liu         include ref height in the subroutine
!     12/10/2013      Shun Liu         output obs ref only 
!     03/17/2014      Shun Liu         output obs ref only 
!     03/17/2014      Shun Liu/Jacob Carley  check reflectivity domain boundary
!     08/20/2014      Shun Liu         distinguish no radar cover area and no qualified data area
!     01/24/2014      Shun Liu         use height from restart file
!################################################################

program ref2nemsio
  use nemsio_module
  implicit none
!
  integer, parameter:: double=selected_real_kind(p=13,r=200)
  type(nemsio_gfile) :: gfile,gfile2,gfile3
!
  real (kind=8) timef
  character(255) cin,cout,cout2,cout3,cout4,cin2
  character(4) gdatatype,modelname
  real,allocatable  :: data(:),tmp(:),fis(:),data1(:),tmp1(:),fis1(:)
  real,allocatable  :: datatmp(:,:),spfh(:,:),tke(:,:)
!---------------------------------------------------------------------------
!--- nemsio meta data
  real  isecond,pdtop,stime,etime,dummy,degrad,wind10m,windtmp
  integer nrec,im,jm,lm,l,idate(7),version, im2,jm2, nframe, &
          ntrac,irealf,nrec1,version1,nmeta,nfhour,nfminute,nfsecond, &
          nfsecondn,nfsecondd,num3d,num2d,nmetavari,nmetavarr,nmetavarl,  &
          nmetaaryi,nmetaaryr
  integer ihrst,idat(3),mp_physics,sf_surface_physics,icycle,fieldsize
  logical global, run,extrameta
  real,allocatable       :: glat1d(:),glon1d(:),gvlat1d(:),gvlon1d(:)
  real,allocatable       :: dsg1(:),dsg2(:),sgml1(:),sgml2(:),sg1(:),sg2(:)
  real,allocatable       :: dxh(:),sldpth(:),dx(:),dy(:),vcoord(:,:,:)
  real,allocatable       :: acfrcv(:,:),acfrst(:,:)        &
                           ,acprec(:,:),acsnom(:,:),acsnow(:,:)
  character(8),allocatable:: recname(:),metaaryrname(:)
  character(16),allocatable  :: reclevtyp(:)
  integer,allocatable:: reclev(:),metaaryrlen(:)
  character(8),allocatable:: recname1(:)
  character(16),allocatable  :: reclevtyp1(:)
  integer,allocatable:: reclev1(:)
  real,allocatable       :: metaaryrval(:,:),cpi(:),ri(:)
  integer:: tlmeta
!---------------------------------------------------------------------------
!--- local vars
  character(8) vname
  character(32) gtype
  character(16) vlevtyp
  integer i,ii,j,jj,jrec,krec,vlev,iret,lev
!---------------------------------------------------------------------------
!--- NMM vars
  integer NUNIT, NSOIL,irec,ndxh
!
  integer nphs,nclod,nheat,nprec,nrdlw,nrdsw,nsrfc
  real    aphtim,ardlw,ardsw,asrfc,avcnvc,avrain
  real    dt,dyh,pt,tlm0d,tph0d,tstart,dphd,dlmd
  CHARACTER(99) :: HISTFILE_ROOT='nmm_b_history.'
  CHARACTER(99) :: NAMELIST_FILE='history_hours.nml'
  CHARACTER(99) :: HISTORY_FILE

  real,allocatable :: hlatd(:),hlond(:),vlatd(:),vlond(:)
  integer,dimension(:,:),allocatable :: isltyp,ivgtyp,ncfrcv,ncfrst
  real,dimension(:,:),allocatable :: akhs_out,akms_out,albase,albedo,  &
    alwin,alwout,alwtoa,aswin,aswout,aswtoa,bgroff, &
    cfrach,cfracl,cfracm,cldefi,cmc,cnvbot,cnvtop,  &
    cprate,cuppt,cuprec,czen,czmean,epsr,grnflx, &
    hbotd,hbots,htopd,htops,mxsnal,pblh,prec,pshltr,potevp,&
    q10,qsh,qshltr,qwbs,qz0,radot,rlwin,rlwtoa,rswin,rswinc,&
    rswout,sfcevp,sfcexc,sfclhx,sfcshx,si,sice,sigt4,sm,   &
    smstav,smstot,sno,snopcx,soiltb,sr,ssroff,sst,subshx,  &
    f10m,tg,th10,ths,thz0,tshltr,twbs,u10,ustar,uz0,v10,vegfrc,vz0,z0 

  real,dimension(:,:),allocatable ::fissfc,pd
!
  real, dimension(:,:,:),allocatable :: cw,dwdt,cldfra,rrw,   &
        exch_h,omgalf,q,q2,rlwtt,rswtt,t,tcucn,train,u,v,w,xlen_mix
! real, dimension(:,:,:),allocatable :: f_ice,f_rain,f_rimef,pint
  real, dimension(:,:,:),allocatable :: stc,smc,sh2o

  integer, dimension(:,:),allocatable :: insoil,inveg
  character(8),allocatable :: variname(:),varrname(:),varlname(:),aryiname(:),aryrname(:)
  integer,allocatable :: varival(:),aryilen(:),aryrlen(:),aryival(:,:)
  real,allocatable :: varrval(:),aryrval(:,:)
  logical,allocatable :: varlval(:)

! define for GSI
  integer:: nlat, nlon,nsig_regional
  integer:: k,kr
  real :: rv, rd, fv, rdog, grav, dz, h
  real,dimension(:,:),allocatable   :: glat, glon
  real,dimension(:,:),allocatable   :: ges_pd, ges_ps, ges_z
  real,dimension(:),allocatable   :: eta1, eta2, zprl
  real,dimension(:,:,:),allocatable   :: ges_prsi,ges_prsl,ges_ref,ges_tp,ges_p,ges_clwmr 
  real,dimension(:,:,:),allocatable   :: dfi_tten
  real,dimension(:,:,:),allocatable   :: ges_tsen,ges_tv,ges_q,ges_hgt,refm,ges_hgt1,ges_hgtm
  real,dimension(:,:,:),allocatable   :: ges_qc,ges_qi,ges_qr,ges_qs   !,ges_q,ges_hgt
  real,dimension(:,:,:),allocatable   :: qvo,qco,qio,qro,tho  
  real,dimension(:,:,:),allocatable   :: ges_cwm, f_ice, f_rain, f_rimef
  real,dimension(:,:),allocatable:: p1d,t1d,q1d,c1d,fi1d,fr1d,fs1d,curefl
  real,dimension(:,:),allocatable:: qw1,qi1,qr1,qs1,dbz1,dbzr1,dbzi1,dbzc1
  real ::qi_tmp,qr_tmp,qw_tmp,t_tmp,f_ice_tmp,f_rain_tmp
  logical l_latent_heat
  logical l_water_vapor
  logical skip

! constant
real,parameter::  semi_major_axis = 6378.1370e3     !                     (m)
real,parameter::  semi_minor_axis = 6356.7523142e3  !                     (m)
real,parameter::  grav_polar      = 9.8321849378    !                     (m/s2)
real,parameter::  grav_equator    = 9.7803253359    !                     (m/s2)
real,parameter::  earth_omega     = 7.292115e-5     !                     (rad/s)
real,parameter::  grav_constant   = 3.986004418e14  !

real,parameter::  flattening = (semi_major_axis-semi_minor_axis)/semi_major_axis
real,parameter::  somigliana = &
       (semi_minor_axis/semi_major_axis) * (grav_polar/grav_equator) - 1.0

real,parameter::  grav_ratio = (earth_omega*earth_omega * &
        semi_major_axis*semi_major_axis * semi_minor_axis) / grav_constant
real,parameter:: deg2rad=3.1415926/180.0
real :: eccentricity_linear,eccentricity
real :: slat, termg, termr, sin2, termrg


! define for REF
  integer:: ig, jg, nn
  real:: rnn,rd_over_cp
  integer,allocatable,dimension(:,:) :: lonig,latjg
  real,dimension(:,:,:),allocatable   :: obs_ref 
  real(4), allocatable :: REFall(:,:), REFall1(:,:,:)
  integer :: ngrib_lon,ngrib_lat
  real,dimension(31):: ref_z
  real,parameter:: rdp=287.04,cp=1004.6

 data ref_z/500, 750, 1000, 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000, 3500, 4000,  &
  4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 10000, 11000, 12000,13000, &
  14000, 15000, 16000, 18000/
!
  character(90) :: HISTFILE

  NSOIL=4
  NUNIT=20
  degrad=90./asin(1.)
!
!**  READ THE NAMELIST
!---------------------------------------------------------------------------
!
!-------------set up nemsio write--------------------------
  call nemsio_init(iret=iret)
  print *,'nemsio_init, iret=',iret
!
!---------------------------------------------------------------------------
!******Example 2:  read full history file
!---------------------------------------------------------------------------
   rd_over_cp=rdp/cp
!--- open gfile for reading
  call getarg(1,cin)
  print *,'filename is cin=',trim(cin)
! call nemsio_open(gfile,trim(cin),'READ',iret=iret)
  call nemsio_open(gfile,trim(cin),'rdwr',iret=iret)
  print *,'after open READ, iret=',iret
  if (iret .ne.0 ) then
    stop
  endif

  call nemsio_getfilehead(gfile,iret=iret,tlmeta=tlmeta,nrec=nrec,dimx=im,dimy=jm, &
    dimz=lm,idate=idate,gdatatype=gdatatype,gtype=gtype,modelname=modelname, &
    nfhour=nfhour,nfminute=nfminute,nfsecondn=nfsecondn,nfsecondd=nfsecondd, &
    nframe=nframe,ntrac=ntrac,nsoil=nsoil,extrameta=extrameta,nmeta=nmeta)

  print *,'nemsio_getfilehead, iret=',iret,'nrec=',nrec,'im=',im,'jm=',jm, &
    'lm=',lm,'idate=',idate,'gdatatype=',gdatatype,'gtype=',trim(gtype), &
    'nfhour=',nfhour,'nfminute=',nfminute,'nfsecondn=',nfsecondn,'nfsecondd=', &
     nfsecondd,'modelname=',modelname,'extrameta=',extrameta,'nframe=',nframe, &
     'nmeta=',nmeta
    print*,' filehead::',tlmeta
!
   fieldsize=(im+2*nframe)*(jm+2*nframe)
   allocate(recname(nrec),reclevtyp(nrec),reclev(nrec))
   allocate(glat1d(fieldsize),glon1d(fieldsize),dx(fieldsize),dy(fieldsize))
   allocate(cpi(ntrac),ri(ntrac),vcoord(lm+1,3,2))
   call nemsio_getfilehead(gfile,iret=iret,recname=recname,reclevtyp=reclevtyp, &
       reclev=reclev,lat=glat1d,lon=glon1d,dx=dx,dy=dy,cpi=cpi,vcoord=vcoord )

    print *,'test recname=',recname(1:10)
    print *,'test reclevtyp=',reclevtyp(1:10)
    print *,'test reclev=',reclev(1:10)
    print *,'test glat1d=',glat1d(1:10),maxval(glat1d),minval(glat1d)
    print *,'test glon1d=',glon1d(1:10),maxval(glon1d),minval(glon1d)
    print *,'test cpi=',cpi
    print *,'test ri=',ri
    print *,'test dx=',dx(1:10),maxval(dx),minval(dx)
    print *,'test dy=',dy(1:10),maxval(dy),minval(dy)
    print *,'test vcoord11=',vcoord(:,1,1)
    print *,'test vcoord21=',vcoord(:,2,1)
    print *,'test vcoord12=',vcoord(:,1,2)
    print *,'test vcoord22=',vcoord(:,2,2)

   call nemsio_getfilehead(gfile,iret=iret,nmetavari=nmetavari,nmetavarr=nmetavarr, &
      nmetavarl=nmetavarl,nmetaaryi=nmetaaryi,nmetaaryr=nmetaaryr) 
     print *,'nmetavari=',nmetavari,'nmetavarr=',nmetavarr, &
        ' nmetavarl=',nmetavarl,'nmetaaryi=',nmetaaryi,'nmetaaryr=', nmetaaryr
   allocate(variname(nmetavari),varrname(nmetavarr),varlname(nmetavarl) )
   allocate(varival(nmetavari),varrval(nmetavarr),varlval(nmetavarl))
   allocate(aryiname(nmetaaryi),aryrname(nmetaaryr))
   allocate(aryilen(nmetaaryi),aryrlen(nmetaaryr))
   call neMsio_getfilehead(gfile,iret=iret,variname=variname,varrname=varrname, &
      varlname=varlname,varival=varival,varrval=varrval,varlval=varlval,         &
      aryiname=aryiname,aryrname=aryrname,aryilen=aryilen,aryrlen=aryrlen) 


    print *,'test variname=',variname
    print *,'test varival=',varival
    print *,'test varrname=',varrname
    print *,'test varrval=',varrval
    print *,'test varlname=',varlname
    print *,'test varlval=',varlval

   allocate(aryival(maxval(aryilen),nmetaaryi),aryrval(maxval(aryrlen),nmetaaryr))
!  call nemsio_getfilehead(gfile,iret=iret,aryival=aryival,aryrval=aryrval)
!  print *,'after aryival,iret=',iret
!   print *,'test aryiname=',aryiname
!   print *,'test aryilen=',aryilen
!   print *,'test aryival=',aryival

!   print *,'test aryrname=',aryrname
!   print *,'test aryrlen=',aryrlen
!   print *,'test aryrval=',aryrval(1:5,:)
!   print *,'test varlname=',varlname
!
    do i=1,nmetaaryi
     if(aryrname(i)=='DXH') then
       ndxh=aryrlen(i)
       exit
     endif
    enddo
    print *,'ndxh=',ndxh

   run=.false.
   global=.false.
   call nemsio_getheadvar(gfile,'run',run,iret)
   print*,'after nemsio_getheadvar,var run=',run,'iret=',iret
   call nemsio_getheadvar(gfile,'global',global,iret)
   print*,'after nemsio_getheadvar,var global=',global,'iret=',iret

!
!---------------------------------------------------------------------------
!****** read all the records
!---------------------------------------------------------------------------
   nlon=im
   nlat=jm

   allocate(glat(nlon,nlat),glon(nlon,nlat))

     ii=0
     do j=1,nlat
        do i=1,nlon
           ii=ii+1
           glat(i,j)=glat1d(ii)/deg2rad       ! input lat in degrees
           glon(i,j)=glon1d(ii)/deg2rad       ! input lon in degrees
        end do
     end do

!    do j=1,nlat,100
!      write(8,100)(glon(i,j),glat(i,j),i=1,nlon,200)
!100  format(20f8.3)
!    end do
!   stop

   call nemsio_getheadvar(gfile,'PDTOP',pdtop,iret)
   print*,'after nemsio_getheadvar,var pdtop=',pdtop,'iret=',iret

   allocate(ges_pd(nlon,nlat))
   allocate(tmp(fieldsize))
   tmp=0.0
   call nemsio_readrecv(gfile,'dpres','hybrid sig lev',1,tmp(:),iret=iret)
     ii=0
     do j=1,nlat
        do i=1,nlon
           ii=ii+1
           ges_pd(i,j)=tmp(ii)
        end do
     end do

   call nemsio_getheadvar(gfile,'PT',pt,iret)
   print*,'after nemsio_getheadvar,var PT=',pt,'iret=',iret
   pt=pt*.01
   pdtop=pdtop*.01

   allocate(ges_ps(nlon,nlat))
   do j=1,nlat
   do i=1,nlon
          ges_ps(i,j)=0.1*(0.01*ges_pd(i,j)+pt)
   end do
   end do

   nsig_regional=lm
   if(1==0)then

   !                  sg1       (used to be eta1)
   allocate(sg1(nsig_regional+1),eta1(nsig_regional+1))
   call nemsio_getheadvar(gfile,'SG1',sg1,iret)
   do k=1,nsig_regional+1
      eta1(k)=sg1(nsig_regional+2-k)
   end do

   !                  sg2       (used to be eta1)
   allocate(sg2(nsig_regional+1),eta2(nsig_regional+1))
   call nemsio_getheadvar(gfile,'SG2',sg2,iret)
   do k=1,nsig_regional+1
      eta2(k)=sg2(nsig_regional+2-k)
   end do

   allocate(ges_prsi(nlon,nlat,nsig_regional+1))
   do k=1,nsig_regional+1
   do j=1,nlat
   do i=1,nlon
        ges_prsi(i,j,k)=0.1*(eta1(k)*pdtop + &
                eta2(k)*(10.0*ges_ps(i,j)-pt) +  pt)
!       if(i==1.and.j==1) then 
!               write(6,*)k,ges_prsi(i,j,k)*1000, eta1(k),eta2(k),ges_ps(i,j)
!       end if
   end do
   end do
   end do
   deallocate(sg1,eta1)
   deallocate(sg2,eta2)

   !                  sgml1       (used to be aeta1)
   nsig_regional=lm
   allocate(sg1(nsig_regional),eta1(nsig_regional))
   call nemsio_getheadvar(gfile,'SGML1',sg1,iret)
   do k=1,nsig_regional
      eta1(k)=sg1(nsig_regional+1-k)
   end do

   !                  sgml2       (used to be aeta2)
   allocate(sg2(nsig_regional),eta2(nsig_regional))
   call nemsio_getheadvar(gfile,'SGML2',sg2,iret)
   do k=1,nsig_regional
      eta2(k)=sg2(nsig_regional+1-k)
   end do

   allocate(ges_prsl(nlon,nlat,nsig_regional))
   do k=1,nsig_regional
   do j=1,nlat
   do i=1,nlon
        ges_prsl(i,j,k)=0.1*(eta1(k)*pdtop + &
                eta2(k)*(10.0*ges_ps(i,j)-pt) +  pt)
!       if(i==1.and.j==1) then 
!               write(6,*)k,ges_prsl(i,j,k),ges_prsi(i,j,k), eta1(k),eta2(k),ges_ps(i,j)
!       end if
   end do
   end do
   end do

   allocate(ges_z(nlon,nlat))
   call nemsio_readrecv(gfile,'hgt','sfc',1,tmp(:),iret=iret)
     ii=0
     do j=1,nlat
        do i=1,nlon
           ii=ii+1
           ges_z(i,j)=tmp(ii)
        end do
     end do
    end if

   allocate(ges_tsen(nlon,nlat,nsig_regional))
   allocate(ges_ref(nlon,nlat,nsig_regional))
   allocate(dfi_tten(nlon,nlat,nsig_regional))
   allocate(ges_clwmr(nlon,nlat,nsig_regional))
   allocate(ges_q(nlon,nlat,nsig_regional))
   allocate(ges_p(nlon,nlat,nsig_regional))
   allocate(ges_qc(nlon,nlat,nsig_regional))
   allocate(ges_qi(nlon,nlat,nsig_regional))
   allocate(ges_qs(nlon,nlat,nsig_regional))
   allocate(ges_qr(nlon,nlat,nsig_regional))
   allocate(ges_tv(nlon,nlat,nsig_regional))
   allocate(ges_tp(nlon,nlat,nsig_regional))
   allocate(qvo(nlon,nlat,nsig_regional))
   allocate(qco(nlon,nlat,nsig_regional))
   allocate(qro(nlon,nlat,nsig_regional))
   allocate(qio(nlon,nlat,nsig_regional))
!  allocate(ges_cwm(nlon,nlat,nsig_regional))
!  allocate(f_ice(nlon,nlat,nsig_regional))
!  allocate(f_rain(nlon,nlat,nsig_regional))
!  allocate(f_rimef(nlon,nlat,nsig_regional))
   allocate(p1d(nlon,nlat),t1d(nlon,nlat),q1d(nlon,nlat),c1d(nlon,nlat))
   allocate(fi1d(nlon,nlat),fr1d(nlon,nlat),fs1d(nlon,nlat),curefl(nlon,nlat))
   allocate(qw1(nlon,nlat),qi1(nlon,nlat),qr1(nlon,nlat),qs1(nlon,nlat))
   allocate(dbz1(nlon,nlat),dbzr1(nlon,nlat),dbzi1(nlon,nlat),dbzc1(nlon,nlat))
   allocate(ges_hgtm(nlon,nlat,nsig_regional))
!  allocate(ges_hgt(nlon,nlat,nsig_regional))
!  allocate(ges_hgt1(nlon,nlat,nsig_regional))
   do kr=1,nsig_regional
     k=nsig_regional+1-kr
     call nemsio_readrecv(gfile,'z','mid layer',k,tmp(:),iret=iret)
     call copydata1to2(nlat,nlon,ges_hgtm(:,:,k),tmp)
   end do
   rd     = 2.8705e+2
   rv     = 4.6150e+2
   fv=rv/rd-1.0
   do kr=1,nsig_regional
     k=nsig_regional+1-kr
     call nemsio_readrecv(gfile,'spfh','mid layer',k,tmp(:),iret=iret)
     call copydata1to2(nlat,nlon,ges_q(:,:,k),tmp)
     call nemsio_readrecv(gfile,'tmp','mid layer',k,tmp(:),iret=iret)
     call copydata1to2(nlat,nlon,ges_tsen(:,:,k),tmp)
!    call nemsio_readrecv(gfile,'z','mid layer',k,tmp(:),iret=iret)
!    call copydata1to2(nlat,nlon,ges_hgt1(:,:,k),tmp)
     do j=1,nlat
        do i=1,nlon
        ges_tv(i,j,k)=ges_tsen(i,j,k)*(1.0+fv*ges_q(i,j,k))
!       ges_tp(i,j,k)=ges_tsen(i,j,k)*(100.0/ges_prsl(i,j,kr))**rd_over_cp
        end do
     end do

!    p1d=ges_prsl(:,:,kr)*1000.0
!    ges_p(:,:,k)=ges_prsl(:,:,kr)*1000.0
!    t1d=ges_tsen(:,:,k)
!    q1d=ges_q(:,:,k)

     !* do not calculate reflectivity
     if(1==0)then
     call nemsio_readrecv(gfile,'clwmr','mid layer',k,tmp(:),iret=iret)
     call copydata1to2(nlat,nlon,c1d(:,:),tmp)

     call nemsio_readrecv(gfile,'f_ice','mid layer',k,tmp(:),iret=iret)
     call copydata1to2(nlat,nlon,fi1d(:,:),tmp)

     call nemsio_readrecv(gfile,'f_rain','mid layer',k,tmp(:),iret=iret)
     call copydata1to2(nlat,nlon,fr1d(:,:),tmp)

     call nemsio_readrecv(gfile,'f_rimef','mid layer',k,tmp(:),iret=iret)
     call copydata1to2(nlat,nlon,fs1d(:,:),tmp)
     do j=1,nlat
        do i=1,nlon
         fs1d(i,j)=max(1.0,fs1d(i,j))
        end do
     end do


     curefl=1.0
     dbz1=0.0
!    call calmict(p1d,t1d,q1d,c1d,fi1d,fr1d,fs1d,Curefl, &
!               qw1,qi1,qr1,qs1,dbz1,dbzr1,dbzi1,dbzc1,nlon,nlat,k)
     
!    qw1=0.0; qi1=0.0; qr1=0.0; qs1=0.0
!    call calmict_sim(p1d,t1d,q1d,c1d,fi1d,fr1d,fs1d,Curefl, &
!               qw1,qi1,qr1,qs1,nlon,nlat,k)
!    write(6,*)'maxval(c1d) 2::',k,maxval(c1d*1000),maxval(fi1d*1000),&
!                                 maxval(fr1d*1000),maxval(fs1d*1000)
!    write(6,'(i6,5f12.7)')'maxval(c1d) 2::',k, maxval(c1d*1000),maxval(qw1*1000),&
!    write(6,202)k, maxval(c1d*1000),maxval(qw1*1000),&
!                                 maxval(qr1*1000),maxval(qi1*1000), &
!                                 maxval(qs1*1000)

201   format('maxval(c1d) 1::',i6,5f12.7) 
202   format('maxval(c1d) 2::',i6,5f12.7) 

     !* snow is large ice
     ges_qc(:,:,k)=qw1
     ges_qi(:,:,k)=qi1
     ges_qs(:,:,k)=qs1
     ges_qr(:,:,k)=qr1
     ges_ref(:,:,k)=dbz1
     ges_clwmr(:,:,k)=c1d
     end if
     !* end block of calculating reflectivity

   end do

   allocate(ges_hgt(nlon,nlat,nsig_regional))
   grav   = 9.80665
   rdog=rd/grav


   do j=1,nlat
     do i=1,nlon
        if(1==0)then
        k=1
        h=rdog*ges_tv(i,j,k)
        dz=h*log(ges_prsi(i,j,k)/ges_prsl(i,j,k))
        ges_hgt(i,j,k)=ges_z(i,j)+dz

        do k=2, nsig_regional
          h  = rdog * 0.5 * (ges_tv(i,j,k-1)+ges_tv(i,j,k))
          dz = h * log(ges_prsl(i,j,k-1)/ges_prsl(i,j,k))
          ges_hgt(i,j,k)=ges_hgt(i,j,k-1)+dz
        end do
        end if

        slat=glat(i,j)*deg2rad
        eccentricity_linear = sqrt(semi_major_axis**2 - semi_minor_axis**2)
        eccentricity = eccentricity_linear / semi_major_axis

        sin2  = sin(slat)*sin(slat)
        termg = grav_equator * &
          ((1.0+somigliana*sin2)/sqrt(1.0-eccentricity*eccentricity*sin2))
        termr = semi_major_axis /(1.0 + flattening + grav_ratio -  &
          2.0*flattening*sin2)
        termrg = (termg/grav)*termr

        do k=1,nsig_regional
         kr=nsig_regional+1-k
!        ges_hgt(i,j,k) = (termr*ges_hgt(i,j,k)) / (termrg-ges_hgt(i,j,k))  ! eq (23)
         ges_hgt(i,j,k) = (termr*ges_hgtm(i,j,kr)) / (termrg-ges_hgtm(i,j,kr))  ! eq (23)
        end do

     end do
   end do

!  deallocate(ges_prsi,ges_prsl)
   call nemsio_close(gfile,iret=iret)


!---------------------------------------------------------------------------
!******  reflectivity interpolation
!---------------------------------------------------------------------------
    ngrib_lon=1401;ngrib_lat=701
    allocate(refall(ngrib_lon,ngrib_lat))
    allocate(refall1(ngrib_lon,ngrib_lat,31))
    refall=-999.0
    refall1=-999.0

    open(1,file='ref3d')
    do k=1,31
      read(1,*)
      do i=1,ngrib_lat
      do j=1,ngrib_lon
       read(1,*)refall(j,i)
      end do
      end do
      refall1(:,:,k)=refall(:,:)
     end do

    where(abs(refall1)>100) refall1=-9.E+20

   allocate(lonig(nlon,nlat))
   allocate(latjg(nlon,nlat))
   allocate(obs_ref(nlon,nlat,nsig_regional))
   allocate(zprl(nsig_regional))
   obs_ref=-9.E+20
   print *,'****   start reflectivity interpolation ****'

           lonig=9999; latjg=9999
           do i=2,nlon-1
           do j=2,nlat-1
             if(glat(i,j)>19.5.and.glat(i,j)<55.0   .and.  &
                glon(i,j)>-137.0.and.glon(i,j)<-59.0    ) then
              ig=int((glon(i,j)+130.0)*100)/5  !nlon
              jg=int((glat(i,j)-20.0)*100)/5   !nlat
              if(ig>1.and.jg>1.and.ig<ngrib_lon.and.jg<ngrib_lat)then
                lonig(i,j)=ig
                latjg(i,j)=jg
                zprl=ges_hgt(i,j,:)
           do k=1,nsig_regional
             rnn=99.0
             nn=99
             if(zprl(k)>=350.0.and.zprl(k)<3250.0) then
             rnn=(zprl(k)-500.0)/250.0+1.0
             else if(zprl(k)>=3250.and.zprl(k)<9250.0) then
             rnn=(zprl(k)-3000.0)/500.0+11.0
             else if(zprl(k)>=9250.and.zprl(k)<16500.0) then
             rnn=(zprl(k)-9000.0)/1000.0+23.0
             else if(zprl(k)>=16500.and.zprl(k)<18500.0) then
             rnn=(zprl(k)-16000.0)/2000.0+30.0
             end if

             nn=nint(rnn)
             if(nn>=1 .and. nn<32)then
               kr=nsig_regional+1-k
               obs_ref(i,j,kr)=refall1(ig,jg,nn)
               if(abs(refall1(ig,jg,nn))>80.0) then
               outer: do ii=-1,1,2
               do jj=-1,1,2 
               if(abs(refall1(ig+ii,jg+jj,nn))<=80.0)then
                 obs_ref(i,j,kr)=refall1(ig+ii,jg+jj,nn)
                 exit outer 
               end if
               end do
               end do outer
               end if
!              if(obs_ref(i,j,kr)>40.0)write(6,*)'interpolation::',obs_ref(i,j,kr),refall1(ig,jg,nn)
             end if
           end do

              end if
             end if
           end do
           end do
    deallocate(refall1,ges_hgt,ges_tv,lonig,latjg,zprl,refall,ges_tsen)

!
!---------------------------------------------------------------------------
!****** close nemsio file
!---------------------------------------------------------------------------

!---------------------------------------------------------------------------
!******Example:  creat new nemsio data fields
!---------------------------------------------------------------------------
!
   deallocate(recname, reclev, reclevtyp)

   cin='obsref.nemsio'
   nrec=nsig_regional
   allocate(recname(nrec))
   allocate(reclev(nrec))
   allocate(reclevtyp(nrec))

   do i=1,nsig_regional
   recname(i)='obs_ref'
   reclev(i)=i
   reclevtyp(i)='mid layer'
   write(6,*)i, reclev(i),recname(i)
   end do

   write(6,*)'im,jm,lm::',im,jm,lm

   call nemsio_open(gfile3,trim(cin),'write',iret=iret,nrec=nrec, &
                    gdatatype='bin4',dimx=im,dimy=jm,dimz=lm,nmeta=5, &
                    recname=recname,reclevtyp=reclevtyp,reclev=reclev)
    tmp=0.0

    do k=1,nsig_regional
    tmp=0.0
               do i=1,nlon
               do j=1,nlat
                  obs_ref(i,j,1)=maxval(obs_ref(i,j,:))
               end do
               end do
    call copydata2to1(nlat,nlon,obs_ref(:,:,k),tmp)
    call nemsio_writerecv(gfile3,'obs_ref','mid layer',k,tmp(:),iret=iret)
    write(6,*)'max obs_ref::', k, maxval(obs_ref(:,:,k)),iret,recname(k),reclev(k)
    end do

    call nemsio_close(gfile3,iret=iret)
    
    write(6,*)'Successful ref2nemsio'

 end program

 subroutine variable2fraction(t, qi, qr, qw, f_ice, f_rain)

!use kinds, only: r_kind
! input:
! qi    -  cloud ice mixing ratio
! qr    -  rain mixing ratio
! qw    -  cloud water mixing ratio

! output:
! f_ice     -  fraction of condensate in form of ice
! f_rain    -  fraction of liquid water in form of rain
! f_rimef   -  ratio of total ice growth to deposition groth

   real t, qi, qr, qw, wc, dum
   real f_ice, f_rimef, f_rain
   real,parameter:: epsq=1.e-12
   real,parameter:: tice=233.15,ticek=273.15

   wc=qi+qr+qw
   if(wc > 0.0) then
     if(qi<epsq)then 
           f_ice=0.0
           if(t<ticek) f_ice=1.0
!          f_rimef=1.0
     else 
           f_ice=0.0
           dum=qi/wc
           if(dum<1.0) then
             f_ice=dum
           else
             f_ice=1.0
           end if
     end if

     if(qr < epsq) then
           f_rain=0.0
     else
           f_rain=qr/(qr+qw)
     end if
   else
           f_rain=0.0
           f_ice=0.0
   end if

 end subroutine variable2fraction



 subroutine copydata1to2(nlat,nlon,a2d,a1d)
 integer :: nlat, lon, i, ii, j
 real,dimension(nlon,nlat)::a2d
 real,dimension(nlon*nlat)::a1d
     ii=0
     do j=1,nlat
        do i=1,nlon
           ii=ii+1
           a2d(i,j)=a1d(ii)
        end do
     end do
 end subroutine copydata1to2

 subroutine copydata2to1(nlat,nlon,a2d,a1d)
 integer :: nlat, lon, i, ii, j
 real,dimension(nlon,nlat)::a2d
 real,dimension(nlon*nlat)::a1d
     ii=0
     do j=1,nlat
        do i=1,nlon
           ii=ii+1
           a1d(ii)=a2d(i,j)
        end do
     end do
 end subroutine copydata2to1


 !***********************************************************************
!-----------------------------------------------------------------------
                           FUNCTION FPVS(T)
!-----------------------------------------------------------------------
!$$$  SUBPROGRAM DOCUMENTATION BLOCK
!                .      .    .
! SUBPROGRAM:    FPVS        COMPUTE SATURATION VAPOR PRESSURE
!   AUTHOR: N PHILLIPS            W/NP2      DATE: 30 DEC 82
!
! ABSTRACT: COMPUTE SATURATION VAPOR PRESSURE FROM THE TEMPERATURE.
!   A LINEAR INTERPOLATION IS DONE BETWEEN VALUES IN A LOOKUP TABLE
!   COMPUTED IN GPVS. SEE DOCUMENTATION FOR FPVSX FOR DETAILS.
!   INPUT VALUES OUTSIDE TABLE RANGE ARE RESET TO TABLE EXTREMA.
!   THE INTERPOLATION ACCURACY IS ALMOST 6 DECIMAL PLACES.
!   ON THE CRAY, FPVS IS ABOUT 4 TIMES FASTER THAN EXACT CALCULATION.
!   THIS FUNCTION SHOULD BE EXPANDED INLINE IN THE CALLING ROUTINE.
!
! PROGRAM HISTORY LOG:
!   91-05-07  IREDELL             MADE INTO INLINABLE FUNCTION
!   94-12-30  IREDELL             EXPAND TABLE
!   96-02-19  HONG                ICE EFFECT
!
! USAGE:   PVS=FPVS(T)
!
!   INPUT ARGUMENT LIST:
!     T        - REAL TEMPERATURE IN KELVIN
!
!   OUTPUT ARGUMENT LIST:
!     FPVS     - REAL SATURATION VAPOR PRESSURE IN KILOPASCALS (CB)
!
! COMMON BLOCKS:
!   COMPVS   - SCALING PARAMETERS AND TABLE COMPUTED IN GPVS.
!
! ATTRIBUTES:
!   LANGUAGE: FORTRAN 90
!   MACHINE:  IBM SP
!
!$$$
!-----------------------------------------------------------------------
!      use spvtbl_mod, only : NX,C1XPVS,C2XPVS,TBPVS
!
      implicit none
!
      integer,parameter::NX=7501
      real C1XPVS,C2XPVS,TBPVS(NX)

      real T
      real XJ
      integer JX
      real FPVS
!-----------------------------------------------------------------------
      XJ=MIN(MAX(C1XPVS+C2XPVS*T,1.),FLOAT(NX))
      JX=MIN(XJ,NX-1.)
      FPVS=TBPVS(JX)+(XJ-JX)*(TBPVS(JX+1)-TBPVS(JX))
!
      RETURN
      END
!-----------------------------------------------------------------------

