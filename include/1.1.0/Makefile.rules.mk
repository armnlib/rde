## ====================================================================
## File: $purplefrog/include/${PF_COMPILER_VERSION}/Makefile.rules.mk
##

INCSUFFIXES = .cdk .h .hf .fh .itf90 .inc 
SRCSUFFIXES = .c .f .ftn .ptn .f90 .ftn90 .ptn90 .cdk90 .tmpl90 .F .FOR .F90

.SUFFIXES :
.SUFFIXES : $(INCSUFFIXES) $(SRCSUFFIXES) .o 

RCOMPIL = pfcompile $(MPI) $(OMP) -includes ./ $(INCLUDE_PATH) $(INCLUDE_MOD)  $(DEBUGCOMPFLAGS)
RBUILD  = pfcompile $(DEBUGLINKFLAGS) -libpath ./ $(LIBRARY_PATH)
FCOMPF = 
CCOMPF =
COMPF = 
#F77C = $(RCOMPIL) -defines "=$(DEFINE)" -O $(OPTIL) -optf="$(FFLAGSYS) $(FFLAGS)" $(COMPF) $(FCOMPF) -src
FC = $(RCOMPIL) -defines "=$(DEFINE)" -O $(OPTIL) -optf="$(FFLAGSYS) $(FFLAGS)" $(COMPF) $(FCOMPF) -src
F90C2 = $(RCOMPIL) -defines "=$(DEFINE)" -O $(OPTIL) -optf="$(FFLAGSYS) $(FFLAGS) $(OPTF_MODULE)" $(COMPF) $(FCOMPF) -src
#FC   = $(F77C)
FTNC = $(RCOMPIL) -defines "=$(DEFINE)"             -optf="$(FFLAGSYS) $(FFLAGS) $(CPPFLAGS)" -P $(COMPF) $(FCOMPF) -src
MYCC   = $(RCOMPIL) -defines "=$(DEFINE)" -O $(OPTIL) -optc="$(CFLAGSYS) $(CFLAGS)" $(COMPF) $(CCOMPF) -src

BUILDSRC = $(ROOT)/$(shell pfmodel_link build/src)
BUILDPRE = $(ROOT)/$(shell pfmodel_link build/pre)
BUILDMOD = $(ROOT)/$(shell pfmodel_link build/mod)

RBUILD3MPI = \
	status=0 ;\
	.pfmakemodelbidon $${MAINSUBNAME} > bidon_$${MAINSUBNAME}.f90 ; \
	$(MAKE) bidon_$${MAINSUBNAME}.o >/dev/null || status=1 ; \
	rm -f bidon_$${MAINSUBNAME}.f90 ;\
	$(RBUILD) -obj bidon_$${MAINSUBNAME}.o -o $@ $(OMP) $(MPI) \
		-libpath $(LIBPATH) \
		-libappl $(LIBS_PRE) $${LIBLOCAL} $(LIBAPPL) \
		-librmn $(RMN_VERSION) \
		-libsys $(LIBSYS) \
		-codebeta $(CODEBETA) \
		-optf "=$(LFLAGS)"  || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}.o 2>/dev/null || true ;\
	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

RBUILD3NOMPI = \
	status=0 ;\
	.pfmakemodelbidon $${MAINSUBNAME} > bidon_$${MAINSUBNAME}.f90 ; \
	$(MAKE) bidon_$${MAINSUBNAME}.o >/dev/null || status=1 ; \
	rm -f bidon_$${MAINSUBNAME}.f90 ;\
	$(RBUILD) -obj bidon_$${MAINSUBNAME}.o -o $@ $(OMP) \
		-libpath $(LIBPATH) \
		-libappl $(LIBS_PRE) $${LIBLOCAL} $(LIBAPPL) \
		-librmn $(RMN_VERSION) \
		-libsys $${COMM_stubs1} $(LIBSYS) \
		-codebeta $(CODEBETA) \
		-optf "=$(LFLAGS)"  || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}.o 2>/dev/null || true ;\
	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

