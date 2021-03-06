!  SVN:$Id$
!=======================================================================

! 2013 module for form drag parameters
! authors Michel Tsamados, David Schroeder, CPOM 

      module ice_history_drag

      use ice_kinds_mod
      use ice_domain_size, only: max_nstrm

      implicit none
      private
      public :: accum_hist_drag, init_hist_drag_2D
      save
      
      !---------------------------------------------------------------
      ! flags: write to output file if true or histfreq value
      !---------------------------------------------------------------

      character (len=max_nstrm), public :: &
           f_Cdn_atm   = 'x', f_Cdn_ocn     = 'x' , &
           f_drag      = 'x'

      !---------------------------------------------------------------
      ! namelist variables
      !---------------------------------------------------------------

      namelist / icefields_drag_nml /     &
           f_Cdn_atm,        f_Cdn_ocn       , & 
           f_drag

      !---------------------------------------------------------------
      ! field indices
      !---------------------------------------------------------------

      integer (kind=int_kind), dimension(max_nstrm) :: &
           n_hfreebd        , n_hdraft,   &
           n_hridge         , n_distrdg,  &
           n_hkeel          , n_dkeel,  &
           n_lfloe          , n_dfloe,  &
           n_Cdn_atm        , n_Cdn_ocn,   &
           n_Cdn_atm_skin   , n_Cdn_atm_floe,  &
           n_Cdn_atm_pond   , n_Cdn_atm_rdg,  &
           n_Cdn_ocn_skin   , n_Cdn_ocn_floe,   &
           n_Cdn_ocn_keel   , n_Cdn_atm_ocn    

!=======================================================================

      contains

!=======================================================================

! Initialize history files
! authors Elizabeth C. Hunke, LANL

      subroutine init_hist_drag_2D

      use ice_broadcast, only: broadcast_scalar
      use ice_calendar, only: nstreams
      use ice_communicate, only: my_task, master_task
      use ice_constants, only: c0, c1, secday, c100, mps_to_cmpdy
      use ice_exit, only: abort_ice
      use ice_fileunits, only: nu_nml, nml_filename, &
          get_fileunit, release_fileunit
      use ice_history_shared, only: tstr2D, tcstr, define_hist_field
      use ice_state, only: tr_lvl

      integer (kind=int_kind) :: ns
      integer (kind=int_kind) :: nml_error ! namelist i/o error flag

      !-----------------------------------------------------------------
      ! read namelist
      !-----------------------------------------------------------------

      call get_fileunit(nu_nml)
      if (my_task == master_task) then
         open (nu_nml, file=nml_filename, status='old',iostat=nml_error)
         if (nml_error /= 0) then
            nml_error = -1
         else
            nml_error =  1
         endif
         do while (nml_error > 0)
            read(nu_nml, nml=icefields_drag_nml,iostat=nml_error)
            if (nml_error > 0) read(nu_nml,*)  ! for Nagware compiler
         end do
         if (nml_error == 0) close(nu_nml)
      endif
      call release_fileunit(nu_nml)

      call broadcast_scalar(nml_error, master_task)
      if (nml_error /= 0) then
         close (nu_nml)
         call abort_ice('ice: error reading icefields_drag_nml')
      endif

      call broadcast_scalar (f_Cdn_atm, master_task)
      call broadcast_scalar (f_Cdn_ocn, master_task)
      call broadcast_scalar (f_drag, master_task)

      ! 2D variables

      do ns = 1, nstreams

       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_hfreebd,"hfreebd","m",tstr2D, tcstr, &
            "hfreebd: freeboard",                           &
            "none", c1, c0,            &
            ns, f_drag)

       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_hdraft,"hdraft","m",tstr2D, tcstr, &
            "hdraft: draught",                           &
            "none", c1, c0,            &
            ns, f_drag)
 
       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_hridge,"hridge","m",tstr2D, tcstr, &
            "hridge: ridge height",                          &
            "none", c1, c0,            &
            ns, f_drag)
 
       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_distrdg,"distrdg","m",tstr2D, tcstr, &
            "distrdg: distance between ridges",  &
            "none", c1, c0,            &
            ns, f_drag)            

       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_hkeel,"hkeel","m",tstr2D, tcstr, &
            "hkeel: keel depth",                           &
            "none", c1, c0,            &
            ns, f_drag)
 
       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_dkeel,"dkeel","m",tstr2D, tcstr, &
            "dkeel: distance between keels", &
            "none", c1, c0,            &
            ns, f_drag)            

       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_lfloe,"lfloe","m",tstr2D, tcstr, &
            "lfloe: floe length",         &
            "none", c1, c0,            &
            ns, f_drag)
 
       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_dfloe,"dfloe","m",tstr2D, tcstr, &
            "dfloe: distance between floes", &
            "none", c1, c0,            &
            ns, f_drag)   
  
       if (f_Cdn_atm(1:1) /= 'x') &
         call define_hist_field(n_Cdn_atm,"Cdn_atm","m",tstr2D, tcstr, &
            "Ca: total ice-atm drag coefficient", &
            "none", c1, c0,            &
            ns, f_Cdn_atm)

       if (f_Cdn_ocn(1:1) /= 'x') &
         call define_hist_field(n_Cdn_ocn,"Cdn_ocn","m",tstr2D, tcstr, &
            "Cdn_ocn: total ice-ocn drag coefficient", &
            "none", c1, c0,            &
            ns, f_Cdn_ocn)
 
       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_Cdn_atm_skin,"Cdn_atm_skin","m", &
            tstr2D, tcstr, &
            "Cdn_atm_skin: neutral skin ice-atm drag coefficient", &
            "none", c1, c0,            &
            ns, f_drag)
 
       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_Cdn_atm_floe,"Cdn_atm_floe","m", &
            tstr2D, tcstr, &
            "Cdn_atm_floe: neutral floe edge ice-atm drag coefficient", &
            "none", c1, c0,            &
            ns, f_drag)            
 
       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_Cdn_atm_pond,"Cdn_atm_pond","m", &
            tstr2D, tcstr, &
            "Cdn_atm_pond: neutral pond edge ice-atm drag coefficient", &
            "none", c1, c0,            &
            ns, f_drag)
            
       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_Cdn_atm_rdg,"Cdn_atm_rdg","m", &
            tstr2D, tcstr, &
            "Cdn_atm_rdg: neutral ridge ice-atm drag coefficient", &
            "none", c1, c0,            &
            ns, f_drag)
            
        if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_Cdn_ocn_skin,"Cdn_ocn_skin","m", &
            tstr2D, tcstr, &
            "Cdn_ocn_skin: neutral skin ice-ocn drag coefficient", &
            "none", c1, c0,            &
            ns, f_drag)
 
       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_Cdn_ocn_floe,"Cdn_ocn_floe","m", &
            tstr2D, tcstr, &
            "Cdn_ocn_floe: neutral floe edge ice-ocn drag coefficient", &
            "none", c1, c0,            &
            ns, f_drag)            
 
       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_Cdn_ocn_keel,"Cdn_ocn_keel","m", &
            tstr2D, tcstr, &
            "Cdn_ocn_keel: neutral keel ice-ocn drag coefficient", &
            "none", c1, c0,            &
            ns, f_drag)
       if (f_drag(1:1) /= 'x') &
         call define_hist_field(n_Cdn_atm_ocn,"Cdn_atm_ocn", &
            "m",tstr2D, tcstr, &
            "Cdn_atm_ocn: ratio total atm drag / ocn drag", &
            "none", c1, c0,            &
            ns, f_drag)

      enddo ! nstreams

      end subroutine init_hist_drag_2D

