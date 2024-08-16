{stdenv
, ...
}: let
in stdenv.mkDerivation {
  name = "read-helper";

  src = ./.;

  # Use $CC as it allows for stdenv to reference the correct C compiler
  buildPhase = ''
    gcc -fno-stack-protector -D_FORTIFY_SOURCE=0 read-helper.c -o read-helper
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp read-helper $out/bin
  '';
}
