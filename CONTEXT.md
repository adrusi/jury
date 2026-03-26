# jury — context document

This file exists so that future me (or future AI) can get oriented quickly without being re-explained everything from scratch.

## systems

### rainbow (macbook)
- **arch**: aarch64-darwin
- **framework**: nix-darwin + home-manager
- **primary user**: `autumn`
- **status**: fully configured via this repo

### kerapace (work laptop)
- **arch**: x86_64-linux (AMD)
- **framework**: NixOS + home-manager
- **status**: currently configured via `/etc/nixos`, migration to this repo in progress
- **target config**: login-as-root (see below)
- **runtime**: currently booting as a **QEMU guest on a Fedora 43 host** via virtiofs, so the config can be iterated without interrupting work
  - `hardware-configuration.nix` has a `specialisation.vm` for this (virtiofs root, no LUKS, no grub, spice/mesa/virtio drivers)
  - bare-metal boot path uses LUKS + btrfs subvolumes + GRUB

## login-as-root

reference: <https://loginasroot.net/linux_root_login_faq>

"poor man's QubesOS." uses Unix UID isolation instead of the Xen hypervisor — one UID per security domain rather than one VM per domain. less hardened than Qubes, but much lighter on resources, more compatible with vendor workflows, and friendlier to a machine with 96 GB of RAM that benefits from shared memory.

planned users on kerapace:
- **`root`** — primary interactive user; gets the full shell/editor/dev environment
- **`firefox`** — browser isolation; gets firefox config and minimal shell
- others TBD (e.g. claude agent sandboxes)

## module organization philosophy

### the problem with conventional nixos/home-manager separation
the standard approach keeps system config and home-manager config in completely separate files/repos. but there are real dependencies between them that become implicit:

- **`pragmatapro.nix`**: font installed system-wide via `fonts.packages`, then referenced by name in ghostty, zed, and vscode home config — if one is present without the other, things break silently
- **`mpv.nix`**: uosc fonts installed system-wide (darwin), mpv wired together with ff2mpv firefox extension in home config
- **`zsh.nix`**: `programs.zsh.enable = true` at system level adds zsh to `/etc/shells` (required for it to be a login shell), full zsh config lives in home

keeping these together in one module file makes the dependency explicit and prevents the two halves from drifting apart.

### target module structure

```
modules/
  system/   plain NixOS modules; never touch home-manager config
  home/     username-parameterized NixOS modules; ONLY set home-manager config
             (but may import system/ counterparts to declare system-level dependencies)
packages/   package derivations (currently defined inline in modules)
hosts/      host configs
```

### home module pattern

home modules are functions from `username` to a NixOS module:

```nix
# modules/home/zsh.nix
username:
{ lib, pkgs, ... }:
{
  imports = [
    ../system/zsh.nix  # system counterpart; conventional to have the same name
  ];

  options.home.${username}.zsh = {
    # custom options, if any, namespaced under home.<username>.*
  };

  config = {
    home-manager.users.${username}.programs.zsh = {
      enable = true;
      # ...
    };
  };
}
```

in host config:

```nix
imports = [
  (import ../modules/home/zsh.nix "root")
  (import ../modules/home/zsh.nix "claude")   # same module, different user
];
```

when a home module is imported for multiple users, any system-level config it sets (via its system/ import) gets merged normally by the NixOS module system. list options (like `fonts.packages`) may appear twice but nix deduplicates by hash at build time, so this is harmless.

### what stays simple

modules with no home-manager component (e.g. `nix-store.nix`) stay as plain NixOS modules in `modules/system/` and are imported directly. no parameterization needed.

### packages

package derivations should not be defined inline in host or module files. they live in `packages/` at the repo root, are exposed as `packages.*` outputs in `flake.nix`, and are passed into the module system via `specialArgs`. currently defined inline (to be extracted):

- **pragmatapro font** — `modules/common/pragmatapro.nix`
- **uosc fonts** — `modules/common/mpv.nix`

## plan

roughly ordered; the refactor is the big one:

1. **extract packages** — move inline derivations to `packages/`, wire up in `flake.nix`, pass via `specialArgs`
2. **restructure modules** — migrate from `modules/common/` + `modules/darwin/` to `modules/system/` + `modules/home/`; this subsumes the common/darwin merge since darwin-specific modules are all system-level and go into `modules/system/`
3. **update rainbow** — update `hosts/rainbow.nix` imports to use the new structure; instantiate home modules for `autumn`
4. **add kerapace** — add `hosts/kerapace.nix` to the flake; instantiate home modules for `root`, `firefox`, and any other users
