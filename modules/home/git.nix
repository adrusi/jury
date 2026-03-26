username:
{ ... }:
{
  imports = [
    ../system/git.nix
  ];

  home-manager.users.${username} = {
    programs.git = {
      enable = true;

      settings = {
        user.name = "Autumn Russell";
        user.email = "autumn@adrusi.com";

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

        alias = {
          co = "checkout";
          br = "branch";
        };
      };

      ignores = [
        ".clangd"
      ];
    };
  };
}
