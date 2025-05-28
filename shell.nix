{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.git
    pkgs.zed-editor # we often need to run on unconfigured machines, so we provide an editor
  ];
}
