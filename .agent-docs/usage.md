# Usage

The flake exposes the patched renderer as `packages.default` with
`schematic` as `mainProgram`.

```bash
# SVG from a model
nix run . -- < model.idef0 > model.svg

# same, explicit entry point
nix run .#decompose -- < model.idef0 > child.svg

# build the store path, then call binaries directly
nix build
./result/bin/schematic < model.idef0 > model.svg

# development shell with ruby available
nix develop
```

Every `bin/*` entry point reads the model from stdin.

## Full pipeline

```bash
# 1. SVG — pure Ruby, no external deps
result/bin/schematic < model.idef0 > model.svg

# 2. PNG — sandbox-friendly, 300 DPI
nix shell nixpkgs#resvg --command resvg --dpi 300 model.svg model.png
```

See [rasterization.md](rasterization.md) for DPI math, renderer flags, and the
font setup that keeps the render hermetic.
