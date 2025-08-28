{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.karabiner-elements = {
    enable = true;
    package = pkgs.karabiner-elements.overrideAttrs (old: {
      version = "14.13.0";

      src = pkgs.fetchurl {
        inherit (old.src) url;
        hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
      };

      dontFixup = true;
    });
  };

  home-manager.users.${config.system.primaryUser} = {
    xdg.configFile."karabiner/karabiner.json".text = lib.generators.toJSON { } {
      global = {
        ask_for_confirmation_before_quitting = true;
        check_for_updates_on_startup = false;
        enable_notification_window = false;
        show_in_menu_bar = false;
        show_profile_name_in_menu_bar = false;
        unsafe_ui = false;
      };
      profiles = [
        {
          name = "Default profile";
          selected = true;
          virtual_hid_keyboard = {
            country_code = 0;
            keyboard_type_v2 = "ansi";
          };
          simple_modifications = [
            {
              from = {
                apple_vendor_op_case_key_code = "keyboard_fn";
              };
              to = [ { key_code = "left_control"; } ];
            }
            {
              from = {
                key_code = "caps_lock";
              };
              to = [ { key_code = "caps_lock"; } ];
            }
            {
              from = {
                key_code = "left_control";
              };
              to = [ { apple_vendor_top_case_key_code = "keyboard_fn"; } ];
            }
            {
              from = {
                key_code = "right_option";
              };
              to = [ { key_code = "non_us_backslash"; } ];
            }
          ];
          complex_modifications = {
            rules = [
              {
                description = "Right Cmd → Hyper Key (⌃⌥⇧⌘)";
                manipulators = [
                  {
                    type = "basic";
                    from = {
                      key_code = "right_command";
                      modifiers = {
                        optional = [ "caps_lock" ];
                      };
                    };
                    to = [
                      {
                        key_code = "left_shift";
                        modifiers = [
                          "left_command"
                          "left_control"
                          "left_option"
                        ];
                      }
                    ];
                  }
                ];
              }
              {
                description = "Toggle CAPS_LOCK with LEFT_SHIFT + RIGHT_SHIFT";
                manipulators = [
                  {
                    type = "basic";
                    from = {
                      key_code = "left_shift";
                      modifiers = {
                        mandatory = [ "right_shift" ];
                        optional = [ "caps_lock" ];
                      };
                    };
                    to = [ { key_code = "caps_lock"; } ];
                    to_if_alone = [ { key_code = "left_shift"; } ];
                  }
                  {
                    type = "basic";
                    from = {
                      key_code = "right_shift";
                      modifiers = {
                        mandatory = [ "left_shift" ];
                        optional = [ "caps_lock" ];
                      };
                    };
                    to = [ { key_code = "caps_lock"; } ];
                    to_if_alone = [ { key_code = "right_shift"; } ];
                  }
                ];
              }
              {
                description = "CAPS_LOCK to Ctrl/Escape";
                manipulators = [
                  {
                    type = "basic";
                    from = {
                      key_code = "caps_lock";
                      modifiers = {
                        optional = [ "any" ];
                      };
                    };
                    to = [ { key_code = "left_control"; } ];
                    to_if_alone = [ { key_code = "escape"; } ];
                  }
                ];
              }
            ];
          };
        }
      ];
    };
  };
}
