{ pkgs, inputs }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "classic-fonts";
  version = "0.1";
  src = "${inputs.pragmatapro}/D-DIN.zip";

  unpackPhase = ''
    runHook preUnpack
    ${pkgs.unzip}/bin/unzip $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    find . -name '*.otf' -exec install -Dm644 {} -t $out/share/fonts/opentype \;
    runHook postInstall
  '';
}
