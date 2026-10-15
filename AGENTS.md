# IDEF0-SVG-GOST-wrapped

A Nix fan-out of [jimmyjazz/IDEF0-SVG](https://github.com/jimmyjazz/IDEF0-SVG)
vendored at one commit with four change sets already applied for Cyrillic
layout, GOST styling, IDEF0 node numbering, and DSL parser tolerance. The
renderer source lives at the repository root; the flake builds it directly and
exposes one package per entry point (`schematic`, `decompose`, `focus`, `toc`)
plus a combined default. It is general-purpose: any consumer can render IDEF0
diagrams without vendoring a patched copy by hand.

## Before working, read the relevant doc in `.agent-docs/`

- [upstream.md](.agent-docs/upstream.md) — the vendored upstream: commit,
  license, runtime, source layout, and the four `bin/*` entry points.
- [vendor-changes.md](.agent-docs/vendor-changes.md) — what each applied change
  set does and why, plus how to re-derive it from upstream.
- [packaging.md](.agent-docs/packaging.md) — the flake structure, the `mk-script`
  function, how entry points are mapped to packages, and how to verify a build.
- [usage.md](.agent-docs/usage.md) — invoking the wrapped renderer and the full
  SVG→PNG pipeline.
- [rasterization.md](.agent-docs/rasterization.md) — DPI math, renderer flags,
  and hermetic font setup.
- [gotchas.md](.agent-docs/gotchas.md) — counter-intuitive traps.
- [open-items.md](.agent-docs/open-items.md) — unsettled design decisions.

When you add, rename, or remove a doc under `.agent-docs/`, update this index in
the same change so it does not drift from what's on disk.
