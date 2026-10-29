{ lib }:
rec {
  # "#rrggbb" -> [ r g b ] (decimal)
  rgb =
    hex:
    let
      h = lib.toLower (lib.removePrefix "#" hex);
      digits = lib.stringToCharacters "0123456789abcdef";
      val = c: lib.lists.findFirstIndex (d: d == c) (throw "bad hex digit '${c}'") digits;
      byte = i: val (lib.substring i 1 h) * 16 + val (lib.substring (i + 1) 1 h);
    in
    map byte [
      0
      2
      4
    ];

  # SGR truecolor foreground, e.g. for LS_COLORS: "38;2;r;g;b"
  sgrFg = hex: "38;2;" + lib.concatMapStringsSep ";" toString (rgb hex);

  # "#rrggbb" -> "rrggbb" (kakoune's rgb:, ghostty)
  bare = lib.removePrefix "#";
}
