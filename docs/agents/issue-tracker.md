# Issue tracker: GitHub

Issues and PRDs live in GitHub at `lvthillo/dotfiles`. Use `gh` for all operations. Pass `--repo lvthillo/dotfiles` when the current checkout cannot infer the repository.

## Conventions

- Create: `gh issue create --repo lvthillo/dotfiles --title "..." --body "..."`
- Read: `gh issue view <number> --repo lvthillo/dotfiles --comments`
- List: `gh issue list --repo lvthillo/dotfiles --state open`
- Comment: `gh issue comment <number> --repo lvthillo/dotfiles --body "..."`
- Label: `gh issue edit <number> --repo lvthillo/dotfiles --add-label "..."` or `--remove-label "..."`
- Close: `gh issue close <number> --repo lvthillo/dotfiles --comment "..."`

## Pull requests as a triage surface

**PRs as a request surface: no.**

## Skill terminology

- “Publish to the issue tracker”: create a GitHub issue.
- “Fetch the relevant ticket”: run `gh issue view <number> --repo lvthillo/dotfiles --comments`.

## Wayfinding

- Map: one issue labelled `wayfinder:map`.
- Child: a GitHub sub-issue labelled `wayfinder:<type>`.
- Blocking: use GitHub native issue dependencies.
- Claim: `gh issue edit <number> --repo lvthillo/dotfiles --add-assignee @me`.
- Resolve: comment with the answer, close the issue, then add a context pointer to the map.
