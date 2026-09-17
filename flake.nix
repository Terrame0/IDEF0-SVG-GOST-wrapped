{
  description = "IDEF0-SVG-GOST-wrapped";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      idef0 = pkgs.callPackage ./package.nix {};
    in {
      packages.default = idef0;
    });
}
