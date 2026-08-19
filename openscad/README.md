# OpenSCAD props

Requires OpenSCAD (tested with 2021.01). All three files live together; the two
part files `use <poneglyph_glyphs.scad>` for the shared cipher alphabet.

| File | Makes |
|---|---|
| `poneglyph_glyphs.scad` | 26-glyph alphabet + helpers. Open on its own to see the chart. |
| `poneglyph_pieces.scad` | 2×2 jigsaw Poneglyph slab with the clue engraved in glyphs |
| `decoder_wheel.scad` | Two-disc decoder wheel + pivot pin/cap |

## Poneglyph pieces — parameters you'll actually touch
- `CLUE` — list of lines. Uppercase letters, digits, spaces. ≤13 chars per line
  at default sizes; the console prints a WARNING if a line is too wide.
- `KEY_NUMBER` — cipher key (13). Must match the wheel.
- `ENCODE` — `false` for plain Latin letters (easier, less cool).
- `PIECE_W`, `PIECE_H`, `THICK` — piece size (default 60×60×8 mm).
- `CLEARANCE` — jigsaw socket slack. 0.25 default; loosen to 0.3–0.35 if tight.
- `PART` — `"preview"`, `"plate"`, or `0..3` for one piece (row-major from top-left).

## Decoder wheel
- `KEY_NUMBER` — only affects the preview alignment.
- `RAISED` — raised (default) or engraved marks.
- `PART` — `"plate"`, `"outer"`, `"inner"`, `"pin"`, `"preview"`.

## Export (PowerShell, from repo root)
```powershell
$o = "C:\Program Files\OpenSCAD\openscad.exe"
0..3 | % { & $o -o "stl\poneglyph_piece_$($_+1).stl" -D "PART=$_" --render openscad\poneglyph_pieces.scad }
& $o -o stl\poneglyph_plate.stl        -D 'PART="plate"' --render openscad\poneglyph_pieces.scad
& $o -o stl\decoder_wheel_outer.stl    -D 'PART="outer"' --render openscad\decoder_wheel.scad
& $o -o stl\decoder_wheel_inner.stl    -D 'PART="inner"' --render openscad\decoder_wheel.scad
& $o -o stl\decoder_wheel_pin.stl      -D 'PART="pin"'   --render openscad\decoder_wheel.scad
```
Or open the file in the OpenSCAD GUI, set `PART` in the Customizer, F6, Export STL.

## Print settings
- 0.2 mm layers, 3 walls, 15% infill, engraved/raised face **up**, no supports.
- Poneglyphs: red PLA (Road Poneglyphs are red) or paint after.
- Wheel: single colour is fine; for two-tone, pause at the first text layer and
  swap filament. Pivot: printed pin+cap, brass paper brad, or M4 bolt + nyloc.

## Preview renders
See `../renders/*.png` (glyph chart, slab, plate, wheel).
