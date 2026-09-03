## Grilling

When running the `grilling` skill:

- Wait for every dispatched sub-agent to report before asking a round. Recompute the frontier with their findings, then ask it whole, so no question is outdated by a fact that was still in flight.
- In Claude Code, ask each round through `AskUserQuestion`, with the recommended answer as the first option. Split a frontier larger than one call's limit across consecutive calls of the same round.
