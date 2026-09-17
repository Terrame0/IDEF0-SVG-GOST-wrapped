{
  description = "IDEF0-SVG-GOST-wrapped";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
    sundry-input.url = "github:Terrame0/sundry";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    sundry-input,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      lib = pkgs.lib;
      sundry = sundry-input.mk-lib {inherit pkgs;};
      version = "unstable-2018-10-14";
      meta = {
        description = "IDEF0 diagram renderer patched for Cyrillic layout and GOST styling";
        homepage = "https://github.com/jimmyjazz/IDEF0-SVG";
        license = lib.licenses.mit;
        platforms = lib.platforms.unix;
      };
      patched-src = pkgs.stdenvNoCC.mkDerivation {
        pname = "patched-src";
        inherit version;
        src = pkgs.fetchFromGitHub {
          owner = "jimmyjazz";
          repo = "IDEF0-SVG";
          rev = "f689fe913260e0582905a9cb8ef7434c960112ea";
          hash = "sha256-sbKEfiASZT7s2CXIiENnglv0zPdiptaIEhyrOvVw0yw=";
        };
        patches = [
          ./patches/0001-layout-fixes.patch
          ./patches/0002-gost-styling.patch
          ./patches/0003-node-numbering.patch
          ./patches/0004-parser-tolerance.patch
        ];
        dontBuild = true;
        installPhase = "cp -r . $out";
      };

      runtime = pkgs.stdenvNoCC.mkDerivation {
        pname = "runtime";
        inherit version;
        src = patched-src;
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib
          cp -r lib/idef0 $out/lib/
          runHook postInstall
        '';
        meta = meta // {description = "${meta.description} (shared library)";};
      };

      mk-script = name:
        pkgs.stdenvNoCC.mkDerivation {
          pname = "idef0-svg-${name}";
          inherit version;
          src = patched-src;
          nativeBuildInputs = [pkgs.makeWrapper];
          dontBuild = true;
          installPhase = ''
            runHook preInstall
            install -Dm755 "bin/${name}" "$out/bin/${name}"
            ln -s ${runtime}/lib "$out/lib"
            wrapProgram "$out/bin/${name}" --prefix PATH : ${lib.makeBinPath [pkgs.ruby]}
            runHook postInstall
          '';
          meta = meta // {mainProgram = name;};
        };

      entry-points = ["schematic" "decompose" "focus" "toc"];
      scripts = sundry.list.zip-to-attrs entry-points (map mk-script entry-points);
      default = pkgs.buildEnv {
        name = "idef0-svg-gost-${version}";
        paths = builtins.attrValues scripts;
        ignoreCollisions = true;
        meta = meta // {mainProgram = "schematic";};
      };
    in {
      packages = scripts // {inherit default;};
    });
}
