{ lib, pkgs, inputs, secretsDir, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    #inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.networkmanager.nixosModules.networkmanager

		../common/all.nix
		../common/nixos-headless.nix

		inputs.home-manager.nixosModules.home-manager
		../users/me/headless.nix
		../users/root/default.nix
    ../users/server/headles.nix
    ../users/files/headless.nix
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

  environment.systemPackages = with pkgs; [
    bcache-tools
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

 swapDevices = [ {
    device = "/swapfile";
    size = 10*1024;
  } ];

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


  users.users.mamafiles = {
   	isNormalUser = true;
		password = "changeme";
  };

########################## networking ###########################################

	networking.firewall.allowPing = true;
	networking.firewall.enable = true;
	services.samba.openFirewall = true;

  networking.hostName = "rpi";

	networking.firewall.allowedTCPPorts = [
  	5357 # wsdd
		8888 # for general usage
		9999 # for general usage
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
	];


  networking.networkmanager.enable = true;

  networking.networkmanager.profiles = {
    main = {
      connection = {
        id = "main";
        uuid = "a02273d9-ad12-395e-8372-f61129635b6f";
        type = "ethernet";
        autoconnect-priority = "-999";
        interface-name = "eth0";
      };
      ipv4 = {
        address1 = "192.168.1.2/24,192.168.1.1";
        dns = "1.1.1.1;";
        method = "manual";
      };
    };

    me = {
     connection = {
        id = "me";
        uuid = "fe45d3bc-21c6-41ff-bc06-c936017c6e02";
        type = "wireguard";
        autoconnect = "true";
        interface-name = "me0";
     };
      wireguard = {
        listen-port = "49390";
        private-key = builtins.readFile "${secretsDir}/wg-private-rpi";
      };
      ipv4 = {
        address1 = "10.1.1.2/24";
        method = "manual";
      };
    } // (import ../common/wg-peers.nix { inherit secretsDir; }) ;
  };

  ######################################### wstunnel #######################################

  systemd.services.wstunnel = {
    enable = true;
    description = "WStunnel for SSH connections and Wireguard VPN";
    after = [ "network.target" ];
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.wstunnel}/bin/wstunnel --server ws://0.0.0.0:49389 -r 127.0.0.1:49388 -r 127.0.0.1:49390";
    };
    wantedBy = [ "multi-user.target" ];
  };

  ###################################### dyndns ####################################

  systemd.services.update-ip = 
    let 
    update-ip = pkgs.writeShellApplication {
      name = "update-ip";

      runtimeInputs = with pkgs; [ curl w3m ];

      text = ''
        ip=$(curl my.ip.fi)
        curl "http://dynv6.com/api/update?hostname=${builtins.readFile "${secretsDir}/dns-name-two"}&ipv4=$ip&token=${builtins.readFile "${secretsDir}/dns-name-two-token"}"
        curl "https://dynamicdns.park-your-domain.com/update?host=@&domain=${builtins.readFile "${secretsDir}/dns-name"}&password=${builtins.readFile "${secretsDir}/dns-name-token"}&ip=$ip"
        # https://www.namecheap.com/support/knowledgebase/article.aspx/29/11/how-to-dynamically-update-the-hosts-ip-with-an-https-request/
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
      RestartSec = "500s";
      ExecStart = "${update-ip}/bin/update-ip";
    };
    wantedBy = [ "multi-user.target" ];
  };


  ################################## ssh ######################################
  services.openssh = {
    enable = true;
    ports = [ 49388 ];

    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  	settings.PermitRootLogin = "no";
  };

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
        "browsable" = "no";
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
}
