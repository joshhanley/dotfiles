#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_SOURCE="$DOTFILES_DIR/zsh/.zshrc"
GITIGNORE_SOURCE="$DOTFILES_DIR/.gitignore_global"

backup_path() {
  local path="$1"
  local timestamp

  timestamp="$(date +%Y%m%d%H%M%S)"
  mv "$path" "$path.backup.$timestamp"
}

install_zshrc() {
  if [[ ! -f "$ZSHRC_SOURCE" ]]; then
    echo "Missing $ZSHRC_SOURCE"
    return 1
  fi

  if [[ -e "$HOME/.zshrc" ]] && ! cmp -s "$ZSHRC_SOURCE" "$HOME/.zshrc"; then
    backup_path "$HOME/.zshrc"
  fi

  cp "$ZSHRC_SOURCE" "$HOME/.zshrc"
  echo "Installed ~/.zshrc"
}

install_gitignore_global() {
  if [[ ! -f "$GITIGNORE_SOURCE" ]]; then
    echo "Missing $GITIGNORE_SOURCE"
    return 1
  fi

  if [[ -L "$HOME/.gitignore_global" ]]; then
    rm "$HOME/.gitignore_global"
  elif [[ -e "$HOME/.gitignore_global" ]]; then
    backup_path "$HOME/.gitignore_global"
  fi

  ln -s "$GITIGNORE_SOURCE" "$HOME/.gitignore_global"
  git config --global core.excludesfile "$HOME/.gitignore_global"
  echo "Installed ~/.gitignore_global"
}

install_zshrc
install_gitignore_global

echo "Done"
