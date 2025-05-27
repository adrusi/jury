{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs@{ nixpkgs, flake-utils, darwin, home-manager, ... }:
    flake-utils.lib.eachDefaultSystemPassThrough (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      darwinConfigurations.rainbow = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/rainbow/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            users.users.autumn.name = "autumn";
            users.users.autumn.home = "/Users/autumn";
            home-manager.users.autumn = import ./users/autumn/home.nix;
          }
        ];
      };

      devShells.${system}.default = (import ./shell.nix {
        inherit pkgs;
      });
    });
}
