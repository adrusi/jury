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
- **status**: configured via this repo (`hosts/kerapace.nix`)
- **config**: login-as-root (see below)
- **runtime**: booting as a **QEMU guest on a Fedora 43 host** via virtiofs
  - `hosts/kerapace.nix` has a `specialisation.vm` for this (virtiofs root, no LUKS, no grub, spice/mesa/virtio drivers)
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

package derivations live in `packages/` at the repo root and are exposed via a nixpkgs overlay in `flake.nix` (so modules can reference them as `pkgs.pragmatapro-font`, etc.). current packages: `pragmatapro-font`, `uosc-fonts`, `obsidian-git`, `obsidian-lesswrong-theme`, `obsidian-catppuccin-theme`.

## applying config changes on kerapace

kerapace runs as a QEMU VM. `nixos-rebuild switch` works but fails at the grub bootloader step (grub can't see the EFI partition through virtiofs), so it needs a little help.

### the procedure

```sh
# 1. stage changes (nix flakes read from git index, not working tree)
git add -A

# 2. build and partially activate (will fail at grub — that's expected)
nixos-rebuild switch --flake /root/jury#kerapace

# 3. activate the vm specialisation to finish the job
#    (this spoofs the bootloader step and applies vm-appropriate config)
/nix/var/nix/profiles/system/specialisation/vm/bin/switch-to-configuration switch
```

step 3 is necessary because the base `kerapace` config still has grub configured (for bare-metal compatibility). the vm specialisation swaps in virtiofs/qemu-guest settings and replaces the bootloader install step with a no-op.

**why `/nix/var/nix/profiles/system` and not `/run/current-system`**: `nixos-rebuild switch` always updates the profile before running `switch-to-configuration`. if the activation (step 2) fails partway through, `/run/current-system` might not be updated, but the profile always is. using the profile path is reliable.

### after a reboot

on reboot the system activates the base kerapace config (not the vm specialisation). re-run step 3 to get the vm-appropriate config live again. the system will be mostly usable without it but you'll be missing qemu guest agent, spice integration, and virtio gpu.

### commit before building

nix flake evaluation reads from the **git index** (staged files), not from the working tree. a file must be at least `git add`-ed before `nixos-rebuild` will see it. committing is tidier but `git add` is the minimum.
