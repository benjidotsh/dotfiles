#!/bin/sh
set -eu

if ! /usr/sbin/pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license
fi
