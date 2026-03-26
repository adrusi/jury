{ inputs, ... }:
{
  brew-nix.enable = true;

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "autumn";
    mutableTaps = false;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    global.brewfile = true;
  };
}
