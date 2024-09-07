{ config, lib, pkgs, ... }:

{
  options.kitty = {
    enable = lib.mkEnableOption "enable kitty module";
  };

  config = lib.mkIf config.kitty.enable {

    };
  };
}
