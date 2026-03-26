{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "obsidian-catppuccin-theme";
  version = "0.4.44";

  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "obsidian";
    rev = "v2.0.4";
    hash = "sha256-fbPkZXlk+TTcVwSrt6ljpmvRL+hxB74NIEygl4ICm2U=";
  };

  installPhase = ''
    mkdir -p $out
    cp ./manifest.json $out/manifest.json
    cp ./theme.css $out/theme.css
  '';
}
