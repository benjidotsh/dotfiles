#!/bin/sh
set -eu

target=/etc/pam.d/sudo_local
template=/etc/pam.d/sudo_local.template
rule='auth       sufficient     pam_tid.so'

if [ -r "$target" ] && /usr/bin/grep -Eq '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so([[:space:]]|$)' "$target"; then
  exit 0
fi

tmp=$(/usr/bin/mktemp "${TMPDIR:-/tmp}/sudo_local.XXXXXX")
trap '/bin/rm -f "$tmp"' EXIT HUP INT TERM

if [ -r "$target" ]; then
  /bin/cat "$target" > "$tmp"
elif [ -r "$template" ]; then
  /usr/bin/sed '/^[[:space:]]*#auth[[:space:]][[:space:]]*sufficient[[:space:]][[:space:]]*pam_tid\.so[[:space:]]*$/d' "$template" > "$tmp"
fi

printf '%s\n' "$rule" >> "$tmp"
/usr/bin/sudo /usr/bin/install -o root -g wheel -m 0444 "$tmp" "$target"
