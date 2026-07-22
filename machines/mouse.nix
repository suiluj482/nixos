{ pkgs, ... }:

# https://github.com/PixlOne/logiops/wiki/Configuration
# https://github.com/NixOS/nixpkgs/issues/226575
{
  # Install logiops package
  environment.systemPackages = [ pkgs.logiops ];

  # Create systemd service
  systemd.services.logiops = {
    description = "An unofficial userspace driver for HID++ Logitech devices";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.logiops}/bin/logid";
    };
  };

  # Configuration for logiops
  environment.etc."logid.cfg".text = ''
    devices: ({
      name: "MX Master 3S";

      buttons: ({
        cid: 0xc3;
        action = {
          type: "Keypress";
          keys: ["KEY_A"];
        };
      });
    });
  '';
}