{ lib, pkgs, ... }:
{

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
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
    };
  };

  nix.settings = {
    experimental-features = lib.mkDefault "nix-command flakes";
    trusted-users = [ "root" "@wheel" ];
  };

  # end of base.nix

  environment.systemPackages = with pkgs; [ vim git ];
  services.openssh.enable = true;
  networking.hostName = "luna";
  users = {
    users.me = {
      password = "hello";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };
  networking = {
    interfaces."wlan0".useDHCP = true;
    wireless = {
      interfaces = [ "wlan0" ];
      enable = true;
      networks = {
        seb-phone.psk = "hellogello";
      };
    };
  };


  /*
  boot = {

    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };


  fileSystems = {

    "/" = {

      device = "/dev/disk/by-label/NIXOS_SD";

      fsType = "ext4";

      options = [ "noatime" ];

    };

  };


  networking = {

    hostName = hostname;

    wireless = {

      enable = true;

      networks."${SSID}".psk = SSIDpassword;

      interfaces = [ interface ];

    };

  };


  environment.systemPackages = with pkgs; [ vim ];


  services.openssh.enable = true;


  users = {

    mutableUsers = false;

    users."${user}" = {

      isNormalUser = true;

      password = password;

      extraGroups = [ "wheel" ];

    };

  };



  system.stateVersion = "23.11";
  */
}
