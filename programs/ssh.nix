{ secretsDir, ... }:
{
	programs.ssh = {
		enable = true;
		includes = [ "./current_rpi_config" ];
		matchBlocks = {
			"github.com" = {
				hostname = "github.com";
				identityFile = "${secretsDir}/private-key-main";
			};
			hpm = {
				hostname = "192.168.1.56";
				user = "root";
			};

			servers = {
				hostname = "192.168.1.3";
				user = "server";
				identityFile = "${secretsDir}/private-key-main";
			};

			server = {
				hostname = "192.168.1.3";
				user = "admin";
				identityFile = "${secretsDir}/private-key-main";
			};

			ocia = {
				hostname = "140.238.212.229";
				user = "root";
				identityFile = "${secretsDir}/private-key-ocia";
			};

			ocib = {
				hostname = "140.238.211.43";
				user = "root";
				identityFile = "${secretsDir}/private-key-ocib";
			};
		};
	};

	home.file.".ssh/rpi/local".text = ''
		Host config
			HostName 192.168.1.2
			User config
			Port 49388
			AddKeysToAgent yes
			#UseKeychain yes
			IdentityFile ${secretsDir}/private-key-main
			#RemoteCommand cd /svn/config; bash

		Host rpi
			HostName 192.168.1.2
			User admin
			Port 49388
			AddKeysToAgent yes
			#UseKeychain yes
			IdentityFile ${secretsDir}/private-key-main

		Host files
			HostName 192.168.1.2
			User files
			Port 49388
			AddKeysToAgent yes
			#UseKeychain yes
			IdentityFile ${secretsDir}/private-key-main

		Host rpis
			HostName 192.168.1.2
			User server
			Port 49388
			AddKeysToAgent yes
			#UseKeychain yes
			IdentityFile ${secretsDir}/private-key-main
	'';

	home.file.".ssh/rpi/remote".text = ''
		Host config
			HostName sebastian.dns.army
			User config
			Port 49388
			AddKeysToAgent yes
			#UseKeychain yes
			IdentityFile ${secretsDir}/private-key-main
			#RemoteCommand cd /svn/config; bash

		Host rpi
			HostName sebastian.dns.army
			User admin
			Port 49388
			AddKeysToAgent yes
			#UseKeychain yes
			IdentityFile ${secretsDir}/private-key-main

		Host files
			HostName sebastian.dns.army
			User files
			Port 49388
			AddKeysToAgent yes
			#UseKeychain yes
			IdentityFile ${secretsDir}/private-key-main

		Host rpis
			HostName sebastian.dns.army
			User server
			Port 49388
			AddKeysToAgent yes
			#UseKeychain yes
			IdentityFile ${secretsDir}/private-key-main
	'';

	home.file.".ssh/rpi/wstunnel".text = ''
		Host config
			HostName localhost
			User config
			Port 55555
			AddKeysToAgent yes
			#UseKeychain yes
			IdentityFile ${secretsDir}/private-key-main
			#RemoteCommand cd /svn/config; bash

		Host rpi
			HostName localhost
			User admin
			Port 55555
			AddKeysToAgent yes
			#UseKeychain yes
			IdentityFile ${secretsDir}/private-key-main

		Host files
			HostName localhost
			User files
			Port 55555
			AddKeysToAgent yes
			#UseKeychain yes
			IdentityFile ${secretsDir}/private-key-main

		Host rpis
			HostName localhost
			User server
			Port 55555
			AddKeysToAgent yes
			#UseKeychain yes
			IdentityFile ${secretsDir}/private-key-main
	'';
}
