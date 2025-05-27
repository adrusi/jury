{ ... }: {
  nix.linux-builder = {
    enable = true;
    config = import ../../hosts/linux-builder/configuration.nix;
  };
}
