{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
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
    ../modules/common/vscode.nix
    ../modules/common/haskell.nix
    # ../modules/common/zen.nix
    ../modules/common/ghostty.nix
    ../modules/common/pragmatapro.nix
    ../modules/common/zsh.nix
    ../modules/common/direnv.nix
    ../modules/common/mpv.nix
    ../modules/common/git.nix
    ../modules/common/ssh.nix
    ../modules/common/obsidian.nix
    ../modules/common/kak/module.nix
    # ../modules/darwin/linux-builder.nix
    ../modules/darwin/touchid.nix
    ../modules/darwin/macos-settings.nix
    ../modules/darwin/karabiner-elements.nix
    ../modules/darwin/homebrew.nix
    ../modules/darwin/bartender.nix
  ];

  # system.activationScripts.applications.text = lib.mkForce "";

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

  environment.systemPackages = [
    # pkgs.libation
    pkgs.yt-dlp
    pkgs.git
    pkgs.claude-code
    pkgs.zulu25
    pkgs.zulu17
  ];

  nix-homebrew.taps = {
    "italomandara/homebrew-cxpatcher" = inputs.brewtap-cxpatcher;
  };

  homebrew.casks = [
    "betterdisplay"
    "mullvad-vpn"
    "crossover"
    "steam"
    "transmission"
    "gimp"
    "inkscape"
    "racket"
    "italomandara/CXPatcher/cxpatcher"
    "zoom"
    "calibre"
    "spotify"
    "multimc"
  ];

  users.users.autumn.name = "autumn";
  users.users.autumn.home = "/Users/autumn";
  system.primaryUser = "autumn";
  nix.settings.allowed-users = [ "@admin" ];

  home-manager.extraSpecialArgs = {
    inherit inputs;
  };
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "home-manager-backup";

  home-manager.users.${config.system.primaryUser} = {
    imports = [
      inputs.mac-app-util.homeManagerModules.default
    ];

    # NOTE: massive hack. see https://github.com/nix-community/home-manager/issues/8336
    home.stateVersion = "23.11";
    # home.stateVersion = "25.11";
    programs.home-manager.enable = true;

    home.packages = [
      pkgs.brewCasks.claude
      pkgs.brewCasks.signal
      pkgs.brewCasks.supercollider
      pkgs.prismlauncher
    ];

    programs.ssh.enable = true;
  };
}
