username:
{ config, ... }:
let
  p = config.design.palette;
in
{
  imports = [
    ../design/options.nix
  ];

  home-manager.users.${username} = {
    programs.zathura = {
      enable = true;
      options = {
        font = "${config.design.fonts.sans} normal ${toString config.design.dims.readerSize}";
        recolor = true;
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
      };
    };
  };
}
