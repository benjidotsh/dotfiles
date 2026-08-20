# Separate repository tooling from home state

Keep this repository's `.agents`, `.claude` skill links, and related maintenance files outside chezmoi's source state. They guide work on this repository and were not part of the declared Nix-managed home environment; Claude user configuration is recreated separately as declared home state.
