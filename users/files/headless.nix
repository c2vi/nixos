{ self, config, inputs, ... }:
{
	users.users.files = {
   	isNormalUser = true;
		password = "changeme";
	};

  home-manager.extraSpecialArgs = {
    inherit self;
    hostname = config.networking.hostName;
  };

  home-manager.users.files = import ../common/home.nix;

  users.users.files.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjgXf9S9hxjyph2EEFh1el0z4OUT9fMoFAaDanjiuKa me@main"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWsqiz0gEepvPONYxqhKKq4Vxfe1h+jo11k88QozUch me@bitwarden"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAioUu4ow6k+OMjjLdzogiQM4ZEM3TNekGNasaSDzQQE me@phone"

    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmwi4ovyqhX/5YwGUZqntVD+i44qL+Nxf9Ubj4XxV9n me@acern"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAIh7LDjwojcjJM8puPqFibx9zPn/k1cYgWXNQf0ZbC4 me@hpm"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC81lBzAYuwvcEITxRrUR8BT2geyj2dB91pNavUsulKj me@loki"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDvGUZE8lZ7OZifndT0nPPJrgKXScD7zMTRIeBfQOfwh me@lush"
  ];


}
