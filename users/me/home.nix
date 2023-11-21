
{ config, pkgs, self, secretsDir, inputs, persistentDir, ... }:

{
	imports = [
    ./home-headless.nix

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
	];
}


