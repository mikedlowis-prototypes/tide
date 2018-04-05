#include "internals.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

CAMLprim value load_file(value path) {
    CAMLparam1(path);
    CAMLlocal1(str);
    int fd, nread;
    struct stat sb;
    if (((fd = open(path, O_RDONLY, 0)) < 0) || (fstat(fd, &sb) < 0) || (sb.st_size == 0)) {
        str = caml_alloc_string(0);
    } else {
        str = caml_alloc_string(sb.st_size);
        while ((nread = read(fd, String_val(str), sb.st_size)) > 0);
        if (nread < 0)
            caml_failwith("read() failed");
    }
    if (fd > 0) close(fd);
    CAMLreturn(str);
}

CAMLprim value env_set(value name, value val) {
    CAMLparam2(name,val);
    CAMLreturn(Val_unit);
}

CAMLprim value env_get(value name) {
    CAMLparam1(name);
    CAMLreturn(Val_unit);
}
