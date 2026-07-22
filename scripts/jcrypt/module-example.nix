# Example: how to use jcrypt.nix in your home-manager configuration.
# Adapt paths to match your flake layout.

{ config, lib, pkgs, ... }:

{
  imports = [ ./jcrypt.nix ];

  programs.jcrypt = {
    enable = true;

    mountBase   = "/mnt/crypt";
    fileManager = "nautilus";
    symlink     = true;

    vaults = {
      akten  = "${config.home.homeDirectory}/documents/akten/other/encrypted";
      notes  = "${config.home.homeDirectory}/documents/notes/other/encrypted";
      system = "${config.home.homeDirectory}/documents/system/other/encrypted";
      media  = "${config.home.homeDirectory}/js/media/other/encrypted";
    };
  };
}
