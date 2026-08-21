/opt/homebrew/bin/brew shellenv fish | source

set -gx EDITOR 'code --wait'
set -gx VOLTA_HOME "$HOME/.volta"
fish_add_path --move --path "$VOLTA_HOME/bin"
fish_add_path --append --path "$HOME/.local/bin" "$HOME/go/bin" /Library/TeX/texbin

set -gx GOPATH "$HOME/go"
set -gx JAVA_HOME /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home
set -gx AWS_CA_BUNDLE /opt/homebrew/etc/ca-certificates/cert.pem
set -gx NODE_EXTRA_CA_CERTS "$HOME/.zcli/zscaler_root.pem"
set -gx SSL_CERT_FILE "$HOME/.zcli/zscaler_root.pem"
set -gx REQUESTS_CA_BUNDLE "$HOME/.zcli/zscaler_root.pem"

# Bitwarden's SSH agent serves SSH identities and git SSH signing once its
# keys are onboarded; until then the on-disk keys keep working.
if test -S "$HOME/.bitwarden-ssh-agent.sock"
    set -gx SSH_AUTH_SOCK "$HOME/.bitwarden-ssh-agent.sock"
end

if status is-interactive
    set -g fish_greeting
    set -gx GPG_TTY (tty)
    starship init fish | source

    alias eza 'command eza --icons auto --git --group-directories-first'
    alias ll 'eza -l'
    alias la 'eza -la'
    alias lt 'eza --tree --level=2'
    alias cat 'bat --paging=never'

    alias sts 'aws sts get-caller-identity'
    alias tfapply 'terraform apply'
    alias tfplan 'terraform plan'
    alias czm 'cz commit'
    alias devex-prod 'set -gx AWS_PROFILE devex-prod-admin'
    alias devex-non-prod 'set -gx AWS_PROFILE devex-non-prod-admin'

    alias gp 'git push'
    alias gl 'git pull'
    alias gst 'git status'
    alias ga 'git add'
    alias gaa 'git add --all'
    alias gc 'git commit'
    alias gcmsg 'git commit -m'
    alias gco 'git checkout'
    alias gcb 'git checkout -b'
    alias gd 'git diff'
    alias gb 'git branch'
    alias glog 'git log --oneline --decorate --graph'

    alias dot-sync 'chezmoi update'
end
