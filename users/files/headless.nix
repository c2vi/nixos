{ self, config, inputs, ... }:
{
	users.users.files = {
   	isNormalUser = true;
		password = "changeme";
    group = "files";
	};
  users.groups.files = {};

  home-manager.extraSpecialArgs = {
    inherit self;
    hostname = config.networking.hostName;
  };

  home-manager.users.files = import ../common/home.nix;

  users.users.files.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAgNB1nsKZ5KXnmR6KWjQLfwhFKDispw24o8M7g/nbR me@bitwarden"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/mCDzCBE2J1jGnEhhtttIRMKkXMi1pKCAEkxu+FAim me@main"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGw5kYmBQl8oolNg2VUlptvvSrFSESfeuWpsXRovny0x me@phone"

    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmwi4ovyqhX/5YwGUZqntVD+i44qL+Nxf9Ubj4XxV9n me@acern"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAIh7LDjwojcjJM8puPqFibx9zPn/k1cYgWXNQf0ZbC4 me@hpm"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC81lBzAYuwvcEITxRrUR8BT2geyj2dB91pNavUsulKj me@loki"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDvGUZE8lZ7OZifndT0nPPJrgKXScD7zMTRIeBfQOfwh me@lush"
  ];


}
