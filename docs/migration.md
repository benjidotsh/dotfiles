# Migrating this machine from Nix to chezmoi

One-time cutover for the machine currently managed by
[lvthillo/nix](https://github.com/lvthillo/nix). Until the cutover is
complete, Nix stays installed but **frozen**: never run
`darwin-rebuild switch` again (its `cleanup = "zap"` would uninstall
Homebrew packages this repo declares, and home-manager would fight
chezmoi over dotfiles).

## Phase 1 — take over (reversible)

1. `chezmoi init --apply lvthillo/dotfiles` (or `chezmoi apply` from the
   local checkout). This overwrites home-manager's dotfile symlinks with
   real files, installs the Brewfile inventory (including replacements
   for nixpkgs software: VS Code, fish, starship, eza, bat, go, direnv,
   fonts, mas), and converges the login shell to Fish.
   - First apply prompts for `sudo` twice: `/etc/shells` + `chsh`, and
     Touch ID PAM.
2. Log out and back in. Verify: fish + starship prompt, `git pull/push`
   in a personal and a `~/dpg/` repo, `code`, `ll`/`cat` aliases.
3. Live on it for a few days. To roll back: `darwin-rebuild switch`
   restores the nix-managed state.

## Phase 2 — Bitwarden onboarding

1. Open Bitwarden (installed by the Brewfile), sign in, enable the SSH
   agent in Settings.
2. Import `~/.ssh/id_ed25519` and `~/dpg/.ssh/id_ed25519` into the vault.
3. On GitHub (both accounts), add the two public keys as **signing**
   keys (they are already auth keys). Commits now sign via SSH instead
   of GPG key 55F15386881C1246 — old commits stay verified on GitHub as
   long as the GPG key remains registered.
4. New shells export `SSH_AUTH_SOCK` to the Bitwarden socket
   automatically. Once confirmed working, optionally delete the on-disk
   private keys and change `~/dpg/.ssh/.gitconfig`'s `sshCommand` to
   `ssh -i ~/dpg/.ssh/id_ed25519.pub -o IdentitiesOnly=yes`.

## Phase 3 — remove Nix

1. `nix run nix-darwin#darwin-uninstaller` — removes nix-darwin's launch
   daemons (`org.nixos.activate-system`, `darwin-store`, `nix-gc`) and
   `/etc` shell hooks.
2. Uninstall Nix itself (official-installer manual steps):
   - `sudo launchctl bootout system/org.nixos.nix-daemon` and delete
     `/Library/LaunchDaemons/org.nixos.nix-daemon.plist`.
   - Delete the 32 `_nixbld*` users and the `nixbld` group
     (`sudo dscl . -delete /Users/_nixbld<N>`).
   - Remove the `nix` line from `/etc/synthetic.conf` and the `/nix`
     line from `/etc/fstab` (`sudo vifs`).
   - Restore `/etc/zshrc`, `/etc/bashrc`, `/etc/bash.bashrc` from their
     `.backup-before-nix` copies if present.
3. Fix Homebrew taps: `ls -la /opt/homebrew/Library/Taps` — remove any
   symlinks into `/nix/store` (they came from nix-homebrew's pinned
   taps; modern brew uses the JSON API instead).
4. Delete the store volume: `sudo diskutil apfs deleteVolume "Nix Store"`
   (~89 GB returns to the container). Reboot.
5. Archive the `lvthillo/nix` repository.

## Phase 4 — enable destructive cleanup

After a clean `brew bundle check` and a few quiet days, restore
authoritative-inventory behavior in
`home/.chezmoiscripts/run_after_10-homebrew.sh`:

```sh
"$brew" bundle install --upgrade --force-cleanup --zap --global
```

From then on, undeclared brew-managed software is removed on every
apply (ADR 0005).

## Known losses (accepted, ADR 0001/0010)

Flake pinning, generations, rollback, `just` workflows, the
update-flake-lock GitHub Action, `alejandra`/`nixd`/nix-ide, and the
`nix-sync`/`nix-update` aliases (`dot-sync` replaces them).
