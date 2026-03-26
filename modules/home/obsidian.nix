username:
{ pkgs, lib, ... }:
{
  imports = [
    ../system/obsidian.nix
  ];

  home-manager.users.${username} = {
    programs.obsidian = {
      enable = true;
      vaults.wiki = {
        enable = true;
        settings = {
          communityPlugins = [
            {
              enable = true;
              pkg = pkgs.obsidian-git;
              settings = {
                gitPath = "${lib.getBin pkgs.git}/bin/git";
              };
            }
          ];
          themes = [
            {
              enable = false;
              pkg = pkgs.obsidian-lesswrong-theme;
            }
            {
              enable = true;
              pkg = pkgs.obsidian-catppuccin-theme;
            }
          ];
        };
      };
    };
  };
}
