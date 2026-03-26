{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "obsidian-lesswrong-theme";
  version = "1.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "outsidetext";
    repo = "lesswrong-obsidian";
    rev = "437013fa8ae0f30f5e3cf45b03465c96b998b46b";
    hash = "sha256-IMeVqPjkLv3ug6my+zaQhieusLXTU0gSFwHpB/6ZCes=";
  };

  installPhase = ''
    mkdir -p $out
    cp ./manifest.json $out/manifest.json
    cp ./preview.png $out/preview.png
    cp ./theme.css $out/theme.css
  '';
}
