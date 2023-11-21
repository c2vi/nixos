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

  users.users.me.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjgXf9S9hxjyph2EEFh1el0z4OUT9fMoFAaDanjiuKa me@main"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWsqiz0gEepvPONYxqhKKq4Vxfe1h+jo11k88QozUch me@bitwarden"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAioUu4ow6k+OMjjLdzogiQM4ZEM3TNekGNasaSDzQQE me@phone"
  ];

}
