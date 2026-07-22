{ config, lib, pkgs, home, ...}:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  environment.systemPackages = with pkgs; [
    # lutris
  ];
} // 
home {
  home.packages = with pkgs; [
    steam
    mindustry
    # lutris
  ];
}