{
  inputs = {
    pragmatapro = {
      url = "git+file:./assets/pragmatapro";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    swayfx = {
      url = "github:adrusi/swayfx";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-sway-favicon = {
      url = "github:adrusi/firefox-sway-favicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dmodel-issue = {
      url = "git+file:./vendor/dmodel-issue";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      flake-utils,
      darwin,
      vscode-extensions,
      dmodel-issue,
      ...
    }:
    let
      localPackagesOverlay = final: _prev: {
        pragmatapro-font = import ./packages/pragmatapro.nix {
          pkgs = final;
          inherit inputs;
        };
        uosc-fonts = import ./packages/uosc-fonts.nix { pkgs = final; };
        obsidian-git = import ./packages/obsidian-git.nix { pkgs = final; };
        obsidian-lesswrong-theme = import ./packages/obsidian-lesswrong-theme.nix { pkgs = final; };
        obsidian-catppuccin-theme = import ./packages/obsidian-catppuccin-theme.nix { pkgs = final; };
        notable-firefox-addon = import ./packages/notable.nix { pkgs = final; inherit inputs; };
      };
      remotePackagesOverlay = final: prev: {
        dmodel-issue-tracker = dmodel-issue.packages.${prev.stdenv.system}.default;
      };
      overlays = [ localPackagesOverlay remotePackagesOverlay inputs.firefox-addons.overlays.default ];
    in
    {
      nixosConfigurations.kerapace = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.overlays = overlays;
            nixpkgs.config.allowUnfree = true;
          }
          ./hosts/kerapace.nix
        ];
      };

      darwinConfigurations.rainbow = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          { nixpkgs.overlays = overlays; }
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
