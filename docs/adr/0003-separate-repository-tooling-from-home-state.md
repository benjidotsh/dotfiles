# Separate repository tooling from home state

Keep this repository's `.agents`, `.claude` skill links, root `AGENTS.md`, and related maintenance files outside chezmoi's source state. They guide work on this repository and were not part of the declared Nix-managed home environment; only the independently declared Claude user configuration is recreated in the target home. The choice to keep the repository's agent skills vendored in `.agents` and the `.claude` skill links is superseded by ADR 0010, which moves them into the user-level authoritative set; the rest stands.
