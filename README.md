# Dotfiles

Chezmoi-managed personal computing environment for Apple Silicon macOS.
Forked from [benjidotsh/dotfiles](https://github.com/benjidotsh/dotfiles),
adapted for a single machine and Bitwarden (see `docs/adr/0010`).

## Fresh-machine bootstrap

1. Sign in to the Mac App Store.
2. Run:

   ```sh
   sh -c "$(curl -fsLS get.chezmoi.io)" -- \
     -b "$HOME/.local/bin" \
     init --apply --purge-binary lvthillo/dotfiles
   ```

3. Open Bitwarden, sign in, and enable the SSH agent
   (Settings → SSH agent). Import the personal and work SSH keys into the
   vault if this is their first Bitwarden machine.
4. Log out of macOS and back in once. This activates the Fish login shell,
   deferred Desktop Services, and preference changes.

No apply step needs the vault unlocked: public keys are committed and no
secrets are templated. Never run `chezmoi` as root; focused scripts request
`sudo` when required.

## Routine convergence

```sh
chezmoi update
```

This updates the source state and Homebrew software, then repairs managed
drift. (`dot-sync` is the Fish alias for it.)

## Migrating this machine off Nix

See `docs/migration.md` for the one-time cutover: freezing nix-darwin,
first apply, Bitwarden onboarding, Nix removal, and enabling Homebrew's
destructive cleanup afterwards.
