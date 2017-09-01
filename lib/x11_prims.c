#include <curses.h>
#include <caml/mlvalues.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/callback.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xft/Xft.h>

static int error_handler(Display* disp, XErrorEvent* ev);
static char* readprop(Window win, Atom prop);
static void create_window(int height, int width);

static struct {
    bool running;
    Display* display;
    Visual* visual;
    Colormap colormap;
    unsigned depth;
    int screen;
    Window root;
    int errnum;
    /* assume one window per process for now */
    Window self;
    XftDraw* xft;
    Pixmap pixmap;
    int width;
    int height;
    XIC xic;
    XIM xim;
    GC gc;
} X = {0};

CAMLprim value x11_connect(void) {
    CAMLparam0();
    if (!X.display) {
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
        X.running  = true;
    }
    CAMLreturn(Val_unit);
}

CAMLprim value x11_disconnect(void) {
    CAMLparam0();
    if (X.display) {
        if (X.self) {
            XUnmapWindow(X.display, X.self);
            XSync(X.display, True);
        }
        XCloseDisplay(X.display);
    }
    CAMLreturn(Val_unit);
}

CAMLprim value x11_connfd(void) {
    CAMLparam0();
    CAMLreturn(Val_int( ConnectionNumber(X.display) ));
}

CAMLprim value x11_make_window(value height, value width) {
    CAMLparam2(height, width);
    create_window(Int_val(height), Int_val(width));
    CAMLreturn(Val_int(X.self));
}

CAMLprim value x11_make_dialog(value height, value width) {
    CAMLparam2(height, width);
    create_window(Int_val(height), Int_val(width));
    Atom WindowType = XInternAtom(X.display, "_NET_WM_WINDOW_TYPE", False);
    Atom DialogType = XInternAtom(X.display, "_NET_WM_WINDOW_TYPE_DIALOG", False);
    XChangeProperty(X.display, X.self, WindowType, XA_ATOM, 32, PropModeReplace, (unsigned char*)&DialogType, 1);
    CAMLreturn(Val_int(X.self));
}

CAMLprim value x11_show_window(value state) {
    CAMLparam1(state);
    if (Bool_val(state))
        XMapWindow(X.display, X.self);
    else
        XUnmapWindow(X.display, X.self);
    CAMLreturn(Val_unit);
}

CAMLprim value x11_event_loop(value ms, value cbfn) {
    CAMLparam2(ms, cbfn);
    while (X.running) {
        XEvent e; XPeekEvent(X.display, &e);
        bool pending = false; //pollfds(Int_val(ms), cbfn);
        int nevents  = XEventsQueued(X.display, QueuedAfterFlush);
        if (pending || nevents) {
            /* pare down irrelevant mouse drag events to just the latest */
            XTimeCoord* coords = XGetMotionEvents(X.display, X.self, CurrentTime, CurrentTime, &nevents);
            if (coords) XFree(coords);

            /* now take the events, convert them, and call the callback */
            for (XEvent e; XPending(X.display);) {
                XNextEvent(X.display, &e);
                if (!XFilterEvent(&e, None)) {
                    // Convert the event.
                    caml_callback(cbfn, Val_unit);
                }
            }

            if (X.running) {
                caml_callback(cbfn, Val_unit /* redraw event */);
                XCopyArea(X.display, X.pixmap, X.self, X.gc, 0, 0, X.width, X.height, 0, 0);
            }
        }
        XFlush(X.display);
    }
    CAMLreturn(Val_unit);
}

CAMLprim value x11_errno(void) {
    CAMLparam0();
    CAMLreturn(Val_int(X.errnum));
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
    X.errnum = ev->error_code;
    return 0;
}

static void create_window(int height, int width) {
    /* create the main window */
    X.width  = width ;
    X.height = height;
    XWindowAttributes wa;
    XGetWindowAttributes(X.display, X.root, &wa);
    X.self = XCreateSimpleWindow(X.display, X.root,
        (wa.width  - X.width) / 2,
        (wa.height - X.height) / 2,
        X.width,
        X.height,
        0, X.depth,
        0xffffffff // config_get_int(Color00)
    );

    /* register interest in the delete window message */
    Atom wmDeleteMessage = XInternAtom(X.display, "WM_DELETE_WINDOW", False);
    XSetWMProtocols(X.display, X.self, &wmDeleteMessage, 1);

    /* setup window attributes and events */
    XSetWindowAttributes swa;
    swa.backing_store = WhenMapped;
    swa.bit_gravity = NorthWestGravity;
    XChangeWindowAttributes(X.display, X.self, CWBackingStore|CWBitGravity, &swa);
    //XStoreName(X.display, X.self, "tide");
    XSelectInput(X.display, X.self,
          StructureNotifyMask
        | ButtonPressMask
        | ButtonReleaseMask
        | ButtonMotionMask
        | KeyPressMask
        | FocusChangeMask
        | PropertyChangeMask
    );

    /* set input methods */
    if ((X.xim = XOpenIM(X.display, 0, 0, 0)))
        X.xic = XCreateIC(X.xim, XNInputStyle, XIMPreeditNothing|XIMStatusNothing,
                          XNClientWindow, X.self, XNFocusWindow, X.self, NULL);

    /* initialize pixmap and drawing context */
    X.pixmap = XCreatePixmap(X.display, X.self, width, height, X.depth);
    X.xft    = XftDrawCreate(X.display, X.pixmap, X.visual, X.colormap);

    /* initialize the graphics context */
    XGCValues gcv;
    gcv.foreground = WhitePixel(X.display, X.screen);
    gcv.graphics_exposures = False;
    X.gc = XCreateGC(X.display, X.self, GCForeground|GCGraphicsExposures, &gcv);
}
