username:
{
  pkgs,
  lib,
  config,
  ...
}:
let
  c = config.stylesheet.colors;
  bare = lib.removePrefix "#";
in
{
  imports = [
    ../stylesheet/options.nix
  ];

  home-manager.users.${username} = {
    programs.ghostty = {
      enable = true;
      package = pkgs.ghostty;
      enableZshIntegration = true;
      enableBashIntegration = true;

      settings = {
        font-family = config.stylesheet.fonts.ui;
        font-size = config.stylesheet.sizes.ghostty;
        theme = "jury";
      };

      # ghostty wants a named theme; "jury" is just the stylesheet colors
      # rendered in ghostty's format
      themes = {
        jury = {
          palette = lib.genList (i: "${toString i}=${c."color${toString i}"}") 16;
          background = bare c.bg;
          foreground = bare c.fg;
          cursor-color = bare c.cursor;
          cursor-text = bare c.bg;
          selection-background = bare c.selection;
          selection-foreground = bare c.fg;
        };
      };
    };
  };
}
