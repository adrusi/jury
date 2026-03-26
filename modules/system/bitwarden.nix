{ pkgs, lib, ... }:
{
  homebrew.casks = lib.optionals pkgs.stdenv.isDarwin [ "bitwarden" ];
}
