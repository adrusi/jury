# Firefox userChrome.css for design/language.md (section 7.10), rendered from
# a design palette. Written against Firefox's Nova chrome (browser.nova.enabled,
# the default since ~150): it overrides Nova's design tokens where they're
# declared and restyles the few structures tokens don't reach. The tab strip
# and sidebar are hidden elsewhere (sway draws tabs), so the chrome is one
# toolbar: buttons as square cells either side of a full-height URL field.
{
  lib,
  p,
  fonts,
  # toolbar height in CSS px: the sway titlebar height over Firefox's
  # devPixelsPerPx, so the toolbar lines up with the vtab rows beside it
  toolbarHeight,
  # one device pixel in CSS px
  devPx,
  # selection rules, device px
  ruleVertical,
  ruleHorizontal,
}:
let
  css = n: "${toString n}px";
  h = css toolbarHeight;
  hair = css devPx;
  vrule = css (ruleVertical * devPx);
  hrule = css (ruleHorizontal * devPx);

  # 16x16 line icons on a 1.5px stroke with square caps and mitred joins.
  # Firefox only resolves context-fill in fill, so the strokes are a mask over
  # a context-fill rect: the icons take the toolbar's icon color in every state.
  icon =
    body:
    let
      svg = "<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 16 16'><mask id='m'><g fill='none' stroke='white' stroke-width='1.5' stroke-linecap='square' stroke-linejoin='miter'>${body}</g></mask><rect width='16' height='16' fill='context-fill' mask='url(#m)'/></svg>";
    in
    ''url("data:image/svg+xml,${
      builtins.replaceStrings [ "#" "<" ">" "\"" ] [ "%23" "%3C" "%3E" "'" ] svg
    }")'';
  icons = {
    back = icon "<path d='M3.5 8h9.5'/><path d='M7.5 4 3.5 8l4 4'/>";
    forward = icon "<path d='M2.5 8h10'/><path d='M8.5 4l4 4-4 4'/>";
    reload = icon "<path d='M12.5 8a4.5 4.5 0 1 1-1.32-3.18'/><path d='M11.5 2v3h-3'/>";
    stop = icon "<path d='M4 4l8 8M12 4l-8 8'/>";
    menu = icon "<path d='M2.5 4h11M2.5 8h11M2.5 12h11'/>";
    extensions = icon "<path d='M2.5 2.5h4v4h-4zM9.5 2.5h4v4h-4zM2.5 9.5h4v4h-4zM9.5 9.5h4v4h-4z'/>";
    downloads = icon "<path d='M8 2.5v8'/><path d='M4.5 7 8 10.5 11.5 7'/><path d='M2.5 13.5h11'/>";
    account = icon "<path d='M5.5 5.5a2.5 2.5 0 1 0 5 0a2.5 2.5 0 1 0-5 0'/><path d='M3 13.5c.5-2.5 2.5-4 5-4s4.5 1.5 5 4'/>";
    sidebar = icon "<path d='M2.5 3.5h11v9h-11zM6 3.5v9'/>";
  };

  # token overrides; applied to the elements that redeclare them as well as
  # :root, since a declaration on a descendant beats one inherited from :root
  tokens = ''
    --toolbox-background-color: ${p.panel} !important;
    --toolbox-background-color-inactive: ${p.panel} !important;
    --toolbox-text-color: ${p.ink} !important;
    --toolbox-text-color-inactive: ${p.ink} !important;
    --toolbar-background-color: ${p.panel} !important;
    --toolbar-text-color: ${p.ink} !important;
    --toolbarseparator-color: ${p.rule} !important;
    --chrome-content-separator-color: ${p.rule} !important;
    --tabs-navbar-separator-color: ${p.rule} !important;
    --content-area-shadow: none !important;

    --toolbar-field-background-color: ${p.paper} !important;
    --toolbar-field-background-color-focus: ${p.paper} !important;
    --toolbar-field-text-color: ${p.ink} !important;
    --toolbar-field-text-color-focus: ${p.ink} !important;
    --toolbar-field-border-color: ${p.rule} !important;
    --toolbar-field-border-color-focus: ${p.signal} !important;

    --toolbarbutton-border-radius: 0 !important;
    --toolbarbutton-icon-fill: ${p.ink2} !important;
    --toolbarbutton-icon-fill-hover: ${p.ink} !important;
    --toolbarbutton-icon-fill-active: ${p.signal} !important;
    --toolbarbutton-icon-fill-attention: ${p.signal} !important;
    --toolbarbutton-icon-fill-attention-text: ${p.paper} !important;
    --toolbarbutton-background-color: transparent !important;
    --toolbarbutton-background-color-hover: ${p.selgrey} !important;
    --toolbarbutton-background-color-active: ${p.seltint} !important;
    --toolbarbutton-outline-color: transparent !important;
    --toolbarbutton-outline-color-hover: transparent !important;
    --toolbarbutton-outline-color-active: transparent !important;
    --toolbarbutton-badge-background-color: ${p.signal} !important;

    --focus-outline-color: ${p.signal} !important;
    --color-accent-primary: ${p.signal} !important;
    --color-accent-primary-hover: ${p.signal} !important;
    --color-accent-primary-active: ${p.signal} !important;
    --color-accent-primary-selected: ${p.signal} !important;
    --color-accent-attention: ${p.signal} !important;
    --link-color: ${p.ink} !important;
    --link-color-hover: ${p.signal} !important;
    --link-color-active: ${p.signal} !important;

    --text-color: ${p.ink} !important;
    --text-color-deemphasized: ${p.ink2} !important;
    --text-color-disabled: ${p.dim} !important;
    --text-color-error: ${p.alarm} !important;
    --background-color-box: ${p.panel} !important;
    --background-color-canvas: ${p.paper} !important;
    --background-color-list-item-hover: ${p.selgrey} !important;
    --border-color: ${p.rule} !important;
    --border-color-deemphasized: ${p.rule} !important;
    --border-color-interactive: ${p.rule2} !important;
    --border-color-interactive-hover: ${p.ink2} !important;
    --border-color-selected: ${p.signal} !important;

    --border-radius-xsmall: 0 !important;
    --border-radius-small: 0 !important;
    --border-radius-medium: 0 !important;
    --border-radius-large: 0 !important;
    --border-radius-xlarge: 0 !important;
    --button-border-radius: 0 !important;
    --button-background-color: ${p.panel} !important;
    --button-background-color-hover: ${p.selgrey} !important;
    --button-background-color-active: ${p.seltint} !important;
    --button-border-color: ${p.rule2} !important;
    --button-text-color: ${p.ink} !important;
    --button-text-color-hover: ${p.ink} !important;
    --button-text-color-active: ${p.signal} !important;
    --button-background-color-primary: ${p.panel} !important;
    --button-background-color-primary-hover: ${p.selgrey} !important;
    --button-background-color-primary-active: ${p.seltint} !important;
    --button-border-color-primary: ${p.signal} !important;
    --button-text-color-primary: ${p.signal} !important;
    --button-text-color-primary-hover: ${p.signal} !important;
    --button-text-color-primary-active: ${p.signal} !important;
    --button-background-color-menu-hover: ${p.selgrey} !important;
    --button-background-color-menu-active: ${p.seltint} !important;
    --button-text-color-menu-hover: ${p.ink} !important;
    --button-background-color-toolbar-hover: ${p.selgrey} !important;
    --button-background-color-toolbar-active: ${p.seltint} !important;

    --panel-background-color: ${p.panel} !important;
    --panel-text-color: ${p.ink} !important;
    --panel-border-color: ${p.rule} !important;
    --panel-border-radius: 0 !important;
    --panel-box-shadow: none !important;
    --panel-menuitem-border-radius: 0 !important;
    --panel-separator-color: ${p.rule} !important;
    --panel-footer-background-color: ${p.panel} !important;
    --panel-icon-fill: ${p.ink2} !important;
    --menuitem-border-radius: 0 !important;

    --urlbar-border-radius: 0 !important;
    --urlbar-inner-border-radius: 0 !important;
    --urlbar-background-border-radius: 0 !important;
    --urlbar-box-background-color: transparent !important;
    --urlbar-box-background-color-hover: ${p.selgrey} !important;
    --urlbar-box-background-color-active: ${p.seltint} !important;
    --urlbar-box-text-color: ${p.ink2} !important;
    --urlbar-box-text-color-hover: ${p.ink} !important;
    --urlbar-box-text-color-active: ${p.signal} !important;
    --urlbarview-border-radius: 0 !important;
    --urlbarview-row-border-radius: 0 !important;
    --urlbarview-icon-border-radius: 0 !important;
    --urlbarview-background-color-hover: ${p.selgrey} !important;
    --urlbarview-background-color-selected: ${p.seltint} !important;
    --urlbarview-text-color-hover: ${p.ink} !important;
    --urlbarview-text-color-selected: ${p.signal} !important;
    --urlbarview-text-color-secondary: ${p.dim} !important;
    --urlbarview-text-color-action: ${p.ink2} !important;
    --urlbarview-separator-color: ${p.rule} !important;
    --urlbarview-result-button-selected-background-color: ${p.seltint} !important;
    --urlbarview-result-button-selected-color: ${p.signal} !important;
    --urlbarview-result-button-hover-background-color: ${p.selgrey} !important;
    --urlbarview-result-button-hover-color: ${p.ink} !important;
    /* the URL field: paper inside a hairline, signal hairline when focused
       or open (Nova draws it from these on #urlbar itself) */
    --urlbar-background-color: ${p.paper} !important;
    --urlbar-background-color-focus: ${p.paper} !important;
    --urlbar-input-container-border-width: ${hair} !important;
    --urlbar-input-container-border-width-open: ${hair} !important;
    --urlbar-background-border: ${hair} solid ${p.rule} !important;
    --urlbar-background-border-open: ${hair} solid ${p.signal} !important;
    --urlbar-background-border-focused: ${hair} solid ${p.signal} !important;
    --urlbar-background-outline-focused: none !important;
    --urlbarview-margin-block: 0px !important;
    --urlbarview-margin-inline: 0px !important;
    /* the open URL bar grows over the toolbar in stock; keep it in its cell */
    --urlbar-background-overhang-open: 0px !important;
    --urlbar-input-growth-open-block: 0px !important;
    --urlbar-input-growth-open-inline: 0px !important;
    --urlbar-background-box-shadow-open: none !important;
  '';
