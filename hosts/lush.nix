{ lib, pkgs, inputs, ... }:
{
  system.stateVersion = "23.05"; # Did you read the comment?

  imports = [
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      #inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  #nixpkgs.hostPlatform.system = "aarch64-linux";
  #nixpkgs.buildPlatform.system = "x86_64-linux";

  hardware.enableRedistributableFirmware = true;

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
    #kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
    };
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];

    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # end of base.nix

  environment.systemPackages = with pkgs; [ vim git ];
  networking.hostName = "lush";
  users = {
    users.me = {
      password = "hello";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjgXf9S9hxjyph2EEFh1el0z4OUT9fMoFAaDanjiuKa me@main"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWsqiz0gEepvPONYxqhKKq4Vxfe1h+jo11k88QozUch me@bitwarden"
      ];
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
  */

}
