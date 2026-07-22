{ config, home, pkgs, ... }:

{
} 
// 
home {

  programs = {
    rofi = {
      enable = true;
      extraConfig = {
        show-icons = true;
        drun-match-fields = [ "name" ];
        matching = "prefix";
        terminal = "kitty";
      };
    };
    # walker = {
    #   enable = true;
    # };
    # anyrun = {
    #   enable = true;
    #   config = {
    #     plugins = [
    #       "${pkgs.anyrun}/lib/libapplications.so"
    #       "${pkgs.anyrun}/lib/libshell.so"
    #       "${pkgs.anyrun}/lib/librink.so"
    #       # "${pkgs.anyrun}/lib/libtranslate.so"
    #       "${pkgs.anyrun}/lib/libnix_run.so"
    #       "${pkgs.anyrun}/lib/libactions.so"
    #     ];
    #   };
    #   extraConfigFiles."actions.ron".text = ''
    #     Config(
    #       enable_power_actions: true,
    #     )
    #   '';
    # };
    # fuzzel
  };

}