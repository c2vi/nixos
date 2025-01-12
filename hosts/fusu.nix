
{ inputs, pkgs, ... }:
{
	imports = [
		../common/all.nix
		../common/nixos.nix
    ../common/building.nix

		inputs.home-manager.nixosModules.home-manager
    ../users/me/headless.nix
    ../users/root/default.nix
    ../users/files/headless.nix
	];

  # mac address for wakeonlan: 00:19:99:fd:28:23

  # allow acern to ssh into server
  #users.users.server.openssh.authorizedKeys.keys = [
    #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHTV1VoNAjMha5IP+qb8XABDo02pW3iN0yPBIbSqZA27 me@acern"
  #];

  

  # allow server user to shutdown fusu
  #security.sudo.extraRules = [
    #{
      #users = [ "server" ];
      #commands = [ { command = "/run/current-system/sw/bin/shutdown"; options = [ "SETENV" "NOPASSWD" ]; } ];
    #}
  #];


  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.package = pkgs.zfs_unstable;
  boot.zfs.forceImportRoot = false;
  networking.hostId = "7552c83e";

  fileSystems."/home/files/storage" = {
    device = "storage";
    fsType = "zfs";
  };

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuSwtpm = true;
    #qemuOvmfPackage = pkgs.OVMFFull;
  };

	# Use the GRUB 2 boot loader.
	boot.loader.grub = {
  	enable = true;
    #device = "/dev/disk/by-id/ata-TOSHIBA_MQ04ABF100_11MYT5RBT";
    device = "nodev"; # don't install, when i do nixre -h fusu ... but when installing onto the two discs (sata hdd and nvme ssd) change to the device like above
  	efiSupport = false;
		extraConfig = ''
			set timeout=2
		'';
  };

  #fileSystems."/boot" = {
  #  device = "/dev/disk/by-label/fusu-boot";
  #  fsType = "fat32";
  #};

	services.openssh = {
  		enable = true;
  		# require public key authentication for better security
  		settings.PasswordAuthentication = false;
  		settings.KbdInteractiveAuthentication = false;
  		settings.PermitRootLogin = "yes";
      ports = [ 49388 ];

      settings.X11Forwarding = true;

      extraConfig = ''
        X11UseLocalhost no
      '';
	};

	networking.firewall.allowPing = true;
	networking.firewall.enable = true;

	services.samba.openFirewall = true;

	networking.firewall.allowedTCPPorts = [
		8888 # for general usage
		9999 # for general usage
    8080 # for mitm proxy
    5901 # vnc

	];

  networking.networkmanager.enable = false;  # Easiest to use and most distros use this by default.

  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
  ];

  environment.systemPackages = with pkgs; [
    ntfs3g
    virtiofsd
  ];

	nix.settings = {
		trusted-public-keys = [
			"sebastian@c2vi.dev:0tIXGRJMLaI9H1ZPdU4gh+BikUuBVHtk+e1B5HggdZo="
		];
      trusted-users = [ "me" ];
	};


  networking.useDHCP = false;
  networking.bridges = {
    "br0" = {
      interfaces = [ "enp0s25" ];
    };
  };
  networking.interfaces.br0.ipv4.addresses = [ {
    address = "192.168.1.2";
    prefixLength = 24;
  } ];
	networking = {
		usePredictableInterfaceNames = true;
		defaultGateway = {
			address = "192.168.1.1";
			interface = "br0";
		};
		hostName = "fusu";
		nameservers = [ "1.1.1.1" "8.8.8.8" ];
	};

}
