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

    huffi = {
      url = "github:suiluj482/huffi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-vscode-extensions,
    catppuccin,
    plasma-manager,
    huffi,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib;

    myVars = import ./vars { inherit lib; };
    myLib = import ./lib { inherit lib; inherit myVars; };

    myArgs = (system: myVars // myLib // {
      inherit self; inherit inputs; inherit system;
      inherit myVars; inherit myLib;
    });

    mkSystem = {name, device-type ? "desktop", system ? "x86_64-linux"}: {
      "js-${name}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = myArgs system // {
          system-name = myVars.naming-schema name;
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
