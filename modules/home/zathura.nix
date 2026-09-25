username:
{ config, ... }:
let
  c = config.stylesheet.colors;
in
{
  imports = [
    ../stylesheet/options.nix
  ];

  home-manager.users.${username} = {
    programs.zathura = {
      enable = true;
      options = {
        font = "${config.stylesheet.fonts.ui} normal ${toString config.stylesheet.sizes.zathura}";
        recolor = true;
        recolor-lightcolor = c.bg;
        recolor-darkcolor = c.fg;
        default-bg = c.bg;
        default-fg = c.fg;
        statusbar-bg = c.accent;
        statusbar-fg = c.bg;
        inputbar-bg = c.color5;
        inputbar-fg = c.bg;
      };
    };
  };
}
