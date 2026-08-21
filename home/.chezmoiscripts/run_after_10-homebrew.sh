#!/bin/sh
set -eu

brew=/opt/homebrew/bin/brew

"$brew" update
# --force-cleanup --zap is deferred until Nix is removed and the inventory has
# settled; see docs/chezmoi/MIGRATION.md before enabling it.
"$brew" bundle install --upgrade --global