RBUILD3NOMPI_C = \
	status=0 ;\
	.pfmakemodelbidon -c $${MAINSUBNAME} > bidon_$${MAINSUBNAME}_c.c ; \
	$(MAKE) bidon_$${MAINSUBNAME}_c.o >/dev/null || status=1 ; \
	rm -f bidon_$${MAINSUBNAME}_c.c ;\
	$(RBUILD) -obj bidon_$${MAINSUBNAME}_c.o -o $@ $(OMP) -conly \
		-libpath $(LIBPATH) \
		-libappl $(LIBS_PRE) $${LIBLOCAL} $(LIBAPPL) \
		-librmn $(RMN_VERSION) \
		-libsys $${COMM_stubs1} $(LIBSYS) \
		-codebeta $(CODEBETA) \
		-optc "=$(LCLAGS)"  || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}_c.o 2>/dev/null || true ;\
	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

C_DOT_O      = cd $(dir $@) ; $(MYCC) $<  -basedir $(BUILDSRC) -reldir $(dir $@)
F_DOT_O      = cd $(dir $@) ; $(FC) $<    -basedir $(BUILDSRC) -reldir $(dir $@)
F90_DOT_O    = cd $(dir $@) ; $(F90C2) $< -basedir $(BUILDSRC) -reldir $(dir $@)

FTN_DOT_F       = rm -f $*.f   ; cd $(dir $@) && $(FTNC) $< && mv -f $(notdir $*.f) $(BUILDPRE)/$*.f     || exit 1
FTN90_DOT_F90   = rm -f $*.f90 ; cd $(dir $@) && $(FTNC) $< && mv -f $(notdir $*.f90) $(BUILDPRE)/$*.f90 || exit 1
#FTN90_DOT_F90    = rm -f $(BUILDPRE)/$*.f90 ; cd $(dir $@) && ln -sf $(BUILDPRE)/$*.f90 $(notdir $*.f90) && $(FTNC) $<
#FTN90_DOT_F90    = rm -f $(BUILDPRE)/$*.f90 ; cd $(dir $@) && $(FTNC) -predir $(BUILDPRE)/$(dir $@) $< 
PREF_DOT_O_CD   = cd $(dir $@) && $(FC) $(BUILDPRE)/$*.f      -basedir $(BUILDSRC) -reldir $(dir $@) || exit 1 && touch $(notdir $@) 
PREF90_DOT_O_CD = cd $(dir $@) && $(F90C2) $(BUILDPRE)/$*.f90 -basedir $(BUILDSRC) -reldir $(dir $@) || exit 1 && touch $(notdir $@) 
PREF_DOT_O   = $(FC) $(BUILDPRE)/$*.f      -basedir $(BUILDSRC) -reldir $(dir $@) || exit 1 && touch $(notdir $@)
PREF90_DOT_O = $(F90C2) $(BUILDPRE)/$*.f90 -basedir $(BUILDSRC) -reldir $(dir $@) || exit 1 && touch $(notdir $@)

#TODO: mv -f *.[mM][oO][dD] is dangerous with parallel make [-j]; may want s.dependencies to provide list of .mod for each src file
F90_DOT_O_MOD_CDMV = if [[ x"$(OPTF_MODULE)" == x ]] ; then cd $(dir $@) ; mv -f *.[mM][oO][dD] $(BUILDMOD) 2>/dev/null || true ; fi
F90_DOT_O_MOD_MV = [[ x"$(OPTF_MODULE)" == x ]] && mv -f *.[mM][oO][dD] $(BUILDMOD) 2>/dev/null || true


.c.o:
	#.c.o
	$(C_DOT_O)
	#.c.o
.f.o:
	#.f.o
	$(F_DOT_O)
	#.f.o
.f90.o:
	#.f90.o:
	$(F90_DOT_O) ;\
	$(F90_DOT_O_MOD_MV)
	#.f90.o:
.F.o:
	s.f77 -c -o $@ -src $<  $(COMPILE_FLAGS) $(FFLAGS)
.F90.o:
	s.f90 -c -o $@ -src $<  $(COMPILE_FLAGS) $(FFLAGS) ;\
	$(F90_DOT_O_MOD_CDMV)
.ftn.o:
	#.ftn.o
	$(FTN_DOT_F) ;\
	$(PREF_DOT_O)
	#.ftn.o
.ftn90.o:
	#.ftn90.o
	$(FTN90_DOT_F90) ;\
	$(PREF90_DOT_O) ;\
	$(F90_DOT_O_MOD_MV)
	#.ftn90.o
