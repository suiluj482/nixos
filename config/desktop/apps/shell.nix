{ config, pkgs, paths, system-name, home, naming-schema, ...}:

home {
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "rebootWin" ''
      nix-shell -p efibootmgr --run "sudo efibootmgr -n 0" && reboot
    '')

    (pkgs.writeShellScriptBin "zmk" ''
      cd $zmk && codium .
    '')
  ];
}