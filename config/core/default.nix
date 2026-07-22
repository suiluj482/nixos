{ ... }: 

{
  imports = [
    ./applications
    ./nix
    ./international.nix
    ./networking.nix
    ./sudo.nix
    ./user.nix
  ];

  services.fwupd.enable = true;
}