# Process restarts after macOS preference convergence

Date: 2026-08-07
Observed OS: macOS 26.6 (25G72)

## Conclusion

The convergence script needs at most three targeted restarts when the relevant
domain actually changed:

```sh
killall Dock          # after any com.apple.dock change
killall Finder        # after FXDefaultSearchScope, for guaranteed immediate effect
killall ControlCenter # after com.apple.menuextra.clock ShowSeconds
```

It should **not** kill `cfprefsd` or `SystemUIServer`.

One setting is different: Apple explicitly requires logging out and back in
after changing `DSDontWriteNetworkStores`. Apply the USB counterpart at the
same time and document one logout after initial bootstrap. Do not automate the
logout.

`AppleInterfaceStyle` should ideally be set through System Events' supported
`dark mode` scripting property, which triggers the normal live appearance
transition and needs no process restart. If the design keeps the raw global
default for exact parity, only newly launched apps are guaranteed to see it;
an eventual logout/login covers all applications.

## Matrix

| Planned preference | Owner/consumer | Required action for immediate, guaranteed effect | Later natural effect |
|---|---|---|---|
| `com.apple.dock show-recents` | Dock | Restart Dock | Next Dock launch/login |
| `com.apple.dock appswitcher-all-displays` | Dock | Restart Dock | Next Dock launch/login |
| `com.apple.dock minimize-to-application` | Dock | Restart Dock | Next Dock launch/login |
| `com.apple.dock mineffect` | Dock | Restart Dock | Next Dock launch/login |
| `com.apple.dock persistent-apps` | Dock | Restart Dock | Next Dock launch/login |
| `com.apple.dock persistent-others` | Dock | Restart Dock | Next Dock launch/login |
| `com.apple.dock wvous-br-corner` | Dock | Restart Dock | Next Dock launch/login |
| `com.apple.dock tilesize` | Dock | Restart Dock | Next Dock launch/login |
| `com.apple.dock showAppExposeGestureEnabled` | Dock | Restart Dock | Next Dock launch/login |
| `com.apple.finder FXDefaultSearchScope` | Finder | Restart Finder if immediate repair is required | Next Finder launch/login |
| global `NSAutomaticSpellingCorrectionEnabled` | Each AppKit application | No central process; restart already-running affected apps only | Each app's next launch; logout/login covers all |
| global `AppleInterfaceStyle` through raw `defaults` | AppKit and system UI processes | No single sufficient restart; use System Events instead, or logout/login | New app launches; next login covers all |
| `com.apple.desktopservices DSDontWriteNetworkStores` | Finder/Desktop Services session | Logout/login (Apple's documented requirement) | Next login |
| `com.apple.desktopservices DSDontWriteUSBStores` | Finder/Desktop Services session | Treat like the network-store sibling: logout/login | Next login |
| `com.apple.menuextra.clock ShowSeconds` | ControlCenter on Big Sur and later | Restart ControlCenter | Next ControlCenter launch/login |

## Why these boundaries

### Defaults and caching

The `defaults(1)` manual shipped with macOS 26.6 says not to modify the domain
of a running application: the application might not see the change and might
overwrite it. It also explains that `NSGlobalDomain` is inherited by
applications when the application domain has no value. This supports two
rules:

- restart the process that owns an application domain when immediate effect is
  required;
- do not invent a central restart for global AppKit preferences—applications
  consume them individually.

Apple's preferences documentation likewise explains that `NSUserDefaults`
caches values and that applications can observe changes. Observation is an
application choice, so writing a preference does not by itself guarantee that
every running consumer refreshes.
[Apple, Accessing Preference Values](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/AccessingPreferenceValues/AccessingPreferenceValues.html)

No explicit cache flush is needed. Apple removed synchronization requirements
from `UserDefaults`/`CFPreferences`; synchronization methods are now
unnecessary. [Apple Foundation release notes](https://developer.apple.com/documentation/macos-release-notes/foundation-release-notes)

### Dock

All nine planned Dock/layout/gesture values share `com.apple.dock`, so one Dock
restart after all writes is sufficient.

This is also exactly how the established owners converge it:

- current nix-darwin writes all user defaults and runs `killall Dock` when the
  configured Dock set is non-empty; it does not restart Finder,
  `SystemUIServer`, or `cfprefsd`;
  [nix-darwin `defaults-write.nix`](https://github.com/nix-darwin/nix-darwin/blob/master/modules/system/defaults-write.nix)
- dockutil writes the Dock through CFPreferences, synchronizes the domain, then
  terminates Dock unless `--no-restart` was requested. Its changelog records
  that it removed the old `cfprefsd` restart in favor of the defaults API.
  [dockutil `Dock.swift`](https://github.com/kcrawford/dockutil/blob/main/Sources/DockUtil/Dock.swift),
  [dockutil changelog](https://github.com/kcrawford/dockutil#changelog)

For a batch, pass `--no-restart` to every dockutil operation, write the scalar
Dock defaults, then restart Dock once—and only if something changed.

### Finder search scope

`FXDefaultSearchScope` is in Finder's own preference domain. Under the current
`defaults(1)` warning, restarting Finder is the only simple way to guarantee
that the already-running Finder reads it immediately. It is unnecessary if
eventual effect at Finder's next launch/login is acceptable.

Current nix-darwin does not restart Finder, so omitting this restart preserves
its activation semantics but does not guarantee immediate repair. A
drift-aware chezmoi script can be slightly stronger without recurring
disruption: restart Finder only when this key changed.

### Spelling correction

`NSAutomaticSpellingCorrectionEnabled` is a global default used by individual
applications, not a daemon setting. New applications inherit it. Existing
applications may keep their cached value; there is no single process whose
restart refreshes every application. Do not kill a UI service for it.

### Dark appearance

The raw Nix behavior is:

```sh
defaults write -g AppleInterfaceStyle -string Dark
```

That persists the global value, but the `defaults(1)` warning means it is not a
reliable way to cause every running application to transition. Killing Dock,
Finder, ControlCenter, or SystemUIServer cannot refresh arbitrary third-party
apps.

macOS 26.6's installed System Events scripting definition declares the
`appearance preferences` object and its writable Boolean `dark mode` property
(`/System/Library/CoreServices/System Events.app/Contents/Resources/SystemEvents.sdef`).
Using that preference owner invokes the normal system-wide transition:

```sh
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'
```

Apple documents Dark Mode as system-wide and says the system automatically asks
running windows and views to redraw during an appearance transition.
[Apple, Supporting Dark Mode](https://developer.apple.com/documentation/uikit/supporting-dark-mode-in-your-interface)

Caveat: the first Apple-event automation from a terminal may require the user
to approve macOS Automation access. If avoiding that permission prompt matters
more than immediate transition, retain `defaults write` and rely on the one
post-bootstrap logout already required by Desktop Services.

### Network and USB `.DS_Store`

Apple's own administrator guidance specifies:

```sh
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
```

and then explicitly requires logging out and back in. It does not prescribe a
Finder, Desktop Services, `cfprefsd`, or UI-server restart as a substitute.
[Apple, Adjust SMB browsing behavior in macOS](https://support.apple.com/102064)

Apple does not publish equivalent current guidance for
`DSDontWriteUSBStores`. Because it is the sibling switch in the same Desktop
Services domain and is consumed by the same user session, the conservative
classification is the same logout/login—not an invented daemon restart. This
is an inference, not an Apple-documented guarantee.

### Menu-bar seconds and `SystemUIServer`

`killall SystemUIServer` is obsolete for this setting.

On the inspected macOS 26.6 installation, the ControlCenter executable contains
the `com.apple.menuextra.clock` domain, its clock controller/status-item types,
and `AppleTimePreferencesChangedNotification`. The SystemUIServer executable
still contains the domain string, but is no longer the menu-bar clock owner.

An established clock-settings implementation independently documents the
behavioral boundary: before Big Sur, restarting SystemUIServer refreshed the
clock; on Big Sur and later it does not, and ControlCenter must be restarted
after changing `com.apple.menuextra.clock`.
[menu-bar-clock background and process notes](https://github.com/tech-otaku/menu-bar-clock#systemuiserver-process)

Therefore:

```sh
defaults write com.apple.menuextra.clock ShowSeconds -bool true
killall ControlCenter
```

Restart ControlCenter only when the value changed. It is automatically
relaunched by the user session.

## Recommended convergence shape

```sh
dock_changed=false
finder_changed=false
clock_changed=false

# Compare each current value, write only drift, and mark its owner here.
# Use dockutil --no-restart while rebuilding the Dock layout.

if [ "$dock_changed" = true ]; then killall Dock; fi
if [ "$finder_changed" = true ]; then killall Finder; fi
if [ "$clock_changed" = true ]; then killall ControlCenter; fi
```

Do not put `killall cfprefsd` or `killall SystemUIServer` in the script. Tell the
user once, after fresh bootstrap, to log out and back in so the Desktop Services
settings take effect. Later applies may persist those keys again but should not
force a logout.
