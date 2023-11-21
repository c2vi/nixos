{ pkgs, inputs, ...}:
{
  imports = [
    inputs.nix-wsl.nixosModules.wsl
    ./users/me/headless.nix
    ./common/all.nix
    ./common/nixos-headless.nix
  ];

  wsl.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 2222 ];

    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users.me.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjgXf9S9hxjyph2EEFh1el0z4OUT9fMoFAaDanjiuKa me@main"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWsqiz0gEepvPONYxqhKKq4Vxfe1h+jo11k88QozUch me@bitwarden"
  ];

  programs.bash.loginShellInit = "nixos-wsl-welcome";
}
