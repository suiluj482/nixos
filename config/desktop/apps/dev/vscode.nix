{ inputs, config, lib, pkgs, home, ...}:

home {
  # home.packages = with pkgs; [
  #   ltex-ls-plus
  # ];
  programs.vscodium = {
    enable = true;
    package = pkgs.vscodium-fhs;
    
    profiles = 
      let
        basic_extensions = 
          (with pkgs.vscode-extensions; [ 
            mechatroner.rainbow-csv
            esbenp.prettier-vscode
            gruntfuggly.todo-tree
            usernamehw.errorlens
            mkhl.direnv

            valentjn.vscode-ltex

            # language specific
            james-yu.latex-workshop
            # ltex-plus.vscode-ltex-plus
            tamasfe.even-better-toml
            nefrob.vscode-just-syntax

            bbenoist.nix
            rust-lang.rust-analyzer
            llvm-vs-code-extensions.vscode-clangd
            redhat.java
            ms-python.python
            ms-pyright.pyright
            golang.go
          ]) ++ 
          (with pkgs.vscode-marketplace; [ 
            uctakeoff.vscode-counter

            # language specific
            spadin.zmk-tools
            plorefice.devicetree
            trond-snekvik.kconfig-lang
            # antyos.openscad
            leanprover.lean4
            kdl-org.kdl
            keesschollaart.vscode-home-assistant
            theqtcompany.qt-core
            theqtcompany.qt-qml
          ]);
        copilot_extensions = basic_extensions ++ (with pkgs.vscode-extensions; [ 
            github.copilot
            github.copilot-chat
          ]) ++ (with pkgs.vscode-marketplace; [ 
          ]);
      in {
        default = {
          # enableExtensionUpdateCheck = true;
          # enableUpdateCheck = false;
          extensions = basic_extensions;
          # userSettings = {};
        };
        copilot.extensions = copilot_extensions;
        nuxt.extensions = copilot_extensions ++ (with pkgs.vscode-extensions; [ 
            bradlc.vscode-tailwindcss
          ]) ++ (with pkgs.vscode-marketplace; [
            nuxtr.nuxt-vscode-extentions 
            nuxtr.nuxtr-vscode
            vue.volar
            nuxt.mdc
            #web
            # prisma.prisma
          ]);
        haskell.extensions = copilot_extensions ++ (with pkgs.vscode-extensions; [
            haskell.haskell
            justusadam.language-haskell
          ]) ++ (with pkgs.vscode-marketplace; [ 
          ]);
        cad.extensions = basic_extensions ++ (with pkgs.vscode-extensions; [

          ]) ++ (with pkgs.vscode-marketplace; [ 
            bernhard-42.ocp-cad-viewer
          ]);
    };
  };
}

# even better toml
# vscode-pets
# rust-analyser
# dependi