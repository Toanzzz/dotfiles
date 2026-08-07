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

  if ((${#missing[@]} > 0)); then
    echo "Installing missing packages: ${missing[*]}"
    brew install "${missing[@]}"
  fi
}

init_submodules() {
  git -C "$DOTFILES_DIR" submodule update --init --recursive
}

link_file() {
  local src="$1"
  local dest="$2"

  if [[ -L "$dest" ]]; then
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    mv "$dest" "${dest}.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backed up existing $dest"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "Linked $dest -> $src"
}

ensure_homebrew
install_brew_packages
init_submodules

link_file "${DOTFILES_DIR}/.zshrc" "${HOME_DIR}/.zshrc"
link_file "${DOTFILES_DIR}/.tmux.conf" "${HOME_DIR}/.tmux.conf"
link_file "${DOTFILES_DIR}/.tmux/plugins/tpm" "${HOME_DIR}/.tmux/plugins/tpm"

echo "Done."
echo "If this is a fresh tmux setup, open tmux and press prefix + I to install plugins."
