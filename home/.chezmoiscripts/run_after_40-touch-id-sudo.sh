#!/bin/sh
set -eu

target=/etc/pam.d/sudo_local
rule='auth       sufficient     pam_tid.so'

tmp=$(mktemp -t sudo_local)
trap 'rm -f "$tmp"' EXIT
printf '%s\n' "$rule" > "$tmp"

if ! cmp -s "$tmp" "$target" 2>/dev/null; then
  # root:wheel 0444 matches the stock /etc/pam.d files.
  sudo install -o root -g wheel -m 0444 "$tmp" "$target"
fi
