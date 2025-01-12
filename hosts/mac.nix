{ pkgs, inputs, ... }: let

myobs = pkgs.wrapOBS {
  plugins = with pkgs.obs-studio-plugins; [
    obs-ndi
    obs-teleport
  ];
};


in {

  imports = [
		../common/all.nix
		../common/nixos.nix
    ../common/building.nix

		inputs.home-manager.nixosModules.home-manager
    ../users/me/headless.nix
    ../users/root/default.nix
  ];

	networking.hostName = "mac";
  networking.firewall.enable = false;
	networking.useDHCP = true;
  services.avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
  };

	# Use the GRUB 2 boot loader.
	boot.loader.grub = {
  	enable = true;
    #device = "/dev/nbd1";
    device = "nodev";
  	efiSupport = true;
		extraConfig = ''
			set timeout=2
		'';
  };

  environment.systemPackages = with pkgs; [
    mount
    pkgs.hicolor-icon-theme
    efibootmgr
    tcpdump
  ];


  fileSystems."/" = {
    device = "/dev/disk/by-label/mac-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

	networking = {
		#usePredictableInterfaceNames = false;
		defaultGateway = {
			address = "192.168.1.1";
			interface = "enp2s0";
		};
		nameservers = [ "1.1.1.1" "8.8.8.8" ];
		interfaces = {
			"enp2s0" = {
				name = "enp2s0";
				ipv4.addresses = [
					{ address = "192.168.1.33"; prefixLength = 24;}
				];
			};
		};
	};

	services.openssh = {
  		enable = true;
  		# require public key authentication for better security
  		settings.PasswordAuthentication = false;
  		settings.KbdInteractiveAuthentication = false;
  		settings.PermitRootLogin = "no";

      settings.X11Forwarding = true;

      extraConfig = ''
        X11UseLocalhost no
      '';
	};

  ###################################################### the kiosk stuff

  boot.plymouth.enable = true;
  services.dbus.enable = true;

  fonts.enableDefaultPackages = true;
  xdg.icons.enable = true;
  gtk.iconCache.enable = true;

  services.udisks2.enable = false;
  hardware.opengl.enable = true;
  hardware.enableRedistributableFirmware = true;

  systemd.services."cage@" = {
    enable = true;
    after = [ "systemd-user-sessions.service" "dbus.socket" "systemd-logind.service" "getty@%i.service" "plymouth-deactivate.service" "plymouth-quit.service" ];
    before = [ "graphical.target" ];
    wants = [ "dbus.socket" "systemd-logind.service" "plymouth-deactivate.service" ];
    wantedBy = [ "graphical.target" ];
    conflicts = [ "getty@%i.service" ]; # "plymouth-quit.service" "plymouth-quit-wait.service"

    restartIfChanged = false;
    serviceConfig = {
      ExecStart = "${pkgs.cage}/bin/cage -d -- ${myobs}/bin/obs";
      User = "root";

      # ConditionPathExists = "/dev/tty0";
      IgnoreSIGPIPE = "no";

      # Log this user with utmp, letting it show up with commands 'w' and
      # 'who'. This is needed since we replace (a)getty.
      UtmpIdentifier = "%I";
      UtmpMode = "user";
      # A virtual terminal is needed.
      TTYPath = "/dev/%I";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";
      # Fail to start if not controlling the virtual terminal.
      StandardInput = "tty-fail";
      #StandardOutput = "syslog";
      #StandardError = "syslog";
      # Set up a full (custom) user session for the user, required by Cage.
      PAMName = "cage";
    };
  };

  security.pam.services.cage.text = ''
    auth    required pam_unix.so nullok
    account required pam_unix.so
    session required pam_unix.so
    session required ${pkgs.systemd}/lib/security/pam_systemd.so
  '';

  systemd.targets.graphical.wants = [ "cage@tty1.service" ];

  systemd.defaultUnit = "graphical.target";

}
