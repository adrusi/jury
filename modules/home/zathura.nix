username:
{ config, ... }:
let
  p = config.theme.palette;
in
{
  imports = [
    ../theme/options.nix
  ];

  home-manager.users.${username} = {
    programs.zathura = {
      enable = true;
      options = {
        recolor = true;
        recolor-lightcolor = p.base;
        recolor-darkcolor = p.text;
        default-bg = p.base;
        default-fg = p.text;
        statusbar-bg = p.lavender;
        statusbar-fg = p.base;
        inputbar-bg = p.pink;
        inputbar-fg = p.base;
      };
    };
  };
}
