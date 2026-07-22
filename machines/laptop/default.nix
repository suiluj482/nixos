{ config, pkgs, inputs, home, ... }:

{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix

    ../../config

    ./wireguard.nix
  ];

}
