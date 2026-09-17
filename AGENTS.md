# IDEF0-SVG-GOST-wrapped

Nix wrapper around [jimmyjazz/IDEF0-SVG](https://github.com/jimmyjazz/IDEF0-SVG)
that pins upstream at one commit, applies two patches for Cyrillic layout and
GOST styling, and exposes the patched renderer as a flake package. It is
general-purpose: any consumer can render IDEF0 diagrams without vendoring a
patched copy by hand.

## Before working, read the relevant doc in `.agent-docs/`

- [upstream.md](.agent-docs/upstream.md) — the pinned upstream: commit, license,
  runtime, source layout, and the four `bin/*` entry points.
- [patches.md](.agent-docs/patches.md) — what each patch changes and why, plus
  how to regenerate one.
- [packaging.md](.agent-docs/packaging.md) — the flake and derivation structure,
  and how to verify a build.
- [usage.md](.agent-docs/usage.md) — invoking the wrapped renderer and the full
  SVG→PNG pipeline.
- [rasterization.md](.agent-docs/rasterization.md) — DPI math, renderer flags,
  and hermetic font setup.
- [gotchas.md](.agent-docs/gotchas.md) — counter-intuitive traps.
- [open-items.md](.agent-docs/open-items.md) — unsettled design decisions.

When you add, rename, or remove a doc under `.agent-docs/`, update this index in
the same change so it does not drift from what's on disk.
