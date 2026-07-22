{ config, home, pkgs, ... }:
let
  appMimeTypes = {
    "org.gnome.Loupe.desktop" = [
      "image/jpeg"
      "image/png"
      "image/gif"
      "image/webp"
      "image/tiff"
      "image/x-tga"
      "image/vnd-ms.dds"
      "image/x-dds"
      "image/bmp"
      "image/vnd.microsoft.icon"
      "image/vnd.radiance"
      "image/x-exr"
      "image/x-portable-bitmap"
      "image/x-portable-graymap"
      "image/x-portable-pixmap"
      "image/x-portable-anymap"
      "image/x-qoi"
      "image/qoi"
      "image/svg+xml"
      "image/svg+xml-compressed"
      "image/avif"
      "image/heic"
      "image/jxl"
    ];

    "firewolf.desktop" = [
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/chrome"
      "text/html"
      "application/xhtml+xml"
      "application/x-extension-htm"
      "application/x-extension-html"
      "application/x-extension-shtml"
      "application/x-extension-xhtml"
      "application/x-extension-xht"
    ];

    "codium.desktop" = [
      "text/plain"
      "application/xml"
    ];

    "org.gnome.Evince.desktop" = [ "application/pdf" ];

    "signal.desktop" = [
      "x-scheme-handler/sgnl"
      "x-scheme-handler/signalcaptcha"
    ];

    "onlyoffice-desktopeditors.desktop" = [
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    ];

    "legcord.desktop" = [ "x-scheme-handler/discord" ];

    "org.gnome.TextEditor.desktop" = [ "application/vnd.ms-publisher" ];

    "obsidian.desktop" = [ "x-scheme-handler/obsidian" ];

    "unityhub.desktop" = [ "x-scheme-handler/unityhub" ];
  };
in
home {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = builtins.foldl' (acc: app:
      acc // (builtins.listToAttrs (map (mime: {
        name = mime;
        value = [ app ];
      }) appMimeTypes.${app}))
    ) {} (builtins.attrNames appMimeTypes);
  };
}

# switch to imperative handlr-regex