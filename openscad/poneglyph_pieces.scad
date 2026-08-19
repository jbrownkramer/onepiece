// ============================================================
//  ROAD PONEGLYPH  --  jigsaw slab in ROWS x COLS pieces
//
//  The clue is engraved across the WHOLE slab, then the slab is
//  cut into interlocking pieces, so a single piece shows only
//  fragments of letters.  Only the assembled slab reads.
//
//  Letters are written in the Poneglyph glyph alphabet (see
//  poneglyph_glyphs.scad) and decoded with decoder_wheel.scad.
//  Set ENCODE=false for plain Latin letters instead.
//
//  HOW TO USE
//    1. Edit CLUE (one string per line) - keep each line short
//       enough; the console warns if a line is too wide.
//    2. Set PART:
//         "preview"  assembled slab (look at it, don't print)
//         "plate"    all pieces laid out for printing
//         0,1,2,3..  a single piece (row-major from top-left)
//    3. F6 render, export STL.  Print engraved-face UP.
//
//  Print notes: 0.2 mm layers, 3 walls, 15% infill.  Red PLA if
//  you have it (Road Poneglyphs are red); otherwise paint later.
// ============================================================

use <poneglyph_glyphs.scad>

/* [What to render] */
PART = "plate";          // ["preview","plate",0,1,2,3,4,5,6,7,8]

/* [Cipher] */
ENCODE     = true;       // true = poneglyph glyphs, false = plain letters
KEY_NUMBER = 13;         // decoder wheel arrow setting (13 = birthday!)

/* [The clue - one entry per line, uppercase letters, digits, spaces] */
CLUE = [
    "THE ONE PIECE",
    "WAITS BELOW",
    "WHERE STRAW",
    "HATS SLEEP",
];

/* [Slab layout] */
COLS      = 2;           // pieces across
ROWS      = 2;           // pieces down
PIECE_W   = 60;          // mm, each piece
PIECE_H   = 60;          // mm, each piece
THICK     = 8;           // mm slab thickness

/* [Jigsaw tabs] */
TAB_STEM_W = 9;          // width of the neck
TAB_STEM_L = 3.5;        // length of the neck before the head
TAB_HEAD_R = 5.5;        // radius of the round head
CLEARANCE  = 0.25;       // extra gap in the female sockets (0.2-0.35)

/* [Clue text] */
TEXT_SIZE  = 8;          // glyph height mm  (13 chars/line fits at 8 on a 120 mm slab)
LINE_GAP   = 6;          // gap between lines mm
PITCH_K    = 0.85;       // character advance as a fraction of TEXT_SIZE
ENGRAVE    = 1.4;        // depth of engraving mm

/* [Decorative border] */
BORDER        = true;
BORDER_TEXT   = "THE ONE PIECE IS REAL ";   // repeats around the edge (also in glyphs)
BORDER_SIZE   = 4.5;     // border glyph height mm
BORDER_INSET  = 3;       // distance from slab edge to border band mm
FRAME_GROOVE  = true;    // thin groove between border and clue
GROOVE_W      = 1.0;
GROOVE_DEPTH  = 0.8;

/* [Misc] */
LABEL_BACK    = true;    // engrave piece number on the underside
PLATE_GAP     = 6;       // spacing between pieces on the plate mm
CORNER_R      = 2;       // rounded outer corners

// ------------------------------------------------------------
SHIFT   = KEY_NUMBER - 1;
SLAB_W  = COLS * PIECE_W;
SLAB_H  = ROWS * PIECE_H;
TAB_EXT = TAB_STEM_L + 1.6 * TAB_HEAD_R;     // how far a tab sticks out
PITCH   = TEXT_SIZE * PITCH_K;
BPITCH  = BORDER_SIZE * 0.9;
BORDER_BAND = BORDER ? BORDER_INSET + BORDER_SIZE + BORDER_INSET : 0;
INNER_MARGIN = BORDER_BAND + (FRAME_GROOVE ? GROOVE_W + 2 : 2);
INNER_W = SLAB_W - 2 * INNER_MARGIN;
INNER_H = SLAB_H - 2 * INNER_MARGIN;
SHIFT_USED = ENCODE ? SHIFT : 0;

