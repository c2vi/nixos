
{ config, pkgs, workDir, confDir, secretsDir, inputs, ... }:

{
	# The home.stateVersion option does not have a default and must be set
	home.stateVersion = "23.05";

	imports = [
		inputs.nix-index-database.hmModules.nix-index

		# all my programms with their own config
		../../programs/git.nix
		../../programs/lf/default.nix
		../../programs/alacritty.nix
		../../programs/bash.nix
		../../programs/emacs/default.nix
		../../programs/rofi/default.nix
		../../programs/zathura.nix
		../../programs/ssh.nix
		../../programs/neovim.nix
	];

	programs.nix-index.enable = false;
	programs.nix-index.enableBashIntegration = false;
	programs.nix-index.enableZshIntegration = false;

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

	home.sessionVariables = {
		EDITOR = "nvim";
	};

	home.sessionPath = [ "${workDir}/config/mybin" ];

	home.file = {
		".config/rclone".source = config.lib.file.mkOutOfStoreSymlink "${secretsDir}/rclone-conf";
		".xmobarrc".source = "${confDir}/misc/xmobar.hs";
		".subversion/config".text = ''
			[miscellany]
			global-ignores = node_modules
		''; # documentation for this config file: https://svnbook.red-bean.com/en/1.7/svn.advanced.confarea.html
	};

	home.packages = with pkgs; [
		neovim
		vim
		obsidian
		tree
		xorg.xkbcomp
		rofi
		haskellPackages.xmonad-extras
		haskellPackages.xmonad-contrib
		alacritty
		xorg.xev
		ntfs3g
		htop
		subversion
		pv
		blueman
		pavucontrol
		spotify
		flameshot
		nodejs
		neofetch
		networkmanagerapplet
		haskellPackages.xmobar
		dolphin
		mupdf
		zathura
		xclip
		rclone
		stalonetray
		killall
		nil
		file
		wstunnel
		playerctl
		alsa-utils
		usbutils
		pciutils
		lshw
		jmtpfs
		pmutils
		cntr
		signal-desktop
		element-desktop
		discord
		wireshark
		zip
		unzip
		arp-scan
		gparted
		lolcat
		android-tools
		moonlight-qt
		comma
		delta

		hack-font

		inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin

		# python....
		(python310.withPackages (p: with p; [
			pandas
			click
			click-aliases
		]))

		(busybox.overrideAttrs (final: prev: {
			# get only nslookup from busybox
			# because the less would overwrite the actuall less and the busybox does not have -r
			# it's a pfusch, but it works
			postInstall = prev.postInstall + ''
				echo ============ removing anything but nslookup ============
				mv $out/bin/nslookup $out/nslookup
				mv $out/bin/busybox $out/busybox

				rm $out/bin/*

				mv $out/nslookup $out/bin/nslookup
				mv $out/busybox $out/bin/busybox
			'';
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
	];
}


	#fonts.fonts = with pkgs; [
   	#hack-font
	#];
