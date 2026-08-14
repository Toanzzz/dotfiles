#============================================================================#
# ZSH Starship (Cross-shell Prompt)
#============================================================================#

# Install fist with `brew install starship`
eval "$(starship init zsh)"

#============================================================================#
#   ZSH Theme
#============================================================================#
ZSH_THEME="simple"


# FZF
source <(fzf --zsh)

# Prevent commit when missing username & email
# git config --global user.useconfigonly true

#============================================================================#
#   ZSH Auto commplete
#============================================================================#
# Install first with `brew install zsh-autosuggestions`
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

#============================================================================#
#   Shortcuts
#============================================================================#

# AWS Profile Switcher
alias awsp='export AWS_PROFILE=$(aws configure list-profiles | fzf --prompt="Select AWS Profile: ") && aws sts get-caller-identity'

# Java Home Switcher
alias javah='export JAVA_HOME=$(/usr/libexec/java_home -X | xpath -e "//key[.=\"JVMHomePath\"]/following-sibling::string[1]/text()" -q | fzf --prompt="Select Java Home: ")'

# SSH connect selector
sshs() {
  local selected
  selected=$(grep -E "^Host " ~/.ssh/config | grep -v "[*?]" | awk '{for (i=2; i<=NF; i++) print $i}' | sort -u | fzf --prompt="Select SSH host: ")
  if [ -n "$selected" ]; then
    echo "🚀 Connecting to: $selected"
    ssh "$selected"
  else
    echo "❌ No host selected."
  fi
}

# Git user name and email shortcuts
alias t-gitinit='personalized_gitinit Toàn me@toan.io'
alias bees-gitinit='personalized_gitinit Toàn toan@thebees.group'
alias cmd-gitinit='personalized_gitinit toàn toan.ng@commandoss.com'
# alias al-gitinit='personalized_gitinit Toàn toan@alphalabs.vn'
# alias fs-gitinit='personalized_gitinit Toàn toan@farmerstud.io'

function personalized_gitinit {
  name="$1"
  email="$2"

  if [ -z name ]; then
    echo "Missing args"
    return 1
  fi

  git config user.name $name
  git config user.email $email
  echo "Updated \e[41mgit\e[49m config:"
  git config --get-regexp --show-scope 'user\.(name|email)' |
    awk '{print $1, "\033[92m" $2, "\033[96m" $3" \033[39m" }' |
    column -t
}

# Tmux shortcuts
alias tm-t-infra="tmux new -As Ton -n infra -c ~/code/T/infra"
alias tm-bees-infra="tmux new -As 'BEES IaC' -n main -c ~/code/BEES/iac"
alias tm-truyentranh="tmux new -As TTMANGA -n web -c ~/code/TruyenTranhVN/truyentranh"
alias tm-coralhub="tmux new -As CoralHub -n main -c ~/code/NerdCoder/coralhub"
alias tm-mailgate="tmux new -As MailGate -n main -c ~/code/CommandOSS/mailgate"
alias tm-dotfiles="tmux new -As dotfiles -n main -c ~/code/T/dotfiles"
alias tm-spd-seed="tmux new -As 'SPD Seed' -n main -c ~/code/NerdCoder/spd-seed-analyzer"
alias clear="if [[ '$TMUX' ]]; then clear; tmux clear-history; else clear; fi"

# Git Worktrees Jump
gwtj() {
  # 1. Check if we are inside a Git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: Not in a git repository." >&2
    return 1
  fi

  local target
  
  # 2. Store the chosen path with the preview window (written on one line to prevent backslash parsing errors)
  target=$(git worktree list | fzf --preview 'git -C {1} log --oneline --graph --decorate --color=always -15' --preview-window 'right:50%:border-left' | awk '{print $1}')
  
  # 3. Only 'cd' if a selection was actually made
  if [[ -n "$target" ]]; then
    cd "$target"

    # 4. If in tmux, offer to update session default directory for new windows
    if [[ -n "$TMUX" ]]; then
      echo -n "Update tmux default dir to $target? [y/N] "
      read -r reply
      if [[ "$reply" =~ ^[Yy]$ ]]; then
        # Control mode + full redirect: set session path without nesting or TTY escape noise
        local sid
        sid=$(tmux display-message -p '#{session_id}')
        TMUX= tmux -C attach-session -t "$sid" -c "$target" \; detach-client </dev/null >/dev/null 2>&1
        tmux rename-window "$(basename "$target")"
        echo "Updated tmux default directory and window name."
      fi
    fi
  fi
}

# Tailscale
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# Show detailed
alias ls="ls -lahG"

# SSH to a temp server
alias sshu="ssh -o=UserKnownHostsFile=/dev/null -o=StrictHostKeyChecking=no"

# Screen Copy for Andorid devices - predefined param
alias scrcpy="\
scrcpy \
  --shortcut-mod=lctrl \
  --no-mouse-hover \
  --keep-active \
  --stay-awake \
  --turn-screen-off \
  --power-off-on-close \
  --show-touches \
  --max-size=1920 \
"

#============================================================================#
#   Configuration ENV
#============================================================================#

# Default bin directory (Homebrew and user bin folder)
export PATH="/opt/homebrew/bin:$HOME/.local/bin:$HOME/bin:$PATH"

### Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

### Deno
export PATH="$HOME/.deno/bin:$PATH"

### Bun
export PATH="$HOME/.bun/bin:$PATH"

### Kubernetes - Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

### Aptos.DEV
export PATH="$HOME/.aptos:$PATH"

### Add .NET Core SDK tools
export PATH="$PATH:$HOME/.dotnet/tools"

### Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"

### Add Android SDK tools
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin/"
export PATH="$PATH:$HOME/Library/Android/sdk/emulator"

### WASI - WebAssembly System Interface
export WASI_SDK_PATH="$HOME/.wasi/wasi-sdk-21.0"
export WASMTIME_HOME="$HOME/.wasmtime"
export PATH="$WASMTIME_HOME/bin:$PATH"

### Mise - Polyglot runtime manager (asdf rust clone)
### https://mise.jdx.dev/
export PATH="$HOME/.local/share/mise/shims:$PATH"
eval "$(mise activate zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

# Android SDK Build tools
export PATH=$PATH:~/Library/Android/sdk/build-tools/36.0.0/

### Sublime Text
export PATH="$HOME/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
