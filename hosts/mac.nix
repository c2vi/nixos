{ lib, secretsDir, pkgs, inputs, ... }: let

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
    inputs.networkmanager.nixosModules.networkmanager
    ../users/me/gui.nix
    ../users/root/default.nix
    ../common/nixos-wayland.nix
  ];

	networking.hostName = "mac";
  networking.firewall.enable = false;
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
	networking.firewall.allowedTCPPorts = [
		8888 # for general usage
		9999 # for general usage
    6000 # Xserver
    6666 # vnc sway
    5900 # vnc for win VM
    5901 # vnc
    5902 # vnc
    4400 # rdp win VM
    4401 # ssh for mandroid
    4402 # random
    4403 # random
    4404 # random
    4405 # clipboard sync
	];

	networking.firewall.allowedUDPPorts = [
      48899 # GoodWe inverter discovery
      4410 # lan-mouse
	];

	swapDevices = [ { device = "/swapfile"; } ];

  boot.kernelModules = [ "usbip_core" ];
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuSwtpm = true;
    #qemuOvmfPackage = pkgs.OVMFFull;
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
    linuxPackages.usbip
    helvum
    passt
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

  home-manager.users.me.home.file.".config/sway/config".text = ''
    exec ${pkgs.wayvnc}/bin/wayvnc 0.0.0.0 6666
    #exec 'wl-paste -w ${pkgs.netcat-openbsd}/bin/nc 192.168.1.11 4405'
    #exec 'sh -c "while true; do ${pkgs.netcat-openbsd}/bin/nc -l 4405 | wl-copy; done"'
    #exec 'sh -c "while true; do cat ~/clipboard | wl-paste; done"'
  '';

  home-manager.users.me.programs.lan-mouse = {
    enable = true;
    systemd = true;
    settings = {
      authorized_fingerprints."f1:f2:c8:38:fd:e9:34:2f:a0:79:49:b4:ca:d6:4e:c6:31:10:42:1b:9f:ba:61:6f:41:9a:b7:ce:1a:32:47:a1" = "main";
      port = 4410;
      clients = [
        {
          position = "left";
          hostname = "main";
          activate_on_startup = true;
          ips = [ "192.168.1.11" ];
          port = 4410;
          #enter_hook = "${pkgs.wl-clipboard}/bin/wl-paste | ${pkgs.netcat-openbsd}/bin/nc 192.168.1.11 4405";
          enter_hook = "/run/current-system/sw/bin/cat /home/me/.cache/clipboard | ${pkgs.netcat-openbsd}/bin/nc 192.168.1.11 4405 -N";
        }
      ];
    };
  };
  home-manager.users.me.systemd.user.services.lan-mouse.Service.Environment = "PATH=/bin";

  users.users.me.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGw5kYmBQl8oolNg2VUlptvvSrFSESfeuWpsXRovny0x me@phone"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgKLRF9iYRH3Y8hPjLX1ZY6GyavruqcQ0Q0Y8bnmpv9 me@tab"
  ];


  #services.greetd.enable = lib.mkForce false;
  services.greetd = lib.mkForce {
    enable = true;
    settings = rec {
      terminal.vt = 2;
      initial_session = {
        command = "${pkgs.writeScriptBin "run-sway" ''
          export WLR_RENDERER_ALLOW_SOFTWARE=1
          export SDL_VIDEODRIVER=wayland
          export _JAVA_AWT_WM_NONREPARENTING=1
          export QT_QPA_PLATFORM=wayland
          export XDG_CURRENT_DESKTOP=sway
          export XDG_SESSION_DESKTOP=sway
          exec sway > /tmp/sway-log 2>&1
        ''}/bin/run-sway";
        user = "me";
      };
      default_session = initial_session;
    };
  };


  systemd.extraConfig = "DefaultLimitNOFILE=2048";

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
      ExecStart = "${pkgs.cage}/bin/cage -d -- ${pkgs.moonlight-qt}/bin/moonlight";
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


  ############################# networkmanager
  networking.networkmanager.enable = true;

  networking.networkmanager.profiles = {
    pw = {
      connection = {
        id = "pw";
        uuid = "e0103dac-7da0-4e32-a01b-487b8c4c813c";
        type = "wifi";
        interface-name = "wlp3s0";
      };

      wifi = {
        hidden = "true";
        mode = "infrastructure";
        ssid = builtins.readFile "${secretsDir}/wifi-ssid";
      };

      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = builtins.readFile "${secretsDir}/wifi-password";
      };

      ipv4 = {
        #address1 = "192.168.20.11/24";
        dns = "1.1.1.1;8.8.8.8;";
        method = "auto";
      };
    };

    hot = {
      connection = {
        id = "hot";
        uuid = "ab51de8a-9742-465a-928b-be54a83ab6a3";
        type = "wifi";
        autoconnect = false;
        interface-name = "wlp3s0";
      };
      wifi = {
        mode = "ap";
        ssid = "c2vi-mac";
      };

      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = builtins.readFile "${secretsDir}/wifi-password";
      };

      ipv4 = {
        method = "shared";
      };
    };

    share = {
      connection = {
        id = "share";
        uuid = "f55f34e3-4595-4642-b1f6-df3185bc0a04";
        type = "ethernet";
        autoconnect = false;
        interface-name = "enp2s0";
      };

      ethernet = {
        mac-address = "C8:2A:14:0B:7F:3D";
      };

      ipv4 = {
        address1 = "192.168.4.1/24";
        method = "shared";
      };

      ipv6 = {
        addr-gen-mode = "stable-privacy";
        method = "auto";
      };
    };

    dhcp = {
      connection = {
        id = "dhcp";
        uuid = "c006389a-1697-4f77-91c3-95b466f85f13";
        type = "ethernet";
        autoconnect = true;
        interface-name = "enp2s0";
      };

      ethernet = {
        mac-address = "C8:2A:14:0B:7F:3D";
      };

      ipv4 = {
        method = "auto";
        address1 = "192.168.1.33/24,192.168.1.1";
      };
    };

  };
}
