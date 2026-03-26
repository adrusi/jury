{ pkgs }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "uosc-fonts";
  version = "5.8.0";
  src = pkgs.fetchFromGitHub {
    owner = "tomasklaen";
    repo = "uosc";
    rev = "5.8.0";
    hash = "sha256-Jj88PkP7hpyUOHsz0w0TOTTdJoQ/ShgJfHg//GUuUvM=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 src/fonts/*.ttf -t $out/share/fonts/truetype
    install -Dm644 src/fonts/*.otf -t $out/share/fonts/opentype
    runHook postInstall
  '';
}
