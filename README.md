# Dotfiles

Chezmoi-managed personal computing environment for Apple Silicon macOS.

## Fresh-machine bootstrap

1. Sign in to the Mac App Store.
2. Run:

   ```sh
   sh -c "$(curl -fsLS get.chezmoi.io)" -- \
     -b "$HOME/.local/bin" \
     init --apply --skip-secrets --purge-binary benjidotsh/dotfiles
   ```

3. Open 1Password and enable both its CLI integration and SSH agent.
4. Apply the secret-backed state:

   ```sh
   /opt/homebrew/bin/chezmoi apply
   ```

5. If enabling VS Code Settings Sync, open `Settings Sync: Configure` and
   leave `Extensions` unchecked. The Brewfile is the sole extension owner.
6. Log out of macOS and back in once. This activates the Fish login shell,
   deferred Desktop Services, and preference changes.

Select `personal` or `work` when prompted.
Never run `chezmoi` as root; focused scripts request `sudo` when required.

## Routine convergence

```sh
chezmoi update
```

This updates the source state, Homebrew software, VS Code extensions, global
agent skills, and the personal Android SDK baseline, then repairs managed
drift. Use `chezmoi apply --skip-secrets` when 1Password is intentionally unavailable.
