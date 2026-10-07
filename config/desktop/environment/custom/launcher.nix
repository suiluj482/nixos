{ inputs, homeContext, ... }:
{
  nixpkgs.overlays = [ inputs.huffi.overlays.default ];
}
//
homeContext ({ config, inputs, ...}: {

  imports = [ inputs.huffi.homeManagerModules.huffi ];

  programs.huffi = {
    enable = true;
    settings = {
      engine.provider.builtin.actions.extra.entries = [
        {
          title = "reboot windows";
          terminal_exec = [ "rebootWin" ];
          keywords = [ "nixos" ];
          icon = "utilities-terminal";
        }
        {
          title = "zmk";
          terminal_exec = [ "zmk" ];
          keywords = [ "keyboard" ];
          icon = "utilities-terminal";
        }
        {
          title = "nix config";
          terminal_exec = [ "nixos" "open" ];
          keywords = [ "nixos" ];
          icon = "utilities-terminal";
        }
        {
          title = "rebuild";
          terminal_exec = [ "nixos" "rebuild" ];
          keywords = [ "nixos" ];
          icon = "utilities-terminal";
        }
        {
          title = "update";
          terminal_exec = [ "nixos" "update" ];
          keywords = [ "nixos" ];
          icon = "utilities-terminal";
        }
        {
          title = "shutdown";
          terminal_exec = [ "nixos" "shutdown" ];
          keywords = [ "nixos" ];
          icon = "utilities-terminal";
        }
      ];
    };
  };


  # programs = {
  #   # rofi = {
  #   #   enable = true;
  #   #   extraConfig = {
  #   #     show-icons = true;
  #   #     drun-match-fields = [ "name" ];
  #   #     matching = "prefix";
  #   #     terminal = "kitty";
  #   #   };
  #   # };
  #   # walker = {
  #   #   enable = true;
  #   # };
  #   # anyrun = {
  #   #   enable = true;
  #   #   config = {
  #   #     plugins = [
  #   #       "${pkgs.anyrun}/lib/libapplications.so"
  #   #       "${pkgs.anyrun}/lib/libshell.so"
  #   #       "${pkgs.anyrun}/lib/librink.so"
  #   #       # "${pkgs.anyrun}/lib/libtranslate.so"
  #   #       "${pkgs.anyrun}/lib/libnix_run.so"
  #   #       "${pkgs.anyrun}/lib/libactions.so"
  #   #     ];
  #   #   };
  #   #   extraConfigFiles."actions.ron".text = ''
  #   #     Config(
  #   #       enable_power_actions: true,
  #   #     )
  #   #   '';
  #   # };
  #   # fuzzel
  # };

})