username:
{ ... }:
{
  imports = [
    ../system/pragmatapro.nix
  ];

  home-manager.users.${username} = {
    programs.ghostty.settings = {
      font-family = "PragmataPro";
    };
    programs.kitty.settings = {
      font_family = "PragmataPro Mono";
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
