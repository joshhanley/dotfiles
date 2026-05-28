# Edit zshrc config
alias zshconfig="nano ~/.zshrc"
alias zshreload="source ~/.zshrc"

# Manage aliases
alias aa='cat "$ZSH_CONFIG/aliases.zsh"'
alias ea='nano "$ZSH_CONFIG/aliases.zsh" && zshreload'

# Override clear
# alias clear="clear && printf '\e[3J'"

# Quick directory changes
# alias sites="cd ~/Sites"
# alias jd="cd ~/Sites/JobDiaryTDD"
# alias vt="cd ~/Sites/VueTest"
# alias pkg="cd ~/Development/packages"

# Commands
alias copykey="pbcopy < ~/.ssh/id_rsa.pub"
alias dev="code . && fork ."

# GitHub commands
ghpr() {
  gh pr checkout "$1" -b pr/"$1"
}

ghrepo() {
  gh repo create "$1" --private --source . --push
}

# Git commands
gce() {
  git commit --allow-empty -m "$1"
}

# Sensible Herd defaults (to stop all sorts of problems)
# alias php="herd debug"
alias php="herd php"
alias composer="herd composer"

# PHP commands
alias pa="php artisan"
alias pf="phpunit --filter"
alias pu="phpunit"
# alias pci="clear; phpunit --bootstrap ~/Development/packages/runAsCI.php"
alias pd="./vendor/bin/dusk-updater detect --auto-update"

# Laravel
lnew() {
  laravel new "$1" --livewire --pest --npm --database="mysql" --npm --git && cd "$1" && code . && fork .
}

alias am="php artisan migrate"
alias ams="php artisan migrate --seed"
alias am-f="php artisan migrate --force"
alias amf="php artisan migrate:fresh"
alias amfs="php artisan migrate:fresh --seed"

# Livewire
alias ulw="composer config minimum-stability dev && composer config repositories.livewire/livewire path $HOME/Dev/packages/livewire && composer require livewire/livewire"
alias rlw="composer config --unset repositories.livewire/livewire && composer require livewire/livewire"

# npm
alias nrd="npm run dev"
alias nrb="npm run build"
alias nrw="npm run watch"
