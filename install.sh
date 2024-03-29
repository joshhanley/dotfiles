#!/bin/sh

echo "Setting up your Mac..."

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `install.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle

# Start MySQL
brew services start mysql

# Set default MySQL root password and auth type.
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;"

# memcached note
# echo "At the first memcached question answer 'no --disable-memcached-sasl'"

# Install PHP extensions with PECL
# pecl install memcached imagick
pecl install imagick

# Install global Composer packages
/opt/homebrew/bin/composer global require beyondcode/expose friendsofphp/php-cs-fixer laravel/installer laravel/valet php-cs-fixer/diff tightenco/lambo # phploc/phploc phpunit/phpunit

# Install Laravel Valet
$HOME/.composer/vendor/bin/valet install

#Install global NPM packages
/opt/homebrew/bin/npm install -g @bchatard/alfred-jetbrains npm-reinstall # @vue/cli @vue/devtools @vue/cli-init nativescript  postcss-cli

# Create a Sites directory
# This is a default directory for macOS user accounts but doesn't comes pre-installed
mkdir $HOME/Sites

# Create Development directory
mkdir $HOME/Development

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
# rm -rf $HOME/.zshrc
# ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc

# Symlink the Mackup config file to the home directory
ln -s $HOME/.dotfiles/.mackup $HOME/.mackup
ln -s $HOME/.dotfiles/.mackup.cfg $HOME/.mackup.cfg

# Set macOS preferences
# We will run this last because this will reload the shell
source .macos.sh
