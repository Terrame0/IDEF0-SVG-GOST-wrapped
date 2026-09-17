# Patches

Three ordered patches in [`../patches/`](../patches) turn the pristine upstream
checkout into the GOST-ready tree. They apply with `patch -p1` or `git apply`
from the repository root and were verified to reproduce the reference tree
byte-for-byte.

The `patchedSrc` derivation in [`../flake.nix`](../flake.nix) lists all three
under `patches = [ ... ]`, so `stdenv` applies them during `patchPhase` before the
library and scripts are installed.

## 0001 — layout fixes

Files: `labels.rb`, `sides.rb`, `process_box.rb`, `diagram.rb`,
`external_guidance_line.rb`, `external_mechanism_line.rb`.

The upstream layout is calibrated for Latin text and packs anchors too tightly
for Russian labels. The patch:

- `Label.length` = `len * 6` → `len * 7.5`. Cyrillic is roughly 25% wider than
  Latin at the same glyph count, so labels otherwise overlapped their boxes and
  each other.
- Adds `to_svg_background`, a white rect the size of the label.
- `HorizontalSide::SPACING` = `180`, anchor spacing `20` → `SPACING`. With the
  upstream 20 px pitch a long Russian control name cannot fit; this is the root
  fix for "Законодательство РФ" overdrawing "Правила хостела".
- `ProcessBox#width` derives from `SPACING` instead of the literal `20`.
- `Diagram#generate_lines` emits in two passes: all line bodies first, then all
  labels. Upstream emits `line → arrow → label` per line, so a later line body
  paints over an earlier label. A white background alone cannot fix that because
  the body is drawn after the label.
- Guidance/mechanism labels get the white background. Horizontal input/output
  labels do not: blanking them would cut their own line.

## 0002 — GOST styling

Files: `line.rb`, `diagram.rb`.

- `line.rb`: `svg_dashed_line` loses `stroke-dasharray='5,5'`; GOST wants solid.
- `diagram.rb`: font `Helvetica` → `"Times New Roman", "Liberation Serif", serif`,
  size `12` → `15`.

## 0003 — node numbering

Files: `process_box.rb`, `diagram.rb`, `process.rb`.

Upstream never drew the mandatory IDEF0 node tag, and the obvious patch — a
literal `A0` in every box — is wrong for anything but a single-process context
diagram. This patch computes the tag from the model tree instead:

- `Process#node_number` → `A0` at the root, otherwise the parent's prefix plus
  the child's 1-based index (`A1`, `A2`, …); grandchildren become `A11`, `A21`, …
- `Process#child_number` / `#number_prefix` implement that recursion.
- `Diagram#box` and `ProcessBox#initialize` accept the number, defaulting to
  `A0` so the single-process case needs no extra wiring.
- `ProcessBox#to_svg` draws the number in the top-left corner.

A single-process model still renders `A0`; a decomposition renders distinct
`A1`, `A2`, … per child. The numbers follow model order, not the layout engine's
left-to-right placement (see [gotchas.md](gotchas.md)).

## Regenerating a patch

Each patch is the diff between one step of the series and the next, so they must
be regenerated in order. To extend or edit safely:

```bash
git clone https://github.com/jimmyjazz/IDEF0-SVG /tmp/idef0
cd /tmp/idef0 && git init -q && git add -A && git commit -qm base
# apply 0001, commit; apply 0002, commit; then make your 0003 edits
git log --oneline                 # base, layout, gost-styling, ...
git diff HEAD~1 HEAD > patches/0003-<name>.patch
```

Regenerating an earlier patch means replaying the later ones on top, because each
diff assumes its predecessors are already applied.
