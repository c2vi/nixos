
{ pkgs, lib, workDir, self, secretsDir, config, inputs, system, pkgsUnstable, ... }:
{

  # https://bugzilla.kernel.org/show_bug.cgi?id=110941
  # ??????????? TODO
  # boot.kernelParams = [ "intel_pstate=no_hwp" ];

  # Supposedly better for the SSD.
  # ??????????? TODO
  # fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];


/*
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.plasma5.enable = true;


	modules.battery_monitor.enable = true;
  services.blueman.enable = true;
	hardware.bluetooth.enable = true;


  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # enable Sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  */

  #services.openssh.enable = true;

  # virtual display
  hardware.display = {

    edid.packages = [
      (pkgs.runCommand "edid-custom" {} ''
        mkdir -p "$out/lib/firmware/edid"
        base64 -d > "$out/lib/firmware/edid/virtual.bin" <<'EOF'
        AP///////wAEctsABAdgIAYWAQOAPCJ4CGCFplZKnCUSUFQAAAABAQEBAQHRwAEBAQEBAQEBAjqA
        GHE4LUBYLEUAQEQhAAAGAAAA/ABTMjczSEwKICAgICAgAAAA/QA3Sx5QEgAKICAgICAgAAAA/wBM
        UUEwQzAxNzgwMDEKAEA=
        EOF
      '')
    /*
      (pkgs.runCommand "edid-custom" {} ''
        mkdir -p "$out/lib/firmware/edid"
        base64 -d > "$out/lib/firmware/edid/virtual.bin" <<'EOF'
        AP///////wAEctsABAdgIAYWAQOAPCJ46mCFplZKnCUSUFQAAAABAQEBAQHRwAEBAQEBAQEBAjqA
        GHE4LUBYLEUAVVAhAAAeAAAA/ABTMjczSEwKICAgICAgAAAA/QA3Sx5QEgAKICAgICAgAAAA/wBM
        UUEwQzAxNzgwMDEKACU=
        EOF
      '')
      */
    ];


    # find a free GPU output using this command:
    # for p in /sys/class/drm/*/status; do con=${p%/status}; echo -n "${con#*/card?-}: "; cat $p; done
    outputs."DP-2" = {
      edid = "virtual.bin";

      # forces this output on even though the display is not physically connected
      # https://wiki.archlinux.org/title/Kernel_mode_setting#Forcing_modes
      #mode = "e";
      mode = "1920x1080e";
    };
  };


  programs.fuse.userAllowOther = true;

  services.sunshine = {
    enable = false;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    
    /*
    package = pkgs.sunshine.overrideAttrs {
      src = pkgs.fetchFromGitHub {
        owner = "garnacho";
        repo = "Sunshine";
        rev = "xdg-portal";
        hash = "sha256-To1vhNQxjIa5Hc+z2xo+ODSQyIH6cnI3A7Ofc7MDL60=";
      };
    };
    */

    package = pkgsUnstable.sunshine.overrideAttrs (prev: {
      patches = prev.patches or [] ++ [
        #(pkgs.fetchpatch {
          #url = "https://github.com/LizardByte/Sunshine/pull/2507.patch";
          #hash = "sha256-DdyiR7djH4GF1bcQP/a20BYpTBvrAzd0UxJ0o0nC4rU=";
        #})
      ];

      buildInputs = prev.buildInputs or [] ++ [
        pkgsUnstable.pipewire
        pkgsUnstable.xdg-desktop-portal
      ];
      cmakeFlage = prev.cmakeFlags or [] ++ [
        (lib.cmakeBool "SUNSHINE_ENABLE_PORTAL" true)
      ];

      src = pkgs.fetchFromGitHub {
        owner = "c2vi";
        repo = "Sunshine";
        rev = "2671cd374dc5d12d402de572d170c9dfee8c5d7b";
        hash = "sha256-7IOMXmvl7/WYF6ktSUrLZjq+Lnq9YpSqUsj0FVtG8tI=";
        fetchSubmodules = true;
      };
    });
  };



  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver intel-ocl intel-vaapi-driver intel-compute-runtime-legacy1
  ];



  home-manager.users.me.programs.lan-mouse = {
    enable = true;
    settings = {
      authorized_fingerprints."0d:4f:2c:8a:46:d5:6a:e2:22:c9:02:89:39:da:75:69:2d:e9:32:39:d7:dc:e6:e2:50:d6:20:22:a5:26:d4:44" = "mac";
      port = 4410;
      clients = [
        {
          position = "right";
          hostname = "mac";
          activate_on_startup = true;
          ips = [ "192.168.1.33" ];
          port = 4410;
          #enter_hook = "${pkgs.wl-clipboard}/bin/wl-paste | ${pkgs.openssh}/bin/ssh mac 'cat > ~/clipboard'";
          #enter_hook = "/run/current-system/sw/bin/echo hooooooooooo > /home/me/p1";
          enter_hook = "/run/current-system/sw/bin/cat /home/me/.cache/clipboard | /run/current-system/sw/bin/ssh mac 'cat >~/clipboard'";
        }
      ];
    };
  };
  home-manager.users.me.systemd.user.services.lan-mouse.Service.Environment = "PATH=/bin";




  virtualisation.vmVariant.services.timesyncd.enable = lib.mkForce false;

  services.tailscale.enable = true;

  services.resilio = {
    enable = true;
    enableWebUI = true;
  };
  users.users.me.homeMode = "770"; # important for resilio



  virtualisation.waydroid.enable = true;


  services.nscd.enable = lib.mkForce false;

  system.nssModules = lib.mkForce [];

  services.xserver.enableTCP = true;
  services.xserver.displayManager.lightdm.extraSeatDefaults = ''
    xserver-allow-tcp=true
  '';
  services.xserver.displayManager.xserverArgs = [ "-listen tcp" ];

  nixpkgs.config.allowUnfree = lib.mkForce true;


  programs.nix-ld.enable = true;
  programs.steam.enable = true;

  home-manager.users.me.home.file.".config/sway/config".text = ''
    exec ${pkgs.wayvnc}/bin/wayvnc 0.0.0.0 6666
    #exec wl-paste -w ${pkgs.netcat-openbsd}/bin/nc 192.168.1.33 4405
    #exec 'wl-paste -w ssh mac "cat > ~/clipboard"'
    #exec 'sh -c "while true; do ${pkgs.netcat-openbsd}/bin/nc -l 4405 | wl-copy; done"'
  '';



  ################# make firefox default browser
  environment.sessionVariables.DEFAULT_BROWSER = "firefox"; # for electron apps
  xdg.mime.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };




  # disable touch clicks because i always tap while typing
  #services.xserver.libinput.touchpad.tappingButtonMap = null;
  services.xserver.libinput.touchpad.tapping = false;


	imports = [
		../common/all.nix
		../common/nixos-headless.nix
		#../common/nixos-graphical.nix
    ../common/nixos-wayland.nix
    ../common/building.nix
		../mods/battery_monitor.nix

    inputs.networkmanager.nixosModules.networkmanager
		inputs.home-manager.nixosModules.home-manager
		../users/me/gui.nix
		../users/root/default.nix

    # see: https://github.com/NixOS/nixpkgs/issues/300081
    #"${inputs.nixpkgs-unstable}/nixos/modules/virtualisation/incus.nix" 
    #../scripts/yt-block/module.nix

    # add waveforms flake module
    #inputs.waveforms.nixosModule
	];

  services.udev.packages = [ inputs.waveforms.packages.${system}.adept2-runtime ];
  users.users.rslsync.extraGroups = ["users"];

  # add myself to plugdev group for waveforms
  # and incus-admin to use incus without sudo
  users.users.me.extraGroups = [ "incus-admin" "plugdev" "rslsync" ];


  nixpkgs.config.permittedInsecurePackages = [
    "python-2.7.18.8"
  ];


  environment.systemPackages = with pkgs; [
    inputs.waveforms.packages.${system}.waveforms
    intel-compute-runtime-legacy1
    ffmpeg-full
    remmina
    vesktop
    prismlauncher

    # add pyclip for waydroid
    python310Packages.pyclip

    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
    (pkgs.wrapOBS {
      plugins = with obs-studio-plugins; [
        obs-ndi
        obs-teleport
      ];
    })

    (writeShellScriptBin "davinci" ''
      NIXPKGS_ALLOW_UNFREE=1 OCL_ICD_ENABLE_TRACE=True QT_QPA_PLATFORM=xcb nix run nixpkgs#davinci-resolve --impure -L
    '')


    # waveforms

    # my keyboar flash script, that opens as an alacritty window
    (pkgs.writeShellScriptBin "keyboard-flash" "alacritty --command ${pkgs.writeShellScriptBin "keyboard-flash-internal" "${./..}/scripts/keyboard-flash; bash"}/bin/keyboard-flash-internal")

    # my keyboar flash script, that opens as an alacritty window
    (pkgs.writeShellScriptBin "keyboard-flash-left" "alacritty --command ${pkgs.writeShellScriptBin "keyboard-flash-internal" "${./..}/scripts/keyboard-flash left; bash"}/bin/keyboard-flash-internal")

    slint-lsp
    cifs-utils
    nfs-utils
    ntfs3g
    dhcpcd
    looking-glass-client
    swtpm
    win-virtio
  ];

  # shedule nix builds with low priority, so the laptop is still usable while building something
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";
  systemd.services.nix-daemon.serviceConfig.CPUSchedulingPolicy = lib.mkForce "idle";
  systemd.services.nix-daemon.serviceConfig.IOSchedulingPriority = lib.mkForce "idle";
  systemd.services.nix-daemon.serviceConfig.CPUWeight= lib.mkForce "idle";
  /*
  systemd.services.nix-daemon.serviceConfig.CPUQuota = lib.mkForce "100%";
  systemd.services.nix-daemon.environment = {
    LD_PRELOAD = "${pkgs.trickle}/lib/trickle/trickle-overload.so";
    TRICKLE_WINDOW_SIZE = "200";
    TRICKLE_UPLOAD_LIMIT = "10";
    TRICKLE_LSMOOTH = "20";
    TRICKLE_VERBOSE = "0";
    TRICKLE_SOCKNAME = "";
    TRICKLE_ARGV = "alacritty";
    TRICKLE_TSMOOTH = "3.0";
    TRICKLE_DOWNLOAD_LIMIT = "30";
  };
  nix.extraOptions = ''
    download-speed = 30
  '';
  */

  # enable ntp
  #services.ntp.enable = true;
  # if i hibernate and ren unhibernate in the school network ... the time will be off, because 0.nixos.pool.ntp.org can't be reached
  services.timesyncd.enable = true;

  ################################### optimisations ####################################
  #boot.kernelPackages = pkgs.linuxPackages; # .overrideAttrs (old: {
    #NIX_CFLAGS_COMPILE = [ (old.NIX_CFLAGS_COMPILE or "") ] ++ [ "-O3" "-march=native" ];
  /*
  #});
  boot.kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor (pkgs.linux_6_1.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = [ (old.NIX_CFLAGS_COMPILE or "") ] ++ [ "-O3" "-march=native" ];
  })));
  */
  #boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_1.override {
    #argsOverride = rec {
      #NIX_CFLAGS_COMPILE = [ "-O3" "-march=native" ];
    #};
  #});
  #*/
