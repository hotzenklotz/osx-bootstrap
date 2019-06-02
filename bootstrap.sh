#!/usr/bin/env bash
#
# Bootstrap script for setting up a new OSX machine
#
# This should be idempotent so it can be run multiple times.
#
# Some apps don't have a cask and so still need to be installed by hand. These
# include:
#
# - Twitter (app store)
# - Postgres.app (http://postgresapp.com/)
#
# Notes:
#
# - If installing full Xcode, it's better to install that first from the app
#   store before running the bootstrap script. Otherwise, Homebrew can't access
#   the Xcode libraries as the agreement hasn't been accepted yet.
#
# Reading:
#
# - http://lapwinglabs.com/blog/hacker-guide-to-setting-up-your-mac
# - https://gist.github.com/MatthewMueller/e22d9840f9ea2fee4716
# - https://news.ycombinator.com/item?id=8402079
# - http://notes.jerzygangi.com/the-best-pgp-tutorial-for-mac-os-x-ever/

echo "Starting bootstrapping"

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update homebrew recipes
brew update

# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils
brew install gnu-sed
brew install gnu-tar
brew install gnu-indent
brew install gnu-which
brew install grep

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

PACKAGES=(
    ack
    autoconf
    automake
    awscli
    cmake
    colordiff
    fasd
    ffmpeg
    findutils
    gettext
    git
    grep
    hdf5
    jq
    libjpeg
    node
    npm
    nvm
    postgresql
    python
    python3
    rename
    ssh-copy-id
    tmux
    tree
    watch
    wget
    youtube-dl
)

echo "Installing packages..."
brew install ${PACKAGES[@]}

echo "Cleaning up..."
brew cleanup

CASKS=(
    1password
    android-file-transfer
    appcleaner
    arduino
    betaflight-configurator
    caffeine
    cncjs
    cyberduck
    dopcker
    dropbox
    firefox
    gifox
    gimp
    github
    google-backup-and-sync
    google-chrome
    iterm2
    java
    postico
    postman
    prusaslicer
    pycharm
    slack
    spectacle
    spotify
    steam
    sublime-text
    the-unarchiver
    ultimaker-cura
    viber
    virtualbox
    visual-studio-code
    vlc
    xquartz
)

echo "Installing cask apps..."
brew cask install ${CASKS[@]}

echo "Installing fonts..."
FONTS=(
    font-open-sans
    font-montserrat
    font-raleway
    font-roboto
    font-clear-sans
    font-source-code-pro
)
brew cask install ${FONTS[@]}

echo "Configuring OSX..."

# Set fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 0

# Require password as soon as screensaver or sleep mode starts
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Show filename extensions by default
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Enable tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `Nlsv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 36

# Pin dock to right side of screen
defaults write com.apple.Dock orientation -string "right"

# Ipen "Save" dialog expanded
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

killall Dock > /dev/null 2>&1
killall Finder > /dev/null 2>&1

echo "Copying Dotfiles"
cp .inputrc ~
cp .gitignore ~
cp .gitconfig ~
cp .aliases ~
cp .bash_profile ~

source ~/.bash_profile

echo "Install bash-it"
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
~/.bash_it/install.sh --interactive #--silent

echo "Bootstrapping complete"
