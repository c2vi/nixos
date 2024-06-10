{ mypkgs, specialArgs, nixos-generators,
  system, inputs, nixpkgs, self,
  ... 
}:{
  usbip-kernel = self.nixosConfigurations.main.config.system.build.kernel.overrideAttrs (prev: {
    kernelPatches = prev.kernelPatches or [] ++ [ {
      name = "usbip";
      patch = "null";
      extraConfig = ''
        USB_ACM y
        USBIP_CORE y
        USBIP_VHCI_HCD y
        USBIP_VHCI_HC PORTS 8
        USBIP_VHCI_NR_HCS 1
        USBIP_DEBUG y
        USBIP_SERIAL y
      '';
      } ];
  });
  kernel-test = (nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
		inherit specialArgs;
    modules = [
      ./hosts/main.nix
      ./hardware/hpm-laptop.nix
      #self.nixosConfigurations.main._module
      {
        boot.kernelPatches = [ {
          name = "usbip";
          patch = null;
          extraConfig = ''
            USB_ACM m
            USBIP_CORE m
            USBIP_VHCI_HCD m
            USBIP_VHCI_NR_HCS 1
          '';
            #USBIP_VHCI_HC PORTS 8
            #USBIP_DEBUG y
            #USBIP_SERIAL y
          } ];
      }
    ];
  }).config.system.build.kernel;

  tunefox = mypkgs.firefox-unwrapped.overrideAttrs (final: prev: {
    NIX_CFLAGS_COMPILE = [ (prev.NIX_CFLAGS_COMPILE or "") ] ++ [ "-O3" "-march=native" "-fPIC" ];
    requireSigning = false;
  });

  run-vm = specialArgs.pkgs.writeScriptBin "run-vm" ''
    ${self.nixosConfigurations.hpm.config.system.build.vm}/bin/run-hpm-vm -m 4G -cpu host -smp 4
  '';

  hec-img = nixos-generators.nixosGenerate {
    inherit system;
    modules = [
      ./hosts/hpm.nix
    ];
    format = "raw";
    inherit specialArgs;
  };

  prootTermux = inputs.nix-on-droid.outputs.packages.${system}.prootTermux;

  hello-container = let pkgs = nixpkgs.legacyPackages.${system}.pkgs; in pkgs.dockerTools.buildImage {
    name = "hello";
    tag = "0.1.0";

    config = { Cmd = [ "${pkgs.bash}/bin/bash" ]; };

    created = "now";
  };
}
