# This is the file for my NUR Repo
# Reminder for myself: Any package here should not import <nixpkgs>, but use the pkgs

{ pkgs ? import <nixpkgs> { } }: {

  cbm = pkgs.callPackage ./mods/cbm.nix {};

  mac-telnet = pkgs.callPackage ./mods/mac-telnet.nix {};

  iio-hyprland = let
    repo = pkgs.fetchFromGitHub {
      owner = "yassineibr";
      repo = "iio-hyprland";
      rev = "nix-support";
      hash = "sha256-xFc8J8tlw6i+FbTC05nrlvQIXRmguFzDqh+SQOR54TE=";
    }; in pkgs.callPackage "${repo}/default.nix" {};
}
