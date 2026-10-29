username:
{ config, ... }:
let
  c = config.stylesheet.colors;
  p = config.design.palette;
in
{
  imports = [
    ../stylesheet/options.nix
    ../design/options.nix
  ];

  home-manager.users.${username} = {
    programs.zathura = {
      enable = true;
      options = {
        font = "${config.stylesheet.fonts.ui} normal ${toString config.stylesheet.sizes.zathura}";
        recolor = true;
      }
      // (
        if config.design.enable then
          {
            # pages are paper; the status and input bars are panel chrome
            recolor-lightcolor = p.paper;
            recolor-darkcolor = p.ink;
            default-bg = p.panel;
            default-fg = p.ink;
            statusbar-bg = p.panel;
            statusbar-fg = p.ink;
            inputbar-bg = p.panel;
            inputbar-fg = p.ink;
            highlight-color = p.seltint;
            highlight-active-color = p.signal;
            notification-error-bg = p.panel;
            notification-error-fg = p.alarm;
          }
        else
          {
            recolor-lightcolor = c.bg;
            recolor-darkcolor = c.fg;
            default-bg = c.bg;
            default-fg = c.fg;
            statusbar-bg = c.accent;
            statusbar-fg = c.bg;
            inputbar-bg = c.color5;
            inputbar-fg = c.bg;
          }
      );
    };
  };
}
