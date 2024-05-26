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

  qemu-espressif = let
    keycodemapdb = pkgs.fetchFromGitLab {
      owner = "qemu-project";
      repo = "keycodemapdb";
      rev = "f5772a62ec52591ff6870b7e8ef32482371f22c6";
      hash = "sha256-GbZ5mrUYLXMi0IX4IZzles0Oyc095ij2xAsiLNJwfKQ=";
    };
    berkeley-softfloat-3 = pkgs.fetchFromGitLab {
      owner = "qemu-project";
      repo = "berkeley-softfloat-3";
      rev = "b64af41c3276f97f0e181920400ee056b9c88037";
      hash = "sha256-Yflpx+mjU8mD5biClNpdmon24EHg4aWBZszbOur5VEA=";
    };
    berkeley-testfloat-3 = pkgs.fetchFromGitLab {
      owner = "qemu-project";
      repo = "berkeley-testfloat-3";
      rev = "e7af9751d9f9fd3b47911f51a5cfd08af256a9ab";
      hash = "sha256-inQAeYlmuiRtZm37xK9ypBltCJ+ycyvIeIYZK8a+RYU=";
    };
    dtc = pkgs.fetchFromGitLab {
      owner = "qemu-project";
      repo = "dtc";
      rev = "b6910bec11614980a21e46fbccc35934b671bd81";
      hash = "sha256-gx9LG3U9etWhPxm7Ox7rOu9X5272qGeHqZtOe68zFs4=";
    };
    libblkio = pkgs.fetchFromGitLab {
      owner = "qemu-project";
      repo = "libblkio";
      rev = "f84cc963a444e4cb34813b2dcfc5bf8526947dc0";
    };
    libvfio-user = pkgs.fetchFromGitLab {
      owner = "qemu-project";
      repo = "libvfio-user";
      rev = "0b28d205572c80b568a1003db2c8f37ca333e4d7";
      hash = "sha256-V05nnJbz8Us28N7nXvQYbj66LO4WbVBm6EO+sCjhhG8=";
    };
    libslirp = pkgs.fetchFromGitLab {
      owner = "qemu-project";
      repo = "libslirp";
      rev = "26be815b86e8d49add8c9a8b320239b9594ff03d";
      hash = "sha256-6LX3hupZQeg3tZdY1To5ZtkOXftwgboYul792mhUmds=";
    };
    qemu-src = pkgs.fetchurl {
      url = "https://github.com/espressif/qemu/releases/download/esp-develop-8.2.0-20240122/qemu-esp_develop_8.2.0_20240122-src.tar.xz";
      hash = "sha256-5nuibo0OV63sSIAv3EgZJ5artVMyfSnNfnmEsc0jMGk=";
    };
    berkeley-softfloat-3-patched = pkgs.stdenv.mkDerivation {
      name = "berkeley-softfloat-3-patched";
      src = qemu-src;
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        mkdir -p $out
        cp -r ${berkeley-softfloat-3}/* $out
        cp -r subprojects/packagefiles/berkeley-softfloat-3/* $out
      '';
    };
    berkeley-testfloat-3-patched = pkgs.stdenv.mkDerivation {
      name = "berkeley-testfloat-3-patched";
      src = qemu-src;
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        mkdir -p $out
        cp -r ${berkeley-testfloat-3}/* $out
        cp -r subprojects/packagefiles/berkeley-testfloat-3/* $out
      '';
    };
  in pkgs.qemu.overrideAttrs {
      # ln -sf ${libblkio} $(pwd)/subprojects/libblkio
    preConfigure = ''
      cpp --version
      echo hooooooooooooooooooooo
      ln -sf ${keycodemapdb} $(pwd)/subprojects/keycodemapdb
      ln -sf ${berkeley-softfloat-3-patched} $(pwd)/subprojects/berkeley-softfloat-3
      ln -sf ${berkeley-testfloat-3-patched} $(pwd)/subprojects/berkeley-testfloat-3
      ln -sf ${dtc} $(pwd)/subprojects/dtc
      ln -sf ${libvfio-user} $(pwd)/subprojects/libvfio-user
      ln -sf ${libslirp} $(pwd)/subprojects/libvfio
    '';
    src = qemu-src;
  };
}
