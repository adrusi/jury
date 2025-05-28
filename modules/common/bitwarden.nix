{ config, lib, pkgs, inputs, ... }: lib.mkMerge [
  (lib.mkIf pkgs.stdenv.isLinux {
    home-manager.users.${config.system.primaryUser}.home.packages = [
      pkgs.bitwarden
    ];
  })
  (lib.mkIf pkgs.stdenv.isDarwin {
    homebrew.casks = [
      "bitwarden"
    ];
  })
  {
    home-manager.users.${config.system.primaryUser}.programs.firefox = {
      profiles.default = {
        extensions.packages = [
          inputs.firefox-addons.packages.${pkgs.system}.bitwarden
        ];

        settings = {
          # use bitwarden instead of built-in password manager
          "signon.rememberSignons" = false;
        };
      };
    };
  }
]
