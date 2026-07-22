{ config, home, pkgs, ... }:

{
  imports = [
    ./custom
    ./kde.nix
    # ./gnome.nix
    # ./cosmic.nix
  ];

  services.xserver = { # X11
    enable = true;
    xkb = {
      layout = "de";
      variant = "nodeadkeys";
    };
  };

  services = {
    gnome.gnome-keyring.enable = true;
  };
  security.pam.services.login.enableGnomeKeyring = true;

} 
// 
home {

  home.packages = with pkgs; [ 
    gcr # Provides org.gnome.keyring.SystemPrompter
  ]; 
  services = {
    gnome-keyring = {
      enable = true;
      components = [
        "pkcs11"
        "secrets"
        "ssh"
      ];
    };
  };

  programs = {
  };

}
