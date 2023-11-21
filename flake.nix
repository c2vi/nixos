{
	description = "Sebastian (c2vi)'s NixOS";

	inputs = {
		#nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";

    rpi-nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";


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


    nixos-hardware.url = "github:nixos/nixos-hardware";


    robotnix = {
      url = "github:nix-community/robotnix";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      #url = "github:nix-community/nix-on-droid/release-23.05";
      url = "github:zhaofengli/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # for bootstrap zip ball creation and proot-termux builds, we use a fixed version of nixpkgs to ease maintanence.
    # head of nixos-23.05 as of 2023-06-18
    # note: when updating nixpkgs-for-bootstrap, update store paths of proot-termux in modules/environment/login/default.nix
    nixpkgs-for-bootstrap.url = "github:NixOS/nixpkgs/c7ff1b9b95620ce8728c0d7bd501c458e6da9e04";

    nix-wsl.url = "github:nix-community/NixOS-WSL";

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

      # my server at home
   		"rpi" = nixpkgs.lib.nixosSystem {
			  inherit specialArgs;
      	system = "x86_64-linux";
        modules = [
          ./hosts/rpi.nix
        ];
      };

      # my raspberry to try out stuff with
   		"lush" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          inputs.nixos-hardware.nixosModules.raspberry-pi-4
          ./hosts/lush.nix
          {
	          system.stateVersion = "23.05"; # Did you read the comment?

            nixpkgs.hostPlatform.system = "aarch64-linux";
            nixpkgs.buildPlatform.system = "x86_64-linux";

            hardware.enableRedistributableFirmware = true;
          }
        ];
      };

      # my headless nixos vm
   		"loki" = nixpkgs.lib.nixosSystem {
			  inherit specialArgs;
      	system = "x86_64-linux";
      };

      # a nixos chroot environment
   		"chroot" = nixpkgs.lib.nixosSystem {
			  inherit specialArgs;
      	system = "x86_64-linux";

      	modules = [
          ./hosts/the-most-default.nix
          ({ ... }: {
            
          })
        ];
      };

   		"acern" = nixpkgs.lib.nixosSystem {
			  inherit specialArgs;
      	system = "x86_64-linux";
        modules = [
          ./hosts/acern.nix
        ];
      };

			"the-most-default" = nixpkgs.lib.nixosSystem {
      		system = "x86_64-linux";
      		specialArgs = { inherit inputs confDir workDir secretsDir persistentDir self; };
      		modules = [
         		./hosts/the-most-default.nix
      		];
			};
			"test" = nixpkgs.lib.nixosSystem {
      		#specialArgs = { inherit inputs confDir workDir secretsDir persistentDir self; };
      		system = "aarch64-linux";
      		modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            {
              nixpkgs.hostPlatform.system = "aarch64-linux";
              nixpkgs.buildPlatform.system = "x86_64-linux";
            }
      		];
      };
   	};

    robotnixConfigurations = rec {
      "phone" = inputs.robotnix.lib.robotnixSystem (import ./hosts/phone/default.nix);
    };

    nixOnDroidConfigurations = rec {
      "phone" = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      };
    };

    nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [ ./hosts/nix-on-phone.nix ];

      # list of extra special args for Nix-on-Droid modules
      extraSpecialArgs = {
        # rootPath = ./.;
      };

      # set nixpkgs instance, it is recommended to apply `nix-on-droid.overlays.default`
      pkgs = import nixpkgs {
        system = "aarch64-linux";

        overlays = [
          inputs.nix-on-droid.overlays.default
          # add other overlays
        ];
      };

      # set path to home-manager flake
      home-manager-path = inputs.home-manager.outPath;
    };

		packages.x86_64-linux = {
			cbm = nixpkgs.legacyPackages.x86_64-linux.callPackage ./mods/cbm.nix { };
			supabase = nixpkgs.legacyPackages.x86_64-linux.callPackage ./mods/supabase.nix { };
			#default... TODO
			run-vm = specialArgs.pkgs.writeScriptBin "run-vm" ''
				${self.nixosConfigurations.hpm.config.system.build.vm}/bin/run-hpm-vm -m 4G -cpu host -smp 4
        '';
      acern = inputs.nix-wsl.nixosConfigurations.modern.config.system.build.tarballBuilder;
      #luna = (self.nixosConfigurations.luna.extendModules {
        #modules = [ "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix" ];
      #}).config.system.build.sdImage;
      lush = self.nixosConfigurations.lush.config.system.build.sdImage;
      test = nixpkgs.legacyPackages.x86_64-linux.pkgsCross.raspberryPi.raspberrypi-armstubs;
		};

		apps.x86_64-linux = {
      wsl = {
        type = "app";
        program = "${self.nixosConfigurations.wsl.config.system.build.tarballBuilder}/bin/nixos-wsl-tarball-builder";
      };
		  default = {
        type = "app";
        program = "${self.packages.x86_64-linux.run-vm}/bin/run-vm";
      };
		};
	};
}
