#include <curses.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <stdlib.h>

CAMLprim value env_get(value var) {
    CAMLparam1(var);
    puts("bar");
    CAMLreturn(caml_copy_string(""));
}
