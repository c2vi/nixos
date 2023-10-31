{ pkgs, ... }:
{
	programs.lf = {
		package = pkgs.lf.overrideAttrs (final: prev: {
			patches = (prev.patches or [ ]) ++ [
				./lf-filter.patch
			];
			checkPhase = "";
		});

		enable = true;
		commands = {
			dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
			editor-open = ''$$EDITOR $f'';
			mkdir = ''
				''${{
				printf "Directory Name: "
				read DIR
				mkdir $DIR
				}}
			'';
		};
		settings = {
			preview = true;
			drawbox = true;
			icons = true;
		};
		keybindings = {
			"." = "set hidden!";
			"<enter>" = "open";
			do = "dragon-out";
			"gh" = "cd";
			"g/" = "/";
			ee = "editor-open";
			V = ''$${pkgs.bat}/bin/bat --paging=always --theme=gruvbox "$f"'';
		};
	};
}
