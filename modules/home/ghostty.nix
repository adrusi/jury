username:
{
  pkgs,
  lib,
  config,
  ...
}:
let
  p = config.theme.palette;
  bare = lib.removePrefix "#";
in
{
  imports = [
    ../theme/options.nix
  ];

  home-manager.users.${username} = {
    programs.ghostty = {
      enable = true;
      package = pkgs.ghostty;
      enableZshIntegration = true;
      enableBashIntegration = true;

      settings = {
        font-size = config.theme.sizes.ghostty;
        theme = "jury";
      };

      # ghostty wants a named theme; "jury" is just the palette from
      # config.theme rendered in ghostty's format
      themes = {
        jury = {
          palette = lib.imap0 (i: c: "${toString i}=${c}") config.theme.ansi;
          background = bare p.base;
          foreground = bare p.text;
          cursor-color = bare p.rosewater;
          cursor-text = bare p.base;
          selection-background = bare p.selectionBg;
          selection-foreground = bare p.text;
        };
      };
    };
  };
}
