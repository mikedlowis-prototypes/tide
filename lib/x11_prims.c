#include <stdbool.h>
#include <caml/mlvalues.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/callback.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xft/Xft.h>
#include <X11/Xresource.h>

/* The order of this enum should match the type specified in x11.ml. The
   variants are divided into two groups, those with args and those without.
   Each group's tags increment, starting at 0, in the order the appear in the
   type definition */
enum {
    TFocus = 0,
    TKeyPress,
    TMouseClick,
    TMouseRelease,
    TMouseMove,
    TPaste,
    TCommand,
    TPipeClosed,
    TPipeWriteReady,
    TPipeReadReady,
    TUpdate,
    TShutdown = 0,
    TNone = -1
};

enum Keys {
    KEY_F1     = (0xE000+0),
    KEY_F2     = (0xE000+1),
    KEY_F3     = (0xE000+2),
    KEY_F4     = (0xE000+3),
    KEY_F5     = (0xE000+4),
    KEY_F6     = (0xE000+5),
    KEY_F7     = (0xE000+6),
    KEY_F8     = (0xE000+7),
    KEY_F9     = (0xE000+8),
    KEY_F10    = (0xE000+9),
    KEY_F11    = (0xE000+10),
    KEY_F12    = (0xE000+11),
    KEY_INSERT = (0xE000+12),
    KEY_DELETE = (0xE000+13),
    KEY_HOME   = (0xE000+14),
    KEY_END    = (0xE000+15),
    KEY_PGUP   = (0xE000+16),
    KEY_PGDN   = (0xE000+17),
    KEY_UP     = (0xE000+18),
    KEY_DOWN   = (0xE000+19),
    KEY_RIGHT  = (0xE000+20),
    KEY_LEFT   = (0xE000+21),
    KEY_ESCAPE = 0x1B,
    RUNE_ERR   = 0xFFFD
};

extern size_t utf8encode(char str[6], int32_t rune);
extern bool utf8decode(int32_t* rune, size_t* length, int byte);

static int error_handler(Display* disp, XErrorEvent* ev);
static char* readprop(Window win, Atom prop);
static void create_window(int height, int width);
static value mkrecord(int tag, int n, ...);
static int32_t special_keys(int32_t key);
static void xftcolor(XftColor* xc, int c);
static void init_db(void);
static char* strmcat(char* first, ...);

static value ev_focus(XEvent*);
static value ev_keypress(XEvent*);
static value ev_mouse(XEvent*);
static value ev_selclear(XEvent*);
static value ev_selnotify(XEvent*);
static value ev_selrequest(XEvent*);
static value ev_propnotify(XEvent*);
static value ev_clientmsg(XEvent*);
static value ev_configure(XEvent*);

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
    XrmDatabase db;
} X = {0};

static value (*EventHandlers[LASTEvent]) (XEvent*) = {
    [FocusIn]          = ev_focus,
    [FocusOut]         = ev_focus,
    [KeyPress]         = ev_keypress,
    [ButtonPress]      = ev_mouse,
    [ButtonRelease]    = ev_mouse,
    [MotionNotify]     = ev_mouse,
    [SelectionClear]   = ev_selclear,
    [SelectionNotify]  = ev_selnotify,
    [SelectionRequest] = ev_selrequest,
    [PropertyNotify]   = ev_propnotify,
    [ClientMessage]    = ev_clientmsg,
    [ConfigureNotify]  = ev_configure
};

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

CAMLprim value x11_show_window(value win, value state) {
    CAMLparam2(win,state);
    if (Bool_val(state))
        XMapWindow(X.display, (Window)Int_val(win));
    else
        XUnmapWindow(X.display, (Window)Int_val(win));
    CAMLreturn(Val_unit);
}

CAMLprim value x11_flip(void) {
    CAMLparam0();
    XCopyArea(X.display, X.pixmap, X.self, X.gc, 0, 0, X.width, X.height, 0, 0);
    CAMLreturn(Val_unit);
}

CAMLprim value x11_draw_rect(value rect) {
    CAMLparam1(rect);
    #define intfield(r,i) Int_val(Field(r,i))
    XftColor clr;
    printf("x: %d y: %d w: %d h: %d: c: %#x\n",
         intfield(rect, 0),  intfield(rect, 1),  intfield(rect, 2),
         intfield(rect, 3),  intfield(rect, 4)
    );
    xftcolor(&clr, intfield(rect, 4));
    XftDrawRect(X.xft, &clr, intfield(rect, 0), intfield(rect, 1),  /* x,y */
                             intfield(rect, 2), intfield(rect, 3)); /* w,h */
    XftColorFree(X.display, X.visual, X.colormap, &clr);

    CAMLreturn(Val_unit);
}

