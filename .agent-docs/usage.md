# Usage

The flake exposes one package per entry point plus a combined default:

| Output | Contents |
|---|---|
| `packages.default` | all four binaries |
| `packages.schematic` | the context/render entry point |
| `packages.decompose` | child diagram of a process |
| `packages.focus` | single-process view |
| `packages.toc` | model outline to stdout |

Every entry point reads the model from stdin.

## Render

```bash
# combined default: nix run resolves schematic via meta.mainProgram
nix run . -- < model.idef0 > model.svg

# a specific entry point
nix run .#toc -- < model.idef0
nix run .#decompose -- < model.idef0 > child.svg

# build the combined package, then call any binary
nix build
./result/bin/schematic < model.idef0 > model.svg

# build a single entry point
nix build .#focus
./result/bin/focus "Обработка заявок" < model.idef0 > focus.svg
```

## Full pipeline

```bash
# 1. SVG — pure Ruby, no external deps
./result/bin/schematic < model.idef0 > model.svg

# 2. PNG — sandbox-friendly, 300 DPI
nix shell nixpkgs#resvg --command resvg --dpi 300 model.svg model.png
```

See [rasterization.md](rasterization.md) for DPI math, renderer flags, and the
font setup that keeps the render hermetic.
