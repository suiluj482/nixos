{ config, home, pkgs, ... }:

{
  imports = [
    ./environment
    ./theming
    ./apps
  ];

} 
