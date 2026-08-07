#!/bin/sh
set -eu

write_default() {
  domain=$1
  key=$2
  type=$3
  expected=$4
  current=$(/usr/bin/defaults read "$domain" "$key" 2>/dev/null || true)

  if [ "$current" != "$expected" ]; then
    /usr/bin/defaults write "$domain" "$key" "$type" "$expected"
  fi
}

write_default com.apple.dock show-recents -bool 0
write_default com.apple.dock appswitcher-all-displays -bool 1
write_default com.apple.dock minimize-to-application -bool 0
write_default com.apple.dock mineffect -string genie
write_default com.apple.dock wvous-br-corner -int 1
write_default com.apple.dock tilesize -int 64

# Enables the App Expose trackpad gesture.
write_default com.apple.dock showAppExposeGestureEnabled -int 1

write_default NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool 0
write_default NSGlobalDomain AppleInterfaceStyle -string Dark

# Search the current folder by default in Finder.
write_default com.apple.finder FXDefaultSearchScope -string SCcf

# Avoid .DS_Store files on network and removable volumes. macOS applies these
# Desktop Services settings fully after logout/login.
write_default com.apple.desktopservices DSDontWriteNetworkStores -bool 1
write_default com.apple.desktopservices DSDontWriteUSBStores -bool 1

write_default com.apple.menuextra.clock ShowSeconds -bool 1
