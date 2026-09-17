# Patches

Two ordered patches in [`../patches/`](../patches) turn the pristine upstream
checkout into the GOST-ready tree. They apply with `patch -p1` or `git apply`
from the repository root and were verified to reproduce the reference tree
byte-for-byte.

`package.nix` lists both under `patches = [ ... ]`, so `stdenv` applies them
during `patchPhase` before install.

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

Files: `line.rb`, `diagram.rb`, `process_box.rb`.

- `line.rb`: `svg_dashed_line` loses `stroke-dasharray='5,5'`; GOST wants solid.
- `diagram.rb`: font `Helvetica` → `"Times New Roman", "Liberation Serif", serif`,
  size `12` → `15`.
- `process_box.rb`: adds the `A0` node tag in the top-left corner, a mandatory
  IDEF0 attribute upstream never drew.

## Regenerating a patch

Patches are the diff between a pristine checkout and the patched tree, split into
the two logical steps. To extend:

```bash
git clone https://github.com/jimmyjazz/IDEF0-SVG /tmp/idef0
cd /tmp/idef0 && git init -q && git add -A && git commit -qm base
# edit lib/idef0/*.rb
git diff > patches/000N-<name>.patch
```
