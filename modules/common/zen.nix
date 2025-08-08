{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.zen-browser.nixosModules.zen-browser
  ];

  home-manager.users.${config.system.primaryUser} = {
    imports = [
      inputs.zen-browser.homeManagerModules.zen-browser
    ];

    programs.zen-browser = {
      enable = true;
      package = (if pkgs.stdenv.isDarwin then pkgs.brewCasks.zen else pkgs.zen-browser);

      profiles.default = {
        id = 0;
        isDefault = true;

        search = {
          force = true;
          default = "ddg";
        };

        settings = {
          # auto-enable extensions installed via nix
          "extensions.autoDisableScopes" = 0;

          # prevent fullscreen youtube videos creating a new workspace on macos
          "full-screen-api.macos-native-full-screen" = false;

          # use bitwarden instead of built-in password manager
          "signon.rememberSignons" = false;

          # the most annoying useless firefox antifeature
          "extensions.pocket.enabled" = false;
          "browser.newtabpage.activity-stream.discoverystream.saveToPocketCard.enabled" = false;
          "browser.newtabpage.activity-stream.discoverystream.sendToPocket.enabled" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "browser.urlbar.suggest.pocket" = false;

          # some of the milder privacy enhancements
          "privacy.resistFingerprinting" = false; # set to false to see if this is whats breaking image uploads
          "privacy.trackingprotection.enabled" = false; # set to false to see if this is whats breaking image uploads

          # rendering performance
          "layout.frame_rate.precise" = true;
          "webgl.force-enabled" = true;
          "layers.acceleration.force-enabled" = true;
          "layers.offmainthreadcomposition.enabled" = true;
          "layers.offmainthreadcomposition.async-animations" = true;
          "layers.async-video.enabled" = true;
          "html5.offmainthread" = true;
        };

        extensions = {
          force = true;

          packages =
            let
              addons = inputs.firefox-addons.packages.${pkgs.system};
            in
            [
              addons.auto-tab-discard
              addons.bitwarden
              addons.reddit-enhancement-suite
              addons.sponsorblock
              addons.ublock-origin
              addons.zotero-connector
              addons.shinigami-eyes
            ];

          settings = {
            "uBlock0@raymondhill.net".settings = {
              selectedFilterLists = [
                "user-filters"
                "ublock-filters"
                "ublock-badware"
                "ublock-privacy"
                "ublock-quick-fixes"
                "ublock-unbreak"
                "easylist"
                "easyprivacy"
                "urlhaus-1"
                "plowe-0"
                "fanboy-cookiemonster"
                "ublock-cookies-easylist"
                "adguard-cookies"
                "ublock-cookies-adguard"
                "fanboy-social"
                "adguard-social"
                "fanboy-thirdparty_social"
                "easylist-chat"
                "easylist-newsletters"
                "easylist-notifications"
                "easylist-annoyances"
                "adguard-mobile-app-banners"
                "adguard-other-annoyances"
                "adguard-popup-overlays"
                "adguard-widgets"
                "ublock-annoyances"
              ];
            };

            # auto-tab-discard
            "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}".force = true;
            "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}".settings = {
              "max.single.discard" = 50; # Maximum number of tabs to check for discarding per single automatic discarding request
              "audio" = true; # Do not discard a tab when media is playing
              "paused" = false; # Do not discard a tab when there is a paused media player
              "pinned" = true; # Do not discard a tab when it is pinned
              "form" = true; # Do not discard a tab when form changes are not yet submitted
              "battery" = false; # Do not discard tabs when the computer is connected to a power source
              "online" = true; # Do not discard tabs when there is no internet connection and the tab is not cached
              "notification.permission" = false; # Do not discard a tab if it can display desktop notifications
              "favicon" = false; # Change favicon of discarded tabs (if possible)
              "prepends" = ""; # Prepend a symbol to the discarded tabs (e.g. 💤 or ⏻︎) (if possible)
              "faqs" = false; # Open FAQs page on updates
              "memory-enabled" = false; # Discard a background tab if its memory usage (totalJSHeapSize) exceeds (in MB)
              "memory-value" = 60; # Discard a background tab if its memory usage (totalJSHeapSize) exceeds (in MB)
              "./plugins/youtube/core.js" = true; # Store YouTube's timestamp before discarding
              "./plugins/unloaded/core.js" = true; # Discard all unloaded tabs on browser startup. This method discards almost all inactive tabs.
              "./plugins/blank/core.js" = true; # Open a temporary blank page when all tabs in an inactive window are discarded (to be able to discard the active tab on this window)
            };
          };
        };

        userChrome = "";
        userContent = "";
      };
    };
  };
}
