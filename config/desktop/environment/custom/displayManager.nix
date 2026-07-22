{ config, pkgs, ... }: 

{
  # environment.systemPackages = [ pkgs.adwaita-icon-theme ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;

    # settings = {
    #   Theme = {
    #     CursorTheme = "Adwaita";
    #     CursorSize = 24;
    #   };
    # };
  };
  services.displayManager.defaultSession = "niri";
}