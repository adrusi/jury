{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.brew-nix.darwinModules.default
    inputs.mac-app-util.darwinModules.default
    ../modules/common/nix-store.nix
    ../modules/common/firefox.nix
    ../modules/common/bitwarden.nix
    ../modules/common/discord.nix
    ../modules/common/zed.nix
    ../modules/common/ghostty.nix
    ../modules/common/pragmatapro.nix
    ../modules/common/zsh.nix
    ../modules/common/direnv.nix
    ../modules/common/kak/module.nix
    ../modules/darwin/linux-builder.nix
    ../modules/darwin/touchid.nix
    ../modules/darwin/macos-settings.nix
    ../modules/darwin/karabiner-elements.nix
    ../modules/darwin/homebrew.nix
  ];

  system.stateVersion = 6;
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  system.defaults = {
    loginwindow.GuestEnabled = false;
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
  };

  networking = {
    computerName = "rainbow";
    hostName = "rainbow";
    localHostName = "rainbow";
  };

  homebrew.casks = [
    "betterdisplay"
  ];

  users.users.autumn.name = "autumn";
  users.users.autumn.home = "/Users/autumn";
  system.primaryUser = "autumn";
  nix.settings.allowed-users = ["@admin"];

  home-manager.extraSpecialArgs = {
    inherit inputs;
  };
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "home-manager-backup";

  home-manager.users.${config.system.primaryUser} = {
    imports = [
      inputs.mac-app-util.homeManagerModules.default
    ];

    home.stateVersion = "25.11";
    programs.home-manager.enable = true;

    home.packages = [
      pkgs.brewCasks.claude
    ];

    programs.ssh.enable = true;
  };
}
