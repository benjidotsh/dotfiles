#!/bin/sh
set -eu

brew=/opt/homebrew/bin/brew

"$brew" update
"$brew" bundle install --upgrade --force-cleanup --zap --global