// warn about lines that won't fit
for (l = CLUE)
    if (glyph_line_width(l, TEXT_SIZE, PITCH) > INNER_W)
        echo(str("WARNING: clue line too wide for slab: '", l, "' (",
                 glyph_line_width(l, TEXT_SIZE, PITCH), " mm > ", INNER_W, " mm)"));
if (len(CLUE) * (TEXT_SIZE + LINE_GAP) - LINE_GAP > INNER_H)
    echo("WARNING: too many clue lines for slab height");
echo(str("Assembled slab: ", SLAB_W, " x ", SLAB_H, " mm; each piece up to ",
         PIECE_W + 2 * TAB_EXT, " x ", PIECE_H + 2 * TAB_EXT, " mm incl. tabs"));

// ---- 2D: one line of the clue (glyphs or letters) ------------
module clue_line(str, size, pitch) {
    if (ENCODE)
        glyph_line(str, size, SHIFT_USED, pitch);
    else
        for (i = [0 : len(str) - 1])
            translate([(i - (len(str) - 1) / 2) * pitch, 0])
                text(str[i], size = size, font = "Liberation Sans:style=Bold",
                     halign = "center", valign = "center");
}

// repeat BORDER_TEXT to fill n characters
function rep_text(n, s = "", src = BORDER_TEXT) =
    len(s) >= n ? s : rep_text(n, str(s, src), src);

// ---- 2D: everything engraved into the top face -----------------
module engraving2d() {
    // clue block, centered on the slab
    n = len(CLUE);
    block_h = n * TEXT_SIZE + (n - 1) * LINE_GAP;
    translate([SLAB_W / 2, SLAB_H / 2])
        for (i = [0 : n - 1])
            translate([0, block_h / 2 - TEXT_SIZE / 2 - i * (TEXT_SIZE + LINE_GAP)])
                clue_line(CLUE[i], TEXT_SIZE, PITCH);

    if (BORDER) {
        bc = BORDER_INSET + BORDER_SIZE / 2;              // band centre offset from edge
        // top & bottom bands
        nh = floor((SLAB_W - 2 * BORDER_BAND) / BPITCH);
        th = rep_text(nh);
        translate([SLAB_W / 2, SLAB_H - bc]) glyph_line(th, BORDER_SIZE, SHIFT_USED, BPITCH);
        translate([SLAB_W / 2, bc]) rotate(180) glyph_line(th, BORDER_SIZE, SHIFT_USED, BPITCH);
        // left & right bands
        nv = floor((SLAB_H - 2 * BORDER_BAND) / BPITCH);
        tv = rep_text(nv);
        translate([bc, SLAB_H / 2]) rotate(90) glyph_line(tv, BORDER_SIZE, SHIFT_USED, BPITCH);
        translate([SLAB_W - bc, SLAB_H / 2]) rotate(-90) glyph_line(tv, BORDER_SIZE, SHIFT_USED, BPITCH);
        // corner dots
        for (x = [bc, SLAB_W - bc], y = [bc, SLAB_H - bc])
            translate([x, y]) circle(d = BORDER_SIZE * 0.5, $fn = 24);
    }
}

module groove2d() {
    if (FRAME_GROOVE) {
        o = BORDER_BAND;
        difference() {
            translate([o, o]) square([SLAB_W - 2 * o, SLAB_H - 2 * o]);
            translate([o + GROOVE_W, o + GROOVE_W])
                square([SLAB_W - 2 * o - 2 * GROOVE_W, SLAB_H - 2 * o - 2 * GROOVE_W]);
        }
    }
}

// ---- 3D: the full engraved slab (uncut) ------------------------
module slab() {
    difference() {
        linear_extrude(THICK)
            offset(r = CORNER_R) offset(delta = -CORNER_R)
                square([SLAB_W, SLAB_H]);
        translate([0, 0, THICK - ENGRAVE]) linear_extrude(ENGRAVE + 1) engraving2d();
        translate([0, 0, THICK - GROOVE_DEPTH]) linear_extrude(GROOVE_DEPTH + 1) groove2d();
    }
}

