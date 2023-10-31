{ inputs, ... }:
{
	imports = [
		../common/all.nix
		../common/nixos.nix
		../common/nixos-graphical.nix

		../users/me/default.nix
	];

	networking.hostName = "hpm";
}

