
{ pkgs, lib, workDir, self, secretsDir, config,  ... }:
{

  # https://bugzilla.kernel.org/show_bug.cgi?id=110941
  # ??????????? TODO
  # boot.kernelParams = [ "intel_pstate=no_hwp" ];

  # Supposedly better for the SSD.
  # ??????????? TODO
  # fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];


	imports = [
		../common/all.nix
		../common/nixos-headless.nix
		../common/nixos-graphical.nix
    ../common/building.nix

		../users/me/default.nix
		../users/root/default.nix
	];

  services.avahi.enable = true;

  environment.systemPackages = with pkgs; [
    cifs-utils
    ntfs3g
  ];

  virtualisation.podman.enable = true;

  hardware.bluetooth.settings = {
    General = {
      MultiProfile = "multiple";
    };
  };

   nix = {
      distributedBuilds = false; # false, because i can't build on hpm currently ... not signed by trusted user error
   };

	networking.hostName = "main";
   networking.search = [ "c2vi.local" ];
   networking.extraHosts = ''
      192.168.1.6 hpm
      192.168.1.2 rpi
      127.0.0.1 youtube.com
      127.0.0.1 www.youtube.com
   '';


  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
    #"x86_64-unknown-linux-gnu"
    #"armv6l-unknown-linux-gnueabihf"
    #"armv7l-hf-multiplatform"
  ];


	# some bind mounts
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

  # my youtube blocking service
  systemd.services.stark = 
    let 
    stark = pkgs.writeShellApplication {
      name = "stark";

      runtimeInputs = with pkgs; [ curl w3m ];

      text = ''
        if [ -f "/etc/host-youtube-block" ];
        then
          timeout=$(cat /etc/host-youtube-block)
          if [[ "$timeout" == "1" ]]
          then
            rm /etc/host-youtube-block
          else
            echo old: $timeout
            timeout=$((timeout - 1))
            echo new: $timeout
            echo -en $timeout > /etc/host-youtube-block
          fi
        else
          rm /etc/hosts
          ln -nsf ${config.environment.etc.hosts.source.outPath} /etc/hosts
        fi
      '';
      };
    in
  {
    enable = true;
    description = "block Youtube";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      Restart = "always";
      RestartSec = "60s";
      ExecStart = "${stark}/bin/stark";
    };
    wantedBy = [ "multi-user.target" ];
  };


	# syncthing for main
	services.syncthing = {
   	enable = true;
   	user = "me";
   	#dataDir = "/home/";
   	configDir = "/home/me/.config/syncthing";
		extraFlags = ["-no-browser"];
		openDefaultPorts = true;
   	overrideDevices = true;     # overrides any devices added or deleted through the WebUI
   	overrideFolders = true;     # overrides any folders added or deleted through the WebUI
   	devices = {
   		"seb-phone" = { 
				id = builtins.readFile "${secretsDir}/syncthing-id-phone";
				#addresses = [ "tcp://192.168.200.24:22000" ];
			};
   		"seb-tab" = { 
				id = builtins.readFile "${secretsDir}/syncthing-id-tab";
				#addresses = [ "tcp://192.168.200.26:22000" ];
			};
    	};
    	folders = {
      	"priv-share" = {        # Name of folder in Syncthing, also the folder ID
        		path = "/home/me/work/priv-share";    # Which folder to add to Syncthing
        		#devices = [ "seb-phone" "seb-tab" ];      # Which devices to share the folder with
        		devices = [ "seb-phone" "seb-tab" ];      # Which devices to share the folder with
      	};
   	};
	};


	security.polkit.enable = true;

	networking.firewall.allowPing = true;
	networking.firewall.enable = true;
	services.samba.openFirewall = true;


	# samba
	services.samba-wsdd.enable = true; # make shares visible for windows 10 clients

	networking.firewall.allowedTCPPorts = [
  	5357 # wsdd
		8888 # for general usage
		9999 # for general usage
    8080 # for mitm proxy
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


  	virtualisation.libvirtd.enable = true;

  	system.activationScripts.setupLibvirt = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/libvirt/storage
		ln -nsf ${workDir}/vm/libvirt/my-image-pool.xml /var/lib/libvirt/storage/my-image-pool.xml
    rm -rf /var/lib/libvirt/qemu/networks
    ls ${workDir}/vm/qemu | while read path
    do
		  ln -nsf ${workDir}/vm/qemu/$path /var/lib/libvirt/qemu/$path
    done

		# there is no /bin/bash
		# https://discourse.nixos.org/t/add-bin-bash-to-avoid-unnecessary-pain/5673
		ln -nsf /run/current-system/sw/bin/bash /bin/bash
   '';


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
}


