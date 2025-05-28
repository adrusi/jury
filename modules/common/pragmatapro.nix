{ pkgs, inputs, ... }: {
  fonts.packages = [
    (pkgs.stdenvNoCC.mkDerivation {
      pname = "pragmatapro-font";
      version = "0.9";
      src = "${inputs.pragmatapro}/PragmataPro0.9-8svlok.zip";

      unpackPhase = ''
        runHook preUnpack
        ${pkgs.unzip}/bin/unzip $src
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
        install -Dm644 PragmataPro0.9/*.ttf -t $out/share/fonts/truetype
        runHook postInstall
      '';
    })
  ];
}
