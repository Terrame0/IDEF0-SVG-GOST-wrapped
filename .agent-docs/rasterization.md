# Rasterization

`schematic` and friends emit SVG. Turning that into a report figure is a
separate step.

## Sizing

The SVG is sized in **points** (`width='881pt'` with a matching `viewBox`), so
1 user unit = 1 pt and the pixel size is `round(pt * dpi / 72)`.

Verified output for the reference model (881 × 240 pt):

| DPI | Pixels |
|---|---|
| 96 | 1175 × 320 |
| 150 | 1835 × 500 |
| 300 | 3671 × 1000 |
| 600 | 7342 × 2000 |

For a report figure at 15–17 cm wide, 300 DPI is the practical floor; 600 DPI is
crisper at roughly 4× the file size.

## Renderers

All three below were verified to produce identical pixel dimensions.

| Renderer | DPI flag | Width flag | Notes |
|---|---|---|---|
| `resvg` | `--dpi N` | `--width N` | Rust, fast; recommended for sandboxed builds — `--skip-system-fonts --use-fonts-dir <dir>` makes fonts hermetic |
| `rsvg-convert` | `-d N -p N` | `-w N` | librsvg; relies on fontconfig |
| `inkscape` | `--export-dpi=N` | `--export-width=N` | heaviest; prints Gtk warnings |

## Fonts

`Times New Roman` does not exist on Linux. The SVG's fallback chain resolves to
**Liberation Serif** (metric-compatible), which covers Cyrillic. A pure Nix
sandbox has no system fontconfig, so pass a font directory explicitly:

```bash
resvg --skip-system-fonts \
      --use-fonts-dir "$(nix build --no-link --print-out-paths nixpkgs#liberation_ttf)/share/fonts" \
      --dpi 300 diagram.svg diagram.png
```

Verified to render Cyrillic correctly with an empty environment.
