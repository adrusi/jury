{ pkgs, lib, ... }:
lib.mkMerge [
  # the uosc package fails to correctly install fonts on macOS
  (lib.mkIf pkgs.stdenv.isDarwin {
    fonts.packages = [ pkgs.uosc-fonts ];
  })

  {
    environment.systemPackages = [ pkgs.mpv ];
  }
]
