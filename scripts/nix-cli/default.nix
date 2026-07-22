{ lib, rustPlatform, bash, pkgs, paths, ... }:

pkgs.writeShellApplication {
  name = "jnix";
  runtimeInputs = with pkgs; [ coreutils git ];
  text = ''
    TEMPLATES="${paths.templates}"
  '' + builtins.readFile ./nix-cli.sh;
}
