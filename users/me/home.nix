
{ pkgs, workDir, confDir, secretsDir, inputs, ... }:

{
	imports = [
		../../common/programs/git.nix
		../../common/programs/lf/default.nix
		../../common/programs/alacritty.nix
		../../common/programs/bash.nix
		../../common/programs/emacs/default.nix
		../../common/programs/rofi/default.nix
		../../common/programs/zathura.nix
		../../common/programs/ssh.nix
		../../common/programs/neovim.nix

	];

	home-manager.backupFileExtension = "backup";

	home-manager.users.me = { config, pkgs, ... }: {
		/* The home.stateVersion option does not have a default and must be set */
		home.stateVersion = "23.05";

		imports = [
			inputs.nix-index-database.hmModules.nix-index
		];

		programs.nix-index.enable = false;
		programs.nix-index.enableBashIntegration = false;
		programs.nix-index.enableZshIntegration = false;
		#programs.command-not-found.enable = false;

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

	};

	fonts.fonts = with pkgs; [
   	hack-font
	];

	users.users.me = {
   	isNormalUser = true;
   	passwordFile = "${secretsDir}/main-user-pwd";
   	extraGroups = [ "networkmanager" "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
   	packages = with pkgs; [
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
			delta

			inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin

			# python....
    		(python310.withPackages (p: with p; [
      		pandas
				click
				click-aliases
    		]))

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
	};

# xmonad
	services.xserver.windowManager.xmonad = {
   	enable = true;
   	config = ../../misc/xmonad.hs;
   	#config = "${confDir}/misc/xmo";
   	enableContribAndExtras = true;
   	extraPackages = hpkgs: [
      	hpkgs.xmobar
      	#hpkgs.xmonad-screenshot
   	];
   	ghcArgs = [
      	"-hidir /tmp" # place interface files in /tmp, otherwise ghc tries to write them to the nix store
      	"-odir /tmp" # place object files in /tmp, otherwise ghc tries to write them to the nix store
      	#"-i${xmonad-contexts}" # tell ghc to search in the respective nix store path for the module
    	];
   };

	services.syncthing = {
   	enable = true;
   	user = "me";
   	#dataDir = "/home/";
   	configDir = "/home/me/.config/syncthing";
		extraFlags = ["-no-browser"];
		openDefaultPorts = true;
   	overrideDevices = true;     # overrides any devices added or deleted through the WebUI
   	overrideFolders = true;     # overrides any folders added or deleted through the WebUI
   	devices = {
   		"seb-phone" = { 
				id = builtins.readFile "${secretsDir}/syncthing-id-phone";
				#addresses = [ "tcp://192.168.200.24:22000" ];
			};
   		"seb-tab" = { 
				id = builtins.readFile "${secretsDir}/syncthing-id-tab";
				#addresses = [ "tcp://192.168.200.26:22000" ];
			};
    	};
    	folders = {
      	"priv-share" = {        # Name of folder in Syncthing, also the folder ID
        		path = "/home/me/work/priv-share";    # Which folder to add to Syncthing
        		#devices = [ "seb-phone" "seb-tab" ];      # Which devices to share the folder with
        		devices = [ "seb-phone" "seb-tab" ];      # Which devices to share the folder with
      	};
   	};
  };
  fileSystems."${workDir}/priv-share/things" = {
		device = "${workDir}/things";
  		options = [ "bind" ];
  };
  fileSystems."${workDir}/things/htl" = {
		device = "${workDir}/htl";
  		options = [ "bind" ];
  };
  fileSystems."${workDir}/things/diplomarbeit" = {
		device = "${workDir}/diplomarbeit";
  		options = [ "bind" ];
  };

}