#(old: {
  #}));

  /*
  nixpkgs.overlays = [
    (final: prev: {
      optimizeWithFlags = pkg: flags:
        pkg.overrideAttrs (old: {
          NIX_CFLAGS_COMPILE = [ (old.NIX_CFLAGS_COMPILE or "") ] ++ flags;
        });

      optimizeForThisHost = pkg:
        final.optimizeWithFlags pkg [ "-O3" "-march=native" "-fPIC" ];

      firefox = final.optimizeForThisHost prev.firefox;
    })
  ];
  */


  hardware.bluetooth.settings = {
    General = {
      MultiProfile = "multiple";
    };
  };

   nix = {
      distributedBuilds = false; # false, because i can't build on hpm currently ... not signed by trusted user error
   };

  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
  ];

	# some bind mounts
  /*
	fileSystems."${workDir}/priv-share/things" = {
		device = "${workDir}/things";
  		options = [ "bind" ];
	};
	fileSystems."${workDir}/things/htl" = {
		device = "${workDir}/htl";
  		options = [ "bind" ];
	};
	fileSystems."${workDir}/things/diplomarbeit" = {
		device = "${workDir}/diplomarbeit";
  		options = [ "bind" ];
	};
  # */

    # */
  	system.activationScripts.makeBinBash = lib.stringAfter [ "var" ] ''
		# there is no /bin/bash
		# https://discourse.nixos.org/t/add-bin-bash-to-avoid-unnecessary-pain/5673
		ln -nsf /run/current-system/sw/bin/bash /bin/bash
   '';
   # */

  ################################ my youtube blocking service #############################
  environment.etc."host.conf" = {
    # needed so that firefox does not ignore the hosts file
    text = ''
      multi off
      order hosts,nis,bind
    '';
  };


  ############################## networking ###############################################

	networking.hostName = "main";

	security.polkit.enable = true;
  services.rpcbind.enable = true;

  #services.avahi.hostName = "c2vi";
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

  networking.networkmanager.enable = true;
  #networking.networkmanager.extraConfig = ''
  #[main]
  #dhcp=dhcpcd
  #'';
  #networking.useDHCP = lib.mkForce true;

	networking.firewall.allowPing = true;
	networking.firewall.enable = true;

	services.samba.openFirewall = true;

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 
    44444 # resilio sync
  ];

	networking.firewall.allowedTCPPorts = [
  	5357 # wsdd
		8888 # for general usage
		9999 # for general usage
    8080 # for mitm proxy
    51820  # wireguard
    6000 # Xserver
    10000 # tailscale tcp funnel
    4405 # clipboard sync with imac
	];

	networking.firewall.allowedUDPPorts = [
  		3702 # wsdd
      51820  # wireguard
      67 # allow DHCP traffic
      53 # allow dns
      48899 # GoodWe inverter discovery
      4410 # lan-mouse
	];

  #networking.search = [ "c2vi.local" ];
  #networking.hosts = {
    #"10.1.1.3" = [ "phone" ];
  #};
  #environment.etc.hosts.mode = "rw";

  networking.networkmanager.profiles = {
    home = {
      connection = {
        id = "home";
        uuid = "a02273d9-ad12-395e-8372-f61129635b6f";
        type = "ethernet";
        autoconnect-priority = "-999";
        interface-name = "enp1s0";
      };
      ipv4 = {
        address1 = "192.168.1.11/24,192.168.1.1";
        dns = "1.1.1.1;";
        method = "manual";
      };
    };

    htl = {
      connection = {
        id = "htl";
        uuid = "0d3af539-9abd-4417-b882-cbff96fc3490";
        type = "wifi";
        interface-name = "wlo1";
      };
      ipv4 = {
        method = "auto";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "HTLinn";
      };
      wifi-security = {
        key-mgmt = "wpa-eap";
        auth-alg = "open";
      };
      "802-1x" = {
        eap = "peap";
        identity = builtins.readFile "${secretsDir}/school-username";
        password = builtins.readFile "${secretsDir}/school-password";
        phase2-auth = "mschapv2";
      };
    };

    pt = {
      connection = {
        id = "pt";
        uuid = "f028117e-9eef-47c1-8483-574f7ee798a4";
        type = "bluetooth";
        autoconnect = "false";
      };

      bluetooth = {
        bdaddr = "E8:78:29:C4:BA:7C";
        type = "panu";
      };

      ipv4 = {
        address1 = "192.168.44.11/24";
        method = "auto";
      };
    };

    pw = {
      connection = {
        id = "pw";
        uuid = "e0103dac-7da0-4e32-a01b-487b8c4c813c";
        type = "wifi";
        interface-name = "wlo1";
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

    hec = {
      connection = {
        id = "hec";
        uuid = "a84fdbd8-af9c-4e2d-9185-7676e9d139f4";
        type = "wifi";
        interface-name = "wlo1";
      };

      wifi = {
        hidden = "true";
        mode = "infrastructure";
        ssid = builtins.readFile "${secretsDir}/hec-wifi-ssid";
      };

      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = builtins.readFile "${secretsDir}/hec-wifi-password";
      };

      ipv4 = {
        #address1 = "192.168.20.11/24";
        method = "auto";
      };
    };

    hot = {
      connection = {
        id = "hot";
        uuid = "ab51de8a-9742-465a-928b-be54a83ab6a3";
        type = "wifi";
        autoconnect = false;
        interface-name = "wlo1";
      };
      wifi = {
        mac-address = "0C:96:E6:E3:64:03";
        mode = "ap";
        ssid = "c2vi-main";
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
        interface-name = "enp1s0";
      };

      ethernet = {
        mac-address = "F4:39:09:4A:DF:0E";
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
        autoconnect = "false";
        interface-name = "enp1s0";
      };

      ethernet = {
        mac-address = "F4:39:09:4A:DF:0E";
      };

      ipv4 = {
        address1 = "192.168.1.11/24,192.168.1.1";
        method = "auto";
      };
    };

    /*
    me = {
     connection = {
        id = "me";
        uuid = "fe45d3bc-21c6-41ff-bc06-c936017c6e02";
        type = "wireguard";
        autoconnect = "true";
        interface-name = "me0";
     };
      wireguard = {
        listen-port = "51820";
        private-key = builtins.readFile "${secretsDir}/wg-private-main";
      };
      ipv4 = {
        address1 = "10.1.1.11/24";
        method = "manual";
      };
    } // (import ../common/wg-peers.nix { inherit secretsDir; });
    */
  };

  /*
  networking.wireguard.interfaces = {
    me1 = {
      ips = [ "10.1.1.11/24" ];
      listenPort = 51820;

      privateKeyFile = "${secretsDir}/wg-private-main";

      peers = import ../common/wg-peers.nix { inherit secretsDir; };
    };
  };
  # */


  systemd.services.waydroid = {
    enable = false;
    description = "run waydroid session in background";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      Restart = "always";
      RestartSec = "500s";
      ExecStart = "${pkgs.waydroid}/bin/waydroid session start";
      User = "me";
      Group = "users";
    };
    wantedBy = [ "multi-user.target" ];
  };


	#################################### samba ######################################
  /*
	services.samba-wsdd.enable = true; # make shares visible for windows 10 clients

	services.samba = {
  		enable = true;
  		securityType = "user";
  		settings = {
        global = {
			    "security" = "user";
			    "map to guest" = "bad user";
			    "guest account" = "me";
			    "server role" = "standalone server";
			    "workgroup" = "WORKGROUP";
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
  */


  ######################################### virtualisation ###############################
  	virtualisation.libvirtd = {
      enable = true;
      qemuOvmf = true;
      qemuSwtpm = true;
      #qemuOvmfPackage = pkgs.OVMFFull;
    };


    # see: https://github.com/NixOS/nixpkgs/issues/300081
    #disabledModules = [ "virtualisation/incus.nix" ]; 
    networking.nftables.enable = true;
    # client package now separated...
    #virtualisation.incus.clientPackage = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.incus;
    virtualisation.incus.enable = true;
    systemd.services.incus.path = [ pkgs.swtpm ];
    #virtualisation.incus.package = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.incus;


    virtualisation.podman.enable = true;

    virtualisation.kvmgt.enable = true;
    boot.extraModprobeConfig = "options i915 enable_guc=2";
    boot.resumeDevice = "/dev/disk/by-uuid/20002ed7-1431-4992-90f6-730bdc6eef2c";
    boot.kernelParams = [
      "resume_offset=45743809"
      "intel_iommu=on"
      "pcie_aspm=force"
      #"drm.debug=0xff"
    ];

    virtualisation.kvmgt.vgpus = {
      "i915-GVTg_V5_8" = {
        uuid = [ "1382e8c5-b033-481b-99b8-e553ef6a0056" ];
      };
    };

     /*
  	system.activationScripts.setupLibvirt = lib.stringAfter [ "var" ] ''
      mkdir -p /var/lib/libvirt/storage
      ln -nsf ${workDir}/vm/libvirt/my-image-pool.xml /var/lib/libvirt/storage/my-image-pool.xml
      rm -rf /var/lib/libvirt/qemu/networks
      ls ${workDir}/vm/qemu | while read path
      do
        ln -nsf ${workDir}/vm/qemu/$path /var/lib/libvirt/qemu/$path
      done
    '';
    # */



	############################## swap and hibernate ###################################
	swapDevices = [ { device = "/swapfile"; } ];

	# boot.resumeDevice = "/swapfile";
	services.logind = {
		extraConfig = ''
			HandlePowerKey=suspend-then-hibernate
		'';
		lidSwitch = "lock";
		lidSwitchExternalPower = "lock";
		lidSwitchDocked = "ignore";
	};
	systemd.sleep.extraConfig = ''
		HibernateDelaySec=4h
		HibernateMode=shutdown
	'';
}


