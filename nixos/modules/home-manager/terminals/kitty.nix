{ config, lib, ... }:

{
  options.programs.kitty.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable the Kitty terminal configuration.";
  };

  config = lib.mkIf config.kitty.enable {
    # Put any Kitty-specific configuration here
  };
}
