{ pkgs, secretsDir, inputs, config, ... }:
{
	users.users.me = {
   	isNormalUser = true;
   	#passwordFile = "${secretsDir}/me-pwd";
		password = "changeme";
   	extraGroups = [ "networkmanager" "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
	};

	#home-manager._module.args = { inherit inputs; };
	home-manager.users.me = import ./home.nix;
  home-manager.extraSpecialArgs = {
    hostname = config.networking.hostName;
  };

	fonts.fonts = with pkgs; [
   	hack-font
	];
}
