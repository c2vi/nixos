{ self, config, inputs, ... }:
{
	users.users.server = {
   	isNormalUser = true;
   	#passwordFile = "${secretsDir}/me-pwd";
		password = "changeme";
	};

  home-manager.extraSpecialArgs = {
    inherit self;
    hostname = config.networking.hostName;
  };

  home-manager.users.server = import ../common/home.nix;

  users.users.server.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjgXf9S9hxjyph2EEFh1el0z4OUT9fMoFAaDanjiuKa me@main"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWsqiz0gEepvPONYxqhKKq4Vxfe1h+jo11k88QozUch me@bitwarden"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAioUu4ow6k+OMjjLdzogiQM4ZEM3TNekGNasaSDzQQE me@phone"
  ];


}
