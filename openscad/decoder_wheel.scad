// ============================================================
//  ROBIN'S DECODER WHEEL  --  two-disc cipher wheel
//
//  Outer disc: letters A-Z around the rim, numbers 1-26 inside them.
//  Inner disc: the 26 Poneglyph glyphs (same alphabet as
//              poneglyph_pieces.scad) with an arrow at glyph #0.
//
//  To decode: turn the inner disc until the ARROW points at the
//  key number (KEY_NUMBER, default 13).  Every glyph now sits under
//  its true letter.
//
//  PART = "plate"    both discs + pivot pin/cap laid out for printing
//         "outer"    outer disc only
//         "inner"    inner disc only
//         "pin"      pivot pin + cap only
//         "preview"  assembled, inner rotated to KEY_NUMBER
//
//  Print notes: 0.2 mm layers, face up.  Raised text prints better
//  than engraved at this size on a single-colour printer; pause &
//  swap filament at the text layer for a two-tone wheel if you like.
//  Pivot: use the printed pin+cap, OR a brass paper brad, OR an M4
//  bolt + nyloc nut through the 4.5 mm hole.
// ============================================================

use <poneglyph_glyphs.scad>

/* [What to render] */
PART = "plate";          // ["plate","outer","inner","pin","preview"]

/* [Cipher] */
KEY_NUMBER = 13;         // arrow setting used for the preview (and your clue!)

/* [Sizes] */
OUTER_D   = 100;         // outer disc diameter mm
INNER_D   = 66;          // inner disc diameter mm
THICK     = 2.4;         // disc thickness mm
LETTER_SIZE = 6;         // A-Z height mm
NUMBER_SIZE = 3.2;       // 1-26 height mm
GLYPH_SIZE  = 6;         // glyph height mm
RELIEF      = 0.6;       // height of raised (or depth of engraved) marks mm
RAISED      = true;      // true = raised marks, false = engraved
PIVOT_D     = 4.5;       // pivot hole diameter mm
FONT        = "Liberation Sans:style=Bold";

/* [Rings - radii measured from centre] */
R_LETTERS = 44;          // centre-line of the letter ring
R_NUMBERS = 37.5;        // centre-line of the number ring
R_GLYPHS  = 27.5;        // centre-line of the glyph ring on the inner disc

// ------------------------------------------------------------
STEP  = 360 / 26;
SHIFT = KEY_NUMBER - 1;
$fn   = 96;

// place `children()` upright at angle slot i (i=0 is straight up, clockwise)
module at_slot(i, r) { rotate(-i * STEP) translate([0, r]) children(); }

// ---- 2D marks -----------------------------------------------
module outer_marks2d() {
    for (i = [0 : 25]) {
        at_slot(i, R_LETTERS)
            text(ALPHABET_LETTER(i), size = LETTER_SIZE, font = FONT,
                 halign = "center", valign = "center");
        at_slot(i, R_NUMBERS)
            text(str(i + 1), size = NUMBER_SIZE, font = FONT,
                 halign = "center", valign = "center");
        // tick between slots, just outside the inner disc
        rotate(-(i + 0.5) * STEP)
            translate([-0.4, INNER_D / 2 + 0.6]) square([0.8, 2]);
    }
    // outer rim ring
    difference() { circle(d = OUTER_D - 1); circle(d = OUTER_D - 3); }
}

function ALPHABET_LETTER(i) = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[i];

module inner_marks2d() {
    for (j = [0 : 25]) {
        at_slot(j, R_GLYPHS) glyph2d(j, GLYPH_SIZE);
        // ticks at the rim between glyphs
        rotate(-(j + 0.5) * STEP)
            translate([-0.4, INNER_D / 2 - 3]) square([0.8, 2.6]);
    }
    // arrow at glyph #0, pointing outward
    translate([0, INNER_D / 2 - 5.5])
        polygon([[-2.6, 0], [2.6, 0], [0, 5.2]]);
    // small centre ring
    difference() { circle(d = PIVOT_D + 6); circle(d = PIVOT_D + 4); }
}

// ---- 3D discs -----------------------------------------------
module disc(d) {
    difference() {
        cylinder(d = d, h = THICK);
        translate([0, 0, -1]) cylinder(d = PIVOT_D, h = THICK + 2);
    }
}

module marked_disc(d) {
    if (RAISED) {
        disc(d);
        translate([0, 0, THICK - 0.01]) linear_extrude(RELIEF + 0.01) children();
    } else {
        difference() {
            disc(d);
            translate([0, 0, THICK - RELIEF]) linear_extrude(RELIEF + 1) children();
        }
    }
}

module outer_disc() { marked_disc(OUTER_D) outer_marks2d(); }
module inner_disc() { marked_disc(INNER_D) inner_marks2d(); }

// ---- pivot pin + cap ---------------------------------------
PIN_D   = PIVOT_D - 0.35;                 // slides through both holes
PIN_LEN = 2 * THICK + (RAISED ? RELIEF : 0) + 0.4;
module pin() {
    cylinder(d = PIVOT_D + 5, h = 1.6);   // head (goes on the underside)
    cylinder(d = PIN_D, h = 1.6 + PIN_LEN + 2.5);
}
module cap() {
    difference() {
        cylinder(d = PIVOT_D + 5, h = 2.5);
        translate([0, 0, -1]) cylinder(d = PIN_D - 0.3, h = 5);   // press fit
    }
}

// ---- output ------------------------------------------------------
module preview() {
    outer_disc();
    translate([0, 0, THICK + (RAISED ? RELIEF : 0)])
        rotate(-SHIFT * STEP) inner_disc();
}

module plate() {
    outer_disc();
    translate([OUTER_D / 2 + INNER_D / 2 + 6, 0, 0]) inner_disc();
    translate([OUTER_D / 2 + 8, -INNER_D / 2 - 10, 0]) pin();
    translate([OUTER_D / 2 + 22, -INNER_D / 2 - 10, 0]) cap();
}

if (PART == "plate")        plate();
else if (PART == "outer")   outer_disc();
else if (PART == "inner")   inner_disc();
else if (PART == "pin")     { pin(); translate([14, 0, 0]) cap(); }
else                        preview();
