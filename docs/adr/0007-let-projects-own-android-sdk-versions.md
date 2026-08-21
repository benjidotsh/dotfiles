# Let projects own Android SDK versions

> Superseded by ADR 0010: the Android SDK is not part of this fork's single-machine baseline, and no Android tooling is declared.

For the personal profile, install Android Studio and Android command-line tools through Homebrew, then use a recurring chezmoi script to maintain `platform-tools` and `emulator` in `~/Library/Android/sdk`. Pre-accept outstanding SDK licenses with Android's documented `yes | sdkmanager --licenses` flow. Do not declare a global Android platform or build-tools version: Android Studio or Gradle downloads the versions required by each project after license acceptance. This avoids freezing the machine on an eventually stale API while preserving automatic setup and repair. System images and virtual devices remain user- and project-selected because they are large and encode device-specific choices.
