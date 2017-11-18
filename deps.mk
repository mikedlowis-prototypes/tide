edit.cmx edit.o edit.cmi : lib/x11.cmi lib/x11.cmx lib/view.cmi lib/view.cmx lib/draw.cmi lib/draw.cmx lib/buf.cmi lib/buf.cmx edit.ml
lib/buf.cmx lib/buf.o : lib/rope.cmi lib/rope.cmx lib/misc.cmi lib/misc.cmx lib/buf.cmi lib/buf.ml
lib/buf.cmi :
lib/cfg.cmx lib/cfg.o lib/cfg.cmi : lib/x11.cmi lib/x11.cmx lib/cfg.ml
lib/draw.cmx lib/draw.o : lib/x11.cmi lib/x11.cmx lib/cfg.cmi lib/cfg.cmx lib/buf.cmi lib/buf.cmx lib/draw.cmi lib/draw.ml
lib/draw.cmi : lib/x11.cmi lib/buf.cmi
lib/misc.cmx lib/misc.o lib/misc.cmi : lib/misc.ml
lib/rope.cmx lib/rope.o : lib/rope.cmi lib/rope.ml
lib/rope.cmi :
lib/scrollmap.cmx lib/scrollmap.o : lib/draw.cmi lib/draw.cmx lib/buf.cmi lib/buf.cmx lib/scrollmap.cmi lib/scrollmap.ml
lib/scrollmap.cmi : lib/buf.cmi
lib/view.cmx lib/view.o lib/view.cmi : lib/scrollmap.cmi lib/scrollmap.cmx lib/draw.cmi lib/draw.cmx lib/buf.cmi lib/buf.cmx lib/view.ml
lib/view_tests.cmx lib/view_tests.o lib/view_tests.cmi : lib/view_tests.ml
lib/x11.cmx lib/x11.o lib/x11.cmi : lib/x11.ml
tests/buf_tests.cmx tests/buf_tests.o tests/buf_tests.cmi : tests/buf_tests.ml
tests/misc_tests.cmx tests/misc_tests.o tests/misc_tests.cmi : tests/misc_tests.ml
tests/rope_tests.cmx tests/rope_tests.o tests/rope_tests.cmi : tests/test.cmi tests/test.cmx lib/rope.cmi lib/rope.cmx tests/rope_tests.ml
tests/scrollmap_tests.cmx tests/scrollmap_tests.o tests/scrollmap_tests.cmi : tests/test.cmi tests/test.cmx lib/scrollmap.cmi lib/scrollmap.cmx tests/scrollmap_tests.ml
tests/test.cmx tests/test.o tests/test.cmi : tests/test.ml
unittests.cmx unittests.o unittests.cmi : tests/test.cmi tests/test.cmx tests/scrollmap_tests.cmi tests/scrollmap_tests.cmx tests/rope_tests.cmi tests/rope_tests.cmx tests/misc_tests.cmi tests/misc_tests.cmx tests/buf_tests.cmi tests/buf_tests.cmx unittests.ml
