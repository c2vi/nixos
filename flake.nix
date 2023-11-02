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


      robotnix = {
         url = "github:nix-community/robotnix";
         #inputs.nixpkgs.follows = "nixpkgs";
      };

	};

	outputs = { self, nixpkgs, ... }@inputs: 
		let 
			confDir = "/home/me/work/config";
			workDir = "/home/me/work";
			secretsDir = "/home/me/.mysecrets";
			persistentDir = "/home/me/work/app-data";
      	specialArgs = {
				inherit inputs confDir workDir secretsDir persistentDir self;
				pkgs = import nixpkgs { system = "x86_64-linux"; config = {
					allowUnfree = true;
					permittedInsecurePackages = [
	 					"electron-24.8.6"
  					];
				}; };
			};
		in
	{
   	nixosConfigurations = rec {

   		"main" = nixpkgs.lib.nixosSystem {
				inherit specialArgs;
      		system = "x86_64-linux";

      		modules = [
         		./hosts/main.nix
					./hardware/my-hp-laptop.nix
      		];
   		};

   		"hpm" = nixpkgs.lib.nixosSystem {
				inherit specialArgs;
      		system = "x86_64-linux";

      		modules = [
         		./hosts/hpm.nix
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

      robotnixConfigurations = rec {
         "phone" = inputs.robotnix.lib.robotnixSystem (import ./hosts/phone/default.nix);
      };

		packages.x86_64-linux = {
			cbm = nixpkgs.x86_64.callPackage ./mods/cbm.nix { };
			#default... TODO
			run-vm = specialArgs.pkgs.writeScriptBin "run-vm" ''
				${self.nixosConfigurations.hpm.config.system.build.vm}/bin/run-hpm-vm -m 4G -cpu host -smp 4
        '';
		};

		apps.x86_64-linux = {
			 default = {
          	type = "app";
          	program = "${self.packages.x86_64-linux.run-vm}/bin/run-vm";
        };
		};
	};
}
