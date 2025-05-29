{ config, pkgs, lib, ... }: lib.mkMerge [
  (lib.mkIf pkgs.stdenv.isDarwin {
    environment.systemPackages = [
      pkgs.ghostty-bin
    ];
  })
  {
    home-manager.users.${config.system.primaryUser} = {
      programs.ghostty = {
        enable = true;
        package = pkgs.ghostty-bin;
        enableZshIntegration = true;
        enableBashIntegration = true;

        settings = {
          font-size = 11;
          theme = "catppuccin-latte";
        };
      };
    };
  }
]
