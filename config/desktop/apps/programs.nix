{ config, pkgs, home, paths, ...}:

{
  nixpkgs.config.element-web.conf = {
    show_labs_settings = true;
    default_theme = "dark";
  };

  services = {
    gvfs.enable = true;
    avahi.enable = true;
  };


  virtualisation.virtualbox.host.enable = true;
  environment.systemPackages = [ pkgs.vagrant ];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
} //
home {

  home = {
    file = {
      ".config/mozilla/firefox/profiles.ini" = {
        text = 
        ''
        [Profile0]
        Name=main
        IsRelative=0
        Path=${paths.data}/browser/firefox/main
        Default=1

        [Profile1]
        Name=banking
        IsRelative=0
        Path=${paths.data}/browser/firefox/banking
        Default=0


        [Profile3]
        Name=template
        IsRelative=0
        Path=${paths.data}/browser/firefox/template
        Default=0

        [General]
        StartWithLastProfile=1
        Version=2
        '';
      };
    };

    packages = with pkgs; [
      #browser
      firefox
      (pkgs.makeDesktopItem {
        name = "firewolf";
        exec = "firefox";
        desktopName = "firewolf";
        categories = [ "Utility" ];
        terminal = false;
        icon = "firefox";
      })
      (pkgs.makeDesktopItem {
        name = "wolf";
        exec = "firefox";
        desktopName = "wolf";
        categories = [ "Utility" ];
        terminal = false;
        icon = "firefox";
      })
      (pkgs.makeDesktopItem {
        name = "bankingFirefox";
        exec = "firefox -no-remote -P banking";
        startupWMClass = "bankingFirefox";
        desktopName = "bankingFirefox";
        categories = [ "Utility" ];
        terminal = false;
        icon = "firefox";
      })
      (pkgs.makeDesktopItem {
        name = "drmFirefox";
        exec = "firefox -no-remote -P drm";
        startupWMClass = "drmFirefox";
        desktopName = "drmFirefox";
        categories = [ "Utility" ];
        terminal = false;
        icon = "firefox";
      })
      brave

      # Uni
      zotero
      zoom-us
      onlyoffice-desktopeditors
      
      #Basics
      thunderbird
      protonmail-desktop
      obsidian
      libreoffice
      pdfarranger
      # zettlr
      showtime # image viewer
      gnome-sound-recorder # recorder
      nautilus # file browser
      evince # pdf viewer

      #security, sync, backup
      keepassxc
      # bitwarden-desktop
      ente-auth
      nextcloud-client

      #sozial
      element-desktop
      signal-desktop
      # spotify
      legcord

      gimp

      # kicad
      unityhub
      # bambu-studio

      #editors
      # jetbrains.idea-community

      # util
    ];
  };
}