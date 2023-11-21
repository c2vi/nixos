{ secretsDir, ... }: let
  main-pub = builtins.readFile "${secretsDir}/wg-pub-main";
  rpi-pub = builtins.readFile "${secretsDir}/wg-pub-rpi";
  lush-pub = builtins.readFile "${secretsDir}/wg-pub-lush";
  hpm-pub = builtins.readFile "${secretsDir}/wg-pub-hpm";
  acern-pub = builtins.readFile "${secretsDir}/wg-pub-acern";
  phone-pub = builtins.readFile "${secretsDir}/wg-pub-phone";
in
{
  "wireguard-peer.${main-pub}" = {
    endpoint = "192.168.1.40:51820";
    persistent-keepalive = "25";
    allowed-ips = "0.0.0.0";
  };
  "wireguard-peer.${rpi-pub}" = {
    endpoint = "192.168.1.2:49390";
    persistent-keepalive = "25";
    allowed-ips = "0.0.0.0";
  };
  "wireguard-peer.${lush-pub}" = {
    endpoint = "192.168.5.5:51820";
    persistent-keepalive = "25";
    allowed-ips = "0.0.0.0";
  };
}




################### old config #########################

/*
{ secretsDir, ... }: [
  #### local ####
  {
    name = "rpi";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-rpi";
    allowedIPs = [ "10.1.1.0/24" ];
    endpoint = "192.168.1.2:49390, c2vi.dev:49389";
    persistentKeepalive = 25;
  }
  {
    name = "main-local";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-main";
    allowedIPs = [ "10.1.1.0/24" ];
    endpoint = "192.168.1.40:51820";
    persistentKeepalive = 25;
  }
  {
    name = "lush-local";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-lush";
    allowedIPs = [ "10.1.1.0/24" ];
    endpoint = "192.168.5.5:51820";
    persistentKeepalive = 25;
  }





  /*
  {
    name = "main";
    publicKey = "${secretsDir}"/wg-public-main;
    allowedIPs = [ "10.1.1.2/24" ];
  }
  {
    name = "phone";
    publicKey = "${secretsDir}"/wg-public-phone;
    allowedIPs = [ "10.1.1.3/24" ];
  }
  {
    name = "hpm";
    publicKey = "${secretsDir}"/wg-public-hpm;
    allowedIPs = [ "10.1.1.6/24" ];
  }
  {
    name = "main";
    publicKey = "${secretsDir}"/wg-public-main;
    allowedIPs = [ "10.1.1.2/24" ];
  }
  */
