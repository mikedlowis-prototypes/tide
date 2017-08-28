# Toolchain Configuration
#-------------------------------------------------------------------------------
ifeq ($(NATIVE), 1)
    OC         = ocamlopt
    OCFLAGS    =
    MKLIB      = ocamlmklib
    MKLIBFLAGS = -custom
    IFEXT      = cmi
    OBJEXT     = cmx
    LIBEXT     = cmxa
    OLDFLAGS   = -compact -ccopt -dead_strip
else
    OC         = ocamlc
    OCFLAGS    =
    MKLIB      = ocamlmklib
    MKLIBFLAGS =
    IFEXT      = cmi
    OBJEXT     = cmo
    LIBEXT     = cma
    OLDFLAGS   = -dllpath .
endif

# Target Definitions
#-------------------------------------------------------------------------------
LIBOBJS = \
    lib/tide.$(OBJEXT) \
    lib/env.$(OBJEXT) \
    lib/env_prims.o

.PHONY: all clean

all: edit

clean:
	$(RM) tide *.cm* *.o *.a *.so
	$(RM) tide lib/*.cm* lib/*.o

# Executable targets
edit: tide.$(LIBEXT) edit.$(OBJEXT)

# Library targets
tide.$(LIBEXT): $(LIBOBJS)
lib/tide.$(OBJEXT): lib/tide.$(IFEXT)

-include deps.mk

# Implicit Rule Definitions
#-------------------------------------------------------------------------------
%:
	$(OC) $(OLDFLAGS) -o $@ $^ -I . -I lib

%.$(IFEXT): %.mli
	$(OC) $(OCFLAGS) -c -o $@ $< -I . -I lib

%.$(OBJEXT): %.ml
	$(OC) $(OCFLAGS) -c -o $@ $< -I . -I lib

%.$(LIBEXT):
	ocamldep *.ml* lib/*.ml* > deps.mk
	$(MKLIB) $(MKLIBFLAGS) $(OCFLAGS) -o $* -oc $* $^

%.o: %.c
	$(OC) $(OCFLAGS) -c $^
	mv $(notdir $@) $(dir $@)
