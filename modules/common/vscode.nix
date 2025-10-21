{
  config,
  pkgs,
  ...
}:
{
  home-manager.users.${config.system.primaryUser} = {
    home.packages = [
      # needed for jupyter extension?
      pkgs.zeromq
    ];

    programs.git.ignores = [
      ".vscode/"
    ];
    programs.vscode = {
      enable = true;
      mutableExtensionsDir = false;
      # mutableExtensionsDir = true;
      profiles.default = {
        keybindings = [

        ];
        userSettings = {
          # telemetry
          "telemetry.telemetryLevel" = "off";

          # theming
          "workbench.colorTheme" = "Catppuccin Latte";
          "workbench.iconTheme" = "catppuccin-latte";

          # type
          "window.zoomLevel" = -1;
          "editor.fontSize" = 12;
          "debug.console.fontSize" = 12;
          "terminal.integrated.fontSize" = 12;

          # nicer suggestion ui
          "editor.suggestSelection" = "first";
          "editor.acceptSuggestionOnCommitCharacter" = false;
          "editor.acceptSuggestionOnEnter" = "off";
          "editor.tabCompletion" = "on";
          "editor.quickSuggestionsDelay" = 0;
          "editor.quickSuggestions" = {
            "other" = false;
            "comments" = false;
            "strings" = false;
          };

          # hide ui cruft
          "breadcrumbs.enabled" = false;
          "editor.hideCursorInOverviewRuler" = true;
          "window.menuBarVisibility" = "toggle";
          "editor.minimap.enabled" = false;
          "workbench.colorCustomizations" = {
            "editorOverviewRuler.bracketMatchForeground" = "#0000";
            "editorOverviewRuler.infoForground" = "#0000";
            "editorOverviewRuler.rangeHighlightForeground" = "#0000";
            "editorOverviewRuler.wordHighlighForeground" = "#0000";
            "editorOverviewRuler.border" = "#0000";
            "editorOverviewRuler.selectionHighlightForeground" = "#0000";
            "scrollbar.shadow" = "#0000";
            "widget.shadow" = "#0000";
          };

          # misc ui
          "workbench.list.smoothScrolling" = true;
          "editor.fontLigatures" = false;
          "editor.bracketPairColorization.enabled" = false;
          "window.titleBarStyle" = "native";
          "workbench.startupEditor" = "none";
          "terminal.integrated.smoothScrolling" = true;
          "editor.stickyScroll.enabled" = false;
          "workbench.activityBar.location" = "top";
          "window.customTitleBarVisibility" = "never";

          # tell terminals theyre in vscode
          "terminal.integrated.env.osx" = {
            "VSCODE_INTEGRATED_TERMINAL" = "true";
            "VSCODE_WORKSPACE_ROOT" = "\${workspaceFolder}";
          };
          "terminal.integrated.env.linux" = {
            "VSCODE_INTEGRATED_TERMINAL" = "true";
            "VSCODE_WORKSPACE_ROOT" = "\${workspaceFolder}";
          };
          "terminal.integrated.env.windows" = {
            "VSCODE_INTEGRATED_TERMINAL" = "true";
            "VSCODE_WORKSPACE_ROOT" = "\${workspaceFolder}";
          };

          # misc
          "search.useGlobalIgnoreFiles" = true;
          "explorer.confirmDragAndDrop" = false;
          "editor.renderLineHighlight" = "gutter";
          "editor.multiCursorModifier" = "ctrlCmd";
          "editor.autoSurround" = "never";
          "files.trimTrailingWhitespace" = true;
          "explorer.confirmDelete" = false;
          "files.autoSave" = "off";
          "testExplorer.codeLens" = true;
          "terminal.integrated.macOptionIsMeta" = true;
          "update.mode" = "manual";
          "jupyter.askForKernelRestart" = false;

          # "extensions.experimental.affinity" = {
          #   "ms-toolsai.jupyter" = 1;
          #   "ms-toolsai.jupyter-renderers" = 1;
          #   "ms-python.python" = 1;
          #   "ms-python.vscode-pylance" = 1;
          # };

          # languages
          "julia.symbolCacheDownload" = true;
          "julia.enableTelemetry" = false;
          # "julia.executablePath" = "${
          #   lib.getBin (if pkgs.stdenv.isDarwin then pkgs.julia-bin else pkgs.julia)
          # }/bin/julia";
          "julia.execution.codeInREPL" = true;

          "haskell.manageHLS" = "PATH";
          "[haskell][literate haskell]" = {
            "editor.tabSize" = 2;
          };

          "[agda][lagda-forester][lagda-markdown][lagda-org][lagda-rst][lagda-tex][lagda-typst]" = {
            "editor.unicodeHighlight.ambiguousCharacters" = false;
          };

          "[agda]" = {
            "editor.tabSize" = 2;
          };
        };
        extensions = [
          pkgs.vscode-extensions.mkhl.direnv
          pkgs.vscode-extensions.jnoortheen.nix-ide

          pkgs.vscode-extensions.catppuccin.catppuccin-vsc
          pkgs.vscode-extensions.catppuccin.catppuccin-vsc-icons

          pkgs.vscode-extensions.ms-toolsai.jupyter

          pkgs.vscode-extensions.julialang.language-julia

          pkgs.vscode-extensions.haskell.haskell
          pkgs.vscode-extensions.justusadam.language-haskell
          # pkgs.vscode-extensions.hoovercj.haskell-linter

          pkgs.vscode-extensions.ms-python.python
          pkgs.vscode-extensions.ms-python.vscode-pylance
          pkgs.vscode-extensions.ms-python.debugpy
          # pkgs.vscode-extensions.ms-python.vscode-python-envs

          pkgs.vscode-extensions.banacorn.agda-mode
        ];
      };
    };
  };
}
