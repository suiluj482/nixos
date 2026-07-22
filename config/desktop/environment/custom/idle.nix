{ pkgs, home, paths, ...}:  
  
home {
  #### idle
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";  # don't spawn multiple instances
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "niri msg action power-on-monitors";
      };
      listener = [
        {
          timeout = 300;  # 5 min: turn off monitors
          on-timeout = "niri msg action power-off-monitors";
          on-resume = "niri msg action power-on-monitors";
        }
        {
          timeout = 330;  # 5.5 min: lock
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900;  # 15 min: suspend
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          path = "${paths.nixos}/data/pictures/hyprlock.png";
        }
      ];
    };
  };
}