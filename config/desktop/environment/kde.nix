{ pkgs, inputs, home, paths, ... }:
{
  services = {
    desktopManager.plasma6.enable = true;
    # displayManager.plasma-login-manager.enable = true;
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
  ];
  environment.systemPackages = with pkgs.kdePackages; [
    discover
    kcalc
    kcharselect
    kclock
    kcolorchooser
    kolourpaint
    ksystemlog
    isoimagewriter
    partitionmanager
  ];
  # wayland-utils
  # wl-clipboard
  programs.kdeconnect.enable = true;
  networking.firewall = rec {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
} 
//
home {
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  services.kdeconnect.enable = true;

  home.packages = [ pkgs.papirus-icon-theme ];

  programs.plasma = {
    enable = true;
    # overrideConfig = true;

    kscreenlocker.appearance.showMediaControls = false;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "Papirus-Dark";
      wallpaper = "${paths.nixosData}/pictures/lion.jpg";
    };

    # panels = [
    #   {
    #     location = "top";
    #   }
    # ];
  };
}