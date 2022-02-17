function lwp (args)

expid    = subwrd(args,1)
output   = subwrd(args,2)
debug    = subwrd(args,3)

* Define Seasons to Process
* -------------------------
seasons  = ''
       k = 4
while( k > 0 )
    season = subwrd(args,k)
if( season = '' )
    k = -1
else
    seasons = seasons % ' ' % season
k = k+1
endif
endwhile
'uppercase 'seasons
            seasons = result

'run getenv "TAYLOR"'
         taylor = result
if(      taylor = 'true' )

* Initialize
* ----------
'reinit'
'set display color white'
'set clab off'
'c'

'run getenv "GEOSUTIL"'     ; geosutil     = result
'run getenv "VERIFICATION"' ; verification = result


* Get Liquid Water Path Variables
* -------------------------------
'run getvar LWP MOIST'
        qname.1 = subwrd(result,1)
        qfile.1 = subwrd(result,2)
        scale.1 = subwrd(result,3)
        expdsc  = subwrd(result,4)

'run getvar LWI SURFACE'
        qname.2 = subwrd(result,1)
        qfile.2 = subwrd(result,2)
        scale.2 = subwrd(result,3)

'run getvar CCWP MOIST'
        qname.3 = subwrd(result,1)
        qfile.3 = subwrd(result,2)
        scale.3 = subwrd(result,3)

if( qname.1 = "NULL" ) ; return ; endif
if( qname.3 = "NULL" ) ; return ; endif


* Ensure NAMES have no underscores
* --------------------------------
      num=3
        m=1
while ( m<num+1 )
'fixname 'qname.m
          alias.m = result
say 'Alias #'m' = 'alias.m
        m = m+1
endwhile


* Experiment Datasets
* -------------------
'set dfile 'qfile.1
'setlons'
'set lat -90 90'
'setdates'
'sett'

* Land/Water Masks
* ----------------
lw = 2
if( qname.lw = "NULL" )
   'setmask mod'
   'define  maskmod = lwmaskmod'
   'define omaskmod = maskout( 1, maskmod-0.5 )'
   'define lmaskmod = maskout( 1, 0.5-maskmod )'
else

* Initialize Mask using Dataset Values (Note: Adjust if Needed)
* -------------------------------------------------------------
'run getenv "LMASK"' ; lmask = result
'run getenv "OMASK"' ; omask = result
'run getenv "IMASK"' ; imask = result
               if( lmask = "NULL" ) ; lmask = 1 ; endif
               if( omask = "NULL" ) ; omask = 0 ; endif
               if( imask = "NULL" ) ; imask = 2 ; endif

   'set dfile 'qfile.lw
   'set z 1'
   'sett'
    if( qname.lw != alias.lw ) ; 'rename 'qname.lw ' 'alias.lw ; endif
   'define   omask = maskout( 1 , -abs('alias.lw'-'omask') )'
   'define   lmask = maskout( 1 , -abs('alias.lw'-'lmask') )'

   'seasonal omask'
   'seasonal lmask'
   'set t 1'
   'define   omaskmod = omask'season
   'define   lmaskmod = lmask'season
endif


* Verification Datasets
* ---------------------
'   open 'verification'/SSMI/ssmi.ctl'
'getinfo  numfiles'
          ssmifile = result

*'set dfile 'ssmifile
*'setmask obs'

'set dfile 'ssmifile
'set z 1'
'getdates'
'define   lwpo = lwp*1000'
*'define   lwpo = maskout( lwp,lwmaskobs-0.5 )'
'seasonal lwpo'


* Model Data Sets
* ---------------
'set dfile 'qfile.1
'set z 1'
'sett'
if( qname.1 != alias.1 ) ; 'rename 'qname.1 ' 'alias.1 ; endif
'define   lwpm = maskout( 'alias.1'*'scale.1',omaskmod )*1000'
'seasonal lwpm'

'set dfile 'qfile.3
'set z 1'
'sett'
if( qname.3 != alias.3 ) ; 'rename 'qname.3 ' 'alias.3 ; endif
'define   ccwpm = maskout( 'alias.3'*'scale.3',omaskmod )*1000'
'seasonal ccwpm'

* Perform Taylor Plots
* --------------------
'set dfile 'qfile.1
'define twpmdjf = lwpmdjf + ccwpmdjf'
'define twpmjja = lwpmjja + ccwpmjja'
'define twpmson = lwpmson + ccwpmson'
'define twpmmam = lwpmmam + ccwpmmam'
'define twpmann = lwpmann + ccwpmann'

'taylor twpmdjf lwpodjf djf 'expid
'taylor twpmjja lwpojja jja 'expid
'taylor twpmson lwposon son 'expid
'taylor twpmmam lwpomam mam 'expid
'taylor twpmann lwpoann ann 'expid

'taylor_write 'expid' LWP 'output
'taylor_read   GFDL   LWP 'verification
'taylor_read   CAM3   LWP 'verification
'taylor_read   e0203  LWP 'verification
                                                                                                   
"taylor_plt 4 CAM3 GFDL e0203 "expid" "output" LWP 'Liquid Water Path vs SSMI' "debug

endif
