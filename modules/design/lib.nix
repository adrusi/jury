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

  # [ r g b ] -> "#rrggbb"
  hex =
    rgbs:
    "#" + lib.concatMapStrings (c: lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString c))) rgbs;

  # a colour t of the way from a to b (t in [0, 1]), e.g. a tint over paper
  mix =
    a: b: t:
    hex (lib.zipListsWith (x: y: builtins.floor (x + (y - x) * t + 0.5)) (rgb a) (rgb b));
}
