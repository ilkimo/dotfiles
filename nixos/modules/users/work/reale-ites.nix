{ lib, config, pkgs, inputs,... }:

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
    
    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Environment configuration variables";
    };
    
    extraSpecialArgs = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Args to pass to home manager";
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
      ] ++ (lib.optionals (cfg.env.terminal == "kitty" || cfg.env.terminal == "default") [ kitty ])
        ++ (lib.optionals (cfg.env.shell == "zsh" || cfg.env.shell == "default") [ zsh-powerlevel10k ])
        ++ (lib.optionals (cfg.env.vibes == true) [ tree sl cmatrix ]);
    };
  };
}
