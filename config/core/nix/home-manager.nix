{ config, inputs, specialArgs, pkgs, ...}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager 
  ];
  
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.extraSpecialArgs = specialArgs;

  environment.systemPackages = with pkgs; [
    home-manager
  ];

  # backup overwritten files
  # home-manager.backupFileExtension = true;
  # home-manager.backupCommand = let
  #   backupScript = pkgs.writeShellScript "hm-backup" ''
  #     timestamp=$(date +%Y%m%dT%H%M)
  #     dest="/mnt/storage/backup/nix/home-manager/$timestamp$1"
  #     mkdir -p "$(dirname "$dest")"
  #     mv "$1" "$dest"
  #     echo "Backed up $1 to $dest"
  #   '';
  # in "${backupScript}";

} 
