{
  config,
  pkgs,
  inputs,
  ...
}:
{
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

  home-manager.users.${config.system.primaryUser} = {
    programs.ghostty.settings = {
      font-family = "PragmataPro Mono Liga";
      font-feature = [
        "ss13"
      ];
    };
    programs.zed-editor.userSettings = {
      buffer_font_family = "PragmataPro Mono Liga";
      terminal.font_family = "PragmataPro Mono Liga";
      languages.haskell.buffer_font_features.calt = true;
      terminal.font_features = {
        ss13 = true;
      };
    };
    programs.vscode.profiles.default.userSettings = {
      "editor.fontFamily" = "PragmataPro Mono Liga";
      "debug.console.fontFamily" = "PragmataPro Mono Liga";
      "terminal.integrated.fontFamily" = "PragmataPro Mono Liga";
      "terminal.integrated.fontLigatures.enabled" = true;
      "terminal.integrated.fontLigatures.featureSettings" = "'ss13'";
      "[haskell][literate haskell]" = {
        "editor.fontLigatures" = "'calt'";
      };
    };
  };
}
