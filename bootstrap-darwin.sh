#!/bin/bash

#
# MAC OS X ブートストラップ
#
# このスクリプトは Mac OS X 使用時に `bootstrap.sh` から実行されます。


##
# 変数定義

CWD=$(pwd)

TEXT_BOLD=$(tput bold)
TEXT_RED=$(tput setaf 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

DOTFILES_DARWIN_PATH="${HOME}/.dotfiles/darwin"


##
# 主処理

echo "${TEXT_BOLD}Mac OS X の最適化を開始します...${TEXT_RESET}"

# ローカル Time Machine スナップショットを無効化
sudo tmutil disablelocal

# `locate` コマンド用 DB 作成
#sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

# LoginHook のインストール
if ! sudo defaults read com.apple.loginwindow LoginHook &> /dev/null
then
    sudo defaults write com.apple.loginwindow LoginHook ${DOTFILES_DARWIN_PATH}/hook.sh
fi

# ネットワークドライブ上での `.DS_Store` 作成を無効化
if ! defaults read com.apple.desktopservices DSDontWriteNetworkStores &> /dev/null
then
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
fi

# 隠しファイル (ドットファイル) を表示
if ! defaults read com.apple.finder AppleShowAllFiles &> /dev/null
then
    defaults write com.apple.finder AppleShowAllFiles -bool true
    killall Finder
fi

# Kotoeri のデフォルト空白文字を全角から半角へ
defaults write com.apple.inputmethod.Kotoeri zhsy -dict-add " " -bool no
killall Kotoeri

# スクリーンショットの影を無効化
if ! defaults read com.apple.screencapture disable-shadow &> /dev/null
then
    defaults write com.apple.screencapture disable-shadow -bool true
    killall SystemUIServer
fi


echo "${TEXT_BOLD}基本的なアプリケーションのインストールを開始します...${TEXT_RESET}"

# カレントディレクトリを ~/Downloads へ
cd ${HOME}/Downloads

# XQuartz のインストール
if [ ! -d /Applications/Utilities/XQuartz.app ]
then
    curl -L -O http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.7.dmg
    hdiutil attach XQuartz-2.7.7.dmg
    sudo installer -pkg /Volumes/XQuartz-2.7.7/XQuartz.pkg -target /
    hdiutil detach /Volumes/XQuartz-2.7.7
fi

# Asepsis のインストール
if ! which asepsisctl &> /dev/null
then
    curl -L -O http://downloads.binaryage.com/Asepsis-1.5.dmg
    hdiutil attach Asepsis-1.5.dmg
    sudo installer -pkg /Volumes/Asepsis/Asepsis.mpkg -target /
    hdiutil detach /Volumes/Asepsis
fi

# カレントディレクトリをリセット
cd ${CWD}


echo "${TEXT_BOLD}開発環境のセットアップを開始します...${TEXT_RESET}"

# Xcode インストール有無確認
if [ ! -d /Applications/Xcode.app ]
then
    echo "${TEXT_RED}Xcode が見つかりません。中止します。${TEXT_RESET}"
    exit 1
fi

# Xcode ライセンス同意
# TODO: Skip if already agreed
sudo xcodebuild -license

# Command Line Tools のインストール
if [ ! -d $(xcode-select --print-path) ]
then
    xcode-select --install
fi

# Homebrew のインストール
HOMEBREW="${HOME}/.homebrew"

if ! which brew &> /dev/null
then
    export PATH="${HOMEBREW}/bin:${PATH}"
fi

if [ ! -d ${HOMEBREW} ]
then
    mkdir -p ${HOMEBREW}
    curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C ${HOMEBREW}

    brew tap homebrew/versions
    brew tap homebrew/dupes
    brew tap josegonzalez/homebrew-php
fi

unset HOMEBREW

# Homebrew 経由で基本的な依存パッケージをインストール
brew update
brew upgrade

BREWS=(
    'autoconf'
    'automake'
    'cmake'
    'gcc48'
    'gettext'
    'git'
    'git-extras'
    'grc'
    'libpeg'
    'libpng'
    'mcrypt'
    'mercurial'
    'openssl'
    'php-build'
    'pkg-config'
    're2c'
    'readline'
    'rmtrash'
    'ruby-build'
    'scons'
    'rben'
    'pyenv'
)

for BREW in "${BREWS[@]}"
do
    FORMULA=$(echo ${BREW} | cut -d ' ' -f 1)

    if ! brew list | grep ${FORMULA} &> /dev/null
    then
        brew install ${BREW}
    fi

    unset FORMULA
done

unset BREW BREWS

brew cleanup


# nenv 経由で Node.js をインストール
if ! which nenv &> /dev/null
then
    NENV="${HOME}/.nenv"

    if [ ! -d ${NENV} ]
    then
        git clone git://github.com/ryuone/nenv.git ${NENV}
    else
        cd ${NENV}
        git pull
        cd ${CWD}
    fi

    export PATH="${NENV}/bin:${PATH}"

    nenv install 0.10.10
    nenv rehash
    nenv global 0.10.10

    unset NENV
fi

# デフォルト言語設定
#sudo languagesetup

# 終了処理
unset \
    CWD \
    TEXT_BOLD \
    TEXT_RED \
    TEXT_GREEN \
    TEXT_RESET \
    DOTFILES_DARWIN_PATH
