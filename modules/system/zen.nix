{ inputs, ... }:
{
  imports = [
    inputs.zen-browser.nixosModules.zen-browser
  ];
}
