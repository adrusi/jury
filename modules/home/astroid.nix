username:
{ pkgs, ... }:
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.lieer
      pkgs.notmuch
      pkgs.astroid
      pkgs.w3m
    ];

    accounts.email.maildirBasePath = "Mail";
    accounts.email.accounts.dmodel = {
      primary = true;
      address = "autumn@dmodel.ai";
      userName = "autumn@dmodel.ai";
      realName = "Autumn Sinclair";
      flavor = "gmail.com";
      maildir.path = "dmodel";

      notmuch.enable = true;

      lieer = {
        enable = true;
        sync.enable = true;
        sync.frequency = "*:0/5";
        settings = {
          ignore_tags_local = [ "new" ];
          drop_non_existing_labels = true;
          replace_slash_with_dot = true;
        };
      };

      astroid = {
        enable = true;
        sendMailCommand = "gmi send -t -C ~/Mail/dmodel";
      };
    };

    programs.notmuch = {
      enable = true;
      new.tags = [ "new" ];
      hooks = {
        postNew = ''
          notmuch tag +inbox -- tag:new and folder:dmodel/INBOX
          notmuch tag -new   -- tag:new
        '';
      };
    };

    programs.astroid = let
      nixpkgs-old = import (pkgs.fetchFromGithub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "c7f47036d3df2add644c46d712d14262b7d86c0c";
        hash = "sha256-gyqXNMgk3sh+ogY5svd2eNLJ6oEwzbAeaoBrrxD0lKk=";
      }) { inherit (pkgs) system; config = { allowUnfree = true; }; };
    in {
      enable = true;
      package = nixpkgs-old.astroid;
      extraConfig.poll.interval = 0;
    };
  };
}
