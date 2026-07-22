{ inputs, config, pkgs, self, home, paths, ... }:
home {
  imports = [ 
    "${self}/scripts/jcrypt/module.nix" 
  ];

  programs.jcrypt = {
    enable = true;

    mountBase   = "/mnt/crypt";
    fileManager = "nautilus";
    symlink     = true;

    vaults = {
      akten = "${paths.documents}/akten/other/encrypted";
      notes = "${paths.documents}/notes/other/encrypted";
      system = "${paths.documents}/system/other/encrypted";
      media = "${paths.js}/media/other/encrypted";
    };
  };
}