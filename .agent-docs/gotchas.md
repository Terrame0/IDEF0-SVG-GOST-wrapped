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

### The DSL parser normalises noun case

A Latin word written in lowercase is accepted, but `Noun.parse` uppercases its
first letter before storing it, so `requires Навык gost-report` renders as
`Навык Gost-report`. The rewrite used to be unreachable because the strict noun
pattern rejected every input it could have matched; patch 0004 made the pattern
permissive and thereby switched the rewrite on. There is no way to keep an
all-lowercase Latin word in a label.

### A noun may not contain a connective word

Patch 0004 identifies the verb by matching one of the five connectives rather
than by requiring an uppercase noun, so the parser no longer needs nouns to be
uppercase-initial. The cost is that a noun which itself contains `receives`,
`respects`, `requires`, `produces`, or `is composed of` can mis-split: the
greedy noun match takes the last valid connective as the verb. Rename such a
noun, or keep it in Cyrillic, where the connective words do not appear.

### Everything else about the parser is still strict

Statements are `Noun Verb Noun`, one per line; lines starting with `#` are
ignored, semicolons are rejected, and the verb must be one of the five
connectives — anything else aborts with a bare `RuntimeError` naming the line.
Empty lines are dropped before parsing.

### `eachDefaultSystem` already binds `system`

Inside `flake-utils.lib.eachDefaultSystem`, writing `packages.${system}.default`
double-nests the attribute into `packages.x86_64-linux.x86_64-linux.default` and
breaks `nix build`. Declare outputs bare: `packages.default`.

### A plausible `fetchFromGitHub` hash can be wrong

The pin's `sha256` was initially written from memory and did not match, which
surfaces only at build time as a fixed-output hash mismatch. Confirm with
`nix-prefetch-git --url <url> --rev <rev>` or paste the `got:` hash from the
Nix error.

### `nix run .#<name>` needs a matching package, not an `apps` output

There is no `apps` output. `nix run .#decompose` works only because `nix run`
falls back to `packages.decompose`; if you rename or drop that package the
command fails again. `nix develop` opens a shell with **no ruby** — there is no
`devShells` either. For an interpreter, use `nix shell nixpkgs#ruby`.

### A `nix build` leaves an untracked `result` symlink

The repo has no `.gitignore`, so `nix build` dirties `git status` with a
`result` entry. Use `nix build --no-link` for a scratch build, or add `result`
to a `.gitignore`.

### Node numbers follow model order, not layout order

Patch 0003 assigns `A1`, `A2`, … by the process's index among its parent's
children, but the layout engine reorders boxes to minimise line crossings. A
decomposition can therefore render `A2` left of `A1` (upstream's
`cook-pizza.idef0` draws `A2`, `A1`, `A3` left to right). The numbers are correct
and unique; their left-to-right position is not guaranteed. Only the
single-process context diagram — the `gost-report` case — is unaffected, since it
has exactly one box.