!=======================================================================

! accumulate average ice quantities or snapshots

      subroutine accum_hist_drag (iblk)

      use ice_constants, only: c1
      use ice_history_shared, only: n2D, a2D, a3Dc, ncat_hist, &
          accum_hist_field
      use ice_atmo, only: hfreebd, hdraft, hridge, distrdg, hkeel, &
          dkeel, lfloe, dfloe, Cdn_atm, Cdn_atm_skin, Cdn_atm_floe, &
          Cdn_atm_pond, Cdn_atm_rdg, Cdn_atm_ocn, Cdn_ocn_skin, &
          Cdn_ocn_keel, Cdn_ocn_floe, Cdn_ocn

      integer (kind=int_kind), intent(in) :: &
           iblk                 ! block index

      !---------------------------------------------------------------
      ! increment field
      !---------------------------------------------------------------

         ! 2D fields

      if (f_Cdn_atm     (1:1) /= 'x') &
        call accum_hist_field(n_Cdn_atm, iblk, Cdn_atm(:,:,iblk), a2D)
      if (f_Cdn_ocn     (1:1) /= 'x') &
        call accum_hist_field(n_Cdn_ocn, iblk, Cdn_ocn(:,:,iblk), a2D)
      if (f_drag     (1:1) /= 'x') then
        call accum_hist_field(n_hfreebd, iblk, hfreebd(:,:,iblk), a2D)
        call accum_hist_field(n_hdraft, iblk, hdraft(:,:,iblk), a2D)
        call accum_hist_field(n_hridge, iblk, hridge(:,:,iblk), a2D)
        call accum_hist_field(n_distrdg, iblk, distrdg(:,:,iblk), a2D)
        call accum_hist_field(n_hkeel, iblk, hkeel(:,:,iblk), a2D)
        call accum_hist_field(n_dkeel, iblk, dkeel(:,:,iblk), a2D)
        call accum_hist_field(n_lfloe, iblk, lfloe(:,:,iblk), a2D)
        call accum_hist_field(n_dfloe, iblk, dfloe(:,:,iblk), a2D)
        call accum_hist_field(n_Cdn_atm_rdg, &
                              iblk, Cdn_atm_rdg(:,:,iblk), a2D)   
        call accum_hist_field(n_Cdn_atm_floe, &
                              iblk, Cdn_atm_floe(:,:,iblk), a2D)
        call accum_hist_field(n_Cdn_atm_pond, &
                              iblk, Cdn_atm_pond(:,:,iblk), a2D)
        call accum_hist_field(n_Cdn_atm_skin, &
                              iblk, Cdn_atm_skin(:,:,iblk), a2D)   
        call accum_hist_field(n_Cdn_atm_ocn, &
                              iblk, Cdn_atm_ocn(:,:,iblk), a2D)
        call accum_hist_field(n_Cdn_ocn_keel, &
                              iblk, Cdn_ocn_keel(:,:,iblk), a2D)  
        call accum_hist_field(n_Cdn_ocn_floe, &
                              iblk, Cdn_ocn_floe(:,:,iblk), a2D)
        call accum_hist_field(n_Cdn_ocn_skin, &
                              iblk, Cdn_ocn_skin(:,:,iblk), a2D)  
      end if

      end subroutine accum_hist_drag

!=======================================================================

      end module ice_history_drag

!=======================================================================
