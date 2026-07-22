{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.jsync;
  
  jsync = pkgs.callPackage ./default.nix {};
in
{
  options.programs.jsync = {
    enable = mkEnableOption "jsync - a simple file synchronization tool";

    src = lib.mkOption {
      type = lib.types.path;
      default = ./.;
      description = ''
        Path to the jsync source tree. Defaults to the directory containing
        this module file. Override when importing from a flake input.
      '';
      example = lib.literalExpression "inputs.jsync";
    };

    # package = mkOption {
    #   type = types.package;
    #   default = jsync;
    #   defaultText = literalExpression "jsync";
    #   description = "The jsync package to install.";
    # };
  };

  config = mkIf cfg.enable {
    home.packages = [ jsync pkgs.rsync ];
  };
}