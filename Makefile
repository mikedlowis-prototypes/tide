# Toolchain Configuration
#-------------------------------------------------------------------------------
OS         = $(shell uname)
OFLAGS     = -g -nodynlink
MKLIBFLAGS = -custom
OLDFLAGS   =

# Native Config
OC     = ocamlopt
BINEXT = bin
OBJEXT = cmx
LIBEXT = cmxa

# Bytecode Config
#OC     = ocamlc
#BINEXT = byte
#OBJEXT = cmo
#LIBEXT = cma

ifeq ($(OS),Darwin)
	OFLAGS += -ccopt -dead_strip
endif

# Include and Lib Paths
#-------------------------------------------------------------------------------
INCS = -I . -I lib -I tests -I lib/lexers \
    -I /usr/X11R6/include \
    -I /usr/include/freetype2 -I /usr/X11R6/include/freetype2

LIBS = -L/usr/X11R6/lib -lX11 -lXft -lfontconfig

# Target Definitions
#-------------------------------------------------------------------------------
BINS = edit.$(BINEXT) unittests.$(BINEXT)

BINSRCS = \
	edit.ml \
	unittests.ml

LEXERS = \
	lib/lexers/lex_cpp.ml

LIBSRCS = \
	lib/misc.ml \
	lib/x11.ml \
	lib/cfg.ml \
	lib/rope.ml \
	lib/buf.ml \
	lib/colormap.ml \
	lib/draw.ml \
	lib/scrollmap.ml \
	$(LEXERS) \
	lib/view.ml

TESTSRCS = \
	tests/test.ml \
	tests/buf_tests.ml \
	tests/misc_tests.ml \
	tests/rope_tests.ml \
	tests/view_tests.ml \
	tests/scrollmap_tests.ml

LIBOBJS = \
	$(LIBSRCS:.ml=.$(OBJEXT)) \
    lib/x11_prims.o \
    lib/misc_prims.o \
    lib/utf8.o

TESTOBJS = $(TESTSRCS:.ml=.$(OBJEXT))

.PHONY: all clean docs deps

all: $(BINS) lib/lexers/lex_cpp.ml
	./unittests.$(BINEXT)

clean:
	$(RM) *.byte *.bin *.cm* *.o *.a
	$(RM) lib/*.cm* lib/*.o tests/*.cm* tests/*.o
	$(RM) lib/lexers/*.cm* lib/lexers/*.ml

# Executable targets
edit.$(BINEXT): tide.$(LIBEXT) edit.$(OBJEXT)
unittests.$(BINEXT): tide.$(LIBEXT) $(TESTOBJS) unittests.$(OBJEXT)

# Library targets
tide.$(LIBEXT): $(LIBOBJS) $(LEXERS:.ml=.$(OBJEXT))
docs: tide.$(LIBEXT)
	ocamldoc -d docs -html -I lib $(LIBSRCS)

# Dependency generation
deps deps.mk: $(wildcard *.ml* lib/*.ml* tests/*.ml*)
	ocamldep -I . -I lib/ -I tests/ -all -one-line $^ > deps.mk
-include deps.mk

# Implicit Rule Definitions
#-------------------------------------------------------------------------------
.SUFFIXES: .c .o .ml .mli .mll .cmo .cmx .cmi .cma .cmxa .byte .bin
.c.o:
	ocamlopt $(OFLAGS) -c $^ $(INCS)
	mv $(notdir $@) $(dir $@)
.ml.cmo :
	ocamlc -c $(OFLAGS) $(INCS) -o $@ $<
.ml.cmx :
	ocamlopt -c $(OFLAGS) $(INCS) -o $@ $<
.mli.cmi :
	$(OC) -c $(OFLAGS) $(INCS) -o $@ $<
.mll.ml :
	ocamllex $(OLEXFLAGS) -o $@ $<
%.cma:
	ocamlmklib $(MKLIBFLAGS) $(OFLAGS) -o $* -oc $* $(LIBS) $^
%.cmxa:
	ocamlmklib $(MKLIBFLAGS) $(OFLAGS) -o $* -oc $* $(LIBS) $^
%.byte:
	ocamlc $(OLDFLAGS) $(INCS) -o $@ $^
%.bin:
	ocamlopt $(OLDFLAGS) $(INCS) -o $@ $^
