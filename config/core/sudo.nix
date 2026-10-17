{ config, pkgs, username, ...}:

{
  security.sudo = {
    extraRules = [
      {
        users = [ username ];
        commands = [
          {
            command = "/run/current-system/sw/bin/efibootmgr -n 0";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
    extraConfig = ''
      Defaults pwfeedback
    '';
  };
}