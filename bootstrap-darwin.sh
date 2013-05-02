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

# カレントディレクトリを ~/Downloads へ
cd ${HOME}/Downloads

# XQuartz のインストール
if [ ! -d /Applications/Utilities/XQuartz.app ]
then
    curl -L -O http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.4.dmg
    hdiutil attach XQuartz-2.7.4.dmg
    sudo installer -pkg /Volumes/XQuartz/XQuartz.pkg -target /
    hdiutil detach /Volumes/XQuartz
fi

# Asepsis のインストール
if ! which asepsisctl &> /dev/null
then
    curl -L -O http://downloads.binaryage.com/Asepsis-1.3.dmg
    hdiutil attach Asepsis-1.3.dmg
    sudo installer -pkg /Volumes/Asepsis/Asepsis.mpkg -target /
    hdiutil detach /Volumes/Asepsis
fi

# カレントディレクトリをリセット
cd ${CWD}

# Xcode インストール有無確認
if [ ! -d /Applications/Xcode.app ]
then
    echo "${TEXT_RED}Xcode が見つかりません。中止します。${TEXT_RESET}"
    exit 1
fi

# Xcode ライセンス同意
# TODO: Skip if already agreed
xcodebuild -license

# Xcode hotfix for apxs
# http://blog.hgomez.net/blog/2012/10/15/mountain-lion-apxs/
if [ '10.8.3' == $(system_profiler SPSoftwareDataType | awk '/System Version/ {print $5}') ]
then
    sudo ln -s /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain
fi

# Homebrew のインストール
if ! which brew &> /dev/null
then
    echo 'Homebrew が見つかりません。インストールします...'

    HOMEBREW_PATH="${HOME}/.homebrew"

    mkdir -p ${HOMEBREW_PATH}
    curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C ${HOMEBREW_PATH}

    export PATH="${HOMEBREW_PATH}/bin:${PATH}"
    unset HOMEBREW_PATH

    echo "Homebrew がインストールされました: $(which brew)"
fi

# Homebrew 経由で基本的な依存パッケージをインストール
echo '基本的なライブラリをインストールします...'
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

# nodebrew 経由で Node.js をインストール
if ! which node &> /dev/null
then
    echo 'Node.js が見つかりません。インストールします...'

    curl -L git.io/nodebrew | perl - setup

    export PATH="${HOME}/.nodebrew/current/bin:${PATH}"

    nodebrew install-binary stable
    nodebrew use stable

    echo "Node.js がインストールされました: $(which node)"
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
