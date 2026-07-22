{ config, pkgs, self, home, paths, ips, device-type, system-name, naming-schema, username, domain, ...}:

# coolercontrol
# httpie
# nvitop
# delta

{
  environment = {
    sessionVariables = paths // ips // {
      inherit username;
      inherit domain;
      name = system-name;
      USERNAME = username;
      DOMAIN = domain;
      SYSTEM_NAME = system-name;
      DEVICE_TYPE = device-type;
    };

    shellAliases = {
      inhibit = "systemd-inhibit --what=sleep:shutdown --mode=block bash";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    kitty
    ripgrep
    ripgrep-all
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-curses;
    };
    # shells
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
    fish.enable = true;

    # editor
    nano.enable = true;
    neovim = {
      enable = true;
      # viAlias = true;
      # vimAlias = true;
    };

    # basics
    git.enable = true;
    bat.enable = true; # cat alternative
    yazi.enable = true; # file manager
    zoxide.enable = true; # cd alternative
  };

  # users.defaultUserShell = pkgs.zsh;
} //
home {
  imports = [
    "${self}/scripts/jsync/module.nix"
  ];

  home.packages = with pkgs; [
    #system
    efibootmgr
    
    unzip
    zip

    # security, sync, backup
    # syncthing
    pika-backup
  ];

  programs = {
    jsync.enable = true;

    # shells
    bash.enable = true; # see note on otherusername shells below 
    zsh = {
      enable = true;
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
    };
    starship = {
      enable = true;
      settings = {
        line_break.disabled = true; 
        # format = "$all$character";
      };
    };

    kitty = { # terminal
      enable = true;
      font.name = "FiraCode Nerd Font Reg";
      settings = {
        shell = "fish";
      };
      # settings.background_opacity = "0.4";
    };
    zellij = { # terminal multiplayer
      enable = true;
      enableZshIntegration = true;
      settings = {
        # copy_command = "wl-copy";
        # copy_on_select = true;
        # ui.pane_frames.rounded_corners = true;
        # show_startup_tips = false;
        show_release_notes = false;
      };
    };
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    btop = { # system info
      enable = true;
      settings = {
        theme_background = true;

      };
    };
    eza.enable = true; # ls alternative
    fd.enable = true; # find alternative
    fzf.enable = true; # fuzzy finder
  };
}