{ config, ... }:

{
    imports = [
        ../../config/server
        
        ./hardware-configuration.nix
    ];
}
