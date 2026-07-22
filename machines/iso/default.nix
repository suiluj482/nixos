{ config, lib, modulesPath, home, username, ...}:
# nix build .'#'nixosConfigurations."js-iso".config.system.build.isoImage
# config.system.build.sdImage for pi?
{
  imports = [
    # "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    # "${modulesPath}/installer/cd-dvd/channel.nix"

    ../../config
  ];

  networking = lib.mkForce {
    networkmanager = {
      enable = false;
    };
  };

  users.users."${username}" = {
    initialPassword = "password"; # initialHashedPassword
  };
}
