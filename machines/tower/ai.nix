{ config, lib, pkgs, home, ... }:
{
  services = {
    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      # Optional: preload models, see https://ollama.com/library
      # loadModels = [ "llama3.2:3b" "deepseek-r1:1.5b"];
    };

    # open-webui = {
    #   enable = true;
    #   port = 8085;
    # };
  };
} //
home {
  home.packages = with pkgs; [
    opencode
  ];
}