{ config, pkgs, self, homeContext, paths, ... }: 

homeContext ({ config, ...}: {

  imports = [
    "${self}/scripts/ha-linux/config.nix"
  ];

  home.packages = [ pkgs.quickshell ];

  home.file.".config/quickshell" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${paths.nixos}/config/desktop/environment/custom/.config/quickshell";
  };
  
})