{ config, homeContext, paths, ... }: 

homeContext ({ config, ...}: {

  programs.waybar.enable = true;

  home.file.".config/waybar" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${paths.nixos}/config/desktop/environment/custom/.config/waybar";
  };

})