CAMLprim value x11_event_loop(value ms, value cbfn) {
    CAMLparam2(ms, cbfn);
    CAMLlocal1( event );
    while (X.running) {
        XEvent e; XPeekEvent(X.display, &e);
        //bool pending = false; //pollfds(Int_val(ms), cbfn);

        int nevents  = XEventsQueued(X.display, QueuedAfterFlush);

        /* Update the mouse posistion and simulate a mosuemove event for it */
        Window xw; int _, x, y; unsigned int mods;
        XQueryPointer(X.display, X.self, &xw, &xw, &_, &_, &x, &y, &mods);
        caml_callback(cbfn, mkrecord(TMouseMove, 3, mods, x, y));

        /* check if we have any pending xevents */
        if (nevents) {
            /* pare down irrelevant mouse drag events to just the latest */
            XTimeCoord* coords = XGetMotionEvents(
                X.display, X.self, CurrentTime, CurrentTime, &nevents);
            if (coords) XFree(coords);

            /* now take the events, convert them, and call the callback */
            for (XEvent e; XPending(X.display);) {
                XNextEvent(X.display, &e);
                if (XFilterEvent(&e, None)) continue;
                if (!EventHandlers[e.type]) continue;
                event = EventHandlers[e.type](&e);
                if (event != Val_int(TNone))
                    caml_callback(cbfn, event);
            }
        }

        /* generate an update event and flush any outgoing events */
        if (X.running) {
        printf("update W: %d H: %d\n", X.width, X.height);
            caml_callback(cbfn, mkrecord(TUpdate, 2, Val_int(X.width), Val_int(X.height)));
        }
        XFlush(X.display);
    }
    CAMLreturn(Val_unit);
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

CAMLprim value x11_var_get(value name) {
    CAMLparam1(name);
    init_db();
    char* type;
    XrmValue val;
    XrmGetResource(X.db, String_val(name), NULL, &type, &val);
    CAMLreturn(mkrecord(0,0));
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
        0, X.depth, 0
    );

    /* register interest in the delete window message */
    Atom wmDeleteMessage = XInternAtom(X.display, "WM_DELETE_WINDOW", False);
    XSetWMProtocols(X.display, X.self, &wmDeleteMessage, 1);

    /* setup window attributes and events */
    XSetWindowAttributes swa;
    swa.backing_store = WhenMapped;
    swa.bit_gravity = NorthWestGravity;
    XChangeWindowAttributes(X.display, X.self, CWBackingStore|CWBitGravity, &swa);
    XStoreName(X.display, X.self, "tide");
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

static value mkrecord(int tag, int nargs, ...) {
    value rec;
    if (nargs == 0) {
        rec = Val_long(tag);
    } else {
        rec = caml_alloc(nargs, tag);
        va_list args;
        va_start(args, nargs);
        for (int i = 0; i < nargs; i++)
            Store_field(rec, i, va_arg(args, value));
        va_end(args);
    }
    return rec;
}

static value ev_focus(XEvent* e) {
    bool focused = (e->type = FocusIn);
    if (X.xic)
        (focused ? XSetICFocus : XUnsetICFocus)(X.xic);
    return mkrecord(TFocus, 1, Val_true);
}

static value ev_keypress(XEvent* e) {
    int32_t rune = RUNE_ERR;
    size_t len = 0;
    char buf[8];
    KeySym key;
    Status status;
    /* Read the key string */
    if (X.xic)
        len = Xutf8LookupString(X.xic, &(e->xkey), buf, sizeof(buf), &key, &status);
    else
        len = XLookupString(&(e->xkey), buf, sizeof(buf), &key, 0);
    /* if it's ascii, just return it */
    if (key >= 0x20 && key <= 0x7F)
        return mkrecord(TKeyPress, 2, e->xkey.state, Val_int(key));
    /* decode it */
    if (len > 0) {
        len = 0;
        for (int i = 0; i < 8 && !utf8decode(&rune, &len, buf[i]); i++);
    }
    return mkrecord(TKeyPress, 2, e->xkey.state, Val_int(special_keys(key)));
}

static value ev_mouse(XEvent* e) {
    int mods = e->xbutton.state, btn = e->xbutton.button,
        x = e->xbutton.x, y = e->xbutton.y;
    if (e->type == MotionNotify)
        return mkrecord(TMouseMove, 3, Val_int(mods), Val_int(x), Val_int(y));
    else if (e->type == ButtonPress)
        return mkrecord(TMouseClick, 4, Val_int(mods), Val_int(btn), Val_int(x), Val_int(y));
    else
        return mkrecord(TMouseRelease, 4, Val_int(mods), Val_int(btn), Val_int(x), Val_int(y));
}

static value ev_selclear(XEvent* e) {
    return Val_int(TNone);
}

static value ev_selnotify(XEvent* e) {
    value event = Val_int(TNone);
    if (e->xselection.property == None) {
        char* propdata = readprop(X.self, e->xselection.selection);
        event = mkrecord(TPaste, 1, caml_copy_string(propdata));
        XFree(propdata);
    }
    return event;
}

static value ev_selrequest(XEvent* e) {
    return Val_int(TNone);
}

static value ev_propnotify(XEvent* e) {
    return Val_int(TNone);
}

static value ev_clientmsg(XEvent* e) {
    Atom wmDeleteMessage = XInternAtom(X.display, "WM_DELETE_WINDOW", False);
    if (e->xclient.data.l[0] == wmDeleteMessage)
        return mkrecord(TShutdown, 0);
    return Val_int(TNone);
}

static value ev_configure(XEvent* e) {
    value event = Val_int(TNone);
    if (e->xconfigure.width != X.width || e->xconfigure.height != X.height) {
        printf("W: %d H: %d\n", X.width, X.height);
        X.width  = e->xconfigure.width;
        X.height = e->xconfigure.height;
        X.pixmap = XCreatePixmap(X.display, X.self, X.width, X.height, X.depth);
        X.xft    = XftDrawCreate(X.display, X.pixmap, X.visual, X.colormap);
    }
    return event;
}

static int32_t special_keys(int32_t key) {
    switch (key) {
        case XK_F1:        return KEY_F1;
        case XK_F2:        return KEY_F2;
        case XK_F3:        return KEY_F3;
        case XK_F4:        return KEY_F4;
        case XK_F5:        return KEY_F5;
        case XK_F6:        return KEY_F6;
        case XK_F7:        return KEY_F7;
        case XK_F8:        return KEY_F8;
        case XK_F9:        return KEY_F9;
        case XK_F10:       return KEY_F10;
        case XK_F11:       return KEY_F11;
        case XK_F12:       return KEY_F12;
        case XK_Insert:    return KEY_INSERT;
        case XK_Delete:    return KEY_DELETE;
        case XK_Home:      return KEY_HOME;
        case XK_End:       return KEY_END;
        case XK_Page_Up:   return KEY_PGUP;
        case XK_Page_Down: return KEY_PGDN;
        case XK_Up:        return KEY_UP;
        case XK_Down:      return KEY_DOWN;
        case XK_Left:      return KEY_LEFT;
        case XK_Right:     return KEY_RIGHT;
        case XK_Escape:    return KEY_ESCAPE;
        case XK_BackSpace: return '\b';
        case XK_Tab:       return '\t';
        case XK_Return:    return '\r';
        case XK_Linefeed:  return '\n';

        /* modifiers should not trigger key presses */
        case XK_Scroll_Lock:
        case XK_Shift_L:
        case XK_Shift_R:
        case XK_Control_L:
        case XK_Control_R:
        case XK_Caps_Lock:
        case XK_Shift_Lock:
        case XK_Meta_L:
        case XK_Meta_R:
        case XK_Alt_L:
        case XK_Alt_R:
        case XK_Super_L:
        case XK_Super_R:
        case XK_Hyper_L:
        case XK_Hyper_R:
        case XK_Menu:
            return RUNE_ERR;

        /* if it ain't special, don't touch it */
        default:
            return key;
    }
}

static void xftcolor(XftColor* xc, int c) {
    #define COLOR(c) ((c) | ((c) >> 8))
    xc->color.alpha = COLOR((c & 0xFF000000) >> 16);
    xc->color.red   = COLOR((c & 0x00FF0000) >> 8);
    xc->color.green = COLOR((c & 0x0000FF00));
    xc->color.blue  = COLOR((c & 0x000000FF) << 8);
    XftColorAllocValue(X.display, X.visual, X.colormap, &(xc->color), xc);
}

static void init_db(void) {
    static bool loaded = false;
    if (loaded) return;
    XrmDatabase db;
    char *homedir  = getenv("HOME"),
         *userfile = strmcat(homedir, "/.config/tiderc", 0),
         *rootfile = strmcat(homedir, "/.Xdefaults", 0);
    XrmInitialize();

    /* load from xrdb or .Xdefaults */
    if (XResourceManagerString(X.display) != NULL)
        db = XrmGetStringDatabase(XResourceManagerString(X.display));
    else
        db = XrmGetFileDatabase(rootfile);
    XrmMergeDatabases(db, &X.db);

    /* load user settings from ~/.config/tiderc */
    db = XrmGetFileDatabase(userfile);
    (void)XrmMergeDatabases(db, &X.db);

    /* cleanup */
    free(userfile);
    free(rootfile);
    loaded = true;
}

static char* strmcat(char* first, ...) {
    va_list args;
    /* calculate the length of the final string */
    size_t len = strlen(first);
    va_start(args, first);
    for (char* s = NULL; (s = va_arg(args, char*));)
        len += strlen(s);
    va_end(args);

    /* allocate the final string and copy the args into it */
    char *str  = malloc(len+1), *curr = str;
    while (first && *first) *(curr++) = *(first++);
    va_start(args, first);
    for (char* s = NULL; (s = va_arg(args, char*));)
        while (s && *s) *(curr++) = *(s++);
    va_end(args);
    /* null terminate and return */
    *curr = '\0';
    return str;
}

