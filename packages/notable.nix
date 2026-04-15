{ pkgs, inputs, ... }:
inputs.firefox-addons.lib.${pkgs.stdenv.system}.buildFirefoxXpiAddon {
  pname = "notable-firefox-addon";
  version = "1.1"; # match your release tag
  addonId = "notable@adrusi.com"; # from your manifest.json "browser_specific_settings.gecko.id"
  url = "https://github.com/adrusi/notable/releases/download/v1.1/notable-1.1-an+fx.xpi";
  sha256 = "sha256-/D6Em3KLBMURuSspQE5wjZ8ll0giTtWqUngWzockxhg="; # build once to get the real hash
  meta = with pkgs.lib; {
    homepage = "https://github.com/adrusi/notable";
    description = "Makes all tabs appear in new windows. Useful for tiling window managers.";
    license = licenses.mit;
    platforms = platforms.all;
    mozPermissions = [ "tabs" ];
  };
}
