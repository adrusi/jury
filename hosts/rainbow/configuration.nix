{ config, pkgs, inputs, ... }: {
  imports = [
    ../../modules/system-common/nix-store.nix
    ../../modules/system-darwin/linux-builder.nix
    ../../modules/system-darwin/touchid.nix
    ../../modules/system-darwin/macos-settings.nix
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


  services.karabiner-elements.enable = true;

  programs.zsh.enable = true;

  environment.systemPackages = [
  ];
}
