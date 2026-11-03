{
  inputs = {
    self.submodules = true;

    pragmatapro = {
      url = ./assets/pragmatapro;
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative partitioning for east
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "github:adrusi/swayfx/design-language";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-sway-favicon = {
      url = "github:adrusi/firefox-sway-favicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # agent-authored userstyles: the signed extension, its native host, the CLI
    atelier = {
      url = "github:adrusi/atelier";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dmodel-issue = {
      url = ./vendor/dmodel-issue;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      flake-utils,
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
        berkeley-mono-font = import ./packages/berkeley-mono.nix {
          pkgs = final;
          inherit inputs;
        };
        classic-fonts = import ./packages/classic-fonts.nix {
          pkgs = final;
          inherit inputs;
        };
        d-din-font = import ./packages/d-din-font.nix {
          pkgs = final;
          inherit inputs;
        };
        ff-din-font = import ./packages/ff-din-font.nix {
          pkgs = final;
          inherit inputs;
        };
        obsidian-git = import ./packages/obsidian-git.nix { pkgs = final; };
        obsidian-lesswrong-theme = import ./packages/obsidian-lesswrong-theme.nix { pkgs = final; };
        obsidian-catppuccin-theme = import ./packages/obsidian-catppuccin-theme.nix { pkgs = final; };
        notable-firefox-addon = import ./packages/notable.nix { pkgs = final; inherit inputs; };
        claude-desktop = import ./packages/claude-desktop.nix { pkgs = final; };
        noto-sans-condensed-static = import ./packages/noto-condensed.nix { pkgs = final; };
      };
      remotePackagesOverlay = final: prev: {
        dmodel-issue-tracker = dmodel-issue.packages.${prev.stdenv.system}.default;
      };
      overlays = [ localPackagesOverlay remotePackagesOverlay inputs.firefox-addons.overlays.default ];

      mkNixos = hostModule: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.overlays = overlays;
            nixpkgs.config.allowUnfree = true;
          }
          hostModule
        ];
      };
    in
    {
      # personal laptop
      nixosConfigurations.roarke = mkNixos ./hosts/roarke.nix;
      # bare-metal fallback
      nixosConfigurations.kerapace = mkNixos ./hosts/kerapace.nix;
      # systemd-nspawn container guest under Fedora
      nixosConfigurations.chaos = mkNixos ./hosts/chaos.nix;
      # always-on GCE devbox (see hosts/east.nix)
      nixosConfigurations.east = mkNixos ./hosts/east.nix;

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
