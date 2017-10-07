# Toolchain Configuration
#-------------------------------------------------------------------------------
INCS = -I . -I lib -I /usr/X11R6/include -I /usr/include/freetype2 -I /usr/X11R6/include/freetype2
LIBS = -L/usr/X11R6/lib -lX11 -lXft -lfontconfig

ifeq ($(NATIVE), 1)
    OC         = ocamlopt
    OCFLAGS    = -g
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
    lib/misc.$(OBJEXT) \
    lib/tide.$(OBJEXT) \
    lib/x11.$(OBJEXT) \
    lib/cfg.$(OBJEXT) \
    lib/rope.$(OBJEXT) \
    lib/buf.$(OBJEXT) \
    lib/x11_prims.o \
    lib/misc_prims.o \
    lib/utf8.o

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
	$(OC) $(OLDFLAGS) -o $@ $^ $(INCS)

%.cmi: %.mli
	$(OC) $(OCFLAGS) -c -o $@ $< $(INCS)

%.$(OBJEXT): %.ml
	$(OC) $(OCFLAGS) -c -o $@ $< $(INCS)

%.$(LIBEXT):
	$(MKLIB) $(MKLIBFLAGS) $(OCFLAGS) -o $* -oc $* $^ $(LIBS)

%.o: %.c
	$(OC) $(OCFLAGS) -c $^ $(INCS)
	mv $(notdir $@) $(dir $@)
