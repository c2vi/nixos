
{ inputs, pkgs, secretsDir, ... }:
{

  #disabledModules = [ "services/databases/couchdb.nix" ];
	imports = [
    #"${inputs.nixpkgs-unstable}/nixos/modules/services/databases/couchdb.nix"
		../common/all.nix
		../common/nixos.nix
    ../common/building.nix

		inputs.home-manager.nixosModules.home-manager
    ../users/me/headless.nix
    ../users/root/default.nix
    ../users/files/headless.nix
    ../users/server/headless.nix
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

  


  services.tailscale.enable = true;
  services.resilio = {
    # TODO: add the config for the share to here
    enable = true;
    enableWebUI = true;
    httpListenAddr = "100.70.54.18";
  };


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

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 
    443 # couchdb for obsidian live sync https
    44444 # resilio sync
    9000 # resilio webui
  ];

	services.samba.openFirewall = true;

	networking.firewall.allowedTCPPorts = [
		8888 # for general usage
		9999 # for general usage
    8080 # for mitm proxy
    5901 # vnc

  	5357 # wsdd
    8080 # for mitm proxy

    49388
    49389
    49390
    49391
    49392
    49393
	];

	networking.firewall.allowedUDPPorts = [
  		3702 # wsdd
      67 # allow DHCP traffic
      53 # allow dns
	];

  networking.networkmanager.enable = false;  # Easiest to use and most distros use this by default.

  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
  ];

  environment.systemPackages = with pkgs; [
    ntfs3g
    virtiofsd
    bcache-tools
    su
    fuse3
    terraform
    usbutils
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



  ############################ couchdb for Obsidian Live sync
  #services.couchdb.enable = true;
  #services.couchdb.extraConfigFiles = [ "/home/files/storage/files/stuff/obsidian-live-sync/local.ini" ];
  #services.couchdb.databaseDir = "/home/files/storage/files/stuff/obsidian-live-sync/data";



  ############################ update ip service

  systemd.services.update-ip = 
    let 
    update-ip = pkgs.writeShellApplication {
      name = "update-ip";

      runtimeInputs = with pkgs; [ curl w3m ];

      text = ''
        ip=$(curl my.ip.fi)
        curl "http://dynv6.com/api/update?hostname=${builtins.readFile "${secretsDir}/dns-name-two"}&ipv4=$ip&token=${builtins.readFile "${secretsDir}/dns-name-two-token"}"
        curl "https://dynamicdns.park-your-domain.com/update?host=home&domain=${builtins.readFile "${secretsDir}/dns-name"}&password=${builtins.readFile "${secretsDir}/dns-name-token"}&ip=$ip"

        # https://www.namecheap.com/support/knowledgebase/article.aspx/29/11/how-to-dynamically-update-the-hosts-ip-with-an-https-request/
      '';
      };
      #curl "https://dynamicdns.park-your-domain.com/update?host=mc&domain=c2vi.dev&password=${builtins.readFile "${secretsDir}/dns-name-token"}&ip=$ip"
    in
  {
    enable = true;
    description = "dyndns ip updates";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      Restart = "always";
      RestartSec = "500s";
      ExecStart = "${update-ip}/bin/update-ip";
    };
    wantedBy = [ "multi-user.target" ];
  };
  






  ###################################### get oci ampere vm ####################################

  systemd.services.oci-ampere = 
    let 
    oci-ampere = pkgs.writeShellApplication {
      name = "oci-ampere";

      runtimeInputs = with pkgs; [ terraform ];

      text = ''
        if [[ -f /home/me/here/oci-ampere-vm/not_gotten ]]
        then
          echo not gotten....................................
          pwd
          cd /home/me/here/oci-ampere-vm
          terraform apply -auto-approve && rm /home/me/here/oci-ampere-vm/not_gotten
        else
          echo gotten!!!!!!!!!!!!!!!!!!!!!
        fi
      '';
      };
    in
  {
    enable = false;
    description = "get a oci ampere vm";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      Restart = "always";
      RestartSec = "500s";
      ExecStart = "${oci-ampere}/bin/oci-ampere";
    };
    wantedBy = [ "multi-user.target" ];
  };


	################################ samba ######################################
	services.samba-wsdd.enable = true; # make shares visible for windows 10 clients

  # needed see: [[samba problems]] in my obsidian vault
  users.users.files.group = "files";
  users.groups.files = {};

	services.samba = {
    enable = true;
    securityType = "user";
    settings = {
      global = {
        "server role" = "standalone server";
        "map to guest" = "bad user";
        "usershare allow guests" = "yes";
        # "hosts allow" = "192.168.1 127.0.0.1 localhost";
        # "hosts deny" = "0.0.0.0/0";
        "workgroup" = "WORKGROUP";
        "security" = "user";
      };
      files = {
        "valid users" = "files";
        "comment" = "all my files";
        "path" = "/home/files/storage/files";
        "browsable" = "no";
        "read only" = "no";
        "guest ok" = "no";
        "force user" = "files";
        "force group" = "files";
        "force create mode" = "0777";
        # Papierkorb
        "vfs object" = "recycle";
        "recycle:repository" = "/home/files/storage/files/trash-files";
        "recycle:keeptree" = "Yes";
        "recycle:versions" = "Yes";
        "recycle:touch" = "Yes";
        "recycle:touch_mtime" = "Yes";
        "recycle:maxsize" = "80000";
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
        "browsable" = "no";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "mamafiles";
        "force user" = "files";
        "force group" = "files";
        "force create mode" = "0777";
      };
    };
  };

  ############################## backup to onedrive ##################################
  # needs that
  programs.fuse.userAllowOther = true; # otherwise the root user has no acces to the mount

  systemd.services.rclone-mount-backup = {
    enable = false;
    description = "Mount rclone backup folder";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'export PATH=/run/wrappers/bin:$PATH; id; ${pkgs.rclone}/bin/rclone mount --allow-non-empty --allow-other --vfs-cache-max-size 2G --vfs-cache-mode full backup: /home/files/backup'";
      User = "files";
      Group = "files";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.borgbackup.jobs.files = {
    #user = "files";
    extraCreateArgs = "--verbose --list --filter=AMECbchfs --stats --checkpoint-interval 600";
    extraArgs = "--progress";
    paths = "/home/files/storage";
    doInit = false;
    repo = "/home/files/backup/dateien-backup-borg-repo";
    compression = "lzma,9";
    startAt = "weekly";
    user = "files";
    group = "files";
    postCreate = ''
      echo create done!!!!!
    '';
    extraPruneArgs = "--stats --list --save-space";
    patterns = [
      "- /home/files/storage/files/no-backup"
    ];

    encryption.mode = "repokey-blake2";
    encryption.passCommand = "cat /home/files/secrets/borg-passphrase";

    environment.BORG_KEY_FILE = "/home/files/secrets/borg-key";

    prune.keep = {
      #within = "1w"; # Keep all archives from the last day
      daily = 7;
      weekly = 7;
      monthly = -1;  # Keep at least one archive for each month
    };

  };


}
