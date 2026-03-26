{ pkgs, lib, ... }:
{
  environment.systemPackages = lib.optionals pkgs.stdenv.isDarwin [
    pkgs.ghostty-bin
  ];
}
