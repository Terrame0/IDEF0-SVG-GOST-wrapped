# Packaging

The Nix glue has two files: a flake that fans out per-system and a derivation
that patches and installs upstream.

## flake.nix

```nix
outputs = { nixpkgs, flake-utils, ... }:
  flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs { inherit system; };
    idef0 = pkgs.callPackage ./package.nix {};
  in {
    packages.default = idef0;
  });
```

`eachDefaultSystem` already binds `system`, so outputs are declared **without**
it: `packages.default`, never `packages.${system}.default`.

## package.nix

`stdenvNoCC.mkDerivation` — upstream is interpreted Ruby, so there is nothing to
compile; `dontBuild = true`.

- `src` — pinned `fetchFromGitHub` (see [upstream.md](upstream.md)).
- `patches` — the two patch files; `stdenv` applies them in `patchPhase`.
- `nativeBuildInputs` — `makeWrapper` only; `ruby` is a runtime dependency, not a
  build input.
- `installPhase` — copies `lib/idef0` to `$out/lib/idef0` and each `bin/*` to
  `$out/bin/`, then `wrapProgram`s each binary with `--prefix PATH : ${ruby}/bin`.

The `lib/idef0` destination is load-bearing: `bin/*` starts with
`require_relative '../lib/idef0/cli'`, so the directory layout inside `$out` must
mirror upstream. Wrapping rather than shebang-patching keeps
`#!/usr/bin/env ruby` working and pins the interpreter.

`meta.mainProgram = "schematic"` lets `nix run .` work without `#schematic`.

## Verifying a build

```bash
nix build
src=$(nix eval --raw ".#packages.x86_64-linux.default.src.outPath")
result/bin/schematic < "$src/samples/cook-pizza.idef0" > /tmp/out.svg
rg -c "Times New Roman" /tmp/out.svg   # patch 0002 landed
rg "stroke-dasharray" /tmp/out.svg     # must be absent
rg -c ">A0<" /tmp/out.svg              # node tag present
```
