{ pkgs, ... }:
let 
	yt_block = pkgs.callPackage ./app.nix {};
	yt_block_starter = pkgs.callPackage ./app.nix {};
in {
	systemd.services.yt-block = {
		 enable = true;
		 description = "Block Youtube";
		 serviceConfig = {
			Restart = "always";
			#RestartSec = "60s";
			ExecStart = "${yt_block_starter}/bin/yt_block_starter";
		 };
		 wantedBy = [ "multi-user.target" ];
	};
  	environment.systemPackages = [ yt_block ];
}
