{ pkgs
, ...
}: let
  python = pkgs.python3.withPackages (ps: with ps; [pkgs.python311Pacakges.cryptography]);
	python_script = pkgs.writeText (builtins.readFile ./main.py);
in pkgs.writeShellApplication {
  name = "yt-block";
  text = ''
    ${python}/bin/python ${python_script}
  '';
}
