{
  config,
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = [
    pkgs.delta
  ];

  home-manager.users.${config.system.primaryUser} = {
    programs.git = {
      enable = true;

      userName = "Autumn Russell";
      userEmail = "autumn@adrusi.com";

      extraConfig = {
        init.defaultBranch = "main";
        pull.ff = "only";
        merge.conflictStyle = "zdiff3";
        rebase.autosquash = true;
        push.autoSetupRemote = true;
        commit.verbose = true;
        rerere.enabled = true;
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        diff.algorithm = "histogram";
        url."git@github.com:".pushInsteadOf = "https://github.com/";
        transfer.fsckobjects = true;
        fetch.fsckobjects = true;
        receive.fsckObjects = true;
        branch.sort = "-committerdate";
        log.date = "iso";
      };

      aliases = {
        co = "checkout";
        br = "branch";
      };

      ignores = [
        ".clangd"
      ];

      # difftastic.enable = true;
    };
  };
}
