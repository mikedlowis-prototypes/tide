#include <curses.h>
#include <caml/mlvalues.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/alloc.h>
//#include <caml/custom.h>
//#include <stdlib.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>

static int error_handler(Display* disp, XErrorEvent* ev);
static char* readprop(Window win, Atom prop);

static struct {
    Display* display;
    Visual* visual;
    Colormap colormap;
    unsigned depth;
    int screen;
    Window root;
    int errno;
} X;

CAMLprim value x11_connect(void) {
    CAMLparam0();
    if (!(X.display = XOpenDisplay(NULL)))
        caml_failwith("could not open display");
    XSetErrorHandler(error_handler);
    X.root = DefaultRootWindow(X.display);
    XWindowAttributes wa;
    XGetWindowAttributes(X.display, X.root, &wa);
    X.visual   = wa.visual;
    X.colormap = wa.colormap;
    X.screen   = DefaultScreen(X.display);
    X.depth    = DefaultDepth(X.display, X.screen);
    CAMLreturn(Val_unit);
}

CAMLprim value x11_disconnect(void) {
    CAMLparam0();
    XCloseDisplay(X.display);
    CAMLreturn(Val_unit);
}

CAMLprim value x11_errno(void) {
    CAMLparam0();
    CAMLreturn(Val_int(X.errno));
}

CAMLprim value x11_intern(value name) {
    CAMLparam1(name);
    Atom atom = XInternAtom(X.display, String_val(name), False);
    CAMLreturn(Val_int(atom));
}

CAMLprim value x11_prop_set(value win, value atom, value val) {
    CAMLparam3(win, atom, val);
    unsigned char* propval = (unsigned char*)String_val(val);
    XChangeProperty(
        X.display, (Window)win, (Atom)atom, XA_STRING, 8, PropModeReplace,
        propval, caml_string_length(val)+1);
    CAMLreturn(Val_unit);
}

CAMLprim value x11_prop_get(value win, value atom) {
    CAMLparam2(win, atom);
    char* prop = readprop((Window)win, (Atom)atom);
    CAMLreturn(caml_copy_string(prop));
}

static char* readprop(Window win, Atom prop) {
    Atom rtype;
    unsigned long format = 0, nitems = 0, nleft = 0, nread = 0;
    unsigned char* data = NULL;
    XGetWindowProperty(X.display, win, prop, 0, -1, False, AnyPropertyType, &rtype,
                       (int*)&format, &nitems, &nleft, &data);
    return (char*)data;
}

static int error_handler(Display* disp, XErrorEvent* ev) {
    X.errno = ev->error_code;
    return 0;
}
