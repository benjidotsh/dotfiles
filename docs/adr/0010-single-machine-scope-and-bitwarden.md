# Adopt a single-machine scope with Bitwarden

This fork targets one Apple Silicon machine that mixes personal and work
use, migrating from a nix-darwin + home-manager declaration
(github.com/lvthillo/nix) with behavioral parity as the goal. The
personal/work profile prompt and its conditionals are removed; the work
Git-directory boundary stays, at the existing `~/dpg/` path with the
existing `~/dpg/.ssh/.gitconfig` include. Bitwarden replaces 1Password:
its desktop SSH agent owns SSH identities and Git SSH-format signing
(exported through `SSH_AUTH_SOCK` and `IdentityAgent`), superseding the
previous GPG signing key. Because the official `bw` CLI cannot unlock via
biometrics and no shell secrets exist in the baseline, no secret is
rendered through templates; public keys are committed as plain files, so
`chezmoi apply` never requires an unlocked vault. During the Nix
transition the on-disk private keys remain valid fallbacks, and the
Homebrew convergence script omits `--force-cleanup --zap` until Nix and
its packages are gone; enabling destructive cleanup afterwards restores
the authoritative-inventory behavior of ADR 0005. ADRs 0004, 0006, and
0008's 1Password- and profile-specific mechanics are superseded
accordingly; the orchestration model (ADR 0002) and Fish login shell
(ADR 0009) are unchanged.
