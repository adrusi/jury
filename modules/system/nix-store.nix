{ pkgs, ... }: {
  nix = if pkgs.stdenv.isLinux then {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
      dates = "weekly";
    };
  } else {
    optimise = {
      automatic = true;
      interval = { Hour = 0; Minute = 0; };
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
      interval = { Hour = 0; Minute = 0; };
    };
  };
}
