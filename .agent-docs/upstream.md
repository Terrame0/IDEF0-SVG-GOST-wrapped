# Upstream

The renderer is [jimmyjazz/IDEF0-SVG](https://github.com/jimmyjazz/IDEF0-SVG),
vendored in place so the repository itself is the patched source. Everything
under `bin/`, `lib/`, and `samples/` is that project; the GOST look comes from
the changes already applied to it (see [vendor-changes.md](vendor-changes.md)).

## Pin

| | |
|---|---|
| Repo | `github:jimmyjazz/IDEF0-SVG` |
| Commit | `f689fe913260e0582905a9cb8ef7434c960112ea` |
| Date | 2018-10-14 |
| License | MIT (James Ross, Simon Harris) |

The vendored tree is that commit with the four change sets applied. Upstream is
frozen; it has not seen a commit since 2018, so the pin is effectively the
project's only dependency. There is no `fetchFromGitHub` and no patch phase:
[`../flake.nix`](../flake.nix) builds `src = ./.` directly.

## Runtime

Ruby stdlib only. No gems, no `Gemfile`, no bundler. Sources load through
`require_relative`, so the process working directory does not matter.

## Layout

```
bin/          executable entry points
lib/idef0/    all library code
samples/      .idef0 sources and rendered .svg references
```

The flake adds `flake.nix` and this `.agent-docs/` directory on top; those are
not upstream.

## Entry points

| Script | Output |
|---|---|
| `schematic` | top-level IDEF0 diagram |
| `decompose` | child diagram of a process |
| `focus` | single-process view |
| `toc` | table of contents to stdout |

All four read the model from stdin: `schematic < model.idef0 > model.svg`.
