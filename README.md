# Dotfiles

Personal shell and Git configuration.

## Setup

Run the setup script from the repo root:

```sh
./setup.sh
```

The script will:

- copy `zsh/.zshrc` to `~/.zshrc`
- symlink `.gitignore_global` to `~/.gitignore_global`
- configure Git to use `~/.gitignore_global` as the global ignore file

Existing `~/.zshrc` or `~/.gitignore_global` files are backed up before being replaced.

Oh My Zsh is not installed by this script. Install it separately before using the full Zsh setup.
