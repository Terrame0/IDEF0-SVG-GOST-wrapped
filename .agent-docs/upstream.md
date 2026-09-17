# Upstream

The wrapper vendors [jimmyjazz/IDEF0-SVG](https://github.com/jimmyjazz/IDEF0-SVG)
at a fixed commit and feeds it to a Nix build. Everything else in this repo is
either a patch against that pin or Nix glue around it. Upstream renders plain
IDEF0; the GOST look comes entirely from the patches.

## Pin

| | |
|---|---|
| Repo | `github:jimmyjazz/IDEF0-SVG` |
| Commit | `f689fe913260e0582905a9cb8ef7434c960112ea` |
| Date | 2018-10-14 |
| License | MIT (James Ross, Simon Harris) |
| `src` hash | `sha256-sbKEfiASZT7s2CXIiENnglv0zPdiptaIEhyrOvVw0yw=` |

Fetched with `fetchFromGitHub` in [`../package.nix`](../package.nix). Upstream is
frozen; it has not seen a commit since 2018, so the pin is effectively the
project's only dependency.

## Runtime

Ruby stdlib only. No gems, no `Gemfile`, no bundler. Sources load through
`require_relative`, so the process working directory does not matter.

## Layout

```
bin/          executable entry points
lib/idef0/    all library code
samples/      .idef0 sources and rendered .svg references
```

## Entry points

| Script | Output |
|---|---|
| `schematic` | top-level IDEF0 diagram |
| `decompose` | child diagram of a process |
| `focus` | single-process view |
| `toc` | table of contents to stdout |

All four read the model from stdin: `schematic < model.idef0 > model.svg`.
