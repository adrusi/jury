{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.mac-app-util.homeManagerModules.default
    ../../modules/home/karabiner-elements.nix
  ];
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  nixpkgs = {
    overlays = [
      inputs.brew-nix.overlays.default
    ];
  };

  home.packages = [
  #   pkgs.brewCasks.bettertouchtool
    pkgs.brewCasks.betterdisplay
  ];
}
