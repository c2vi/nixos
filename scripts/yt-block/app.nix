{ pkgs
, ...
}: let
  python = pkgs.python3.withPackages (ps: with ps; [pkgs.python311Packages.cryptography]);
	python_script = pkgs.writeText "main-py" (builtins.readFile ./main.py);
in pkgs.writeShellApplication {
  name = "yt_block";
  text = ''
    ${python}/bin/python ${python_script} "$@"
  '';
}
