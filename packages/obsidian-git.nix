{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "obsidian-git";
  version = "2.34.0";

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
}
