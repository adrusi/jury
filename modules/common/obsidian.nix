{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.obsidian
  ];

  home-manager.users.${config.system.primaryUser} = {
    programs.obsidian = {
      enable = true;
    };
  };
}
