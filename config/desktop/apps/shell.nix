{ config, pkgs, paths, system-name, home, naming-schema, ...}:

home {
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "pi" ''
      ssh 192.168.178.80
    '')

    (pkgs.writeShellScriptBin "rebootWin" ''
      nix-shell -p efibootmgr --run "sudo efibootmgr -n 0" && reboot
    '')
    (pkgs.makeDesktopItem {
      name = "rebootWin";
      exec = "rebootWin";
      desktopName = "Reboot Windows";
      categories = [ "Utility" ];
      terminal = true;
      icon = "utilities-terminal";
    })

    (pkgs.writeShellScriptBin "zmk" ''
      cd $zmk && codium .
    '')
    (pkgs.makeDesktopItem {
      name = "zmk";
      exec = "zmk";
      desktopName = "zmk";
      categories = [ "Utility" ];
      terminal = false;
      icon = "utilities-terminal";
    })
    
    (pkgs.makeDesktopItem {
      name = "nixConfig";
      exec = "nixos open";
      desktopName = "nixConfig";
      categories = [ "Utility" ];
      terminal = false;
      icon = "utilities-terminal";
    })
    (pkgs.makeDesktopItem {
      name = "rebuild";
      exec = "nixos rebuild";
      desktopName = "rebuild";
      categories = [ "Utility" ];
      terminal = true;
      icon = "utilities-terminal";
    })
    (pkgs.makeDesktopItem {
      name = "update";
      exec = "nixos update";
      desktopName = "update";
      categories = [ "Utility" ];
      terminal = true;
      icon = "utilities-terminal";
    })
    (pkgs.makeDesktopItem {
      name = "shutdown";
      exec = "nixos shutdown";
      desktopName = "shutdown";
      categories = [ "Utility" ];
      terminal = true;
      icon = "utilities-terminal";
    })
  ];
}