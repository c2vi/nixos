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

  programs.bash.loginShellInit = "nixos-wsl-welcome";
}
