{ config, ... }: {
  security.pam.services.sudo_local = {
    reattach = true;
    touchIdAuth = true;
  };

  homebrew.casks = ["secretive"];

  home-manager.users.${config.system.primaryUser}.programs.ssh.matchBlocks."*" = {
    identityAgent = "${config.users.users.${config.system.primaryUser}.home}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
  };
}
