{ config, pkgs, lib, ... }: {
  home-manager.users.${config.system.primaryUser} = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # direnv hook modified to reload shell completions
    programs.zsh.initContent = ''
      _direnv_hook() {
        trap -- "" SIGINT
        eval "$("${lib.getBin pkgs.direnv}/bin/direnv" export zsh)"
        compinit
        trap - SIGINT
      }
      typeset -ag precmd_functions
      if (( ! ''${precmd_functions[(I)_direnv_hook]} )); then
        precmd_functions=(_direnv_hook $precmd_functions)
      fi
      typeset -ag chpwd_functions
      if (( ! ''${chpwd_functions[(I)_direnv_hook]} )); then
        chpwd_functions=(_direnv_hook $chpwd_functions)
      fi
    '';
  };
}
