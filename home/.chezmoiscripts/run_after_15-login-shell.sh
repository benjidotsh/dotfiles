#!/bin/sh
set -eu

fish=/opt/homebrew/bin/fish
shells=/etc/shells
user=$(/usr/bin/id -un)

if ! /usr/bin/grep -Fxq "$fish" "$shells"; then
  printf '%s\n' "$fish" | sudo /usr/bin/tee -a "$shells" >/dev/null
fi

current_shell=$(/usr/bin/id -P "$user" | /usr/bin/awk -F: '{ print $10 }')
if [ "$current_shell" != "$fish" ]; then
  sudo /usr/bin/chsh -s "$fish" "$user"
fi
