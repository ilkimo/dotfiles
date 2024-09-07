{ terminal, lib, ... }:

{
  programs = lib.mkIf (terminal == "default" || terminal == "kitty") {
    home.file.".config/kitty" = {
      source = ./dotfiles/kitty;
      recursive = true;
    };
  } // lib.mkIf (terminal == "alacritty") {
    home.file.".config/alacritty" = {
      source = ./dotfiles/alacritty;
      recursive = true;
    };
  };
}

