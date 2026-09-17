# Packaging

All Nix logic lives in [`../flake.nix`](../flake.nix); there is no separate
`package.nix` and no per-script files. The flake builds the patched source once,
then maps a list of entry-point names through a `mk-script` function to produce
one derivation each.

## Flake inputs

| Input | Used for |
|---|---|
| `nixpkgs` | every derivation |
| `flake-utils` | `eachDefaultSystem` |
| `sundry-input` | `sundry.list.zip-to-attrs` when mapping entry points to packages |

`sundry` is `Terrame0/sundry`; the flake binds it with
`sundry = sundry-input.mk-lib { inherit pkgs; }`. It is only needed for the
name/value pairing in the entry-point mapping, not for building any derivation.

## Layers in flake.nix

| Name | Kind | Purpose |
|---|---|---|
| `patched-src` | derivation | upstream + all patches, installed verbatim (`cp -r . $out`) |
| `runtime` | derivation | `$out/lib/idef0` — the shared Ruby library |
| `mk-script` | function | builds one binary from a script name |
| `entry-points` | list | `schematic`, `decompose`, `focus`, `toc` |
| `scripts` | attrset | names zipped with `mk-script` results via `sundry` |
| `default` | `buildEnv` | bundles all four for `nix build` / `nix run` |

`patched-src` is the single place the patches are applied, so the library and
every script come from the same patched revision.

## mk-script

```nix
mk-script = name:
  pkgs.stdenvNoCC.mkDerivation {
    pname = "idef0-svg-${name}";
    inherit version;
    src = patched-src;
    nativeBuildInputs = [ pkgs.makeWrapper ];
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 "bin/${name}" "$out/bin/${name}"
      ln -s ${runtime}/lib "$out/lib"
      wrapProgram "$out/bin/${name}" --prefix PATH : ${lib.makeBinPath [ pkgs.ruby ]}
      runHook postInstall
    '';
    meta = meta // { mainProgram = name; };
  };
```

Two details are load-bearing:

- **`$out/lib` must sit next to `$out/bin`.** Every `bin/*` starts with
  `require_relative '../lib/idef0/cli'`, and `require_relative` resolves against
  the real file (`bin/.<name>-wrapped`), so the library has to be at `$out/lib`
  in the *same* derivation. It is a symlink to the shared `runtime`, not a copy.
- **`wrapProgram`, not a shebang edit.** It keeps `#!/usr/bin/env ruby` working
  and prepends exactly `ruby` to `PATH`.

`meta.mainProgram = name` makes `nix run .#<name>` resolve to the right binary.

## Mapping the entry points

```nix
entry-points = [ "schematic" "decompose" "focus" "toc" ];
scripts = sundry.list.zip-to-attrs entry-points (map mk-script entry-points);
```

`sundry.list.zip-to-attrs` pairs each name with its derivation, so `mk-script`
runs once per entry point. It uses a no-collision merge, so a duplicate name in
`entry-points` is a hard evaluation error rather than a silent overwrite. Adding
an entry point is one string in `entry-points` and nothing else.

## default

`buildEnv` over the values of `scripts`:

```nix
default = pkgs.buildEnv {
  name = "idef0-svg-gost-${version}";
  paths = builtins.attrValues scripts;
  ignoreCollisions = true;
  meta = meta // { mainProgram = "schematic"; };
};
```

The only collision is the identical `$out/lib` symlink, hence
`ignoreCollisions = true`. `meta.mainProgram = "schematic"` keeps `nix run .`
working.

## flake outputs

`eachDefaultSystem` binds `system`, so outputs are declared **without** it:
`packages.default`, never `packages.${system}.default`. The result is
`packages.default` plus `packages.{schematic,decompose,focus,toc}`;
`nix run .#<name>` works for the four because `nix run` falls back to
`packages.<name>` when there is no `apps` entry.

## Verifying a build

```bash
nix build
# `default` is a buildEnv with no `src`; take the patched tree from a script pkg
src=$(nix eval --raw ".#packages.x86_64-linux.schematic.src.outPath")
result/bin/schematic < "$src/samples/cook-pizza.idef0" > /tmp/out.svg
rg -c "Times New Roman" /tmp/out.svg   # patch 0002 landed
rg "stroke-dasharray" /tmp/out.svg     # must be absent
rg -c ">A[0-9]+<" /tmp/out.svg         # node tags present (patch 0003)

# per-entry-point packages
nix build .#decompose
./result/bin/decompose "Some Process" < model.idef0 > child.svg
```
