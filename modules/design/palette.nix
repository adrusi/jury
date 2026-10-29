# Color tokens from design/language.md section 3. That file is the source of
# truth; keep these tables in sync with it. One palette per mode.
{
  dark = {
    # neutrals
    panel = "#1c1b18";
    paper = "#141311";
    rule = "#34312b";
    rule2 = "#5a564d";
    heavy = "#8a8478";
    ink = "#e4dfd3";
    ink2 = "#aaa497";
    dim = "#76716a";

    # signal and state
    signal = "#eea53a";
    second = "#6ea6e6"; # the other mode's signal: second terminal hue
    seltint = "#33291a";
    selgrey = "#2a2823";
    alarm = "#ee5a42";

    # diff (truecolor)
    addbg = "#1c2a19";
    addemph = "#2d4625";
    delbg = "#2e1a16";
    delemph = "#4d241b";

    # ANSI 0-15
    ansi = [
      "#2a2824"
      "#ee5a42"
      "#a2ab84"
      "#eea53a"
      "#6ea6e6"
      "#b49aa8"
      "#94afa9"
      "#c9c3b5"
      "#5f5a51"
      "#ff7a5f"
      "#b7bf98"
      "#ffbd5c"
      "#90bdf0"
      "#c6adba"
      "#a9c2bc"
      "#e4dfd3"
    ];
  };

  light = {
    # neutrals
    panel = "#e4dfd2";
    paper = "#f3efe6";
    rule = "#c6bfaf";
    rule2 = "#948d7e";
    heavy = "#3a3731";
    ink = "#1a1916";
    ink2 = "#4d4943";
    dim = "#857f73";

    # signal and state
    signal = "#1a66cc";
    second = "#a35a00";
    seltint = "#d3e0f2";
    selgrey = "#d6d0c2";
    alarm = "#c02e18";

    # diff (truecolor)
    addbg = "#dcead0";
    addemph = "#bcd9a6";
    delbg = "#f4dad3";
    delemph = "#ebb8aa";

    # ANSI 0-15
    ansi = [
      "#1a1916"
      "#c02e18"
      "#5f6b3c"
      "#a35a00"
      "#1a66cc"
      "#7a5569"
      "#476e66"
      "#c6bfaf"
      "#857f73"
      "#d6402a"
      "#707d4a"
      "#b86d0c"
      "#3b82dc"
      "#8c667b"
      "#588075"
      "#f3efe6"
    ];
  };
}
