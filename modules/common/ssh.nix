{
  config,
  ...
}:
{
  home-manager.users.${config.system.primaryUser} = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
    };
  };
}
