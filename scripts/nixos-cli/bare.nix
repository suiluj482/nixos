{ lib, rustPlatform, pkgs }:

rustPlatform.buildRustPackage {
  pname = "nixos-cli";
  version = "0.1.0";
  src = ./.;

  cargoHash = "sha256-fA7lkxLy2dTD/R8qGF9dy1YN7FdBhEskCrHWUaaCaFI=";
}
