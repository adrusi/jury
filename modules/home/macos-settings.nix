username:
{ ... }:
{
  imports = [
    ../system/macos-settings.nix
  ];

  home-manager.users.${username} = {
    programs.git.ignores = [ ".DS_Store" ];
  };
}
