{ terminal, lib, ... }:

{
  home.file = lib.mkIf (terminal == "default" || terminal == "kitty") {
    ".config/kitty" = {
      source = ./dotfiles/kitty;
      recursive = true;
    };
  } // lib.mkIf (terminal == "alacritty") {
    ".config/alacritty" = {
      source = ./dotfiles/alacritty;
      recursive = true;
    };
  };
}

