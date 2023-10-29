{
	description = "Sebastian (c2vi)'s NixOS";

	inputs = {
		#nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
		firefox.url = "github:nix-community/flake-firefox-nightly";

		home-manager = {
			url = "github:nix-community/home-manager/release-23.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
	};

	outputs = { self, nixpkgs, ... }@inputs: 
		let 
			confDir = "/home/me/work/config";
			workDir = "/home/me/work";
			secretsDir = "/home/me/.mysecrets";
			persistentDir = "/home/me/work/app-data";
		in
	{
   	nixosConfigurations = {

   		"c2vi-main" = nixpkgs.lib.nixosSystem {
      		system = "x86_64-linux";

      		specialArgs = { inherit inputs confDir workDir secretsDir persistentDir self; };
      		modules = [
         		./hosts/main.nix
      		];
   		};
   	};
	};
}
