{ config, lib, ... }:

{
  options.kitty.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable the Kitty terminal configuration.";
  };

}
