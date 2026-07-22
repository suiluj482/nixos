{ pkgs }:

pkgs.rustPlatform.buildRustPackage {
  pname = "jcrypt";
  version = "0.1.0";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;

  propagatedBuildInputs = [ pkgs.gocryptfs ];

  meta = {
    description = "gocryptfs vault manager";
    mainProgram = "jcrypt";
  };
}