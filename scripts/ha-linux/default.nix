{ lib, rustPlatform, pkgs }:

rustPlatform.buildRustPackage {
  pname = "ha-linux";
  version = "0.1.0";
  src = ./.;

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [ pkgs.makeWrapper ];
}
