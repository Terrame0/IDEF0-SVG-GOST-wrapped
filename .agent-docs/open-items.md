# Open items

Work that is not settled yet, in rough priority order.

## Output contract

Decide whether the package should expose only a `resvg`-based renderer or let
the caller pick the rasterizer. Today the package stops at SVG; rasterization is
the caller's job (see [rasterization.md](rasterization.md)).
