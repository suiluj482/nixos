{ config, paths, ... }:

let
  projectDir = "${paths.nixos}/scripts/ha-linux";
in
{
  systemd.user.services.ha-linux = {
    Unit = {
      Description = "Home Assistant linux client";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${projectDir}/target/release/ha-linux";
      WorkingDirectory = projectDir;
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}