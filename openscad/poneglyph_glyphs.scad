// ============================================================
//  Poneglyph Glyph Library  (shared by poneglyph_pieces.scad
//  and decoder_wheel.scad so both use the SAME 26 symbols)
//
//  Each glyph is drawn on a 2-wide x 3-tall grid of "stroke"
//  segments [x1,y1,x2,y2].  Zero-length segments are dots.
//  glyph2d(idx, size) draws glyph #idx centered at the origin,
//  scaled so its overall height (incl. stroke) == size.
//
//  Cipher:  a letter with alphabet index L (A=0..Z=25) is written
//  as glyph number  (L - SHIFT) mod 26.   On the decoder wheel,
//  turning the inner disc so its arrow points at number KEY
//  (= SHIFT+1) lines every glyph up under its true letter.
// ============================================================

ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

GLYPH_STROKE = 0.5;   // stroke width in grid units (grid is 2 x 3)

GLYPHS = [
/* A */ [[0,0,0,3],[0,3,2,3],[2,3,2,2]],                 // tall gamma with hook
/* B */ [[0,0,2,0],[1,0,1,3],[0,3,2,3]],                 // I-beam
/* C */ [[0,3,2,3],[2,3,2,0],[0,0.4,0,0.4]],             // top+right corner, dot
/* D */ [[0,0,2,3],[0,3,0,1.5]],                         // rising diagonal + half stem
/* E */ [[0,1.5,2,1.5],[1,0,1,3],[2,2.8,2,2.8]],         // cross with dot
/* F */ [[0,0,0,3],[0,1.5,2,3]],                         // stem, diagonal up-right
/* G */ [[0,0,2,0],[0,0,0,3],[0,3,1,3]],                 // L with half cap
/* H */ [[0,0,2,3],[2,0,0,3]],                           // X
/* I */ [[1,0,1,3],[0,1.5,0,1.5],[2,1.5,2,1.5]],         // stem with two side dots
/* J */ [[0,3,2,3],[1,3,1,0],[0,0,1,0]],                 // T with left foot
/* K */ [[0,0,1,3],[1,3,2,0]],                           // lambda / tent
/* L */ [[0,0,0,3],[0,3,2,0]],                           // stem, diagonal down-right
/* M */ [[0,0,0,3],[2,0,2,3],[0,1.5,2,1.5]],             // H
/* N */ [[0,0,1,1.5],[1,1.5,2,0],[1,1.5,1,3]],           // inverted Y
/* O */ [[0,1.5,1,3],[1,3,2,1.5],[2,1.5,1,0],[1,0,0,1.5]], // diamond
/* P */ [[0,0,2,0],[0,0,0,3],[2,0,2,3]],                 // cup (U-box)
/* Q */ [[0,3,2,3],[0,3,0,0],[2,3,2,0]],                 // cap (upside-down cup)
/* R */ [[0,3,2,0],[0,0,0,0],[2,3,2,3]],                 // falling diagonal, corner dots
/* S */ [[0,0,0,3],[0,3,2,3],[2,3,2,0],[2,0,0,0]],       // box outline
/* T */ [[0,3,2,3],[1,3,1,0],[0,1,0,1]],                 // T with side dot
/* U */ [[0,0,1,3],[1,3,2,0],[0,0,2,0]],                 // triangle
/* V */ [[0,3,1,0],[1,0,2,3],[1,2.4,1,2.4]],             // V with dot
/* W */ [[0,0,0,3],[2,0,2,3]],                           // two bars ||
/* X */ [[0,0.6,2,0.6],[0,1.5,2,1.5],[0,2.4,2,2.4]],     // three bars
/* Y */ [[1,0,1,3],[0,3,1,3],[1,0,2,0]],                 // squared S
/* Z */ [[0,0,2,0],[0,3,2,3]],                           // two bars =
];

// ---- helpers ------------------------------------------------

// index of an uppercase letter in the alphabet, -1 if not a letter
function letter_index(c) =
    let(l = search(c, ALPHABET, 1)) (len(l) == 0 || l[0] == undef) ? -1 : l[0];

function to_upper(c) =
    let(o = ord(c)) (o >= 97 && o <= 122) ? chr(o - 32) : c;

// glyph number used to write letter with alphabet index li
function enc_index(li, shift) = ((li - shift) % 26 + 26) % 26;

// nominal footprint of a glyph as a fraction of its height
GLYPH_W_RATIO = (2 + GLYPH_STROKE) / (3 + GLYPH_STROKE);

// draw glyph #idx, centered, height == size
module glyph2d(idx, size) {
    s = size / (3 + GLYPH_STROKE);
    scale(s) translate([-1, -1.5])
        for (seg = GLYPHS[idx % 26])
            hull() {
                translate([seg[0], seg[1]]) circle(d = GLYPH_STROKE, $fn = 20);
                translate([seg[2], seg[3]]) circle(d = GLYPH_STROKE, $fn = 20);
            }
}

// draw one character: letters become (shifted) glyphs, other
// characters (digits, punctuation) are drawn as normal text.
module glyph_char(c, size, shift = 0, font = "Liberation Sans:style=Bold") {
    u  = to_upper(c);
    li = letter_index(u);
    if (li >= 0)
        glyph2d(enc_index(li, shift), size);
    else if (u != " ")
        text(u, size = size * 0.85, font = font, halign = "center", valign = "center");
}

// draw a whole line of characters, fixed pitch, centered on origin.
// pitch = horizontal advance per character (default derived from size)
module glyph_line(str, size, shift = 0, pitch = undef, font = "Liberation Sans:style=Bold") {
    p = (pitch == undef) ? size * 0.9 : pitch;
    n = len(str);
    for (i = [0 : n - 1])
        translate([(i - (n - 1) / 2) * p, 0])
            glyph_char(str[i], size, shift, font);
}

// width a line will occupy (for layout checks)
function glyph_line_width(str, size, pitch = undef) =
    let(p = (pitch == undef) ? size * 0.9 : pitch) len(str) * p;

// ---- self-test chart: run this file directly to see all 26 ------
module glyph_chart(size = 10) {
    for (i = [0 : 25]) {
        x = (i % 13) * size * 1.6;
        y = -floor(i / 13) * size * 3;
        translate([x, y]) glyph2d(i, size);
        translate([x, y - size * 1.1])
            text(ALPHABET[i], size = size * 0.6, halign = "center", valign = "top",
                 font = "Liberation Sans:style=Bold");
    }
}

// Only renders when this file is opened on its own (not when `use`d)
glyph_chart();
