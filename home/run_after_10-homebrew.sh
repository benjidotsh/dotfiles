#!/bin/sh
set -eu

brew=/opt/homebrew/bin/brew
brewfile="$HOME/.Brewfile"

"$brew" update
"$brew" bundle install --upgrade --file "$brewfile"
"$brew" bundle cleanup --force --zap --file "$brewfile"
