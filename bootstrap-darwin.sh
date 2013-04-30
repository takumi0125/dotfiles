#!/bin/bash

#
# MAC OS X BOOTSTRAP
#
# This script will be run from `bootstrap.sh` if using Mac OS X


##
# Variables

CWD=$(pwd)

TEXT_BOLD=$(tput bold)
TEXT_RED=$(tput setaf 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

DOTFILES_DARWIN_PATH="${HOME}/.dotfiles/darwin"


##
# Main process

# Turn off local Time Machine snapshots
sudo tmutil disablelocal

# Enable `locate` command
#sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

# Install LoginHook
if ! sudo defaults read com.apple.loginwindow LoginHook &> /dev/null
then
    sudo defaults write com.apple.loginwindow LoginHook ${DOTFILES_DARWIN_PATH}/hook.sh
fi

# Disable `.DS_Store` on network drives
if ! defaults read com.apple.desktopservices DSDontWriteNetworkStores &> /dev/null
then
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
fi

# Make hidden files visible
if ! defaults read com.apple.finder AppleShowAllFiles &> /dev/null
then
    defaults write com.apple.finder AppleShowAllFiles -bool true
    killall Finder
fi

# Make Kotoeri use only single width space
defaults write com.apple.inputmethod.Kotoeri zhsy -dict-add " " -bool no
killall Kotoeri

# Disable the shadow from the screenshots
if ! defaults read com.apple.screencapture disable-shadow &> /dev/null
then
    defaults write com.apple.screencapture disable-shadow -bool true
    killall SystemUIServer
fi

# Current directory to ~/Downloads
cd ${HOME}/Downloads

# Install XQuartz
if [ ! -d /Applications/Utilities/XQuartz.app ]
then
    curl -L -O http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.4.dmg
    hdiutil attach XQuartz-2.7.4.dmg
    sudo installer -pkg /Volumes/XQuartz/XQuartz.pkg -target /
    hdiutil detach /Volumes/XQuartz
fi

# Install ClamXav
if [ ! -d /Applications/ClamXav.app ]
then
    curl -L -O http://www.clamxav.com/downloads/ClamXav_2.3.6.dmg
    hdiutil attach ClamXav_2.3.6.dmg
    cp -R /Volumes/ClamXav/ClamXav.app /Applications/
    hdiutil detach /Volumes/ClamXav
fi

# Install Asepsis
if ! which asepsisctl &> /dev/null
then
    curl -L -O http://downloads.binaryage.com/Asepsis-1.3.dmg
    hdiutil attach Asepsis-1.3.dmg
    sudo installer -pkg /Volumes/Asepsis/Asepsis.mpkg -target /
    hdiutil detach /Volumes/Asepsis
fi

# Install TotalTerminal
if [ ! -d /Applications/TotalTerminal.app ]
then
    curl -L -O http://downloads.binaryage.com/TotalTerminal-1.3.dmg
    hdiutil attach TotalTerminal-1.3.dmg
    sudo installer -pkg /Volumes/TotalTerminal/TotalTerminal.pkg -target /
    hdiutil detach /Volumes/TotalTerminal
fi

# Reset current working directory
cd ${CWD}

# Check if Xxode is installed
if [ ! -d /Applications/Xcode.app ]
then
    echo "${TEXT_RED}Xcode not found. Aborted.${TEXT_RESET}"
    exit 1
fi

# Xcode license agreement
# TODO: Skip if already agreed
xcodebuild -license

# Xcode hotfix for apxs
# http://blog.hgomez.net/blog/2012/10/15/mountain-lion-apxs/
if [ '10.8.3' == $(system_profiler SPSoftwareDataType | awk '/System Version/ {print $5}') ]
then
    sudo ln -s /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain
fi

# Install Homebrew if not exists
if ! which brew &> /dev/null
then
    echo 'Homebrew not found. Installing...'

    HOMEBREW_PATH="${HOME}/.homebrew"

    mkdir -p ${HOMEBREW_PATH}
    curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C ${HOMEBREW_PATH}

    export PATH="${HOMEBREW_PATH}/bin:${PATH}"
    unset HOMEBREW_PATH

    echo "Homebrew installed to $(which brew)"
fi

# Install fundamental dependencies through Homebrew
echo 'Installing fundamental dependencies...'
brew update
brew upgrade
brew install \
    autoconf \
    automake \
    cmake \
    gettext \
    git \
    git-extras \
    grc \
    openssl \
    pkg-config \
    python \
    rmtrash \
    ruby \
    scons
brew cleanup

# Install Node.js through nodebrew if not exists
if ! which node &> /dev/null
then
    echo 'Node.js not found. Installing...'

    curl -L git.io/nodebrew | perl - setup

    export PATH="${HOME}/.nodebrew/current/bin:${PATH}"

    nodebrew install-binary stable
    nodebrew use stable

    echo "Node.js installed to $(which node)"
fi

# Setup default lagunage
#sudo languagesetup

# Done
unset \
    CWD \
    TEXT_BOLD \
    TEXT_RED \
    TEXT_GREEN \
    TEXT_RESET \
    DOTFILES_DARWIN_PATH
