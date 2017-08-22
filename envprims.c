#include <curses.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <stdlib.h>

CAMLprim value caml_env_set(value var, value val) {
    CAMLparam2(var, val);
    puts("foo");
    CAMLreturn(Val_int(0));
}

CAMLprim value caml_env_get(value var) {
    CAMLparam1(var);
    puts("bar");
    CAMLreturn(caml_copy_string(""));
}

CAMLprim value caml_env_unset(value var) {
    CAMLparam1(var);
    puts("baz");
    CAMLreturn(Val_int(0));
}
