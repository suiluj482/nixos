{ config, lib, pkgs, home, ... }:
{
  # community cache for nvidia packages
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };


  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    # Enable OpenGL
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {

      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
      # of just the bare essentials.
      powerManagement.enable = true;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      open = true;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # # Regular Docker
  # virtualisation.docker.daemon.settings.features.cdi = true;
  # # Rootless
  # virtualisation.docker.rootless.daemon.settings.features.cdi = true;
} //
home {
  home.packages = with pkgs; [
    nvitop
  ];


  # hyprland

  # wayland.windowManager.hyprland.settings = {
  #   cursor.no_hardware_cursors = true;
  #   # librewolf freezing could be an issue, see https://github.com/hyprwm/Hyprland/issues/7327
  #   # see https://github.com/hyprwm/Hyprland/issues/4857
  #   # issues to keep in mind: https://github.com/hyprwm/Hyprland/issues/7560 https://github.com/hyprwm/Hyprland/issues/7205
  #   render.direct_scanout = false;
  #   # fixes
  #   # https://github.com/Rdeisenroth/dotfiles/blob/c3c02c9ee95d99883dfe09c5fb64195abae89a6f/dot_config/hypr/environment.conf
  #   # thank you ruben for making the nvidia wayland journey a bit less painful <3
  #   env = [
  #     # Nvidia
  #     "LIBVA_DRIVER_NAME,nvidia"
  #     "XDG_SESSION_TYPE,wayland"
  #     "GBM_BACKEND,nvidia-drm"
  #     "__GLX_VENDOR_LIBRARY_NAME,nvidia"

  #     "NVD_BACKEND,direct"

  #     "ELECTRON_OZONE_PLATFORM_HINT,auto"
  #     # tearing
  #     "WLR_DRM_NO_ATOMIC,1"
  #     "__GL_GSYNC_ALLOWED,1"
  #     "__GL_VRR_ALLOWED,1"
  #     # qt
  #     "QT_AUTO_SCREEN_SCALE_FACTOR,1"
  #     "QT_QPA_PLATFORM,wayland;xcb"
  #     "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
  #     "QT_QPA_PLATFORMTHEME,qt5ct:qt6ct"
  #     # Firefox Hardware accelleration stuff
  #     "MOZ_DISABLE_RDD_SANDBOX, 1"
  #     "EGL_PLATFORM, wayland"
  #     "MOZ_ENABLE_WAYLAND, 1"
  #     # java
  #     "_JAVA_AWT_WM_NONEREPARENTING,1"
  #     # other
  #     "CLUTTER_BACKEND,wayland"
  #     "GTK_USE_PORTAL,1"
  #   ];
  # };
}