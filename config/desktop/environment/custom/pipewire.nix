{ config, pkgs, home, ... }:

{

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;  # only if you need JACK apps
  };

}
//
home {

  home.packages = with pkgs; [
    pwvucontrol   # or pavucontrol / qpwgraph
  ];

}