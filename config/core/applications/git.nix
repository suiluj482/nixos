{ home, ... }:

home {
  home = {
    file = {
      ".gitconfig" = {
        text = 
          ''
          [user]
              name = suiluj482
              email = 84525736+suiluj482@users.noreply.github.com
          [safe]
              directory = *
          [core]
              excludesfile = /home/suiluj/.gitignore
          [pull]
              rebase = true

          '';
      };
      ".gitignore" = {
        text =
          ''
          '';
      };
    };
  };
}