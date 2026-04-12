{ ... }:
{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          capslock = "overload(control, esc)";
          leftcontrol = "layer(hyper)";
          rightalt = "compose";
        };
        "hyper:C-A-S" = { };
      };
    };
  };
}
