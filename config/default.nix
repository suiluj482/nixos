{ config, lib, pkgs, home, ... }: {
  imports = [
    ./core
    ./desktop
  ];
}
