{ pkgs, inputs }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "berkeley-mono-font";
  version = "2.004";
  # one zip per width (Normal, SemiCondensed, Condensed, ExtraCondensed,
  # UltraCondensed); each nests its .otf files under random ticket dirs
  srcs = map (width: "${inputs.pragmatapro}/BerkeleyMono${width}.zip") [
    ""
    "SemiCondensed"
    "Condensed"
    "ExtraCondensed"
    "UltraCondensed"
  ];

  unpackPhase = ''
    runHook preUnpack
    for src in $srcs; do
      ${pkgs.unzip}/bin/unzip $src
    done
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    find . -name '*.ttf' -exec install -Dm644 {} -t $out/share/fonts/truetype \;
    runHook postInstall
  '';
}
