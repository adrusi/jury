username:
{ config, ... }:
{
  imports = [
    ../system/touchid.nix
  ];

  home-manager.users.${username}.programs.ssh.matchBlocks."*" = {
    identityAgent = "${
      config.users.users.${username}.home
    }/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
  };
}
