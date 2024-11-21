{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/default/configuration.nix
          inputs.home-manager.nixosModules.default
          ./modules/graphic-session/wayland/hyprlnd.nix
          ./modules/graphic-session/display-managers/sddm.nix
        ];
      };
      old-laptop-uni = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/old-laptop-uni/configuration.nix
          inputs.home-manager.nixosModules.default
          ./modules/graphic-session/wayland/hyprlnd.nix
          ./modules/graphic-session/display-managers/sddm.nix
          ./modules/common.nix
        ];
      };
    };
  };
}
