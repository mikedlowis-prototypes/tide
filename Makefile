# Toolchain Configuration
#-------------------------------------------------------------------------------
ifeq ($(NATIVE), 1)
    OC         = ocamlopt
    OCFLAGS    =
    MKLIB      = ocamlmklib
    MKLIBFLAGS = -custom
    OBJEXT     = cmx
    LIBEXT     = cmxa
    OLDFLAGS   = -compact -ccopt -dead_strip
else
    OC         = ocamlc
    OCFLAGS    =
    MKLIB      = ocamlmklib
    MKLIBFLAGS =
    OBJEXT     = cmo
    LIBEXT     = cma
    OLDFLAGS   = -dllpath .
endif

# Target Definitions
#-------------------------------------------------------------------------------
BINS = edit
LIBOBJS = \
    lib/tide.$(OBJEXT) \
    lib/env.$(OBJEXT) \
    lib/env_prims.o

.PHONY: all clean

all: $(BINS)

clean:
	$(RM) deps.mk $(BINS) *.cm* *.o *.a *.so lib/*.cm* lib/*.o

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

%.cmi: %.mli
	$(OC) $(OCFLAGS) -c -o $@ $< -I . -I lib

%.$(OBJEXT): %.ml
	$(OC) $(OCFLAGS) -c -o $@ $< -I . -I lib

%.$(LIBEXT):
	$(MKLIB) $(MKLIBFLAGS) $(OCFLAGS) -o $* -oc $* $^

%.o: %.c
	$(OC) $(OCFLAGS) -c $^
	mv $(notdir $@) $(dir $@)
