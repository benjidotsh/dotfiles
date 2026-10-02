## Grilling

When running the `grilling` skill:

- Wait for every dispatched sub-agent to report before asking a round. Recompute the frontier with their findings, then ask it whole, so no question is outdated by a fact that was still in flight.
- In Claude Code, ask each round through `AskUserQuestion`, with the recommended answer as the first option. Split a frontier larger than one call's limit across consecutive calls of the same round.
- Surface consequential choices about technologies and dependencies, responsibility boundaries, data ownership and flow, trust and validation, operational access, public contracts, and unspecified user-visible behavior. Put unresolved choices into the interview's question rounds. Reuse established conventions within their existing role.
- Before concluding, summarize the relevant choices and distinguish user-approved decisions, inherited conventions, and explicitly delegated choices. Every proposed choice must be resolved with the user; recommendations alone are not agreement.
- During subsequent implementation, reopen grilling when a new consequential choice arises or an agreed decision needs to change. Wait for the user's answer before dependent implementation; continue independent work where possible.
