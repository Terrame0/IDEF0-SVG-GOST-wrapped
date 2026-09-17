# Patches

Four ordered patches in [`../patches/`](../patches) turn the pristine upstream
checkout into the GOST-ready tree. They apply with `patch -p1` or `git apply`
from the repository root and were verified to reproduce the reference tree
byte-for-byte.

The `patchedSrc` derivation in [`../flake.nix`](../flake.nix) lists all four
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

## 0004 — parser tolerance

Files: `noun.rb`, `statement.rb`.

Upstream's `Noun::PATTERN` excludes `[a-z]` as a word-initial character, so a
noun containing a Latin word written in lowercase (`Навык gost-report`,
`Инструмент docx`) fails `Statement::FORMAT` and aborts the whole render. The
exclusion is load-bearing upstream: it is what stops a noun from swallowing the
verb, so simply dropping it mis-splits `Сборка is composed of Подготовка` into
subject `Сборка is composed`, verb `of`. The patch therefore does both halves:

- `noun.rb`: `PATTERN` first-character classes `[^a-z; ]` → `[^; ]`, so any
  non-semicolon word may open a noun. This also makes reachable the
  `gsub(/(^|\s)[a-z]/)` normaliser that uppercases the first letter of a
  lowercase Latin word — previously dead, since the strict pattern rejected
  every input it could have matched.
- `statement.rb`: `FORMAT` matches the verb against a closed alternation of the
  five connectives (`is composed of`, `receives`, `respects`, `requires`,
  `produces`) instead of `Verb::PATTERN`. That restores the disambiguation the
  strict noun pattern used to provide, and it mirrors
  `Process.parse`, which already `raise`s on any other predicate.

The result accepts the same inputs as before — every previously valid line had
its verb in that closed set and no lowercase-initial word inside a noun — plus
nouns with lowercase Latin words. The one new ambiguity: a noun that itself
contains a connective word can still mis-split, since the regex cannot know
which occurrence is the verb.

## Regenerating a patch

Each patch is the diff between one step of the series and the next, so they must
be regenerated in order. To extend or edit safely:

```bash
git clone https://github.com/jimmyjazz/IDEF0-SVG /tmp/idef0
cd /tmp/idef0 && git checkout f689fe913260e0582905a9cb8ef7434c960112ea
# apply 0001…0003 and commit, then make your edits and diff the working tree
git apply /path/to/patches/0001-layout-fixes.patch   # …0002, 0003, commit
# edit the tree for the patch you are writing, then:
git diff > patches/0004-<name>.patch
```

Regenerating an earlier patch means replaying the later ones on top, because each
diff assumes its predecessors are already applied.
