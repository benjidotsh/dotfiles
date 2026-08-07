# Domain docs

## Before exploring

Read:

- `CONTEXT.md` at the repository root.
- Relevant ADRs under `docs/adr/`.

If these files do not exist, proceed silently. Domain-modeling creates them when terms or decisions are resolved.

## Layout

This is a single-context repository:

```
/
├── CONTEXT.md
├── docs/adr/
└── src/
```

## Vocabulary

Use domain terms defined in `CONTEXT.md`. Avoid synonyms the glossary rejects. Treat missing concepts as possible domain-model gaps.

## ADR conflicts

Explicitly flag output that conflicts with an existing ADR.
