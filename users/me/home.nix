
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

		(inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin.overrideAttrs (old: {
      NIX_CFLAGS_COMPILE = [ (old.NIX_CFLAGS_COMPILE or "") ] ++ [ "-O3" "-march=native" "-fPIC" ];
    }))

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
        myPythonRpi = pkgs.writers.writePython3Bin "myPythonRpi" { libraries = [pkgs.python310Packages.dnspython]; } ''
          # flake8: noqa
          import os
          import sys
          import subprocess

          import dns.resolver

          pw_map = {
            "tab": "00:0a:50:90:f1:00",
            "phone": "86:9d:6a:bc:ca:1b",
          }


          if len(sys.argv) == 1:
            print("one arg needed")
            exit()
          net = sys.argv[1]


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
              split = line.strip().split(" ")
              try:
                if split[0][0] not in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]:
                  print("looking up: ", split[1])
                  result = dns.resolver.resolve(split[0].strip(), "A")
                  ips = list(map(lambda ip: ip.to_text(), result))
                  print("got:", ips)
                  old[split[1].strip()] = str(ips[0])
                else:
                  old[split[1].strip()] = split[0].strip()
              except Exception as e:
                print("error with: ", split)
                print(e)


          if net == "pw":
            ips = subprocess.run(["sudo", "${pkgs.arp-scan}/bin/arp-scan", "-l", "-x", "-I", "wlp2s0"], capture_output=True)
            for line in ips.stdout.decode("utf-8").split("\n"):
              try:
                split = line.split("\t")
                ip = split[0]
                mac = split[1]
              except:
                print("error on line:", line)
                continue

              for name, mac_table in pw_map.items():
                if mac == mac_table:
                  # found name
                  print(f"found {name} with ip {ip}")
                  old[name] = ip


          os.system("rm -rf /etc/hosts")
          with open("/etc/hosts", "w") as file:
            lines = []
            for key, val in old.items():
              lines.append(val + " " + key)
            file.write("\n".join(lines) + "\n")
  
          with open("/etc/current_hosts", "w") as file:
            lines = []
            for key, val in old.items():
              lines.append(val + " " + key)
            file.write("\n".join(lines) + "\n")

        '';
      in ''sudo ${myPythonRpi}/bin/myPythonRpi "$@"'';
    })
	];
}


