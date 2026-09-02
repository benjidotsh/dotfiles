# Separate repository tooling from home state

Keep this repository's root `AGENTS.md`, `CLAUDE.md` link, and related maintenance files outside chezmoi's source state. They guide work on this repository and were not part of the declared Nix-managed home environment; only the independently declared Claude and Codex user configuration is recreated in the target home. ADR 0010 supersedes this decision for `.agents` and `.claude` skill links.
