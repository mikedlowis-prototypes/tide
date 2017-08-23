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
    OLDFLAGS   =
endif

# Target Definitions
#-------------------------------------------------------------------------------
.PHONY: all clean

all: tide

clean:
	$(RM) tide *.cm* *.o *.a *.so

env.$(LIBEXT): env.$(OBJEXT) env_set.o env_get.o env_unset.o
tide: env.$(LIBEXT) tide.$(OBJEXT)

# Implicit Rule Definitions
#-------------------------------------------------------------------------------
%:
	$(OC) $(OLDFLAGS) -o $@ $^ -I .

%.$(LIBEXT):
	$(MKLIB) $(MKLIBFLAGS) $(OCFLAGS) -o $* -oc $* $^

%.$(OBJEXT): %.ml
	$(OC) $(OCFLAGS) -c -o $@ $^

%.o: %.c
	$(OC) $(OCFLAGS) -c -o $@ $^
