{ pkgs }:

pkgs.rustPlatform.buildRustPackage {
  pname = "jsync";
  version = "0.1.0";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;

  propagatedBuildInputs = [ pkgs.rsync ];

  meta = {
    description = "A simple file synchronization tool using rsync";
    mainProgram = "jsync";
  };
}