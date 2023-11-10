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
      hpm ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbIgfPvt3NUWLxAv0jvWv7IUXHaR7k5M7Z1Kz24K+ZYuPRboHWNbcqGjik0kWDGwXejtTLkyiThK641Q0ffYp3bumKL3b3fBNLoRwHfVMHT9ZuM7e9nALJRa+0keBPTcO9kHliYJlEBiF4jHSZhVDPnZ0Qskg2m94AipKrhUC4KIbLFAERlDnFTxw8LTnzdfzs/n/80zH5tKq1TSlYd2XBIMlzYwxTGEgItifierQhncleVVUJ8IPLsSulMgCQu3BA8cGmdApbSe41FIieIsYzLEtJVnCRt0PymdYa1NdyngJ8ZWyXo6JjTCEHWv35WW05Oiw/tMyUDQoeebACe+Ve9WsYdb+0uttAQWZauODimGY/kRrwy2jCqDRoKjq+rWmTgLsXzuTr7sZ2nmlCIs0XkTXzwduo6ZJ1uNHYWTIjnC1in5uB5TMBlVQxEOdeLOIB9reHP7dajguCGLsOg/a7W/kx181w5MdXq5e9ch7Hp2eC9wBbwcy4EtmX0GAYSPV4GWGwunU92TFE5kg7haV23sdRfLf6ARrDLtsfvTzvoWWQFiO7AgrcOdSQtMUM0/egLUj0lg/A5fxV1pfXvxAF7TquNJCXhDYczCbej4PQM2WBe2eGY+BjY3gDHtUdzWEqhH+b6/Cz78yAa4aSWDB8D+Ejv0N0BZLaImYQhma5PQ==
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
