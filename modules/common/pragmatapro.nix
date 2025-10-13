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
    programs.ghostty.settings.font-family = "PragmataPro";
    programs.zed-editor.userSettings = {
      buffer_font_family = "PragmataPro";
      terminal.font_family = "PragmataPro";
    };
    programs.vscode.profiles.default.userSettings = {
      "editor.fontFamily" = "PragmataPro Liga";
      "debug.console.fontFamily" = "PragmataPro Liga";
      "terminal.integrated.fontFamily" = "PragmataPro Liga";
    };
  };
}
