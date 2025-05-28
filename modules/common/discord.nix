{ config, inputs, ... }: {
  home-manager.users.${config.system.primaryUser} = {
    imports = [
      inputs.nixcord.homeModules.nixcord
    ];

    programs.nixcord = {
      enable = true;
    };
  };
}
