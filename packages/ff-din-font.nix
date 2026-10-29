{ pkgs, inputs }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "classic-fonts";
  version = "0.1";
  src = "${inputs.pragmatapro}/ff-din.tar.gz";

  unpackPhase = ''
    runHook preUnpack
    tar xf $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    find . -name '*.ttf' -exec install -Dm644 {} -t $out/share/fonts/truetype \;
    runHook postInstall
  '';
}
