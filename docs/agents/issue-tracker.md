# Issue tracker: GitHub

Issues and PRDs live in GitHub at `benjidotsh/dotfiles`. Use `gh` for all operations. Pass `--repo benjidotsh/dotfiles` when the current checkout cannot infer the repository.

## Conventions

- Create: `gh issue create --repo benjidotsh/dotfiles --title "..." --body "..."`
- Read: `gh issue view <number> --repo benjidotsh/dotfiles --comments`
- List: `gh issue list --repo benjidotsh/dotfiles --state open`
- Comment: `gh issue comment <number> --repo benjidotsh/dotfiles --body "..."`
- Label: `gh issue edit <number> --repo benjidotsh/dotfiles --add-label "..."` or `--remove-label "..."`
- Close: `gh issue close <number> --repo benjidotsh/dotfiles --comment "..."`

## Pull requests as a triage surface

**PRs as a request surface: no.**

## Skill terminology

- “Publish to the issue tracker”: create a GitHub issue.
- “Fetch the relevant ticket”: run `gh issue view <number> --repo benjidotsh/dotfiles --comments`.

## Wayfinding

- Map: one issue labelled `wayfinder:map`.
- Child: a GitHub sub-issue labelled `wayfinder:<type>`.
- Blocking: use GitHub native issue dependencies.
- Claim: `gh issue edit <number> --repo benjidotsh/dotfiles --add-assignee @me`.
- Resolve: comment with the answer, close the issue, then add a context pointer to the map.
