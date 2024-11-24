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

# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${cfg.userName} = {
    isNormalUser = true;
    extraGroups = ["dialout" "bluetooth" "networkmanager" ]; # To enable ‘sudo’ for the user add the 'wheel' group.
    packages = with pkgs; [
      google-chrome
      vscode
    ] ++ (lib.optionals (terminal == "kitty" || terminal == "default") [ kitty ])
      ++ (lib.optionals (shell == "zsh" || shell == "default") [ zsh-powerlevel10k ])
      ++ (lib.optionals (vibes == true) [ tree sl cmatrix ]);
  };

  #home-manager = {
    # also pass inputs to home-manager modules
  #  extraSpecialArgs = { inherit terminal; };
  #  users = {
  #    ${cfg.userName} = import ./home.nix;
  #  };
  #};
}
