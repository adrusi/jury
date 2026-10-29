username:
{ pkgs, lib, config, ... }:
let
  design = config.design.enable;
  themeJson = import ./zed-theme.nix {
    inherit (config.design) mode;
    p = config.design.palette;
  };
in
{
  imports = [
    ../stylesheet/options.nix
    ../design/options.nix
  ];

  home-manager.users.${username} = {
    home.packages = [
      pkgs.nil
      pkgs.nixd
      pkgs.basedpyright
    ];

    programs.git.ignores = [
      ".zed/"
    ];

    programs.zed-editor = {
      enable = true;
      package = pkgs.zed-editor;
      installRemoteServer = true;

      themes = lib.optionalAttrs design { datasheet = themeJson; };

      extensions = lib.optionals (!design) config.stylesheet.zed.extensions ++ [
        "agda"
        "assembly"
        "basedpyright"
        "basher"
        "clojure"
        "docker-compose"
        "dockerfile"
        "gdscript"
        "git-firefly"
        "graphviz"
        "haskell"
        "html"
        "java"
        "julia"
        "latex"
        "lilypond"
        "make"
        "marksman"
        "meson"
        "neocmake"
        "nginx"
        "nix"
        "python-requirements"
        "ruby"
        "ruff"
        "scheme"
        "toml"
        "typst"
        "xml"
        "zig"
      ];

      userSettings = {
        vim_mode = false;
        bottom_dock_layout = "left_aligned";
        autosave = "off";
        restore_on_startup = "last_session";
        auto_update = false;
        base_keymap = "VSCode";
        buffer_font_family = config.stylesheet.fonts.monoLiga;
        buffer_font_size = config.stylesheet.sizes.zedBuffer;
        buffer_line_height = "standard";
        scrollbar = {
          selected_text = false;
          selected_symbol = false;
          cursors = false;

          git_diff = true;
          search_results = true;
          diagnostics = "all";

          show = "auto";
          axes = {
            horizontal = true;
            vertical = true;
          };
        };
        minimap.show = "never";
        tab_bar = {
          show = true;
          show_nav_history_buttons = false;
          show_tab_bar_buttons = false;
        };
        tabs = {
          activate_on_close = "neighbour";
          git_status = true;
        };
        toolbar = {
          breadcrumbs = false;
          quick_actions = false;
          selections_menu = false;
          agent_review = false;
          code_actions = false;
        };
        enable_language_server = true;
        diagnostics.inline = {
          enabled = true;
          max_severity = null;
        };
        ensure_final_newline_on_save = true;
        format_on_save = "on";
        indent_guides.enabled = false;
        ui_font_size = config.stylesheet.sizes.zedUi;
        theme = if design then themeJson.name else config.stylesheet.zed.theme;
        # zed's default icons are monochrome, which suits the hue budget
        icon_theme = if design then "Zed (Default)" else config.stylesheet.zed.iconTheme;
        terminal = {
          blinking = "off";
          font_family = config.stylesheet.fonts.monoLiga;
          font_size = config.stylesheet.sizes.zedTerminal;
          line_height = "standard";
          option_as_meta = true;
          button = false;
          toolbar.breadcrumbs = false;
          working_directory = "first_project_directory";
        };
        edit_predictions.mode = "subtle";
      };
    };
  };
}
