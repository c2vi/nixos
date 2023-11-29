
{ config, pkgs, self, secretsDir, inputs, persistentDir, ... }:

{
	imports = [
    ../common/home.nix

    # my gui programs
		../../programs/alacritty.nix
		../../programs/emacs/default.nix
		../../programs/rofi/default.nix
		../../programs/zathura.nix
	];

	gtk.cursorTheme = {
		name = "Yaru";
	 };

	dconf.settings = {
	  "org/virt-manager/virt-manager/connections" = {
		 autoconnect = ["qemu:///system"];
		 uris = ["qemu:///system"];
	  };
	};

	services.dunst.enable = true;


  home.file = {
    ".mysecrets/root-pwd".text = "changeme";
    ".mysecrets/me-pwd".text = "changeme";

    ".mozilla/firefox".source = config.lib.file.mkOutOfStoreSymlink "${persistentDir}/firefox";
    ".cache/rofi-3.runcache".source = config.lib.file.mkOutOfStoreSymlink "${persistentDir}/rofi-run-cache";
  };


	home.packages = with pkgs; [

    # packages that i might not need everywhere??
		wstunnel
		rclone
		playerctl
		alsa-utils
		usbutils
		android-tools
    android-studio
		moonlight-qt
		pciutils
		jmtpfs
		pmutils
		cntr
		nil


    # gui packages
		obsidian
		xorg.xkbcomp
		haskellPackages.xmonad-extras
		haskellPackages.xmonad-contrib
		xorg.xev
		blueman
		pavucontrol
		spotify
		flameshot
		networkmanagerapplet
		haskellPackages.xmobar
		dolphin
		mupdf
		xclip
		stalonetray
		killall
		signal-desktop
		element-desktop
		discord
		wireshark
		gparted
		xorg.xkill
    xorg.xmodmap

    # my own packages
    supabase-cli

		inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin

		# base-devel
		gcc

		# rust
		cargo
		rust-analyzer

		#localPacketTracer8

		#ciscoPacketTracer8

		# virtualisation
		qemu
		libvirt
		virt-manager
		freerdp
    (pkgs.writeShellApplication {
      name = "rpi";
      text = let 
        myPythonRpi = pkgs.writers.writePython3Bin "myPythonRpi" {} ''
          # flake8: noqa
          import os
          import sys
          import subprocess

          mac_map = {
            "tab": "";
            "phone": "86:9d:6a:bc:ca:1b"
          }


          if len(sys.argv) == 1:
            print("one arg needed")
            exit()
          net = sys.argv[1]

          if net == "pw":
            ips = subprocess.run(["${pkgs.arp-scan}/bin/arp-scan", "-l", "-x", "-I", "wlp2s0"])
            for line in ips.split("\n"):
              split = line.split(" ")
              ip = split[0]
              mac = split[1]

          old = {}
          with open(f"/etc/hosts", "r") as file:
            for line in file.readlines():
              if line == "\n":
                continue
              split = line.split(" ")
              try:
                old[split[1].strip()] = split[0].strip()
              except:
                print("error with: ", split)

          #to_update = {}
          with open(f"${self}/misc/my-hosts-{net}", "r") as file:
            for line in file.readlines():
              split = line.split(" ")
              try:
                old[split[1].strip()] = split[0].strip()
              except:
                print("error with: ", split)

          with open("/etc/hosts", "w") as file:
            lines = []
            for key, val in old.items():
              lines.append(val + " " + key)
            file.write("\n".join(lines) + "\n")
  
          with open("/etc/current_hosts", "w") as file:
            file.write(net)
        '';
      in ''sudo ${myPythonRpi}/bin/myPythonRpi "$@"'';
    })
	];
}


