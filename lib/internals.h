#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>
#include <caml/mlvalues.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/callback.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xft/Xft.h>
#include <X11/Xresource.h>

#define intfield(r,i) Int_val(Field(r,i))

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

struct X {
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
};

/*
typedef struct XFont {
    XftFont* font;
    FcPattern* set;
    FcPattern* pattern;
    int height;
    struct XFont* next;
} XFont;
*/

typedef struct XText {
    struct XText* next;
    uint64_t argb;
    XftColor color;
    XftGlyphFontSpec* specs;
    size_t nspecs;
} XText;
