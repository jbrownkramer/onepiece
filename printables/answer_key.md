# Answer key (host only)

## Cipher, key = 13
Glyphs are numbered 0–25 in the order of `openscad/poneglyph_glyphs.scad`
(the chart in `renders/glyph_chart.png` labels glyph #n with the n-th letter,
so "glyph O" = the diamond, glyph #14).

With key **13** (shift 12), a letter is written with the glyph **14 places
later** in the chart:

| Letter | Written as glyph | Letter | Written as glyph |
|---|---|---|---|
| A | O (diamond) | N | B (I-beam) |
| B | P (cup) | O | C (corner + dot) |
| C | Q (cap) | P | D (rising diag + stem) |
| D | R (falling diag + dots) | Q | E (cross + dot) |
| E | S (box) | R | F (stem + diag up) |
| F | T (T + dot) | S | G (L + half cap) |
| G | U (triangle) | T | H (X) |
| H | V (V + dot) | U | I (stem + 2 dots) |
| I | W (two bars ‖) | V | J (T with foot) |
| J | X (three bars ≡) | W | K (tent Λ) |
| K | Y (squared S) | X | L (stem + diag down) |
| L | Z (two bars =) | Y | M (H) |
| M | A (tall Γ) | Z | N (inverted Y) |

Digits and punctuation are engraved as normal characters.

**Wheel check:** arrow at 13 → the diamond sits under A. If it doesn't, the
inner disc is upside down or `KEY_NUMBER` differs between the two files.

## Default clue on the slab
```
THE ONE PIECE
WAITS BELOW
WHERE STRAW
HATS SLEEP
```
(replace with the real hiding place — edit `CLUE` in `poneglyph_pieces.scad`)

Border text around the slab decodes to: `THE ONE PIECE IS REAL` (repeating).

## Piece numbering
Engraved on the underside: 1 = top-left, 2 = top-right, 3 = bottom-left,
4 = bottom-right (assembled orientation, clue readable).
