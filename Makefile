# Toolchain Configuration
#-------------------------------------------------------------------------------
# -nostdlib - Reimplement the Pervasives module to not suck.
ifeq ($(NATIVE), 1)
    OC         = ocamlopt
    OCFLAGS    =
    MKLIB      = ocamlmklib
    MKLIBFLAGS = -custom
    OBJEXT     = cmx
    LIBEXT     = cmxa
else
    OC         = ocamlc
    OCFLAGS    =
    MKLIB      = ocamlmklib
    MKLIBFLAGS = -custom
    OBJEXT     = cmo
    LIBEXT     = cma
endif

# Target Definitions
#-------------------------------------------------------------------------------
.PHONY: all clean

all: tide

clean:
	$(RM) tide *.cm* *.o *.a

env.$(LIBEXT): env.$(OBJEXT) env_set.o env_get.o env_unset.o
tide: env.$(LIBEXT) tide.$(OBJEXT)

# Implicit Rule Definitions
#-------------------------------------------------------------------------------
%:
	$(OC) $(OCFLAGS) -o $@ $^ -I .

%.$(LIBEXT):
	$(MKLIB) $(MKLIBFLAGS) $(OCFLAGS) -o $* $^

%.$(OBJEXT): %.ml
	$(OC) $(OCFLAGS) -c -o $@ $^

%.o: %.c
	$(OC) $(OCFLAGS) -c -o $@ $^
