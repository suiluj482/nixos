{ config, pkgs, homeContext, paths, ... }: 

{
  programs.niri.enable = true;
  
  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

} //
homeContext ({ config, ...}: {

  home.file.".config/niri" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${paths.nixos}/config/desktop/environment/custom/.config/niri";
  };
  
})