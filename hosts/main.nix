
{ pkgs, lib, workDir, confDir, inputs, ... }:
{

  # https://bugzilla.kernel.org/show_bug.cgi?id=110941
  # ??????????? TODO
  # boot.kernelParams = [ "intel_pstate=no_hwp" ];

  # Supposedly better for the SSD.
  # ??????????? TODO
  # fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];


############################# BOOT #############################
# boot

	imports = [
		../mods/battery_monitor.nix
		../mods/my-nixpkgs-overlay.nix
		../hardware/my-hp-laptop.nix
		inputs.home-manager.nixosModules.home-manager
		../users/me/home.nix
	];

	#home-manager.users.me = import ../users/me/home.nix;
	
  	# Setup keyfile
  	boot.initrd.secrets = {
    	"/crypto_keyfile.bin" = null;
  	};

  	fileSystems."/home/me/work" = { 
		#label = "work";
		device = "/dev/disk/by-uuid/fd3c6393-b6fd-4065-baf9-5690eb6ebbed";
		fsType = "btrfs";
		neededForBoot = false;
	};


	# Use the GRUB 2 boot loader.
	boot.loader.grub = {
  		enable = true;
  		version = 2;
  		device = "nodev";
  		efiSupport = true;
		extraConfig = ''
			set timeout=1
		'';
	};
	boot.loader.efi.canTouchEfiVariables = true;

	boot.initrd.luks.devices = {
   	root = {
   		#name = "root";
      	device = "/dev/disk/by-uuid/142d2d21-2998-4eb7-9853-ab6554ba061f";
      	preLVM = true;
      	allowDiscards = true;
   	};
	};


############################# MISC #############################
# misc


  nixpkgs.config.permittedInsecurePackages = [
	 "electron-24.8.6"
  ];

	fileSystems."/tmp" = {
   	fsType = "tmpfs";
   	device = "tmpfs";
   	options = [ "nosuid" "nodev" "relatime" "size=14G" ];
	};


	security.polkit.enable = true;
	networking.firewall.enable = true;
	networking.firewall.allowPing = true;
	services.samba.openFirewall = true;

	# samba
	services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
	networking.firewall.allowedTCPPorts = [
  		5357 # wsdd
		8888 # for general usage
		9999 # for general usage
	];
	networking.firewall.allowedUDPPorts = [
  		3702 # wsdd
	];
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


	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	nixpkgs.config.allowUnfree = true;
  	security.sudo.wheelNeedsPassword = false;

  	virtualisation.libvirtd.enable = true;

  	programs.dconf.enable = true;
  	system.activationScripts.setupLibvirt = lib.stringAfter [ "var" ] ''
		ln -nsf ${workDir}/vm/libvirt/my-image-pool.xml /var/lib/libvirt/storage/my-image-pool.xml
		ln -nsf ${workDir}/vm/qemu/* /var/lib/libvirt/qemu/

		# there is no /bin/bash
		# https://discourse.nixos.org/t/add-bin-bash-to-avoid-unnecessary-pain/5673
		ln -nsf /run/current-system/sw/bin/bash /bin/bash
   '';

	environment.etc.profile.text = ''
export PATH=$PATH:${confDir}/mybin
	'';

	modules.battery_monitor.enable = true;

	xdg.portal = {
		enable = true;
		extraPortals = [
			#pkgs.xdg-desktop-portal-gtk
			#pkgs.xdg-desktop-portal-termfilechooser
			(pkgs.callPackage ../mods/xdg-desktop-portal-termfilechooser/default.nix {})
		];
	};

	networking.hostName = "c2vi-main"; # Define your hostname.
  	networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  	services.blueman.enable = true;
	hardware.bluetooth.enable = true;


	################
	# swap and hibernate

	swapDevices = [ { device = "/dev/lvm0/swap"; } ];
	boot.resumeDevice = "/dev/lvm0/swap";
	services.logind = {
		extraConfig = ''
			HandlePowerKey=suspend-then-hibernate
		'';
		lidSwitch = "suspend-then-hibernate";
		lidSwitchExternalPower = "suspend-then-hibernate";
		lidSwitchDocked = "ignore";
	};
	systemd.sleep.extraConfig = ''
		HibernateDelaySec=2h
		HibernateMode=shutdown
	'';

	# Enable the X11 windowing system.
	services.xserver = {
		enable = true;
   	displayManager = {
		defaultSession = "none+xmonad";
   	sessionCommands = ''
			xmobar ${confDir}/xmonad/xmobar.hs &

			# aparently needed, so that xmonad works
			sleep 2 && \
			${pkgs.xorg.xmodmap}/bin/xmodmap \
				-e "clear control" \
				-e "clear mod1" \
				-e "keycode 64 = Control_L" \
				-e "keycode 37 = Alt_L" \
				-e "add control = Control_L" \
				-e "add mod1 = Alt_L" \
				&
   	'';
	};

   displayManager.lightdm = {
		enable = true;
		greeters.enso = {
			enable = true;
			blur = true;
			extraConfig = ''
				default-wallpaper=/usr/share/streets_of_gruvbox.png
			'';
		};
	};
	layout = "at";
	};

	# Configure keymap in X11
	# services.xserver.xkbOptions = "eurosign:e,caps:escape";

	# Enable CUPS to print documents.
	# services.printing.enable = true;

	# Enable sound.
	sound.enable = true;
	hardware.pulseaudio.enable = true;

	# Enable touchpad support (enabled default in most desktopManager).
	services.xserver.libinput.enable = true;

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
   	vim # Do not forget to add an editor to edit configuration.nix!
   	wget
   	xorg.xmodmap
		bluez
	];

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It's perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "23.05"; # Did you read the comment?
}


