# Use Fish as the login shell

Use Homebrew Fish as the login and interactive shell for both profiles, and have chezmoi converge the account's shell selection after Homebrew installs it. Fish provides autosuggestions, syntax highlighting, completions, and declarative Fish-native configuration without the two Zsh plugins; accept the additional Homebrew shell dependency and Fish's intentional incompatibility with POSIX shell syntax. Existing shebang-driven automation remains in its appropriate POSIX shell.
