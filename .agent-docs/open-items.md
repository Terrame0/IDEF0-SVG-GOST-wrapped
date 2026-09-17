# Open items

Work that is not settled yet, in rough priority order.

## Output contract

Decide whether the package should expose only a `resvg`-based renderer or let
the caller pick the rasterizer. Today the package stops at SVG; rasterization is
the caller's job (see [rasterization.md](rasterization.md)).

## `apps` and `devShells` outputs

Entry points are exposed as `packages.{schematic,decompose,focus,toc}`, so
`nix run .#<name>` works through the `packages` fallback. Add a real `apps`
output for explicitness and a `devShells.default` with `ruby` so `nix develop`
is usable (see [gotchas.md](gotchas.md)).
