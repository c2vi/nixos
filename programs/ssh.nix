{ secretsDir, ... }:
{
	programs.ssh = {
		enable = true;
		#includes = [ "./current_rpi_config" ];
		matchBlocks = {
      "*" = {
				identityFile = "${secretsDir}/private-key";
      };
			"github.com" = {
				hostname = "github.com";
				identityFile = "${secretsDir}/private-key-main";
			};
      rpi = {
        port = 49388;
        user = "me";
        hostname = "192.168.1.2";
      };
      lush = {
        user = "me";
        hostname = "192.168.5.5";
      };
      phone = {
        user = "u0_a345";
        hostname = "192.168.44.1";
        port = 8022;
				identityFile = "${secretsDir}/private-key-main";
      };
      uwu = {
        user = "sebastian";
				identityFile = "${secretsDir}/private-key-main";
        hostname = "192.168.122.56";
      };
      acern = {
        user = "me";
				identityFile = "${secretsDir}/private-key-main";
        hostname = "192.168.1.5";
        port = 2222;
      };
			hpm = {
				#hostname = "192.168.1.6";
				user = "me";
				identityFile = "${secretsDir}/private-key-main";
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

   home.file.".ssh/known_hosts".force = true;
   home.file.".ssh/known_hosts".text = ''
      hpm ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+FpaNOf+ao6RCa6e43vAHFcQZTGu45rIqAG3Vx0/M8
      lush ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFevbQp0XTZOVFZTDMKzgsZn4NNEIN+SFMqUhSbF5WFo
      github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
      rpi ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOX+6B6Axx7AqgCm1H1rrou/3yOLeOLcTd8s0In0mOIY
      phone ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHxg0HKtGAkwymll8r17d9cXdt40dJgRkSAzB699pWke+edne4Ildcnbde2yle01nEL7GOg92vh5t1sh6vkCzJQ=
   '';

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
