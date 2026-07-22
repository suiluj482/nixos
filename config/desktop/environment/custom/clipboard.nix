{ config, pkgs, home, ... }:

home {

  home.packages = with pkgs; [
    wl-clipboard
  ];

  programs.fuzzel.enable = true;
  services.cliphist.enable = true;

}