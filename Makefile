# Toolchain Configuration
#-------------------------------------------------------------------------------
NATIVE = 1
INCS = -I . -I lib -I tests \
    -I /usr/X11R6/include \
    -I /usr/include/freetype2 -I /usr/X11R6/include/freetype2
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
    OCFLAGS    = -g
    MKLIB      = ocamlmklib
    MKLIBFLAGS =
    OBJEXT     = cmo
    LIBEXT     = cma
    OLDFLAGS   = -g -dllpath .
endif

# Target Definitions
#-------------------------------------------------------------------------------
BINS = edit unittests

BINSRCS = \
	edit.ml \
	unittests.ml

LIBSRCS = \
	lib/misc.ml \
	lib/x11.ml \
	lib/cfg.ml \
	lib/rope.ml \
	lib/buf.ml \
	lib/draw.ml \
	lib/scrollmap.ml \
	lib/view.ml

TESTSRCS = \
	tests/test.ml \
	tests/buf_tests.ml \
	tests/misc_tests.ml \
	tests/rope_tests.ml \
	tests/scrollmap_tests.ml

LIBOBJS = \
	$(LIBSRCS:.ml=.$(OBJEXT)) \
    lib/x11_prims.o \
    lib/misc_prims.o \
    lib/utf8.o

TESTOBJS = $(TESTSRCS:.ml=.$(OBJEXT))

.PHONY: all clean docs

all: docs/index.html $(BINS)
	./unittests

clean:
	$(RM) $(BINS) *.cm* *.o *.a *.so lib/*.cm* lib/*.o tests/*.cm* tests/*.o

# Executable targets
edit: tide.$(LIBEXT) edit.$(OBJEXT)
unittests: tide.$(LIBEXT) $(TESTOBJS) unittests.$(OBJEXT)

# Library targets
tide.$(LIBEXT): $(LIBOBJS)
docs/index.html: tide.$(LIBEXT)
	ocamldoc -d docs -html -I lib $(LIBSRCS)

# Dependency generation
deps.mk: $(wildcard *.ml* lib/*.ml* tests/*.ml*)
	ocamldep -I . -I lib/ -I tests/ -all -native -one-line $^ > deps.mk
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
