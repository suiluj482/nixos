{ config, pkgs, home, paths, ...}:

# todo nix way
{
  # flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  services.flatpak.enable = true;
} //
home {
    home.packages = with pkgs; [
        gnome-software
    ];
}