{ inputs, ... }:
{
	imports = [
		../common/all.nix
		../common/nixos.nix
		../common/nixos-graphical.nix

		../users/me/default.nix
	];

	services.openssh = {
  		enable = true;
  		# require public key authentication for better security
  		settings.PasswordAuthentication = false;
  		settings.KbdInteractiveAuthentication = false;
  		settings.PermitRootLogin = "yes";
	};

	users.users.me.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjgXf9S9hxjyph2EEFh1el0z4OUT9fMoFAaDanjiuKa me@main"
	];

	networking = {
		defaultGateway = {
			address = "192.168.1.1";
			interface = "enp0s13f0u1c2";
		};
		hostName = "hpm";
		nameservers = [ "1.1.1.1" "8.8.8.8" ];
		interfaces = {
			"enp0s13f0u1c2" = {
				name = "eth0";
				ipv4.addresses = [
					{ address = "192.168.1.6"; prefixLength = 24;}
				];
			};
		};
	};
}

