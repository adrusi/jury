{ config, pkgs, ... }:
{
  home-manager.users.${config.system.primaryUser} = {
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
      package = (if pkgs.stdenv.isDarwin then pkgs.brewCasks.zed else pkgs.zed-editor);
      installRemoteServer = true;

      extensions = [
        "assembly"
        "basedpyright"
        "basher"
        "catppuccin"
        "catppuccin-icons"
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
        auto_update = pkgs.stdenv.isDarwin;
        base_keymap = "VSCode";
        buffer_font_size = 10;
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
        ui_font_size = 12;
        theme = "Catppuccin Latte";
        icon_theme = "Catppuccin Latte";
        terminal = {
          blinking = "off";
          font_size = 10;
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
