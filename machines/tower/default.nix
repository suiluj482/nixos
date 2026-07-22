{ config, pkgs, inputs, home, ... }:

{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./nvidia.nix

    ../backupSSD.nix

    ../../config
    
    ./ai.nix

    ./wakeonlan.nix
  ];

}
