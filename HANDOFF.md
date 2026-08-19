# HANDOFF — One Piece 13th-birthday party build

Read this first if you're picking the project up on another machine / in a new
Claude Code session. Everything decided so far is here or in the linked files.

## Context
- Kid turning **13**, wants a One Piece party. Parent (Josh) is designing a
  5–6 station game/hunt that walks through the One Piece story and ends with
  finding the One Piece.
- **Josh has NOT settled on the stations or the ending yet.** `party_plan.md`
  is a full menu of every idea with fun/effort ratings; the "suggested lineup"
  at its bottom is only one option. The printables + station cards were written
  for that suggested lineup and will need editing once he picks.
- Assets on hand: a **piñata** (already bought), a **3D printer**, OpenSCAD
  2021.01 installed at `C:\Program Files\OpenSCAD\openscad.exe` on the main PC.
- Full game plan: `party_plan.md`.

## What exists in this repo (status)

| Path | What | Status |
|---|---|---|
| `party_plan.md` | Full idea menu: every arc + game variant, endings, 3D-print list, shopping superset, one suggested lineup | done (menu; nothing chosen) |
| `openscad/poneglyph_glyphs.scad` | Shared 26-glyph cipher alphabet + helpers (`glyph2d`, `glyph_line`, `enc_index`) | done, verified render (`renders/glyph_chart.png`) |
| `openscad/poneglyph_pieces.scad` | 2×2 jigsaw Poneglyph slab, clue engraved across the whole slab in glyphs, cut into 4 interlocking pieces | done, preview verified (`renders/poneglyph_preview.png`, `renders/poneglyph_plate.png`) |
| `openscad/decoder_wheel.scad` | Two-disc cipher wheel (letters/numbers outer, glyphs inner, arrow) + pivot pin/cap | done, preview verified (`renders/decoder_wheel_preview.png`, `renders/decoder_wheel_plate.png`) |
| `openscad/README.md` | Parameters + export commands | done |
| `printables/answer_key.md` | Cipher table for key 13, default clue, how the wheel/slab agree | done |
| `printables/power_cards.html` | Devil Fruit power cards (print, cut) | done |
| `printables/station_cards.html` | Station intro/instruction cards for the host | done |
| `stl/` | Exported STLs | **NOT DONE — next step** |

## Key design decisions (don't re-litigate)
- **Cipher key = 13** (the birthday). `KEY_NUMBER = 13` in both `.scad`
  files → `SHIFT = 12`. Letter with index L is written as glyph `(L − 12) mod 26`.
  On the wheel, turning the inner disc so the arrow points at **13** aligns
  every glyph under its true letter. Both files `use <poneglyph_glyphs.scad>`
  so they can't drift apart.
- Poneglyph clue is engraved across the **whole** slab, then cut, so single
  pieces show letter fragments only — assembly is required to read.
- Default clue (edit `CLUE` in `poneglyph_pieces.scad`):
  `THE ONE PIECE / WAITS BELOW / WHERE STRAW / HATS SLEEP`.
  Josh hasn't given the real hiding-place text yet — **ask or pick a spot in
  the yard/house and rewrite the 4 lines** (≤13 chars each at default sizes;
  the console echoes a WARNING if a line is too wide).
- Border glyphs around the slab decode to `THE ONE PIECE IS REAL` (canon wink).
- Piece size 60 mm (slab 120 mm); pieces incl. tabs ≈ 85 mm; the 4-piece
  plate ≈ 175 mm square — fits a 180 mm bed. Bump `PIECE_W/H` if the bed is
  bigger and you want it chunkier.
- Piñata = **Kaido at Onigashima**, final boss; the **key to the treasure
  chest** goes inside the piñata so the One Piece can't be opened until Kaido
  falls.

## Next steps (in order)
1. **Export STLs** (was about to start when interrupted). From the repo root:
   ```powershell
   $o = "C:\Program Files\OpenSCAD\openscad.exe"
   # Poneglyph pieces, one file each (PART 0..3 = top-left, top-right, bottom-left, bottom-right)
   0..3 | % { & $o -o "stl\poneglyph_piece_$($_+1).stl" -D "PART=$_" --render openscad\poneglyph_pieces.scad }
   # or all four on one plate
   & $o -o stl\poneglyph_plate.stl -D 'PART="plate"' --render openscad\poneglyph_pieces.scad
   # Decoder wheel
   & $o -o stl\decoder_wheel_outer.stl -D 'PART="outer"' --render openscad\decoder_wheel.scad
   & $o -o stl\decoder_wheel_inner.stl -D 'PART="inner"' --render openscad\decoder_wheel.scad
   & $o -o stl\decoder_wheel_pin.stl   -D 'PART="pin"'   --render openscad\decoder_wheel.scad
   ```
   OpenSCAD 2021.01 uses CGAL — the text-heavy Poneglyph render may take
   several minutes per piece. That's normal. (A newer OpenSCAD nightly with
   `--backend=Manifold` is 10–50× faster if it's slow.)
2. Slice & test-print **one** Poneglyph piece + the wheel first; check the
   jigsaw fit (`CLEARANCE`, default 0.25 mm) and that 8 mm glyphs read well
   engraved. Adjust and re-export.
3. Replace the placeholder `CLUE` with the real hiding place, re-export.
4. Print 4 pieces (red PLA if available), wheel ×1–2 (one per team).
5. Print `printables/*.html` (open in a browser → Print). Fill in station
   locations on the station cards.
6. Optional prints from the plan: Devil Fruits (existing models on
   Printables/MakerWorld), Jolly Roger keychains, decoy keys, Kaido horns.

## Open questions for Josh
- **Which stations and which ending** (see `party_plan.md` menu). Then update
  `printables/station_cards.html` to match.
- Real hiding place → clue text.
- Headcount, indoor/outdoor, day vs. dusk (affects Thriller Bark/flashlight
  option and how many wheels to print).
- Bed size of the printer (affects whether the 4-piece plate fits).
- Piñata shape (decides Kaido dressing: horns/face printout).
