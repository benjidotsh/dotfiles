# Migrating this machine from Nix to chezmoi

One-time cutover for the machine currently managed by
[lvthillo/nix](https://github.com/lvthillo/nix). Until the cutover is
complete, Nix stays installed but **frozen**: never run
`darwin-rebuild switch` again (its `cleanup = "zap"` would uninstall
Homebrew packages this repo declares, and home-manager would fight
chezmoi over dotfiles).

## Phase 0 — already done (2026-08-21)

- Staged chezmoi v2.72.0 installed at `~/.local/bin/chezmoi` (Homebrew
  installs the durable copy in Phase 1; delete the staged one after).
- `~/.config/chezmoi/chezmoi.toml` points `sourceDir` at
  `~/personal/repos/dotfiles` (keep it checked out on this branch).
- Dry-run verified: `chezmoi status` shows the expected 23 targets.

## Phase 1 — take over (reversible)

1. Register the existing public keys on GitHub as **signing** keys
   (auth and signing are separate registrations of the same key; new
   commits sign via SSH after this phase and show Unverified until the
   keys are registered). Safe to do before the apply.
   - Personal account (web UI): `pbcopy < ~/.ssh/id_ed25519.pub`, then
     GitHub → Settings → SSH and GPG keys → New SSH key → Key type:
     Signing key.
   - Work account (gh is logged in as lorenz-vanthillo_DPGMEDIA but
     needs the scope first):
     `gh auth refresh -h github.com -s admin:ssh_signing_key`, then
     `gh ssh-key add ~/dpg/.ssh/id_ed25519.pub --type signing --title "dpg signing key"`.
   - Leave the old GPG key registered so past commits stay verified.
2. `~/.local/bin/chezmoi apply -v`. This overwrites home-manager's
   dotfile symlinks with real files, installs the Brewfile inventory
   (including replacements for nixpkgs software: VS Code, fish,
   starship, eza, bat, go, direnv, fonts, mas), and converges the login
   shell to Fish. Expect 10–20 minutes of Homebrew installs.
   - First apply prompts for `sudo` twice: `/etc/shells` + `chsh`, and
     Touch ID PAM.
3. `rm ~/.local/bin/chezmoi` — Homebrew now owns the durable binary
   (ADR 0008).
4. Log out and back in. Verify:
   - `echo $SHELL` → `/opt/homebrew/bin/fish`, starship prompt renders.
   - `ssh -T git@github.com` in a personal and a `~/dpg/` repo.
   - `git commit --allow-empty -m test && git log --show-signature -1`.
   - `brew bundle check --global` → satisfied.
   - `ll` / `cat` aliases, `code` opens.
5. Live on it for a few days. To roll back: `cd ~/nix && just deploy`
   (`darwin-rebuild switch`) restores the nix-managed state.

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
3. Repair Homebrew itself. nix-homebrew installed brew as a gitless
   store snapshot (`brew config` shows ">=4.3.0 (shallow or no git
   repository)"), which breaks the JSON API, so during Phase 1 the
   nix-store `Library/Taps` symlink was already replaced with real
   `homebrew/core` and `homebrew/cask` git taps as a workaround. To get
   a stock brew: re-run the official installer
   (`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`,
   it repairs in place), confirm `brew config` reports a real version,
   then `brew untap homebrew/core homebrew/cask` to drop the heavyweight
   git taps in favor of the API. Unset leftovers: a login shell should
   no longer export `HOMEBREW_REPOSITORY=/opt/homebrew/Library/.homebrew-is-managed-by-nix`
   (it dies with the nix zsh environment).
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
