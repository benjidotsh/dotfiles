#!/bin/sh
set -eu

if [ "$(uname -s)" != Darwin ] || [ "$(uname -m)" != arm64 ]; then
  echo "This configuration supports Apple Silicon macOS only." >&2
  exit 1
fi

if [ ! -x /opt/homebrew/bin/brew ]; then
  /bin/bash -c "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
