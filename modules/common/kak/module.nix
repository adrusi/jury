{ config, pkgs, ... }:
{
  home-manager.users.${config.system.primaryUser} = {
    home.file = {
      ".config/kak-lsp/kak-lsp.toml".source = ./kak-lsp.toml;
      ".config/kak/colors/adrusi.kak".source = ./adrusi.kak;
    };

    programs.kakoune = {
      enable = true;
      defaultEditor = true;
      plugins = [
        pkgs.kakounePlugins.kak-ansi
        pkgs.kakounePlugins.kakoune-lsp
        pkgs.kakounePlugins.parinfer-rust
        # pkgs.kakounePlugins.rep
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
          pname = "osc52-kak";
          version = "1.0.0";
          meta.homepage = "https://github.com/adrusi/osc52.kak";
          src = pkgs.fetchFromGitHub {
            owner = "adrusi";
            repo = "osc52.kak";
            rev = "3ae42e80cade006bc481dd1fb36dfd7c1f2ceae7";
            sha256 = "13apvxdpm2rfxrp5nkad03s5x3ln822rkqnc3q9p3yc4prjnsk2s";
          };
        })
      ];
      extraConfig = builtins.readFile ./kak.kak;
    };
  };
}
