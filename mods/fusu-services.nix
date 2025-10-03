{ pkgs, dataDir, config, inputs, system, ... }: let

  /**
    thanks: @melektron
    This builder creates a small shell script that wraps arion to specify
    it to operate on a specific registered arion service identified by `srv_name`.
    This can be used to manage the docker-compose functionality of an arion service
    that is defined in the NixOS system, independently from the systemctl service that 
    starts it. If you start/stop compose projects using this, you should first stop 
    the systemctl service. 
   */
  createArionServiceManager = srv_name: setup: (
    pkgs.writeShellScriptBin "manage-arion-${srv_name}" ''
      echo operating on: ${config.virtualisation.arion.projects."${srv_name}".settings.out.dockerComposeYaml}
      ${setup}
      ${pkgs.lib.getExe inputs.arion.packages."${system}".arion} --prebuilt-file ${config.virtualisation.arion.projects."${srv_name}".settings.out.dockerComposeYaml} $@
    ''
  );

in {

  environment.systemPackages = [
    pkgs.arion

    # Do install the docker CLI to talk to podman.
    # Not needed when virtualisation.docker.enable = true;
    pkgs.docker-client

    # add all the service managers
    (createArionServiceManager "libvirt" "")
  ];

  # Arion works with Docker, but for NixOS-based containers, you need Podman
  # since NixOS 21.05.
  virtualisation.docker.enable = false;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;

  users.extraUsers.me.extraGroups = ["podman"];

  ######################## libvirtd in container #########################
  virtualisation.arion = {
    backend = "podman-socket";

    projects.libvirt.settings.services.libvirt = { pkgs, lib, ... }: {
      nixos.useSystemd = true;
      service.useHostStore = true;

      nixos.configuration = {
        boot.tmp.useTmpfs = true;
  	    virtualisation.libvirtd = {
          enable = true;
        };
        users.users.me = {
          uid = 1001;
          isNormalUser = true;
          password = "changeme";
          extraGroups = [ "networkmanager" "wheel" "libvirtd" "plugdev" ];
        };
      };

      service = {
        privileged = true;

        volumes = [ 
          "${dataDir}/libvirt/run:/run/libvirt"
          "${dataDir}/libvirt/lib:/var/lib/libvirt"
        ];
      };

    };
  };

}