// ---- 2D: jigsaw knob pointing +x, base at origin ----------------
module knob(grow = 0) {
    offset(delta = grow)
        union() {
            translate([-0.01, -TAB_STEM_W / 2]) square([TAB_STEM_L + 0.02, TAB_STEM_W]);
            translate([TAB_STEM_L + TAB_HEAD_R * 0.6, 0]) circle(r = TAB_HEAD_R, $fn = 48);
        }
}

// male on the right/top edge of piece (c,r) when (c+r) is even
function male_right(c, r) = (c + r) % 2 == 0;
function male_top(c, r)   = (c + r) % 2 == 0;

// ---- 2D: outline of piece (c, r);  c = column from left, r = row from bottom
module tile2d(c, r) {
    x0 = c * PIECE_W; y0 = r * PIECE_H;
    cx = x0 + PIECE_W / 2; cy = y0 + PIECE_H / 2;
    difference() {
        union() {
            translate([x0, y0]) square([PIECE_W, PIECE_H]);
            // right edge, male
            if (c < COLS - 1 && male_right(c, r))
                translate([x0 + PIECE_W, cy]) knob();
            // left edge is male when the left neighbour's right is female
            if (c > 0 && !male_right(c - 1, r))
                translate([x0, cy]) rotate(180) knob();
            // top edge, male
            if (r < ROWS - 1 && male_top(c, r))
                translate([cx, y0 + PIECE_H]) rotate(90) knob();
            // bottom edge male when the neighbour below's top is female
            if (r > 0 && !male_top(c, r - 1))
                translate([cx, y0]) rotate(-90) knob();
        }
        // female sockets (mirror of the neighbour's knob, plus clearance)
        if (c < COLS - 1 && !male_right(c, r))
            translate([x0 + PIECE_W, cy]) rotate(180) knob(CLEARANCE);
        if (c > 0 && male_right(c - 1, r))
            translate([x0, cy]) knob(CLEARANCE);
        if (r < ROWS - 1 && !male_top(c, r))
            translate([cx, y0 + PIECE_H]) rotate(-90) knob(CLEARANCE);
        if (r > 0 && male_top(c, r - 1))
            translate([cx, y0]) rotate(90) knob(CLEARANCE);
    }
}

// piece number: row-major from TOP-left, 1-based (what a person expects)
function piece_no(c, r) = (ROWS - 1 - r) * COLS + c + 1;

// ---- 3D: one finished piece, still in slab coordinates ---------
module piece(c, r) {
    difference() {
        intersection() {
            slab();
            translate([0, 0, -1]) linear_extrude(THICK + 2) tile2d(c, r);
        }
        if (LABEL_BACK)
            translate([c * PIECE_W + PIECE_W / 2, r * PIECE_H + PIECE_H / 2, -1])
                linear_extrude(1 + 0.6)
                    mirror([1, 0, 0])
                        text(str(piece_no(c, r)), size = 8, halign = "center",
                             valign = "center", font = "Liberation Sans:style=Bold");
    }
}

// piece moved so it sits at the origin (for single-piece export)
module piece_at_origin(c, r) {
    translate([-c * PIECE_W + TAB_EXT, -r * PIECE_H + TAB_EXT, 0]) piece(c, r);
}

// ---- output ------------------------------------------------------
module preview() { for (c = [0 : COLS - 1], r = [0 : ROWS - 1]) piece(c, r); }

module plate() {
    for (c = [0 : COLS - 1], r = [0 : ROWS - 1])
        translate([c * (PIECE_W + 2 * TAB_EXT + PLATE_GAP),
                   r * (PIECE_H + 2 * TAB_EXT + PLATE_GAP), 0])
            piece_at_origin(c, r);
}

if (PART == "preview")     preview();
else if (PART == "plate")  plate();
else {
    // single piece by number (row-major from top-left, 0-based)
    n = PART;
    c = n % COLS;
    r = ROWS - 1 - floor(n / COLS);
    piece_at_origin(c, r);
}
