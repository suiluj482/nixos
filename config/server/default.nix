{ home, pkgs, ... }:

{
  imports = [
    ../core
  ];
} //
home {
  home.packages = with pkgs; [
    borgbackup
    # protonmail-bridge
    pass
    gnupg
  ];
}
