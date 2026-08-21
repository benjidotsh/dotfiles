# Chezmoi Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Recreate this machine's nix-darwin + home-manager environment as a chezmoi setup on the `lorenz` branch of this fork, verified with dry-runs only, so Nix can later be removed without losing software or configuration.

**Architecture:** Mirrors benjidotsh/dotfiles — chezmoi orchestrates, Homebrew Bundle owns software as an authoritative inventory, small idempotent POSIX scripts converge macOS state (defaults, Dock, Touch ID sudo, login shell). Bitwarden replaces 1Password for SSH keys and git signing. Target is behavioral parity with the current nix declaration, not Nix parity (no pinning, generations, or rollback).

**Tech Stack:** chezmoi ≥ 2.65, Homebrew Bundle, Fish (login shell), Starship, Bitwarden desktop SSH agent.

**Spec:** The current nix declaration (`flake.nix`, `modules/`, `home/` on this branch) plus the rendered home-manager output on this machine is the behavioral baseline. benjidotsh/dotfiles (and its `docs/adr/`) is the reference implementation.

## Global Constraints

- Apple Silicon macOS only; Homebrew prefix `/opt/homebrew`.
- **Never run `chezmoi apply` for real during preparation** — only `diff`, `status`, `cat`, `--dry-run`.
- Nix stays installed and frozen (no `darwin-rebuild switch`) until the documented cutover.
- The chezmoi source lives in `chezmoi/` (via `.chezmoiroot`), not `home/`, because `home/` is occupied by home-manager modules on this branch.
- Single profile: no personal/work prompt (one machine, mixed use). Benji's per-profile conditionals are flattened.
- v1 Homebrew convergence runs **without** `--force-cleanup --zap`; destructive cleanup is enabled only at cutover (see MIGRATION.md).

## Decisions (divergences from benjidotsh/dotfiles)

