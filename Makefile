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
	$(RM) deps.mk tide *.cm* *.o *.a *.so lib/*.cm* lib/*.o

# Executable targets
edit: tide.$(LIBEXT) edit.$(OBJEXT)

# Library targets
tide.$(LIBEXT): $(LIBOBJS)

deps.mk:
	ocamldep *.ml* lib/*.ml* > deps.mk

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
	$(MKLIB) $(MKLIBFLAGS) $(OCFLAGS) -o $* -oc $* $^

%.o: %.c
	$(OC) $(OCFLAGS) -c $^
	mv $(notdir $@) $(dir $@)
