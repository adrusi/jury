username:
{ inputs, lib, pkgs, ... }:
let
  # workaround for nixpkgs changing the discord package's arguments out from under nixcord
  discordPkg = lib.makeOverridable (
    args: pkgs.discord.override (builtins.removeAttrs args [ "branch" "source" ])
  ) { };
in
{
  home-manager.users.${username} = {
    imports = [
      inputs.nixcord.homeModules.nixcord
    ];

    programs.nixcord = {
      enable = true;
      discord.vencord.enable = true;
      discord.package = discordPkg;
    };
  };
}
