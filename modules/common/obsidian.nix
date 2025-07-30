{
  config,
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = [
    pkgs.obsidian
  ];

  home-manager.users.${config.system.primaryUser} = {
    programs.obsidian = {
      enable = true;
      vaults.wiki = {
        enable = true;
        settings = {
          communityPlugins = [
            {
              enable = true;
              pkg = pkgs.stdenv.mkDerivation {
                pname = "obsidian-git";
                version = "2.32.1";

                src = pkgs.fetchzip {
                  url = "https://github.com/Vinzent03/obsidian-git/releases/download/2.34.0/obsidian-git-2.34.0.zip";
                  hash = "sha256-7+Krdi6wHonEMz7aXscfVtCQhL29YIKqAExlns43tjU=";
                };

                installPhase = ''
                  mkdir -p $out
                  cp ./manifest.json $out/manifest.json
                  cp ./styles.css $out/styles.css
                  cp ./main.js $out/main.js
                '';
              };
              settings = {
                gitPath = "${lib.getBin pkgs.git}/bin/git";
              };
            }
          ];
          themes = [
            {
              enable = false;
              pkg = pkgs.stdenv.mkDerivation {
                pname = "LessWrong";
                version = "1.0.0";

                src = pkgs.fetchFromGitHub {
                  owner = "outsidetext";
                  repo = "lesswrong-obsidian";
                  rev = "437013fa8ae0f30f5e3cf45b03465c96b998b46b";
                  hash = "sha256-IMeVqPjkLv3ug6my+zaQhieusLXTU0gSFwHpB/6ZCes=";
                };

                installPhase = ''
                  mkdir -p $out
                  cp ./manifest.json $out/manifest.json
                  cp ./preview.png $out/preview.png
                  cp ./theme.css $out/theme.css
                '';
              };
            }
            {
              enable = true;
              pkg = pkgs.stdenv.mkDerivation {
                pname = "Catppuccin";
                version = "0.4.44";

                src = pkgs.fetchFromGitHub {
                  owner = "catppuccin";
                  repo = "obsidian";
                  rev = "v2.0.4";
                  hash = "sha256-fbPkZXlk+TTcVwSrt6ljpmvRL+hxB74NIEygl4ICm2U=";
                };

                # offlineCache = pkgs.fetchYarnDeps {
                #   yarnLock = src + "/yarn.lock";
                #   hash = "sha256-Tf1K048Ox+hImIfrdBWQHsiDe+3FGUQLFBcf/Bbbo1U=";
                # };

                # nativeBuildInputs = [
                #   pkgs.nodejs
                #   pkgs.npmHooks.npmInstallHook
                #   pkgs.pnpm
                # ];

                installPhase = ''
                  # pnpm install
                  # pnpm run build
                  mkdir -p $out
                  cp ./manifest.json $out/manifest.json
                  # cp ./preview.png $out/preview.png
                  cp ./theme.css $out/theme.css
                '';
              };
            }
          ];
        };
      };
    };
  };
}
