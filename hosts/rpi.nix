{ lib, pkgs, inputs, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    inputs.nixos-hardware.nixosModules.raspberry-pi-4

		../common/all.nix
		../common/nixos-headless.nix

		../users/me/headless.nix
		../users/root/default.nix
  ];

  system.stateVersion = "23.05";

  # to cross compile
  #nixpkgs.hostPlatform.system = "aarch64-linux";
  #nixpkgs.buildPlatform.system = "x86_64-linux";

  hardware.enableRedistributableFirmware = true;

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
    #kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
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
      server role = standalone server
      map to guest = bad user
      usershare allow guests = yes
      hosts allow = 192.168.0.0/16
      hosts deny = 0.0.0.0
      workgroup = WORKGROUP
      security = user
    '';
    shares = {
      files = {
        "valid users" = "files";
        "comment" = "all my files";
        "path" = "/home/files/storage/files";
        "read only" = "no";
        "guest ok" = "no";
        "force user" = "files";
        "force group" = "files";
        "force create mode" = "0777";
        # Papierkorb
        "vfs object" = "recycle";
        "recycle:repository" = "/home/files/storage/files/trash-files";
        "recycle:keeptree" = "No";
        "recycle:versions" = "Yes";
        "recycle:touch" = "Yes";
        "recycle:touch_mtime" = "Yes";
        "recycle:maxsize" = "8000";
      };
      lan = {
        "comment" = "gastordner";
        "path" = "/home/files/storage/lan";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "files";
        "force group" = "files";
        "force create mode" = "0777";
        # Papierkorb
        "vfs object" = "recycle";
        "recycle:repository" = "/home/files/storage/files/trash-lan";
        "recycle:keeptree" = "No";
        "recycle:versions" = "Yes";
        "recycle:touch" = "Yes";
        "recycle:touch_mtime" = "Yes";
        "recycle:maxsize" = "8000";
      };
      mama = {
        "comment" = "Meine Dateien auf Mamas Laptop";
        "path" = "/home/files/storage/files/stuff/Mamas-Laptop";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "mamafiles";
        "force user" = "files";
        "force group" = "files";
        "force create mode" = "0777";
      };
    };
  };
}
