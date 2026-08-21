# Dotfiles

The desired personal-computing environment for a single Apple Silicon machine that mixes personal and work use.

## Language

**Behavioral parity**:
Preservation of user-visible software and behavior without preserving the former system's implementation guarantees.
_Avoid_: Exact parity, full Nix parity

**Declared state**:
The intended environment explicitly represented by the source configuration. Unmanaged live-machine state is outside it.
_Avoid_: Live state, current machine state

**Fresh-machine bootstrap**:
Application of declared state to an Apple Silicon macOS machine without Nix. Migrating, coexisting with, or removing Nix is outside its boundary.
_Avoid_: Cutover, Nix migration

**Bootstrap checkpoint**:
A required human step between the initial non-secret apply and full convergence. It covers account authentication or operating-system consent that declared state cannot provide.
_Avoid_: Installation step, automated setup

**Convergence**:
Repair of managed configuration drift, including restoration of the authoritative Dock layout, whenever declared state is applied.
_Avoid_: One-time setup

**Authoritative set**:
A declared collection whose undeclared managed members are removed during convergence. Members may drift between applies; they are not immutable.
_Avoid_: Immutable set, preferred set

**Work repository**:
A Git repository located beneath `~/dpg/`. It uses the work Git identity and its designated work SSH key.
_Avoid_: DPG folder, company repo

**Enterprise environment**:
Work-scoped file inputs supplied by enterprise tooling. Declared state may reference their paths but does not own or validate their contents.
_Avoid_: Work secrets, managed certificates

**Shell secret**:
A secret value automatically exported to commands run from the account's configured shell.
_Avoid_: Project secret, enterprise environment
