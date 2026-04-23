username:
{ pkgs, lib, ... }:
{
  home-manager.users.${username} = {
    home.file = {
      ".config/kak-lsp/kak-lsp.toml".source = ./kak-lsp.toml;
      ".config/kak/colors/adrusi.kak".source = ./adrusi.kak;
      ".config/kak/colors/latte.kak".source = ./latte.kak;
    };

    home.packages = [ pkgs.fzf pkgs.bat pkgs.lua pkgs.fd pkgs.ripgrep ];

    programs.kakoune = {
      enable = true;
      defaultEditor = true;
      plugins = [
        pkgs.kakounePlugins.kak-ansi
        pkgs.kakounePlugins.kakoune-lsp
        pkgs.kakounePlugins.parinfer-rust
        # pkgs.kakounePlugins.kak-fzf
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
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
          pname = "luar";
          version = "2026-04-19";
          meta.homepage = "https://github.com/gustavo-hms/luar";
          src = pkgs.fetchFromGitHub {
            owner = "gustavo-hms";
            repo = "luar";
            rev = "e08e1ce7a8e9c9341adf7121a46b9170aea3334b";
            sha256 = "sha256-cJldxfmBLJoKC7JAOk9h1KwXwdHGf9S3I5AoU6wP7vk=";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
          pname = "peneira";
          version = "2026-04-19";
          meta.homepage = "https://github.com/gustavo-hms/peneira";
          src = pkgs.fetchFromGitHub {
            owner = "gustavo-hms";
            repo = "peneira";
            rev = "3162b4fa2a665275278feb2e7eea141a97995c1b";
            sha256 = "sha256-qyWK3vnCnbh4PkeIT8dDwmYpDdQ32nV4RcaWlViC3bg=";
          };
        })
      ];
      extraConfig = builtins.readFile ./kak.kak;
    };
  };
}
