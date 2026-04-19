username:
{ ... }:
{
  home-manager.users.${username} = {
    programs.zathura = {
      enable = true;
      options = {
        recolor = true;
        recolor-lightcolor = "#eff1f5";
        recolor-darkcolor = "#4c4f69";
        default-bg = "#eff1f5";
        default-fg = "#4c4f69";
        statusbar-bg = "#7287fd";
        statusbar-fg = "#eff1f5";
        inputbar-bg = "#ea76cb";
        inputbar-fg = "#eff1f5";
      };
    };
  };
}
