username:
{ pkgs, lib, inputs, ... }:
{
  imports = [
    ../system/bitwarden.nix
  ];

  home-manager.users.${username} = lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux {
      home.packages = [ pkgs.bitwarden ];
    })
    {
      programs.firefox.profiles.default = {
        extensions.packages = [
          inputs.firefox-addons.packages.${pkgs.system}.bitwarden
        ];

        settings = {
          # use bitwarden instead of built-in password manager
          "signon.rememberSignons" = false;
        };
      };
    }
  ];
}
