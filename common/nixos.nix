{}:

# config that i use on all my hosts, that run native nixos
# excluding for example my phone phone

{ 

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
	console = {
		font = "Lat2-Terminus16";
		#keyMap = "at";
		useXkbConfig = true; # use xkbOptions in tty.
	};

}

