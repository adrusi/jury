{
  config,
  pkgs,
  lib,
  ...
}:
{
  home-manager.users.${config.system.primaryUser} = {
    programs.git = {
      enable = true;
      ignores = [ ];
    };
  };
}
