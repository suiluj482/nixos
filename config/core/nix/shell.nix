{ config, pkgs, self, home, paths, ips, system-name, naming-schema, username, domain, ... }:
{
  environment.sessionVariables = {
  };

  environment.shellAliases = {
    i = "nix-shell -p";
  };
} //
home {
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "ie" ''
      #!/bin/bash
      pkg=$1
      shift 1
      extra_args="$@"
      nix-shell -p $pkg --command "$pkg $extra_args"
    '')
    (pkgs.callPackage "${self}/scripts/nixos-cli" { 
      paths = paths; 
      system-name = system-name;
      naming-schema = naming-schema; 
    })
    (pkgs.callPackage "${self}/scripts/nix-cli" { 
      paths = paths; 
    })
  ];
}