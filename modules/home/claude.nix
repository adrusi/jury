username:
{ config, lib, ... }:
let
  hmCfg = config.home-manager.users.${username};
  theme = import ./claude-theme.nix {
    inherit lib;
    inherit (config.design) mode;
    p = config.design.palette;
  };
in
{
  imports = [
    ../design/options.nix
  ];

  home-manager.users.${username} = {
    programs.claude-code = {
      enable = true;
      settings.theme = "custom:datasheet";
    };

    # the design language's palette for this host's mode (see claude-theme.nix)
    home.file."${hmCfg.programs.claude-code.configDir}/themes/datasheet.json".text =
      builtins.toJSON theme;

    programs.git.ignores = [
      "CLAUDE.local.md"
    ];
  };
}
