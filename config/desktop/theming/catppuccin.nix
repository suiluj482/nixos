{ inputs, home, ... }:
{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    autoEnable = false;
    grub.enable = true;
    sddm.enable = true;
  };
} //
home {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];


  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "mocha";
    accent = "mauve";

    fish.enable = true;
    kitty.enable = true;
    bat.enable = true;
    starship.enable = true;
    btop.enable = true;
    fzf.enable = true;
    yazi.enable = true;
    zellij.enable = true;
    rofi.enable = true;
    mako.enable = true;
    hyprlock.enable = true;
    fuzzel.enable = true;
  };
}
