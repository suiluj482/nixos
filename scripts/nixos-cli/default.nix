{ lib, rustPlatform, bash, pkgs, paths, system-name, naming-schema, ... }:

let 
  iso-name = naming-schema "iso";
  
  name = "nixos";
in rustPlatform.buildRustPackage {
  pname = "nixos-cli";
  version = "0.1.0";
  src = ./.;

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [ pkgs.makeWrapper ];

  postInstall = ''
    mv $out/bin/nixos-cli $out/bin/nixos

    wrapProgram $out/bin/nixos \
      --set PATHS_NIXOS "${paths.nixos}" \
      --set SYSTEM_NAME "${system-name}" \
      --set ISO_NAME "${iso-name}"
  '';
}
