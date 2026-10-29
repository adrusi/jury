{ pkgs, inputs }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "classic-fonts";
  version = "0.1";
  src = "${inputs.pragmatapro}/classics.zip";

  unpackPhase = ''
    runHook preUnpack
    ${pkgs.unzip}/bin/unzip $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    find . -name '*.ttf' -exec install -Dm644 {} -t $out/share/fonts/truetype \;
    runHook postInstall
  '';
}
