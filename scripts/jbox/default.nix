{ lib, rustPlatform, bash, pkgs, paths, ... }:

pkgs.writeShellApplication {
  name = "jbox";
  runtimeInputs = with pkgs; [ coreutils git ];
  text = builtins.readFile ./jbox.sh;
}
