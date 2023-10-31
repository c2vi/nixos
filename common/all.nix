{ inputs, self, secretsDir, specialArgs, ... }:

# config that i use on all my hosts

{
	imports = [
		inputs.home-manager.nixosModules.home-manager
		../mods/my-nixpkgs-overlay.nix
	];


	home-manager.extraSpecialArgs = specialArgs;


	# set root user pwd
	users.users.root.passwordFile = "${secretsDir}/root-pwd";

	# Set your time zone.
	time.timeZone = "Europe/Vienna";


	# add mybin to path
	environment.etc.profile.text = ''
export PATH=$PATH:${self}/mybin
	'';

	
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	home-manager.backupFileExtension = "backup";

  	security.sudo.wheelNeedsPassword = false;

	users.mutableUsers = false;

  	networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.


	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It's perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "23.05"; # Did you read the comment?
}
