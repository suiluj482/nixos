{ config, lib, pkgs, home, inputs, ...}:

{
    imports = [
        ./version.nix
        ./home-manager.nix
        ./shell.nix
    ];

    nix.settings = {
        experimental-features = "nix-command flakes";
        auto-optimise-store = true;
    };

    nixpkgs = {
        overlays = [ 
            inputs.nix-vscode-extensions.overlays.default 
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
    nix.nixPath = ["/etc/nix/path"];
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