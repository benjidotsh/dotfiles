# Android SDK automation on a fresh Apple Silicon Mac

Date: 2026-08-07

## Conclusion

Yes. Chezmoi can install and maintain a useful Android SDK baseline without
running Android Studio's setup wizard.

The minimal clean design is:

1. Homebrew installs `android-studio`, `android-commandlinetools`, and the
   existing `zulu@17` JDK for the personal profile.
2. A recurring chezmoi script uses Homebrew's `sdkmanager`, explicitly targets
   `~/Library/Android/sdk`, pre-accepts outstanding licenses, updates installed
   SDK packages, and ensures the declared infrastructure packages.
3. Android Studio and command-line builds share that SDK directory.
4. Emulator system images and AVDs remain user/project choices. They are large
   and encode choices that the existing configuration does not make.

Android explicitly documents `yes | sdkmanager --licenses` for scripted
pre-acceptance when the user has read and agrees to the terms. Using it encodes
that consent and also permits Gradle to download project-required SDK packages.
[Android NDK and CMake setup](https://developer.android.com/studio/projects/install-ndk)

## Ownership

### Homebrew

Add the following personal casks:

```ruby
cask "android-studio"
cask "android-commandlinetools"
cask "zulu@17"
```

The command-line-tools cask has native ARM and Intel downloads, installs its
own SDK root under Homebrew's prefix, exposes `sdkmanager` and `avdmanager` as
binaries, and declares a Java dependency. Its current cask source also makes
clear that this Homebrew-owned directory is removed by the cask's `zap`.
[Homebrew `android-commandlinetools` cask source](https://github.com/Homebrew/homebrew-cask/blob/master/Casks/a/android-commandlinetools.rb)

The Android Studio cask selects the `mac_arm` build on Apple Silicon, installs
`Android Studio.app`, and treats `~/Library/Android/sdk` as Studio-owned data for
zap purposes. [Homebrew `android-studio` cask source](https://github.com/Homebrew/homebrew-cask/blob/master/Casks/a/android-studio.rb)

### Chezmoi

Chezmoi owns SDK infrastructure, not an exact SDK inventory. Android Studio,
Gradle, or projects add the platform and build-tools versions they require; the
script neither removes nor downgrades them.

Declared infrastructure:

```text
platform-tools
emulator
```

`platform-tools` supplies tools such as `adb`; `emulator` preserves the existing
`$ANDROID_HOME/emulator` path. Gradle can automatically download the platform
and build-tools packages a project requires after their licenses are accepted.
[Android SDK update documentation](https://developer.android.com/studio/intro/update)

No system image or AVD is included. An AVD requires a particular system-image
package and a hardware profile; Android recommends selecting these according
to what the app supports. [Android AVD documentation](https://developer.android.com/studio/run/managing-avds)

## Minimal chezmoi script

Assuming the selected profile is available as `.profile`, place this at
`run_after_30-android-sdk.sh.tmpl`:

```sh
{{ if eq .profile "personal" -}}
#!/bin/sh
set -eu

sdk_root="$HOME/Library/Android/sdk"
sdkmanager="$(command -v sdkmanager)"

mkdir -p "$sdk_root"

yes | "$sdkmanager" --sdk_root="$sdk_root" --licenses
"$sdkmanager" --sdk_root="$sdk_root" --update
"$sdkmanager" --sdk_root="$sdk_root" \
  "platform-tools" \
  "emulator"
{{ end -}}
```

A normal `run_` script executes on every `chezmoi apply`. That is intentional:
it notices newly required licenses, updates already installed packages, and
repairs a deleted baseline. Chezmoi runs scripts in deterministic name order,
so `30-android-sdk` can follow the Homebrew convergence script.
[Chezmoi target types](https://www.chezmoi.io/reference/target-types/)

The environment remains:

```sh
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
```

Android documents `ANDROID_HOME` as the SDK installation directory and says
`ANDROID_SDK_ROOT` is deprecated. It also documents adding SDK tool directories
to `PATH`. [Android environment-variable documentation](https://developer.android.com/tools/variables)

## Result

On the first personal-profile apply:

- Homebrew installs native Apple Silicon Android Studio and command-line tools.
- `sdkmanager` creates/populates `~/Library/Android/sdk`.
- Outstanding Android SDK licenses are accepted without prompting.
- Android Studio subsequently sees the SDK at its normal macOS location.
- `adb` and `emulator` are available through the already planned shell paths.
- No AVD exists yet. The user can create one in Android Studio when needed.

On later applies:

- no pending license means no meaningful interaction;
- installed packages are updated, then the declared baseline is reasserted;
- extra SDK packages installed by Studio or projects remain installed.

Android supports installing/updating SDK packages through either Android
Studio or `sdkmanager`, so sharing the directory is a supported workflow.
[Android command-line tools overview](https://developer.android.com/tools)

## Failure modes

- **License command fails:** the script and apply fail visibly. A later apply
  retries because this is a regular `run_` script.
- **Network or Google repository unavailable:** `sdkmanager` exits nonzero and
  the apply fails. Existing SDK contents remain usable.
- **Homebrew command-line tools or Java missing:** `command -v sdkmanager` or
  the Java-based tool fails, making the ordering/dependency error visible.
- **Package ID becomes unavailable:** apply fails at that package and requires
  an intentional configuration change.
- **Android Studio adds packages:** they are updated by `--update` but never
  removed by this script.
- **Homebrew `zap` removes Android Studio:** its cask may delete
  `~/Library/Android/sdk`; the next personal apply recreates the baseline. This
  follows the already accepted destructive Homebrew cleanup semantics.

## Versions and Apple Silicon

- `platform-tools` and `emulator` are rolling stable package IDs.
- Homebrew tracks the current stable command-line-tools and Android Studio
  casks; the existing `brew upgrade` policy advances them.
- Project configuration selects platform and build-tools versions; Gradle or
  Android Studio downloads them into the shared SDK when needed.
- Homebrew selects ARM-native command-line tools and Android Studio on Apple
  Silicon. If an emulator image is later declared, it should be an
  `arm64-v8a` image; Android lists that architecture for accelerated emulation
  on Apple Silicon. [Android emulator acceleration requirements](https://developer.android.com/studio/run/emulator-acceleration)

Android advises choosing a specific command-line-tools version in scripts for
stability, while `latest` is suitable for local use. This repository has
already chosen Homebrew's upgrade-oriented model rather than closure-level
pinning, so letting Homebrew advance the local CLI is consistent; projects
remain responsible for their platform and build-tools versions.
[Android `sdkmanager` installation guidance](https://developer.android.com/tools/sdkmanager)
