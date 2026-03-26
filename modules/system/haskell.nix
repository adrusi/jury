{ ... }:
{
  nix.settings.extra-trusted-public-keys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
  ];
  nix.settings.extra-substituters = [ "https://cache.iog.io" ];
}
