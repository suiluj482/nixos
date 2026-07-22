{
  description = "Homeassistant linux client";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          rustc
          cargo
          # clippy
          # rustfmt
          # rust-analyzer
        ];

        shellHook = ''
          reload() {
            cargo build --release && systemctl --user restart ha-linux
          }
          logs() {
            journalctl --user -u ha-linux -f
          }
        '';
      };

      packages.default = pkgs.callPackage ./default.nix {};
      # todo: home manager module
    });
}
