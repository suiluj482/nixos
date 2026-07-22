{
  description = "js-nixos flake";

  inputs = {
    # https://github.com/NixOS/nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/nix-vscode-extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-vscode-extensions,
    catppuccin,
    plasma-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib;

    naming-schema = name: "js-${name}";

    myArgs = (system: rec {
      inherit self;
      inherit inputs;
      inherit system;

      inherit naming-schema;

      system-name = "";
      device-type = "";

      username = "suiluj";
      domain = "jschuchert.de";

      paths = rec {
        home = "/home/${username}";
        storage = "/mnt/storage";
        js = "${storage}/JS";
        documents = "${js}/documents";
        system = "${documents}/system";
        nixos = "${system}/nixos";
        nixosData = "${system}/nixos/data";
        data = "${system}/data";
        browser = "${system}/data/browser";
        templates = "${nixosData}/templates";
        zmk = "${documents}/projects/hardware/keyboards/zmk/zmk-config";
        # programmData = "${system}/Laptop/ProgrammData";
      };
      ips = {
        prefix = "192.168.178.";
        tower = "192.168.178.36"; # not stable
        laptop = "192.168.178.42"; # not stable
        home = "192.168.1.1";
        server = "192.168.178.131";
      };

      home = conf: { 
        home-manager.users.${username} = conf;
      };
      homeContext = conf: {
        home-manager.users.${username} = { config, ... }: conf { inherit config; };
      };
    });

    mkSystem = {name, device-type ? "desktop", system ? "x86_64-linux"}: {
      "js-${name}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = myArgs system // {
          system-name = naming-schema name;
          device-type = device-type;
        };
        modules = [
          (builtins.toPath ((toString ./machines) + "/" + name))
        ];
      };  
    };
  in {
    nixosConfigurations = lib.mergeAttrsList [
      (mkSystem { name = "iso"; })
      (mkSystem { name = "tower"; device-type = "desktop"; })
      (mkSystem { name = "laptop"; device-type = "laptop"; })
      (mkSystem { name = "server"; device-type = "server"; })
    ];
  };
}
