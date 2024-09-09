{ lib, config, pkgs, ... }:

let
  cfg = config.main-user;
in

{
  options.main-user = {
    enable = lib.mkEnableOption "enable user module";

    userName = lib.mkOption {
      default = "mainuser";
      description = ''
       username
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
    programs.zsh.promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    '';

    users.users.${cfg.userName} = {
      isNormalUser = true;
      initialPassword = "12345";
      description = "main user";
      shell = pkgs.zsh;
    };
  };
}
