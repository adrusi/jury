{ ... }: {
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
  system.defaults = {
    NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;

    NSGlobalDomain.NSDisableAutomaticTermination = false;

    NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";

    NSGlobalDomain.AppleICUForce24HourTime = true;
    menuExtraClock.Show24Hour = true;

    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint = true;

    NSGlobalDomain.AppleShowAllExtensions = true;
    finder.AppleShowAllExtensions = true;
    finder.FXEnableExtensionChangeWarning = false;

    trackpad.TrackpadThreeFingerDrag = true;

    NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
    NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
    NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    NSGlobalDomain.InitialKeyRepeat = 25;
    NSGlobalDomain.KeyRepeat = 4;

    NSGlobalDomain.AppleSpacesSwitchOnActivate = false;
    dock.mru-spaces = false;
    spaces.spans-displays = false;

    dock.autohide = true;
    dock.autohide-delay = 0.0;
    dock.show-recents = false;
    dock.expose-animation-duration = 0.01;
    dock.expose-group-apps = true;
    dock.showhidden = true;

    WindowManager.EnableTiledWindowMargins = false;
    WindowManager.StandardHideDesktopIcons = true;
    WindowManager.StandardHideWidgets = true;

    finder.CreateDesktop = false;
    finder.FXPreferredViewStyle = "clmv"; # column view
    finder.FXRemoveOldTrashItems = true; # remove items after theyve been in trash for 30 days
    finder.NewWindowTarget = "Home";
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;

    hitoolbox.AppleFnUsageType = "Do Nothing";

    screencapture.disable-shadow = true;
    screencapture.location = "~/Pictures/Screenshots"; # note: will not create directory; macos will fallback to ~/Desktop if not created manually
    screencapture.show-thumbnail = true;
    screencapture.type = "png";

    controlcenter.NowPlaying = false;
  };
}