| Area | Benji | This setup | Why |
|---|---|---|---|
| Secret manager | 1Password (`op`, biometric CLI) | Bitwarden desktop SSH agent; **no** `bw` template functions | No shell secrets exist today; avoiding `bw` keeps `chezmoi apply` free of vault unlocks |
| Public keys | Rendered from vault via `onepasswordRead` | Committed as plain files | Public keys are public; removes the only secret-template dependency |
| Git signing | SSH format via `op-ssh-sign` | SSH format via default `ssh-keygen`, key = `~/.ssh/id_ed25519.pub` (work: `~/dpg/.ssh/id_ed25519.pub`) | Works with on-disk keys today and with the Bitwarden agent (via `SSH_AUTH_SOCK`) after onboarding. Replaces current GPG signing (`gpg.format = openpgp`, key 55F15386881C1246) |
| Profiles | `personal` / `work` prompt | None | One machine; conditionals add nothing yet |
| Work dir | `~/DPG` + `~/DPG/.gitconfig` | Keep existing `~/dpg` + `~/dpg/.ssh/.gitconfig` include path | Parity with live setup; no repo moves needed |
| Brew cleanup | `--force-cleanup --zap` always | Deferred to cutover | First apply must not uninstall anything while inventory settles |
| Extras | Android SDK, icons, Rosetta-for-Steam scripts, `.hushlogin` | Omitted (Rosetta run-once kept — already required by this machine's README) | Not part of this baseline |
| Starship | n/a | Rendered home-manager `starship.toml` verbatim, minus the `nix_shell` module | It can never trigger post-Nix |

## Software inventory delta (drives `packages.toml`)

- **Declared in nix, kept:** all `homebrew.brews`/`casks`/`masApps` from `modules/apps.nix`, including uncommitted `cloudflared`.
- **Installed but undeclared (found via `brew bundle dump`):** `imagemagick` — declare it (its deps webp/glib/libheif/harfbuzz/pango follow automatically).
- **New formulae replacing nixpkgs packages:** `bat`, `bitwarden-cli`, `chezmoi`, `direnv`, `eza`, `fish`, `git-lfs`, `go`, `mas`, `starship`.
- **New casks:** `bitwarden`, `font-fira-code-nerd-font`, `font-meslo-lg-nerd-font`, `visual-studio-code` (VS Code currently comes from nixpkgs!).
- **Dropped:** `just` (only served nix workflows), `alejandra`, `nixd`, `nodejs` (volta owns node), `jnoortheen.nix-ide` VS Code extension, `update-flake-lock` GitHub workflow, `nix-sync`/`nix-update` aliases.
- **VS Code extensions:** union of the nix declaration and `code --list-extensions` (adds copilot pair from nix; keeps installed jupyter/containers/chatgpt extensions), minus nix-ide.
- **Out of scope, survives as plain files:** go-installed tools in `~/go/bin`, volta-managed node/npm/corepack, `~/.zcli`.

---

### Task 1: Chezmoi source tree — data + Brewfile

**Files:** `.chezmoiroot` (content: `chezmoi`), `home/.chezmoidata/packages.toml`, `home/.chezmoidata/system.toml`, `home/.chezmoidata/dock.toml`, `home/dot_Brewfile.tmpl`.

- [x] `packages.toml`: single `[packages]` table (`taps`/`formulae`/`casks`/`mas`/`vscode`) per the inventory delta above. MAS list = Xcode 497799835, Slack 803453959, The Unarchiver 425424353, Boop 1518425043, iMovie 408981434, Numbers 361304891, Pages 361309726 (stock apps stay listed so future zap spares them).
- [x] `system.toml`: current `defaults` — dock `show-recents=false`, `wvous-br-corner=1`, `tilesize=64`; NSGlobalDomain `NSAutomaticSpellingCorrectionEnabled=false`, `AppleInterfaceStyle="Dark"`; finder `FXDefaultSearchScope="SCcf"`; desktopservices `DSDontWriteNetworkStores/USBStores=true`; menuextra.clock `ShowSeconds=true`.
- [x] `dock.toml`: Apps.app, Firefox, Slack, Visual Studio Code, Ghostty, Sublime Text, Spotify (VS Code path becomes `/Applications/...` instead of the nix store path).
- [x] `dot_Brewfile.tmpl`: benji's range pattern over `.packages`, flattened (no profile), keeping the `ENV["NODE_EXTRA_CA_CERTS"]` Zscaler line.
- [x] Verify: `chezmoi --source ~/personal/repos/dotfiles cat ~/.Brewfile` renders; every currently-installed leaf package appears.

### Task 2: Dotfiles (fish, git, ssh, starship, ghostty, direnv, bat, gnupg, VS Code)

**Files:** `home/dot_config/fish/config.fish`, `home/dot_config/git/config`, `home/dpg/private_dot_ssh/dot_gitconfig`, `home/private_dot_ssh/config`, `home/private_dot_ssh/id_ed25519.pub`, `home/dpg/private_dot_ssh/id_ed25519.pub`, `home/dot_config/starship.toml`, `home/dot_config/ghostty/config`, `home/dot_config/direnv/direnv.toml`, `home/dot_config/bat/config`, `home/dot_config/bat/themes/Catppuccin Macchiato.tmTheme`, `home/private_dot_gnupg/gpg-agent.conf`, `home/Library/Application Support/Code/User/settings.json`, `home/Library/Application Support/Code/User/mcp.json`.

- [x] `config.fish`: brew shellenv; env vars from `home.sessionVariables` (VOLTA_HOME, GOPATH, JAVA_HOME → `/opt/homebrew/opt/openjdk/...`, AWS_CA_BUNDLE, NODE_EXTRA_CA_CERTS, SSL_CERT_FILE, REQUESTS_CA_BUNDLE); paths from `home.sessionPath`; `SSH_AUTH_SOCK` → `~/.bitwarden-ssh-agent.sock` when the socket exists; interactive block: no greeting, `GPG_TTY`, starship init, all zsh aliases translated (eza wrapper with `--icons auto --git --group-directories-first`, git shortcuts, aws/terraform shortcuts, `cat`→bat) minus `nix-sync`/`nix-update`, plus `dot-sync` → `chezmoi update`.
- [x] git config: rendered `~/.config/git/config` with: LFS filters → plain `git-lfs` (brew), `gpg.format=ssh`, `user.signingKey=~/.ssh/id_ed25519.pub`, keep `[includeIf "gitdir:~/dpg/"]`. Work include adds `user.signingkey=~/dpg/.ssh/id_ed25519.pub`, keeps `core.sshCommand -i ~/dpg/.ssh/id_ed25519` (on-disk key valid until Bitwarden onboarding; then switch to `.pub` + `IdentitiesOnly`).
- [x] ssh config: current rendered config + `IdentityAgent ~/.bitwarden-ssh-agent.sock` (harmless while socket is absent; on-disk `IdentityFile` still wins).
- [x] Public keys committed verbatim from `~/.ssh/id_ed25519.pub` and `~/dpg/.ssh/id_ed25519.pub`.
- [x] starship.toml: rendered file verbatim minus `$nix_shell`; ghostty: `shell-integration = fish`; direnv/bat/gpg-agent.conf ported (drop `enable-ssh-support` — Bitwarden owns SSH); bat theme + `run_onchange` cache rebuild.
- [x] VS Code `settings.json` minus `nix.*`/`[nix]` keys; `mcp.json` with `context7` via `npx -y @upstash/context7-mcp` (the nix `context7-mcp` wrapper disappears with the store).
- [x] Verify: `chezmoi --source ~/personal/repos/dotfiles diff` shows only the intended content deltas for existing files.

### Task 3: Convergence scripts

**Files:** `home/.chezmoiscripts/run_once_before_10-install-homebrew.sh`, `run_once_before_20-install-rosetta.sh`, `run_after_10-homebrew.sh`, `run_after_15-login-shell.sh`, `run_after_30-system-defaults.sh.tmpl`, `run_after_40-touch-id-sudo.sh`, `run_after_60-dock.sh.tmpl`, `run_onchange_after_70-bat-cache.sh.tmpl`.

- [x] Copied from benji with: no profile conditionals; homebrew script uses `brew bundle install --upgrade --global` (cleanup flags deferred); defaults/dock templates range over the flattened data; Touch ID script verbatim (replaces nix-darwin's `security.pam` — would otherwise be lost at Nix removal).
- [x] Verify: scripts appear in `chezmoi --source ~/personal/repos/dotfiles status`; none execute during diff/dry-run.

### Task 4: Docs + verification

**Files:** `docs/migration.md` (bootstrap checkpoint for Bitwarden, cutover sequence, full Nix removal steps for this exact machine), this plan.

- [x] Install chezmoi per benji's README pattern: official installer `-b ~/.local/bin` (no init, no apply).
- [x] `chezmoi --source ~/personal/repos/dotfiles diff` / `status` / `apply --dry-run --verbose` — review every target; confirm zero secret-template usage; confirm no real apply happened.
- [x] Commit everything on the `lorenz` branch of this fork. Leave `main` and the uncommitted `modules/apps.nix` edit untouched.

## Self-review notes

- All nix `home.sessionVariables`, `sessionPath`, `shellAliases`, git settings, ssh settings, defaults, dock, Touch ID, fonts, and MAS apps are covered by a task; MCP context7 covered via mcp.json; `programs.eza/bat/go/direnv/gpg` covered by formulae + config files.
- Not migrated deliberately: nix GC daemon, flake update workflow, `just`, hostname setting (already set on machine), copilot-in-nix-store extension quirks.
