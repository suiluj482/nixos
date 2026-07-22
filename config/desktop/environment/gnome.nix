{ config, pkgs, home, paths, ...}:

{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs; [ 
    file-roller # archive manager
    epiphany    # web browser
  ];
} //
home {
  home = {
    file = {
        ".local/share/sounds/__custom/index.theme" = {
            text = 
            ''
            [Sound Theme]
            Name=__custom
            Inherits=freedesktop
            Directories=.
            '';
        };
        ".local/share/sounds/__custom/screen-capture.disabled".text = "";
    };

    packages = with pkgs; [ 
        gnome-tweaks     
        gnome-extension-manager
        gnomeExtensions.launch-new-instance
        gnomeExtensions.caffeine
        gnomeExtensions.space-bar
        gnomeExtensions.clipboard-history
        gnomeExtensions.media-controls
        gnomeExtensions.removable-drive-menu
        # gnomeExtensions.reboottouefi
        # gnomeExtensions.custom-reboot
        # gnomeExtensions.auto-move-windows
        gnomeExtensions.user-themes
        gnomeExtensions.app-icons-taskbar
        # gnomeExtensions.fly-pie
        # gnomeExtensions.arrange-windows
        # gnomeExtensions.tiling-assistant
    ];
  };


  dconf.settings = {
    # ...
    "org/gnome/desktop/interface".monospace-font-name = "Monospace 10";
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden=true;
    };
    "org/gnome/nautilus/preferences" = {
      show-create-link=true;
      show-delete-permanently=true;
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "codium.desktop"
        "org.gnome.Console.desktop"
        "obsidian.desktop"
        "org.gnome.Nautilus.desktop"
        "element-desktop.desktop"
      ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita";
      #enable-hot-corners = false;
    };
    "org/gnome/desktop/background" = {
      #picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-l.png";
      picture-uri-dark = "file://${paths.nixosData}/pictures/lion.jpg";
    };
    "org/gnome/desktop/sound" = {
      theme-name = "__custom";
    };
    # "org/gnome/desktop/screensaver" = {
    #   picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-d.png";
    #   primary-color = "#3465a4";
    #   secondary-color = "#000000";
    # };

    "org/gnome/shell/keybindings" = {
      toggle-message-tray = ["disabled"];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      mic-mute = ["<Super>k"];
    };
    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
      switch-to-application-5 = [];
      switch-to-application-6 = [];
      switch-to-application-7 = [];
      switch-to-application-8 = [];
      switch-to-application-9 = [];
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
      switch-to-application-5 = [];
      switch-to-application-6 = [];
      switch-to-application-7 = [];
      switch-to-application-8 = [];
      switch-to-application-9 = [];

      show-desktop = ["<Super>d"];

      move-to-monitor-left = [];
      move-to-monitor-right = [];
      move-to-workspace-left = ["<Shift><Super>Left"];
      move-to-workspace-right = ["<Shift><Super>Right"];
      witch-windows = ["<Alt>Tab"];
      switch-windows-backward = ["<Shift><Alt>Tab"];
      switch-applications = ["<Super>Tab"];
      switch-applications-backward = ["<Shift><Super>Tab"];
      close = ["<Super>q" "<Alt>F4"];

      unmaximize = [];

      switch-to-workspace-2 = ["<Super>2"];

      move-to-workspace-10 = ["<Super><Shift>0"];
      move-to-workspace-1 = ["<Super><Shift>1"];
      move-to-workspace-2 = ["<Super><Shift>2"];
      move-to-workspace-3 = ["<Super><Shift>3"];
      move-to-workspace-4 = ["<Super><Shift>4"];
      move-to-workspace-5 = ["<Super><Shift>5"];
      move-to-workspace-6 = ["<Super><Shift>6"];
      move-to-workspace-7 = ["<Super><Shift>7"];
      move-to-workspace-8 = ["<Super><Shift>8"];
      move-to-workspace-9 = ["<Super><Shift>9"];
    };
    "org/gnome/mutter".dynamic-workspaces = false;
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 10;
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;

      disabled-extensions = ["disabled"];
      # `gnome-extensions list` for a list
      enabled-extensions = [
          "arrangeWindows@sun.wxg@gmail.com"
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
          "caffeine@patapon.info"
          "clipboard-history@alexsaveau.dev"
          "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
          "mediacontrols@cliffniff.github.com"
          # "reboottouefi@ubaygd.com"
          "customreboot@nowa1545"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
          "space-bar@luchrioh"
          "tiling-assistant@leleat-on-github"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "flypie@schneegans.github.com"
          # "user-theme@gnome-shell-extensions.gcampax.github.com"
          # "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
          # "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
          # "drive-menu@gnome-shell-extensions.gcampax.github.com"
          # "space-bar@luchrioh"
      ];
    };
    "org/gnome/shell/extensions/clipboard-history" = {
      toggle-menu = ["<Super>v"];
    };
    "org/gnome/shell/extensions/tiling-assistant" = {
      enable-raise-tile-group = false;
      dynamic-keybinding-behavior = 3;
      tile-edit-mode = ["<Super>c"];
    };
    "org/gnome/shell/extensions/space-bar/appearance" = {
      active-workspace-background-color = "rgb(129,61,156)";
    };
    "org/gnome/shell/extensions/space-bar/shortcuts" = {
      enable-activate-workspace-shortcuts = "true";
    };
    "org/gnome/shell/extensions/space-bar/behavior" = {
      show-empty-workspaces = false;
      #position = "right";
    };
    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = [
        "element-desktop.desktop:8"
        "org.keepassxc.KeePassXC.desktop:10"
        "steam.desktop:10"
        "legcord.desktop:3"
        "codium.desktop:2"
      ];
    };
    #tweaks
    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "areas";
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
    "org/gnome/mutter" = {
      attach-modal-dialogs = false;
    };
    #startup applications???
  };
}