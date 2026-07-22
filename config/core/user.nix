{ config, pkgs, username, home, ...}:

{
  users.users = {
    "${username}" = {
      isNormalUser = true;
      description = "${username}";
      extraGroups = ["networkmanager" "wheel" "dialout"];
    };
  };
} // home {
  home = {
    username = username;
    homeDirectory = "/home/${username}";
  };
}
