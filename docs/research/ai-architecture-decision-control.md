# Keeping architectural decisions with the human

Date: 2026-09-14

## Finding

The documented approaches combine interviews, reviewable technical designs, persistent project constraints, and enforcement for rules that can be checked mechanically. Better instructions can help, but a written plan can still contain choices the agent made without asking. The missing distinction is between documenting a decision and obtaining agreement to it.

This is a synthesis of the mechanisms below, not a measured claim that one workflow eliminates surprises.

## What existing tools do

| Approach | Documented mechanism | Limit for this problem |
| --- | --- | --- |
| Claude Code | Plan mode separates exploration from implementation; the plan can be edited before execution. Anthropic also recommends interviewing the user and saving a self-contained spec. | Reviewing a plan only helps if consequential technical choices appear clearly enough to review. [Best practices](https://code.claude.com/docs/en/best-practices) |
| CLAUDE.md | Persistent instructions can hold architectural conventions. Anthropic explicitly describes these files as context rather than enforced configuration, and recommends specific, concise instructions. | A rule saying to ask is behavioral guidance. It is not a technical guarantee. Conflicting instructions can undermine adherence. [Memory documentation](https://code.claude.com/docs/en/memory) |
| GitHub Spec Kit | Separates specification, technical plan, tasks, and implementation. Its README asks the user to supply stack and architecture choices to the planning command. | The framework still needs those choices supplied or reviewed. [Repository](https://github.com/github/spec-kit) |
| OpenSpec | Produces proposal, behavioral specs, technical design, and tasks before a separate apply command. Custom schemas can add review artifacts and prerequisites. | Its dependency checks establish that artifacts exist, not that a human agreed with their contents. Its customization guide explicitly calls for CI or hooks to enforce review gates. [Getting started](https://github.com/Fission-AI/OpenSpec/blob/main/docs/getting-started.md), [customization](https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/docs/customization.md) |
| Superpowers brainstorming | Requires human approval before implementation, scales the design artifact to task size, and presents multiple approaches for architectural work. It requires stopping when hidden complexity increases the task's scope. | This is still a skill written in natural language. It asks for approval even for small changes, which spends human attention. Its spec self-review also tells the agent to pick an interpretation of an ambiguity before the subsequent user review. [Skill source](https://raw.githubusercontent.com/obra/superpowers/main/skills/brainstorming/SKILL.md) |
| Claude Code hooks | Hooks run at fixed lifecycle events. A PreToolUse hook can deny an attempted action. | A script can detect a manifest change or protected path. Determining whether a new abstraction is an architectural decision still requires judgment. Model-based hooks retain that uncertainty. [Hooks guide](https://code.claude.com/docs/en/hooks-guide) |

## A consequential Spec Kit detail

The current clarification command asks at most five questions per session, prioritizes high-impact uncertainty, and avoids speculative stack questions unless they block functional clarity. It reports deferred unresolved areas. This is a deliberate bounded interview, not an exhaustive architecture interview. [Clarify command source](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/clarify.md)

The planning command marks unknown technical context as needing clarification, then resolves those unknowns through research. It records a decision, rationale, and alternatives. That creates useful transparency, but the command does not require a separate human choice for each research-resolved technical unknown. A user concerned about delegated architectural choices should not assume installing Spec Kit fixes that boundary. [Plan command source](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/plan.md)

## OpenAI guidance

OpenAI recommends planning and interviewing for larger work, using a durable plan for longer tasks, and keeping persistent agent instructions concise. Its AGENTS.md guidance includes an example requiring confirmation before adding production dependencies. These are useful examples of a specific decision boundary rather than a general request to make fewer assumptions. [Best practices](https://learn.chatgpt.com/guides/best-practices), [AGENTS.md guide](https://learn.chatgpt.com/docs/agent-configuration/agents-md)

## Candidate workflow to discuss

The following is a proposed adaptation, not an adopted policy.

1. Define which choices belong to the human. Candidate categories include new languages, frameworks, dependencies, external services, storage, deployment, module boundaries, and public contracts. Decide separately which existing conventions the agent may reuse automatically.
2. Before implementation, show each relevant choice, its alternatives and tradeoffs, and whether it is already agreed, inherited from project policy, proposed, or deliberately delegated. Research resolves facts; the human resolves preferences within the reserved categories.
3. Approve a concrete design containing the stack, components, data flow, interfaces, and scope. Preserve the decisions in the project record so later sessions can find their rationale.
4. When implementation reveals a new reserved decision or invalidates an agreed one, return that decision to the human before dependent implementation. Continue independent work where possible.
5. Review the result against the agreed design, reporting deviations explicitly. Add mechanical checks only for boundaries that can actually be detected, such as newly introduced dependencies.

This suggests a short always-loaded rule pointing to a detailed decision workflow. The interview defines choices, the design makes them reviewable, and later review detects drift. A larger AGENTS.md alone addresses only part of that chain.

## Evidence limits

The sources establish documented behavior and inspectable workflow instructions. This review did not find or evaluate a controlled comparison measuring unwanted architectural choices across these tools. Product recommendations and project adoption are not proof of effectiveness. No reviewed tool guarantees that every consequential decision will be surfaced.

For this user's setup, test a proposed policy against a few previous surprises and a new representative task. Check whether the agent surfaces the choices before implementing, preserves accepted choices, and asks again when the design changes. Count unnecessary interruptions as well as missed decisions.
