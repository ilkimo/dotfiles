{ terminal, lib, ... }:

{
  home = lib.mkIf (terminal == "default" || terminal == "kitty") {
    file.".config/kitty" = {
      source = ./dotfiles/kitty;
      recursive = true;
    };
  } // lib.mkIf (terminal == "alacritty") {
    file.".config/alacritty" = {
      source = ./dotfiles/alacritty;
      recursive = true;
    };
  };
}

