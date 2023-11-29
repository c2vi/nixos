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
      phone = {
        user = "u0_a345";
        port = 8022;
      };
      tab = {
        user = "nix-on-droid";
        port = 8022;
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
      [tab]:8022 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdwFZf3IRa4YZyrNseofTRIDbkmdMiIXa3Gxs7wFzZN+ICwXeipfqV1Lh9C1sI4YnRIqfZlCSU+SE2dqVoQB6Uj64cdLrdslHYvgsR9PY3vVtrYypGfE1XTkLvD516x4mFofo22A9j8fK95fcMwpWLtNnv9SVBIT3V+4fUlbRCngdJ1V2cOd41JIwBrIxmRJ6X5v/SEqajmnVneqEmsqGgGA7JBJBCMSz5wwmZzWrTpzwj4SAD5b1z/R12DZfFHmgJCZYcMbjDgUiD5khsOwCCflH8DtO41PkOZRqDlpPPT9al7qhhESwxE6w5gIvaVh6HJljSCNw9OCQWONotv3gF9tVs6sZXsWxRZ2R0oIeA3rnM+mZxEtxElc2MKLVlsQ9SM2Xcr3J4Y43cWm7m03cDOz+iZecxs2qKAgn5Au72fudapDAtiCuYjKlMGEgbWX3CmxL0n/Uo32yfTRXnEHWMzXezmdGsuHUzk/sHTL8z5RVyzIBNl2HGlhldFbATuwRxXyBW9JIuEll+rW9Jm0MvpT3KoD/Q5aXDVH+21l6SSNBcjvZu00WNiYDD+gFR4BlewobtacGNOR4ErjxVZ10d8p6S5smadmo/RmbjhrVJK8EzigJPsVxEEjtuVq+jAQCvLTZCpEyDF/cBv60vIu4CyZkoAq1UaL64m7nIhR/8Yw==
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
