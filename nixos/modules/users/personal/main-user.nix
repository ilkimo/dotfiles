{ lib, config, pkgs, inputs, env, ... }:

let
  cfg = config.main-user;
in

{
  options.main-user = {
    enable = lib.mkEnableOption "enable user module";

    userName = lib.mkOption {
      default = "il_kimo";
      description = ''
       username
      '';
    };
    
    extraSpecialArgs = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Args to pass to home manager";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
    programs.zsh.promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    '';

    users.users.${cfg.userName} = {
      isNormalUser = true;
      extraGroups = ["dialout" "bluetooth" "networkmanager" ]; # To enable ‘sudo’ for the user add the 'wheel' group.
      initialPassword = "12345";
      description = "main user";
      shell = pkgs.zsh;
      packages = with pkgs; [
        google-chrome
        vscode
      ] ++ (lib.optionals (cfg.env.terminal == "kitty" || cfg.env.terminal == "default") [ kitty ])
        ++ (lib.optionals (cfg.env.shell == "zsh" || cfg.env.shell == "default") [ zsh-powerlevel10k ])
        ++ (lib.optionals (cfg.env.vibes == true) [ tree sl cmatrix ]);
    };
    
    home-manager = {
      # also pass inputs to home-manager modules
      extraSpecialArgs = { inherit cfg.extraSpecialArgs; };
      users = {
        ${cfg.userName} = import ./home.nix;
      };
    };
  };
}
