# jury

personal nix configuration (NixOS + nix-darwin + home-manager). public repo

## private submodules

two flake inputs come from private repos, pulled in as git submodules so the
config repo itself can stay public:

- `assets/pragmatapro` — proprietary PragmataPro font files (license-restricted,
  kept in a private repo so it's distributed only to me)
- `vendor/dmodel-issue` — an employer-internal CLI tool

both are declared as relative-path flake inputs (`url = ./assets/pragmatapro`)
plus `self.submodules = true` in `flake.nix`. relative `git+file://` inputs are
deprecated (resolve against PWD, not the flake root —
<https://github.com/NixOS/nix/issues/12281>), which is why it's a plain path
input now.

### how auth works (and why there's no nix-side credential setup)

the submodule pin is the gitlink commit recorded in this superproject — not the
flake.lock. nix's libgit2 submodule handling reads the submodule tree from the
**local** git object store; it only does a network fetch (over libgit2's libssh2
transport, which can't use your ssh config / agent reliably and will fail auth
on private repos) when the objects for the recorded gitlink rev are **not
present locally**.

so as long as the submodules are checked out via the `git` CLI — which uses
your normal ssh auth (e.g. yubikey + ssh-agent) — nix never needs credentials.
no `nix.conf`, no token, no netrc.

`submodule.recurse=true` is set locally in this repo (`git config --local`) so
`git pull` / `git checkout` keep the submodule working trees in sync with the
gitlink automatically — this is what keeps the local objects present so nix
never hits the failing fetch path. it is **not** set globally; a fresh clone of
this repo needs the bootstrap step below to apply it.

## bootstrapping a new machine

1. authenticate ssh to github (yubikey + ssh-agent, or whatever key is
   authorized for the private repos)

2. recursive clone:

   ```sh
   git clone --recursive git@github.com:adrusi/jury
   cd jury
   git config --local submodule.recurse true
   ```

   (if you cloned non-recursively: `git submodule update --init --recursive`)

3. rebuild:

   ```sh
   # NixOS
   nixos-rebuild switch --flake .#kerapace
   # darwin
   darwin-rebuild switch --flake .#rainbow
   ```

## updating the private submodules

`nix flake update` does **not** bump these — the pin is the gitlink, not the
lockfile. update via the `git` CLI (uses ssh, so yubikey/agent applies):

```sh
git submodule update --remote assets/pragmatapro
git add assets/pragmatapro
git commit
```

the next rebuild picks it up automatically (nix reads the new local objects).

**failure mode:** if nix errors with an ssh/auth failure while fetching a
submodule, it means the gitlink rev isn't present in the local submodule object
store (e.g. you pulled a superproject change that bumped the gitlink without
updating the submodule). fix with `git submodule update --init --recursive`.
with `submodule.recurse=true` set (step 2) this shouldn't happen via normal
`git pull`.
