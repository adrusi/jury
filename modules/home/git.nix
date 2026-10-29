username:
{ config, lib, ... }:
let
  p = config.design.palette;
in
{
  imports = [
    ../system/git.nix
    ../design/options.nix
  ];

  home-manager.users.${username} = lib.mkMerge [
    {
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
    }
    {
      # design/language.md 7.7: hashes and modified files in signal, refs in the
      # second hue, errors in alarm; diffs use the truecolor diff tokens with
      # ink text
      programs.git.settings = {
        color = {
          diff = {
            meta = p.ink;
            frag = p.dim;
            commit = p.signal;
            old = "${p.ink} ${p.delbg}";
            new = "${p.ink} ${p.addbg}";
            whitespace = "${p.alarm} reverse";
          };
          status = {
            branch = p.second;
            added = p.second;
            changed = p.signal;
            untracked = p.dim;
            unmerged = p.alarm;
            nobranch = p.alarm;
          };
          branch = {
            current = "${p.second} bold";
            local = p.second;
            remote = p.second;
            upstream = p.second;
          };
          decorate = {
            HEAD = "${p.second} bold";
            branch = p.second;
            remoteBranch = p.second;
            tag = p.second;
            stash = p.dim;
          };
        };
        delta = {
          dark = config.design.mode == "dark";
          light = config.design.mode == "light";
          plus-style = "${p.ink} ${p.addbg}";
          plus-emph-style = "${p.ink} ${p.addemph}";
          minus-style = "${p.ink} ${p.delbg}";
          minus-emph-style = "${p.ink} ${p.delemph}";
          zero-style = p.ink;
          file-style = "${p.ink} bold";
          file-decoration-style = "${p.rule} ul";
          hunk-header-style = "line-number ${p.dim}";
          hunk-header-decoration-style = "none";
          line-numbers = false;
        };
      };
    }
  ];
}
