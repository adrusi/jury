{ config, lib, pkgs, ... }: {
  programs.zsh.enable = true;

  home-manager.users.${config.system.primaryUser} = {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      enableVteIntegration = true;
      defaultKeymap = "emacs";
      history = {
        extended = true;
        share = false;
      };

      initExtraBeforeCompInit = ''
      '';

      initContent = ''
        export LS_COLORS="$(${lib.getBin pkgs.vivid}/bin/vivid generate catppuccin-latte)"
        alias ls="ls --color=auto"

        zstyle ':completion:*' completer _extensions _expand _complete _ignored _correct _approximate _prefix
        zstyle ':completion:*' menu select interactive search
        zstyle ':completion:*' group-name ""
        zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
        zstyle ':completion:*' file-list all
        zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}

        autoload -Uz vcs_info
        zstyle ':vcs_info:*' enable git hg
        zstyle ':vcs_info:*' check-for-changes true
        zstyle ':vcs_info:*' stagedstr '' # 
        zstyle ':vcs_info:*' unstagedstr ''

        [ -n "$ZED_TERM" ] && ZED_WORKSPACE_ROOT="$PWD"
        autoload -U colors
        colors
        setopt prompt_subst
        {
          IFS= read -r PROMPT
          IFS= read -r RPROMPT
          zstyle ':vcs_info:git*' formats "$( ( IFS= read -r line; printf %s "$line"; ) )"
          zstyle ':vcs_info:git*' actionformats "$( ( IFS= read -r line; printf %s "$line"; ) )"
        } < <({
         	bold="%B"
         	italic="%{$(echo -e "\e[3m")%}"
         	cyan="%{$fg[cyan]%}"
         	magenta="%{$fg[magenta]%}"
         	dim="%F{#555}"
          reset="%{$reset_color%}"
          branch_sep=""

          if [ -n "$ZED_TERM" ]; then
           	printf %s\\n "$reset\''${vcs_info_msg_0_}$reset$italic$magenta/\$(realpath --relative-to=\"\$ZED_WORKSPACE_ROOT\" \"\$PWD\" | sed 's/^\.\$//') $reset"
          else
           	printf %s\\n "$reset$cyan%D{%d}$reset$italic%D{%h}$reset$cyan%D{%-H:%M}$reset $([ "$IN_KAKOUNE_CONNECT" ] && printf '[kak %s] ' "$KAKOUNE_SESSION")$italic$cyan%n$reset@$italic''${magenta}%m$reset:$italic$cyan%1~\''${vcs_info_msg_0_} $reset%(#.#.\$) "
          fi

          printf %s\\n ""

          if [ -n "$ZED_TERM" ]; then
           	printf %s\\n "$reset$italic$magenta%r$reset$italic$branch_sep$cyan%b$reset"

           	printf %s\\n "$reset$italic$magenta%r$reset$italic$branch_sep$cyan%b$reset $italic$bold%a$reset"
          else
           	printf %s\\n " $reset$magenta%r$reset$branch_sep$cyan%b$reset%m%u%c"

           	printf %s\\n " $reset$magenta%r$reset$branch_sep$cyan%b$reset $bold%a$reset%m%u%c"
          fi
        })

        autoload -z edit-command-line
        zle -N edit-command-line
        bindkey "^K" edit-command-line

        function man {
          env \
            LESS_TERMCAP_mb=$(printf "\e[1;36m") \
            LESS_TERMCAP_md=$(printf "\e[1;36m") \
            LESS_TERMCAP_me=$(printf "\e[0m") \
            LESS_TERMCAP_se=$(printf "\e[0m") \
            LESS_TERMCAP_so=$(printf "\e[1;45;36m") \
            LESS_TERMCAP_ue=$(printf "\e[0m") \
            LESS_TERMCAP_us=$(printf "\e[1;35m") \
            man "$@"
        }

        export LESSOPEN="| ${lib.getBin pkgs.python312Packages.pygments}/bin/pygmentize -g -f terminal %s"
        export LESS=" -R "

        function mkcd {
            mkdir -p "$1"
            cd "$1"
        }

        real_rm="$(which rm)"
        alias rm="printf 'use \`del'\\''' or %s if you really need rm\\n' $(printf '%q' "$real_rm"); :"
        unset real_rm
        alias del=${lib.getBin pkgs.trash-cli}/bin/trash-put
      '';
    };
  };
}
