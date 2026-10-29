# Kakoune colorscheme for design/language.md, rendered from a design palette.
# Most syntax is ink, structure is carried by weight and italic, and the hue
# budget is spent on keywords/types (second), literals (signal), and errors
# (alarm). Comments are dim. Editor chrome follows the desktop: panel for
# chrome, paper for the buffer, selections in the selection tints.
p:
let
  c = hex: "rgb:${builtins.substring 1 6 hex}";
  ink = c p.ink;
  ink2 = c p.ink2;
  dim = c p.dim;
  rule = c p.rule;
  rule2 = c p.rule2;
  paper = c p.paper;
  panel = c p.panel;
  signal = c p.signal;
  second = c p.second;
  seltint = c p.seltint;
  selgrey = c p.selgrey;
  alarm = c p.alarm;
in
''
  # For Code
  face global value     ${signal}
  face global type      ${second}
  face global variable  default
  face global module    ${ink2}
  face global function  default+b
  face global string    ${signal}
  face global keyword   ${second}
  face global operator  default
  face global attribute ${second}+i
  face global comment   ${dim}+i
  face global meta      ${dim}
  face global builtin   default+b

  # For markup
  face global title  default+b
  face global header default+b
  face global bold   default+b
  face global italic default+i
  face global mono   ${signal}
  face global block  ${ink2}
  face global link   ${second}+u
  face global bullet default
  face global list   default

  # builtin faces
  face global Default            ${ink},${paper}
  face global PrimarySelection   ${ink},${seltint}+g
  face global SecondarySelection ${ink},${selgrey}+g
  face global PrimaryCursor      ${paper},${signal}+fg
  face global SecondaryCursor    ${paper},${ink2}+fg
  face global PrimaryCursorEol   ${paper},${signal}+fg
  face global SecondaryCursorEol ${paper},${ink2}+fg
  face global LineNumbers        ${dim},${paper}
  face global LineNumbersWrapped ${rule2},${paper}
  face global LineNumberCursor   ${ink},${paper}+b
  face global WrapMarker         ${rule2},${paper}
  face global MenuForeground     ${signal},${seltint}
  face global MenuBackground     ${ink},${panel}
  face global MenuInfo           ${ink2},${panel}
  face global Error              default,default,${alarm}+c
  face global Information        ${ink},${panel}
  face global StatusLine         ${ink},${panel}
  face global StatusLineMode     ${signal},${panel}
  face global StatusLineInfo     ${ink2},${panel}
  face global StatusLineValue    ${signal},${panel}
  face global StatusCursor       ${paper},${signal}
  face global Prompt             ${signal},${panel}
  face global MatchingChar       default,${selgrey}+b
  face global BufferPadding      ${dim},${paper}
  face global Whitespace         ${rule},${paper}+f

  # lsp
  face global DiagnosticHint            default,default,${rule2}+c
  face global DiagnosticInfo            default,default,${dim}+c
  face global DiagnosticWarning         default,default,${signal}+c
  face global DiagnosticError           default,default,${alarm}+c
  face global InlayDiagnosticHint       ${dim},default
  face global InlayDiagnosticInfo       ${dim},default
  face global InlayDiagnosticWarning    ${signal},default
  face global InlayDiagnosticError      ${alarm},default
  face global InlayHint                 ${dim},default
  face global LineFlagHint              ${dim},default
  face global LineFlagInfo              ${dim},default
  face global LineFlagWarning           ${signal},default
  face global LineFlagError             ${alarm},default
  face global Reference                 default,default,${dim}+u
  face global ReferenceBind             default,default,${ink2}+ub
  face global SnippetsOtherPlaceholders default,${selgrey}
  face global SnippetsNextPlaceholders  default,${seltint}
  face global documentation             default

  # peneira (fuzzy finder): the selected candidate is a selection
  face global PeneiraSelected  ${signal},${seltint}
  face global PeneiraFlag      ${signal},default+b
  face global PeneiraMatches   ${signal},default+u
''
