# Toolchain Configuration
#-------------------------------------------------------------------------------
ifeq ($(NATIVE), 1)
    OC         = ocamlopt
    OCFLAGS    = -compact
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
.PHONY: all clean

all: tide

clean:
	$(RM) tide *.cm* *.o *.a *.so
	$(RM) tide lib/*.cm* lib/*.o

env.$(LIBEXT): lib/env.$(OBJEXT) lib/env_prims.o
tide: env.$(LIBEXT) tide.$(OBJEXT)

# Implicit Rule Definitions
#-------------------------------------------------------------------------------
%:
	$(OC) $(OLDFLAGS) -o $@ $^ -I . -I lib

%.$(LIBEXT):
	$(MKLIB) $(MKLIBFLAGS) $(OCFLAGS) -o $* -oc $* $^

%.$(OBJEXT): %.ml
	$(OC) $(OCFLAGS) -c -o $@ $^ -I lib

%.o: %.c
	$(OC) $(OCFLAGS) -c $^
	mv $(notdir $@) $(dir $@)
