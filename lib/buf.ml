type encoding = Utf8 | Binary

type lfstyle = Unix | Dos

type bufinfo = {
  path: string;
  modtime: int;
  charset: encoding;
  crlf: lfstyle;
}

type bufstate = {
  nlines : int;
  outpoint : int;
  rope : Rope.t
}

type buf = {
  info : bufinfo;
  current : bufstate;
  lastsave : bufstate;
  undo : bufstate list;
  redo : bufstate list;
}

let create =
  let state = { nlines = 0; outpoint = 0; rope = Rope.empty }
  and info  = { path = ""; modtime = 0; charset = Utf8; crlf = Unix } in
  { info = info; current = state; lastsave = state; undo = []; redo = [] }

let load path =
  let file  = Rope.from_string (Misc.load_file path) in
  let state = { nlines = 0; outpoint = 0; rope = file }
  and info  = { path = ""; modtime = 0; charset = Utf8; crlf = Unix } in
  { info = info; current = state; lastsave = state; undo = []; redo = [] }

let saveas buf path =
  ()

let save buf =
  saveas buf buf.info.path

(*

/* cursor/selection representation */
typedef struct {
    size_t beg;
    size_t end;
    size_t col;
} Sel;

void buf_init(Buf* buf, void ( *errfn )( char* ));
size_t buf_load(Buf* buf, char* path);
void buf_reload(Buf* buf);
void buf_save(Buf* buf);

size_t buf_insert(Buf* buf, bool indent, size_t off, Rune rune);
size_t buf_delete(Buf* buf, size_t beg, size_t end);

void buf_undo(Buf* buf, Sel* sel);
void buf_redo(Buf* buf, Sel* sel);

Rune buf_get(Buf* buf, size_t pos);
size_t buf_end(Buf* buf);

size_t buf_change(Buf* buf, size_t beg, size_t end);
void buf_chomp(Buf* buf);
void buf_loglock(Buf* buf);
void buf_logclear(Buf* buf);
bool buf_iseol(Buf* buf, size_t pos);
size_t buf_bol(Buf* buf, size_t pos);
size_t buf_eol(Buf* buf, size_t pos);
size_t buf_bow(Buf* buf, size_t pos);
size_t buf_eow(Buf* buf, size_t pos);
size_t buf_lscan(Buf* buf, size_t pos, Rune r);
size_t buf_rscan(Buf* buf, size_t pos, Rune r);
void buf_getword(Buf* buf, bool ( *isword )(Rune), Sel* sel);
void buf_getblock(Buf* buf, Rune beg, Rune end, Sel* sel);
size_t buf_byrune(Buf* buf, size_t pos, int count);
size_t buf_byword(Buf* buf, size_t pos, int count);
size_t buf_byline(Buf* buf, size_t pos, int count);
void buf_findstr(Buf* buf, int dir, char* str, size_t* beg, size_t* end);
void buf_lastins(Buf* buf, size_t* beg, size_t* end);
size_t buf_setln(Buf* buf, size_t line);
size_t buf_getln(Buf* buf, size_t off);
size_t buf_getcol(Buf* buf, size_t pos);
size_t buf_setcol(Buf* buf, size_t pos, size_t col);

*)
