{ secretsDir, inputs, ... }:
{
	users.users.me = {
   	isNormalUser = true;
   	passwordFile = "${secretsDir}/main-user-pwd";
   	extraGroups = [ "networkmanager" "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.

	};

	#home-manager._module.args = { inherit inputs; };
	home-manager.users.me = import ./home.nix;
}
