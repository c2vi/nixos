{ pkgs, secretsDir, inputs, config, self, lib, ... }:
{
	users.users.me = {
   	isNormalUser = true;
   	#passwordFile = "${secretsDir}/me-pwd";
		password = "changeme";
   	extraGroups = [ "networkmanager" "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
	};

  home-manager.extraSpecialArgs = {
    inherit self;
    hostname = config.networking.hostName;
  };

	home-manager.users.me = import ./home.nix;

	fonts.fonts = with pkgs; [
   	hack-font
	];
}
