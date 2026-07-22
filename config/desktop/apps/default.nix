{ ... }:

{
  imports = [
    ./crypt.nix
    ./programs.nix
    ./flatpak.nix
    ./shell.nix
    ./vpn.nix
    ./gaming.nix
    ./dev
  ];

  services.blueman.enable = true;
}