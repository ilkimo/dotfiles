{ terminal, lib, ... }:

{
  # Configure Kitty (if selected)
  home.file = lib.mkIf (terminal == "default" || terminal == "kitty") {
    ".config/kitty" = {
      source = ./dotfiles/kitty;
      recursive = true;
    };
  };

  # Configure Alacritty (if selected)
  home.file = lib.mkIf (terminal == "alacritty") {
    ".config/alacritty" = {
      source = ./dotfiles/alacritty;
      recursive = true;
    };
  };
}

