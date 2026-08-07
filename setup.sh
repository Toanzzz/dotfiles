#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"

link_file() {
  local src="$1"
  local dest="$2"

  if [[ -L "$dest" ]]; then
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    mv "$dest" "${dest}.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backed up existing $dest"
  fi

  ln -s "$src" "$dest"
  echo "Linked $dest -> $src"
}

link_file "${DOTFILES_DIR}/.zshrc" "${HOME_DIR}/.zshrc"
link_file "${DOTFILES_DIR}/.tmux.conf" "${HOME_DIR}/.tmux.conf"

echo "Done."
