username:
{ ... }:
{
  # Provides the PragmataPro font files and PragmataPro-specific quirks. The
  # desktop's own faces are fixed by the design (modules/design); this keeps
  # PragmataPro installed and its feature flags set for wherever it's chosen.
  imports = [
    ../system/pragmatapro.nix
  ];

  # PragmataPro is designed around full hinting; a different font module may
  # well want this off.
  fonts.fontconfig.hinting = {
    enable = true;
    style = "full";
  };

  home-manager.users.${username} = {
    # ligature/feature flags specific to PragmataPro's stylistic sets
    programs.zed-editor.userSettings = {
      languages.haskell.buffer_font_features.calt = true;
      terminal.font_features = {
        ss13 = true;
      };
    };
    programs.vscode.profiles.default.userSettings = {
      "terminal.integrated.fontLigatures.enabled" = true;
      "terminal.integrated.fontLigatures.featureSettings" = "'ss13'";
      "[haskell][literate haskell]" = {
        "editor.fontLigatures" = "'calt'";
      };
    };
  };
}
