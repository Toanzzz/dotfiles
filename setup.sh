#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"

BREW_PACKAGES=(
  starship
  fzf
  zsh-autosuggestions
  tmux
)

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  cat >&2 <<'EOF'
Error: Homebrew is not installed.

Install it with:
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Then re-run this script.
EOF
  exit 1
}

install_brew_packages() {
  local missing=()
  local pkg

  for pkg in "${BREW_PACKAGES[@]}"; do
    if brew list --formula "$pkg" >/dev/null 2>&1; then
      echo "Already installed: $pkg"
    else
      missing+=("$pkg")
    fi
  done

  if ((${#missing[@]} == 0)); then
    return 0
  fi

  echo "Installing missing packages: ${missing[*]}"
  brew install "${missing[@]}"
}

init_submodules() {
  git -C "$DOTFILES_DIR" submodule update --init --recursive
}

link_file() {
  local src="$1"
  local dest="$2"
  local current

  if [[ ! -e "$src" && ! -L "$src" ]]; then
    echo "Error: source does not exist: $src" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" ]]; then
    current="$(readlink "$dest")"
    if [[ "$current" == "$src" ]]; then
      echo "Already linked: $dest -> $src"
      return 0
    fi
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    mv "$dest" "${dest}.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backed up existing $dest"
  fi

  ln -s "$src" "$dest"
  echo "Linked $dest -> $src"
}

install_tmux_plugins() {
  local installer="${HOME_DIR}/.tmux/plugins/tpm/bin/install_plugins"

  if [[ ! -x "$installer" ]]; then
    echo "Error: tpm installer not found at $installer" >&2
    exit 1
  fi

  echo "Ensuring tmux plugins are installed"
  "$installer"
}

ensure_homebrew
install_brew_packages
init_submodules

link_file "${DOTFILES_DIR}/.zshrc" "${HOME_DIR}/.zshrc"
link_file "${DOTFILES_DIR}/.tmux.conf" "${HOME_DIR}/.tmux.conf"
link_file "${DOTFILES_DIR}/.tmux/plugins/tpm" "${HOME_DIR}/.tmux/plugins/tpm"

install_tmux_plugins

echo "Done."
