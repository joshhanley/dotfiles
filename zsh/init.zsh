if [[ -r "$ZSH_CONFIG/oh-my-zsh.zsh" ]]; then
  source "$ZSH_CONFIG/oh-my-zsh.zsh"
fi

if [[ -r "$ZSH_CONFIG/aliases.zsh" ]]; then
  source "$ZSH_CONFIG/aliases.zsh"
fi

if [[ -r "$ZSH_CONFIG/ssh.zsh" ]]; then
  source "$ZSH_CONFIG/ssh.zsh"
fi

if [[ -r "$ZSH_CONFIG/path.zsh" ]]; then
  source "$ZSH_CONFIG/path.zsh"
fi

if [[ -r "$ZSH_CONFIG/composer.zsh" ]]; then
  source "$ZSH_CONFIG/composer.zsh"
fi

if [[ -r "$ZSH_CONFIG/herd.zsh" ]]; then
  source "$ZSH_CONFIG/herd.zsh"
fi

# Worktree helpers are kept for reference, but not loaded by default because
# they create/remove git worktrees, manage tmux panes/windows, and can drop databases.
# if [[ -r "$ZSH_CONFIG/worktrees.zsh" ]]; then
#   source "$ZSH_CONFIG/worktrees.zsh"
# fi
