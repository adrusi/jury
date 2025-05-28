{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.brew-nix.darwinModules.default
    inputs.mac-app-util.darwinModules.default
    ../../modules/system-common/nix-store.nix
    ../../modules/system-darwin/linux-builder.nix
    ../../modules/system-darwin/touchid.nix
    ../../modules/system-darwin/macos-settings.nix
    ../../modules/system-darwin/karabiner-elements.nix
    ../../modules/system-darwin/homebrew.nix
  ];

  system.stateVersion = 6;
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "autumn";
  nix.settings.allowed-users = ["@admin"];

  system.defaults = {
    loginwindow.GuestEnabled = false;
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    dock.persistent-apps = [

    ];
  };

  networking = {
    computerName = "rainbow";
    hostName = "rainbow";
    localHostName = "rainbow";
  };

  programs.zsh.enable = true;

  environment.systemPackages = [
  ];

  homebrew = {
    enable = true;
    brews = [

    ];
    casks = [
      "secretive"
    ];
    masApps = {

    };
  };
}
