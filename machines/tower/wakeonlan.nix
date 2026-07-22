{ config, lib, pkgs, home, ... }:
{
  networking = {
    interfaces = {
      enp11s0 = {
        wakeOnLan.enable = true;
      };
    };
    firewall = {
      allowedUDPPorts = [ 9 ];
    };
  };
}