in
''
  /* ---- design language (design/language.md 7.10) ---- */

  :root,
  #navigator-toolbox,
  toolbar,
  #urlbar,
  #urlbar-results,
  panel,
  menupopup {
  ${tokens}
  }

  /* faces: DIN names things, Berkeley Mono carries values */
  :root,
  panel,
  menupopup,
  tooltip {
    font-family: "${fonts.sans}", sans-serif !important;
  }
  #urlbar-input,
  .urlbarView-url,
  #urlbar-scheme,
  #identity-icon-label {
    font-family: "${fonts.mono}", monospace !important;
  }

  /* ---- toolbar: one row as tall as a sway titlebar, divided from the page
     by a hairline ---- */
  #navigator-toolbox {
    border-bottom: ${hair} solid ${p.rule} !important;
    background: ${p.panel} !important;
  }
  #nav-bar {
    height: ${h} !important;
    min-height: ${h} !important;
    max-height: ${h} !important;
    padding: 0 !important;
    margin: 0 !important;
    border: none !important;
    box-shadow: none !important;
    background: ${p.panel} !important;
  }
  #nav-bar-customization-target {
    height: ${h} !important;
    align-items: stretch !important;
  }
  #nav-bar-customization-target > * {
    margin: 0 !important;
    padding-block: 0 !important;
  }

  /* toolbar buttons are square cells the height of the bar */
  #nav-bar .toolbarbutton-1 {
    padding: 0 !important;
    margin: 0 !important;
    height: ${h} !important;
    -moz-box-align: stretch;
  }
  #nav-bar .toolbarbutton-1 > .toolbarbutton-icon,
  #nav-bar .toolbarbutton-1 > .toolbarbutton-badge-stack {
    width: ${h} !important;
    height: ${h} !important;
    padding: calc((${h} - 16px) / 2) !important;
    border-radius: 0 !important;
    outline: none !important;
  }
  #nav-bar .toolbarbutton-1 > .toolbarbutton-badge-stack > .toolbarbutton-icon {
    width: 16px !important;
    height: 16px !important;
    padding: 0 !important;
  }
  /* an open menu button is a selection: tint plus a top rule */
  #nav-bar .toolbarbutton-1[open] > .toolbarbutton-icon,
  #nav-bar .toolbarbutton-1[open] > .toolbarbutton-badge-stack,
  #nav-bar .toolbarbutton-1:is([checked], [open]) > .toolbarbutton-icon {
    background: ${p.seltint} !important;
    box-shadow: inset 0 ${hrule} ${p.signal} !important;
    fill: ${p.signal} !important;
  }
  .toolbarbutton-badge {
    border-radius: 0 !important;
    box-shadow: none !important;
    background: ${p.signal} !important;
    color: ${p.paper} !important;
    font-family: "${fonts.mono}", monospace !important;
  }

  #back-button { list-style-image: ${icons.back} !important; }
  #forward-button { list-style-image: ${icons.forward} !important; }
  #reload-button { list-style-image: ${icons.reload} !important; }
  #stop-button { list-style-image: ${icons.stop} !important; }
  #PanelUI-menu-button { list-style-image: ${icons.menu} !important; }
  #unified-extensions-button { list-style-image: ${icons.extensions} !important; }
  #downloads-button { list-style-image: ${icons.downloads} !important; }
  #fxa-toolbar-menu-button { list-style-image: ${icons.account} !important; }
  #sidebar-button { list-style-image: ${icons.sidebar} !important; }
  #downloads-button .toolbarbutton-animatable-box,
  #downloads-indicator-progress-outer {
    display: none !important;
  }

  /* ---- URL bar: a full-height paper field between rules ---- */
  #urlbar-container {
    padding: 0 !important;
    margin: 0 !important;
    --urlbar-container-height: ${h} !important;
    --urlbar-height: ${h} !important;
    --urlbar-toolbar-height: ${h} !important;
  }
  #urlbar {
    --urlbar-height: ${h} !important;
    --urlbar-toolbar-height: ${h} !important;
    min-height: ${h} !important;
    top: 0 !important;
  }
  #urlbar-input {
    font-size: 13px !important;
    color: ${p.ink} !important;
  }
  #urlbar-input::placeholder,
  .searchbar-textbox::placeholder {
    color: ${p.dim} !important;
    opacity: 1 !important;
  }
  #identity-box,
  #tracking-protection-icon-container,
  .urlbar-page-action,
  #urlbar-searchmode-switcher {
    border-radius: 0 !important;
  }
  #identity-icon-box,
  #identity-permission-box {
    border-radius: 0 !important;
  }
  /* page actions and identity icons sit quietly in ink2 */
  #urlbar .urlbar-icon,
  #identity-icon,
  #tracking-protection-icon,
  #permissions-granted-icon {
    fill: ${p.ink2} !important;
  }
  #star-button[starred] {
    fill: ${p.signal} !important;
  }

  /* results: paper, rows divided by hairlines; the selected row gets the
     selection tint, signal text and a left rule */
  .urlbarView {
    margin: 0 !important;
    padding-top: 0 !important;
    width: 100% !important;
    border-top: ${hair} solid ${p.rule} !important;
  }
  .urlbarView-row {
    border-radius: 0 !important;
  }
  .urlbarView-row[selected] {
    background: ${p.seltint} !important;
    box-shadow: inset ${vrule} 0 ${p.signal} !important;
  }
  .urlbarView-row[selected] .urlbarView-title,
  .urlbarView-row[selected] .urlbarView-action {
    color: ${p.signal} !important;
  }
  .urlbarView-url {
    color: ${p.dim} !important;
  }
  .urlbarView-row[selected] .urlbarView-url {
    color: ${p.ink2} !important;
  }
  .urlbarView-favicon,
  .urlbarView-type-icon {
    border-radius: 0 !important;
  }
  .search-one-offs,
  .urlbarView-body-inner {
    border-color: ${p.rule} !important;
  }

  /* Firefox account promos don't belong in the menu */
  #appMenu-fxa-sign-in-promo {
    display: none !important;
  }
  #appMenu-fxa-separator {
    border-image: none !important;
    background-image: none !important;
    background-color: ${p.rule} !important;
    border-color: ${p.rule} !important;
  }

  /* ---- panels and menus: panel, a hairline frame, no shadow, square ---- */
  panel,
  menupopup {
    --panel-shadow-margin: 0px !important;
  }
  panel::part(content),
  menupopup::part(content),
  .panel-arrowcontent {
    background: ${p.panel} !important;
    color: ${p.ink} !important;
    border: ${hair} solid ${p.rule} !important;
    border-radius: 0 !important;
    box-shadow: none !important;
  }
  menupopup > menuitem,
  menupopup > menu,
  .subviewbutton,
  .toolbaritem-combined-buttons > .subviewbutton {
    border-radius: 0 !important;
  }
  menupopup > :is(menuitem, menu):is([_moz-menuactive], :hover):not([disabled]),
  .subviewbutton:not([disabled]):hover {
    background: ${p.selgrey} !important;
    color: ${p.ink} !important;
  }
  menuseparator::before,
  toolbarseparator {
    border-color: ${p.rule} !important;
  }

  /* ---- find bar and notification bars ---- */
  findbar {
    background: ${p.panel} !important;
    color: ${p.ink} !important;
    border-top: ${hair} solid ${p.rule} !important;
  }
  .findbar-textbox {
    background: ${p.paper} !important;
    color: ${p.ink} !important;
    border: ${hair} solid ${p.rule} !important;
    border-radius: 0 !important;
    font-family: "${fonts.mono}", monospace !important;
  }
  .findbar-textbox:focus {
    outline: ${hair} solid ${p.signal} !important;
    outline-offset: calc(-1 * ${hair}) !important;
  }

  /* page content sits flush below the toolbar: no Nova card around it */
  #tabbrowser-tabbox,
  #tabbrowser-tabpanels,
  .browserStack,
  browser {
    border-radius: 0 !important;
    box-shadow: none !important;
    outline: none !important;
    margin: 0 !important;
  }
  #tabbrowser-tabbox {
    background: ${p.paper} !important;
  }
''
