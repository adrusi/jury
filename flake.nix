{
  inputs = {
    pragmatapro = {
      url = "git+file:./assets/pragmatapro";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.nix-darwin.follows = "darwin";
      inputs.brew-api.follows = "brew-api";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };

    brewtap-cxpatcher = {
      url = "github:italomandara/homebrew-CXPatcher";
      flake = false;
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zen-browser.url = "github:adrusi/zen-browser-nix";

    nixcord.url = "github:kaylorben/nixcord";

    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };
  outputs =
    inputs@{
      nixpkgs,
      flake-utils,
      darwin,
      vscode-extensions,
      ...
    }:
    {
      darwinConfigurations.rainbow = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          {
            nixpkgs.overlays = [
              vscode-extensions.overlays.default
            ];
          }
          ./hosts/rainbow.nix
        ];
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        # pkgs = nixpkgs.legacyPackages.${system};
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = (
          import ./shell.nix {
            inherit pkgs inputs;
          }
        );
      }
    );
}
