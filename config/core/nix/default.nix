{ config, lib, pkgs, home, inputs, system, ...}:

{
    imports = [
        ./version.nix
        ./home-manager.nix
        ./shell.nix
    ];

    nix.settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://suiluj482.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "suiluj482.cachix.org-1:XeMeXzHH4JMCVJ6N115eoFMdpHakQtLlGXGW1Ts5WSE="
      ];
    };

    nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
    };

    nixpkgs = {
        overlays = [ 
            inputs.nix-vscode-extensions.overlays.default
            (final: prev: {
              stable = import inputs.nixpkgs-stable { 
                inherit system; 
                config.allowUnfree = true;
              };
            })
        ];
        config = {
            allowUnfree = true;
        };
    };



    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nix.settings.nix-path = ["/etc/nix/path"];
    environment.etc =
        lib.mapAttrs'
            (name: value: {
                name = "nix/path/${name}";
                value.source = value.flake;
            })
            config.nix.registry;
} //
home {
    programs.home-manager.enable = true;

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";
}