{ config, home, pkgs, paths, ... }:

{
  imports = [
    ./niri.nix
    ./launcher.nix
    ./displayManager.nix
    ./waybar.nix
    ./idle.nix
    ./pipewire.nix
    ./clipboard.nix
    ./quickshell.nix
    ./defaultApplications.nix
  ];

  # wm: niri
  # launcher: rofi
  # login: sddm
  # notifications: mako
  # idle / locker: hypridle, hyprlock
  # bar: quickshell
  
  # todo:
  #   clipboard
  #   screenshots
  #   desktop portal

  # niri meta down/up shortcuts


  ### portal
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk   # generic fallback, file picker, etc.
      pkgs.xdg-desktop-portal-wlr   # screencopy/screencast for wlroots
    ];
    # Explicit config to avoid ambiguity between backends
    config = {
      niri = {
        # default = [ "gtk" ];
        "org.freedesktop.impl.portal.Screencast" = [ "wlr" ];
      };
      # fallback for any other session
      common = {
        default = [ "gtk" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    ddcutil
    brightnessctl
  ];

} 
// 
home {

  #### notifications
  services.mako = {
    enable = true;
    settings = {
      margin = "30";
      default-timeout = 5000;
    };
  };
  # services.swaync = {
  #   enable = true;
  # };

}
