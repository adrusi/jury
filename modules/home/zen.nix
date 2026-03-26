username:
{ pkgs, inputs, ... }:
{
  imports = [
    ../system/zen.nix
  ];

  home-manager.users.${username} = {
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
          "extensions.autoDisableScopes" = 0;
          "full-screen-api.macos-native-full-screen" = false;
          "signon.rememberSignons" = false;
          "extensions.pocket.enabled" = false;
          "browser.newtabpage.activity-stream.discoverystream.saveToPocketCard.enabled" = false;
          "browser.newtabpage.activity-stream.discoverystream.sendToPocket.enabled" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "browser.urlbar.suggest.pocket" = false;
          "privacy.resistFingerprinting" = false;
          "privacy.trackingprotection.enabled" = false;
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

            "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}".force = true;
            "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}".settings = {
              "max.single.discard" = 50;
              "audio" = true;
              "paused" = false;
              "pinned" = true;
              "form" = true;
              "battery" = false;
              "online" = true;
              "notification.permission" = false;
              "favicon" = false;
              "prepends" = "";
              "faqs" = false;
              "memory-enabled" = false;
              "memory-value" = 60;
              "./plugins/youtube/core.js" = true;
              "./plugins/unloaded/core.js" = true;
              "./plugins/blank/core.js" = true;
            };
          };
        };

        userChrome = "";
        userContent = "";
      };
    };
  };
}
