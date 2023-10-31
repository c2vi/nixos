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


		nix-index-database.url = "github:Mic92/nix-index-database";
    	nix-index-database.inputs.nixpkgs.follows = "nixpkgs";


		nixos-generators = {
     		 url = "github:nix-community/nixos-generators";
      	inputs.nixpkgs.follows = "nixpkgs";
    	};

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
					./hardware/my-hp-laptop.nix
      		];
   		};

   		"c2vi-hpm" = nixpkgs.lib.nixosSystem {
      		system = "x86_64-linux";

      		specialArgs = { inherit inputs confDir workDir secretsDir persistentDir self; };
      		modules = [
         		./hosts/main.nix
					./hardware/hpm-laptop.nix
      		];
   		};

			"the-most-default" = nixpkgs.lib.nixosSystem {
      		system = "x86_64-linux";
      		specialArgs = { inherit inputs confDir workDir secretsDir persistentDir self; };
      		modules = [
         		./hosts/the-most-default.nix
      		];
			};
   	};

		packages.x86_64-linux = {
			#default... TODO
		};
	};
}
