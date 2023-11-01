
{ pkgs, lib, workDir, self, secretsDir, ... }:
{

  # https://bugzilla.kernel.org/show_bug.cgi?id=110941
  # ??????????? TODO
  # boot.kernelParams = [ "intel_pstate=no_hwp" ];

  # Supposedly better for the SSD.
  # ??????????? TODO
  # fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];


	imports = [
		../common/all.nix
		../common/nixos.nix
		../common/nixos-graphical.nix

		../users/me/default.nix
	];

	nix.settings = {
		trusted-public-keys = [
			"sebastian@c2vi.dev:0tIXGRJMLaI9H1ZPdU4gh+BikUuBVHtk+e1B5HggdZo="
		];
	};

	networking.hostName = "main";


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


  	virtualisation.libvirtd.enable = true;

  	system.activationScripts.setupLibvirt = lib.stringAfter [ "var" ] ''
		ln -nsf ${workDir}/vm/libvirt/my-image-pool.xml /var/lib/libvirt/storage/my-image-pool.xml
		ln -nsf ${workDir}/vm/qemu/* /var/lib/libvirt/qemu/

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


