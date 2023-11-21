{ lib, pkgs, ... }:
{
  imports = [
		../common/all.nix
		../common/nixos-headless.nix

		../users/me/default.nix
		../users/root/default.nix
  ];

  # This causes an overlay which causes a lot of rebuilding
  environment.noXlibs = lib.mkForce false;
  # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
  # disk with this label on first boot. Therefore, we need to keep it. It is the
  # only information from the installer image that we need to keep persistent

  fileSystems."/" =
    { device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
      raspberryPi.firmwareConfig = ''
        program_usb_boot_mode=1
      '';
    };
  };

  virtualisation.podman.enable = true;

	networking.firewall.allowPing = true;
	networking.firewall.enable = true;
	services.samba.openFirewall = true;

  networking.hostName = "rpi";

  networking = {
		defaultGateway = {
			address = "192.168.1.1";
			interface = "eth0";
		};

    interface."eth0" = {
				#name = "eth0";
				ipv4.addresses = [
					{ address = "192.168.1.6"; prefixLength = 24;}
				];
    };

    interfaces."wlan0".useDHCP = true;

    wireless = {
      interfaces = [ "wlan0" ];
      enable = true;
      networks = {
        seb-phone.psk = "hellogello";
      };
    };
  };

	networking.firewall.allowedTCPPorts = [
  	5357 # wsdd
		8888 # for general usage
		9999 # for general usage
    8080 # for mitm proxy
	];

	networking.firewall.allowedUDPPorts = [
  		3702 # wsdd
	];


  ################################## ssh ######################################
  services.openssh.enable = true;
	users.users.me.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjgXf9S9hxjyph2EEFh1el0z4OUT9fMoFAaDanjiuKa me@main"
	];



	################################ samba ######################################
	services.samba-wsdd.enable = true; # make shares visible for windows 10 clients

	services.samba = {
  		enable = true;
  		securityType = "user";
  		extraConfig = ''
			security = user
			map to guest = bad user
			guest account = me

			server role = standalone server
			workgroup = WORKGROUP
  		'';
  		shares = {
    		rpi_schule = {
    			path = "${workDir}/rpi-schule/";
	 			"guest ok" = "yes";
    			"read only" = "no";
    			public = "yes";
    			writable = "yes";
    			printable = "no";
    			comment = "share for rpi in school wlan";
    		};

    		share = {
    			comment = "share for sharing stuff";
    			path = "${workDir}/share";
    			public = "yes";
	 			"guest ok" = "yes";
    			"read only" = "no";
    			writable = "yes";
    		};
  		};
	};


}
