{ pkgs ? import <nixpkgs> { } }: {
  cbm = pkgs.callPackage ./mods/cbm.nix {};
}
