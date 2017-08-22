OC = ocamlopt
OCMKLIB = ocamlmklib

.PHONY: all clean

env.cmxa: env.cmx envprims.o
tide: env.cmxa tide.cmx

all: tide

clean:
	$(RM) *.cm* *.o *.a

%:
	$(OC) -o $@ $^ -I .

%.cmxa:
	$(OCMKLIB) -custom -o $* $^

%.cmx: %.ml
	$(OC) -c -o $@ $^

%.o: %.c
	$(OC) $(OCFLAGS) -c -o $@ $^

