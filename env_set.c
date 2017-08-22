#include <curses.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <stdlib.h>

CAMLprim value env_set(value var, value val) {
    CAMLparam2(var, val);
    puts("foo");
    CAMLreturn(Val_int(0));
}
