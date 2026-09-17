# Gotchas

Traps that are not visible from reading the code or the patches.

### `Label.length` is a heuristic, not text metrics

The `len * 7.5` multiplier is tuned for the current font size, so changing the
font or size silently brings collisions back. Retune the multiplier whenever
`diagram.rb`'s font settings change. Upstream tracks this as a known `# TODO`
(real text metrics).

### A white label background does not fix overdraw by itself

The background only helps if it is emitted *after* every line body, which is why
the fix lives in `Diagram#generate_lines` and not only in `labels.rb`. Adding
`to_svg_background` without the two-pass emission order still lets a later line
paint over an earlier label.

### `rsvg-convert` has no `--dpi`

A long `--dpi` flag is rejected. Use `-d`/`-p` for x/y density or `-w` for width.

### Do not reach for d2, Mermaid, PlantUML, or Graphviz for IDEF0

None of them can express IDEF0 ports on all four sides. Graphviz `dot` gets
orthogonal edges but stacks controls and mechanisms in a column instead of the
required row above and below the box.

### The DSL parser is strict

`Noun PATTERN` rejects a lowercase word after a space and a trailing semicolon;
comments are recognised by the string-comment detector. Keep one statement per
line, e.g. `Функция receives Вход`.

### `eachDefaultSystem` already binds `system`

Inside `flake-utils.lib.eachDefaultSystem`, writing `packages.${system}.default`
double-nests the attribute into `packages.x86_64-linux.x86_64-linux.default` and
breaks `nix build`. Declare outputs bare: `packages.default`.

### A plausible `fetchFromGitHub` hash can be wrong

The pin's `sha256` was initially written from memory and did not match, which
surfaces only at build time as a fixed-output hash mismatch. Confirm with
`nix-prefetch-git --url <url> --rev <rev>` or paste the `got:` hash from the
Nix error.
