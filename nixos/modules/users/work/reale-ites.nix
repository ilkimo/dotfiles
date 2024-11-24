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
      description = "reale-ites user";
    };
  };
}
