{ config, lib, pkgs, ... }:

let
  cfg = config.programs.jcrypt;

  jcrypt = pkgs.callPackage ./default.nix {};

  configFile = (pkgs.formats.toml { }).generate "config.toml" (
    {
      mount_base   = cfg.mountBase;
      file_manager = cfg.fileManager;
      symlink      = cfg.symlink;
      vaults       = cfg.vaults;
    }
  );

in
{
  options.programs.jcrypt = {

    enable = lib.mkEnableOption "jcrypt gocryptfs vault manager";

    src = lib.mkOption {
      type = lib.types.path;
      default = ./.;
      description = ''
        Path to the jcrypt source tree. Defaults to the directory containing
        this module file. Override when importing from a flake input.
      '';
      example = lib.literalExpression "inputs.jcrypt";
    };

    mountBase = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/crypt";
      description = "Directory under which vault mount points are created.";
      example = "/run/user/1000/crypt";
    };

    fileManager = lib.mkOption {
      type = lib.types.str;
      default = "xdg-open";
      description = "File manager launched by <literal>jcrypt mount --open</literal>.";
      example = "nautilus";
    };

    symlink = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        When enabled, mounting a vault whose encrypted path ends with
        <literal>encrypted</literal> creates a sibling symlink ending with
        <literal>decrypted</literal> pointing at the live mount point.
        The symlink is removed on unmount.
      '';
    };

    vaults = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Attribute set mapping vault names to their encrypted directory paths.";
      example = lib.literalExpression ''
        {
          notes  = "''${config.home.homeDirectory}/documents/notes/other/encrypted";
          system = "''${config.home.homeDirectory}/documents/system/other/encrypted";
        }
      '';
    };

  };

  config = lib.mkIf cfg.enable {

    home.packages = [ jcrypt pkgs.gocryptfs ];

    xdg.configFile."jcrypt/config.toml".source = configFile;

  };
}
