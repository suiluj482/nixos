{ config, pkgs, username, ...}:

{
  security.sudo = {
    # extraRules = [
    #   {
    #     users = [ username ];
    #     commands = [
    #       {
    #         command = "${pkgs.efibootmgr}/bin/efibootmgr -n 0";
    #         options = [ "NOPASSWD" ];
    #       }
    #     ];
    #   }
    # ];
    extraConfig = ''
      Defaults pwfeedback
    '';
  };
}