username:
{ inputs, ... }:
{
  home-manager.users.${username} = {
    imports = [
      inputs.nixcord.homeModules.nixcord
    ];

    programs.nixcord = {
      enable = true;
    };
  };
}