.cdk90.o:
	#.cdk90.o:
	$(FTN90_DOT_F90) ;\
	$(PREF90_DOT_O) ;\
	$(F90_DOT_O_MOD_MV)
	#.cdk90.o:
.tmpl90.o: #TODO
	#.tmpl90.
	echo "Not yet implemented" ; exit 1 ;\
	s.tmpl90.ftn90 < $<  > $*.ftn90 ;\
	s.ftn90 -c -o $@ -src $(EC_ARCH)/$*.ftn90 $(COMPILE_FLAGS) $(FFLAGS)
	#.tmpl90.

.ftn.f:
	$(FTN_DOT_F)
	#.ftn.o
.ftn90.f90:
	$(FTN90_DOT_F90)
	#.ftn90.o
.cdk90.f90:
	$(FTN90_DOT_F90)
.tmpl90.ftn90:
	echo "Not yet implemented" ; exit 1
# 	s.tmpl90.ftn90 < $<  > $@

# EXTRACTSRC0 = if [[ ! -f $@ ]] ; then omd_exp $@ ; fi ; if [[ ! -f $@ ]] ; then exit 1 ; fi
# EXTRACTSRC = if [[ ! -f $@ ]] ; then e2.co $@ ; fi ; if [[ ! -f $@ ]] ; then exit 1 ; fi
# %.c:
# 	$(EXTRACTSRC)
# %.f:
# 	$(EXTRACTSRC)
# %.ftn:
# 	$(EXTRACTSRC)
# %.ptn:
# 	$(EXTRACTSRC)
# %.f90:
# 	$(EXTRACTSRC)
# %.ftn90:
# 	$(EXTRACTSRC)
# %.ptn90:
# 	$(EXTRACTSRC)
# %.cdk:
# 	$(EXTRACTSRC)
# %.cdk90:
# 	$(EXTRACTSRC)
# %.tmpl90:
# 	$(EXTRACTSRC)
# %.F:
# 	$(EXTRACTSRC)
# %.FOR:
# 	$(EXTRACTSRC)
# %.F90:
# 	$(EXTRACTSRC)
# %.h:
# 	$(EXTRACTSRC)
# %.hf:
# 	$(EXTRACTSRC)
# %.fh:
# 	$(EXTRACTSRC)
# %.itf90:
# 	$(EXTRACTSRC)
# %.inc:
# 	$(EXTRACTSRC)

# .ftn90.itf90:
# 	$(FTNC) $< -defines =-DAPI_ONLY ; mv -f $*.f90 $*.itf90
# 	#mu.ftn2f -f90 -defines "=$(DEFINE)" -optf="$(FFLAGS) $(CPPFLAGS)" -P $(COMPF) $(FCOMPF) -src $<  > $@
# 	#r.gppf -lang-f90+ -chop_bang -gpp -F -D__FILE__=\"#file\" -D__LINE__=#line $
#{vincludes[@]} -DAPI_ONLY $< > $@

# .c.o:
# 	s.cc -c -o $@ -src $< $(COMPILE_FLAGS) $(CFLAGS) 
# .f.o:
# 	s.f77 -c -o $@ -src $< $(COMPILE_FLAGS) $(FFLAGS)
# .f90.o:
# 	s.f90 -c -o $@ -src $< $(COMPILE_FLAGS) $(FFLAGS)
# .ftn.o:
# 	s.ftn -c -o $@ -src $< $(COMPILE_FLAGS) $(FFLAGS)
# .ftn90.o:
# 	s.ftn90 -c -o $@ -src $<  $(COMPILE_FLAGS) $(FFLAGS)
# .cdk90.o:
# 	s.ftn90 -c -o $@ -src $<  $(COMPILE_FLAGS) $(FFLAGS)
.for.o:
	s.f77 -c -o $@ -src $< $(COMPILE_FLAGS) $(FFLAGS)
.FOR.o:
	s.f77 -c -o $@ -src $<  $(COMPILE_FLAGS) $(FFLAGS)

#%_interface.cdk90 : %.tmpl90
#	FileName=$@ ; cat $< | r.tmpl90.ftn90 - $${FileName%.ftn90}

## ====================================================================