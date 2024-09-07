{ terminal, ... }:

{
  # Kitty (default terminal)
  programs = lib.mkIf (terminal == "default" || terminal == "kitty") {
    home.file.".config/kitty" = {
      source = ./dotfiles/kitty;
      recursive = true;
    };
  };

  # Alacritty
  programs = lib.mkIf (terminal == "alacritty") {
    home.file.".config/alacritty" = {
      source = ./dotfiles/alacritty;
      recursive = true;
    };
  };
}
