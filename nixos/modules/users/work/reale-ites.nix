{ lib, config, pkgs, ... }:

let
  cfg = config.reale-ites-user;
in

{
  options.reale-ites-user = {
    enable = lib.mkEnableOption "enable user module";

    userName = lib.mkOption {
      default = "kimo_ites";
      description = ''
       username
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.userName} = {
      isNormalUser = true;
      initialPassword = "12345";
      description = "kimo_ites user";
      extraGroups = [ "bluetooth" "networkmanager" ]; # To enable ‘sudo’ for the user add the 'wheel' group.
      packages = with pkgs; [
        google-chrome
        vscode
      ];



    };
  };
}
