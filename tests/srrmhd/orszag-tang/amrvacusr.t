!=============================================================================
! amrvacusr.t.srmhdOT

! INCLUDE:amrvacnul/specialini.t
! INCLUDE:amrvacnul/speciallog.t
INCLUDE:amrvacnul/specialbound.t
INCLUDE:amrvacnul/specialsource.t
INCLUDE:amrvacnul/specialimpl.t
INCLUDE:amrvacnul/usrflags.t
INCLUDE:amrvacnul/correctaux_usr.t
!=============================================================================
subroutine initglobaldata_usr

include 'amrvacdef.f'
!-----------------------------------------------------------------------------
eqpar(gamma_) = 4.0d0/3.0d0
eqpar(eta_)   = 1.0d-2
end subroutine initglobaldata_usr
!=============================================================================
subroutine initonegrid_usr(ixG^L,ix^L,w,x)

! initialize one grid
include 'amrvacdef.f'

integer, intent(in) :: ixG^L, ix^L
double precision, intent(in) :: x(ixG^S,1:ndim)
double precision, intent(inout) :: w(ixG^S,1:nw)
! .. local ..
double precision                :: vD(ixG^S,1:^NC), bD(ixG^S,1:^NC)
double precision:: rho0,p0,vmax

logical, save :: first=.true.
logical:: patchw(ixG^T)
!----------------------------------------------------------------------------
oktest = index(teststr,'initonegrid_usr')>=1
if (oktest) write(unitterm,*) ' === initonegrid_usr  (in ) : ', &
      'ixG^L : ',ixG^L

rho0=one
p0=10.0d0
vmax=0.99d0

vmax=vmax/dsqrt(two)


w(ix^S,psi_)  = 0.0d0
w(ix^S,phib_) = 0.0d0
w(ix^S,q_)    = 0.0d0


w(ix^S,rho_)=rho0
w(ix^S,v1_)=-vmax*sin(x(ix^S,2))
w(ix^S,v2_)= vmax*sin(x(ix^S,1))
w(ix^S,pp_)=p0
w(ix^S,b1_)=-sin(x(ix^S,2))
w(ix^S,b2_)= sin(two*x(ix^S,1))

w(ix^S,e1_)  = w(ix^S,b2_)*w(ix^S,u3_) - w(ix^S,b3_)*w(ix^S,u2_)
w(ix^S,e2_)  = w(ix^S,b3_)*w(ix^S,u1_) - w(ix^S,b1_)*w(ix^S,u3_)
w(ix^S,e3_)  = w(ix^S,b1_)*w(ix^S,u2_) - w(ix^S,b2_)*w(ix^S,u1_)


{#IFDEF EPSINF
w(ix^S,epsinf_)=one
w(ix^S,rho0_)=one
w(ix^S,rho1_)=one
w(ix^S,n_)=one
w(ix^S,n0_)=one
}

  
w(ix^S,lfac_)=one/dsqrt(one-({^C&w(ix^S,v^C_)**2+}))
{^C&w(ix^S,u^C_)=w(ix^S,lfac_)*w(ix^S,v^C_)\}

call conserve(ixG^L,ix^L,w,x,patchfalse)

if(first)then
      write(*,*)'Doing 2D ideal SRMHD, Orszag Tang problem'
      write(*,*)'rho - p - gamma - primRel?:',rho0,p0,eqpar(gamma_),useprimitiveRel
      first=.false.
endif


end subroutine initonegrid_usr
!=============================================================================
subroutine initvecpot_usr(ixI^L, ixC^L, xC, A)

  ! initialize the vectorpotential on the corners
  ! used by b_from_vectorpotential()

  include 'amrvacdef.f'

  integer, intent(in)                :: ixI^L, ixC^L
  double precision, intent(in)       :: xC(ixI^S,1:ndim)
  double precision, intent(out)      :: A(ixI^S,1:ndir)
  ! .. local ..
  !-----------------------------------------------------------------------------

  A(ixC^S,1:ndir) = zero
  
end subroutine initvecpot_usr
!=============================================================================
subroutine specialvar_output(ixI^L,ixO^L,w,x,normconv)

! this subroutine can be used in convert, to add auxiliary variables to the
! converted output file, for further analysis using tecplot, paraview, ....
! these auxiliary values need to be stored in the nw+1:nw+nwauxio slots
!
! the array normconv can be filled in the (nw+1:nw+nwauxio) range with 
! corresponding normalization values (default value 1)

include 'amrvacdef.f'

integer, intent(in)                :: ixI^L,ixO^L
double precision, intent(in)       :: x(ixI^S,1:ndim)
double precision                   :: w(ixI^S,nw+nwauxio)
double precision                   :: normconv(0:nw+nwauxio)
! .. local ..
!-----------------------------------------------------------------------------

end subroutine specialvar_output
!=============================================================================
subroutine specialvarnames_output

! newly added variables need to be concatenated with the varnames/primnames string

include 'amrvacdef.f'
!-----------------------------------------------------------------------------

!call mpistop("special varnames and primnames undefined")

end subroutine specialvarnames_output
!=============================================================================
subroutine printlog_special

include 'amrvacdef.f'
!-----------------------------------------------------------------------------
oktest = index(teststr,'printlog')>=1

call mpistop("special log file undefined")

end subroutine printlog_special
!=============================================================================
subroutine process_grid_usr(igrid,level,ixI^L,ixO^L,qt,w,x)

! this subroutine is ONLY to be used for computing auxiliary variables
! which happen to be non-local (like div v), and are in no way used for
! flux computations. As auxiliaries, they are also not advanced

include 'amrvacdef.f'

integer, intent(in):: igrid,level,ixI^L,ixO^L
double precision, intent(in):: qt,x(ixI^S,1:ndim)
double precision, intent(inout):: w(ixI^S,1:nw)
!-----------------------------------------------------------------------------

end subroutine process_grid_usr
!=============================================================================
! amrvacusr.t.srmhdOT
!=============================================================================
