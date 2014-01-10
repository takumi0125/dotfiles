#!/bin/bash

#
# ブートストラップ
#
# インストールと更新:
# bash <(curl -L https://raw.github.com/sonicjam/dotfiles/master/bootstrap.sh)
# bash ~/.dotfile/bootstrap.sh sync


##
# 変数定義

OS=$(uname -s)
CWD=$(pwd)

TEXT_BOLD=$(tput bold)
TEXT_RED=$(tput setaf 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

DOTFILES_REPO='https://github.com/takumi0125/dotfiles.git'
DOTFILES_PATH="${HOME}/.dotfiles"


##
# 関数定義

# シェルを更新
function update {
    PROFILE_PATH="${HOME}/.bash_profile"
    RC_PATH="${HOME}/.bashrc"

    if [ -f ${PROFILE_PATH} ]
    then
        source ${PROFILE_PATH}
    fi

    if [ -f ${RC_PATH} ]
    then
        source ${RC_PATH}
    fi

    unset PROFILE_PATH RC_PATH
}

# ドットファイルをホームディレクトリへシンボリックリンク
function link {
    DIR=${1}

    if [ -z "${DIR}" ]
    then
        echo "${TEXT_RED}リンク元パスが未定義です。中止します。${TEXT_RESET}"
        unset DIR
        exit 1
    fi

    for FILE in ${DOTFILES_PATH}/${DIR}/.[^.]*
    do
        DEST="${HOME}/$(basename ${FILE})"

        if [ -L ${DEST} ]
        then
            rm ${DEST}
            echo "シンボリックリンク削除 ${DEST}"
        elif [ -f ${DEST} ] || [ -d ${DEST} ]
        then
            mv ${DEST} ${DEST}.orig
            echo "ファイル/ディレクトリ名変更 ${DEST}.orig"
        fi

        ln -s ${FILE} ${DEST}
        echo "シンボリックリンク作成 ${DEST}"

        unset DEST
    done

    update
    unset DIR FILE
}


##
# 主処理

echo "${TEXT_BOLD}開始します...${TEXT_RESET}"

# `sync` パラメータ付の場合は Git から取得をスキップ
if [ -z "${1}" ] || [ 'sync' != ${1} ]
then
    echo "${TEXT_BOLD}Git リポジトリからファイルを取得します...${TEXT_RESET}"

    # `git` コマンドの有無確認
    if ! which git &> /dev/null
    then
        echo "${TEXT_RED}Git コマンドが見つかりません。中止します。${TEXT_RESET}"
        exit 1
    fi

    # `~/.dotfiles` ディレクトリの有無確認
    if ! [ -d ${DOTFILES_PATH} ]
    then
        git clone --recursive ${DOTFILES_REPO} ${DOTFILES_PATH}
    elif [ -d ${DOTFILES_PATH}/.git ]
    then
        cd ${DOTFILES_PATH}
        git pull --ff origin master
        git submodule update --recursive
        cd ${CWD}
    else
        echo "${TEXT_RED}パスが既に存在します。中止します。${TEXT_RESET}"
        exit 1
    fi
fi

# Mac OS X 環境の設定
if [ 'Darwin' == ${OS} ]
then
    echo "${TEXT_BOLD}Mac OS X の設定を開始します...${TEXT_RESET}"

    # `bootstrap-darwin.sh` 実行
    if ! bash ${DOTFILES_PATH}/bootstrap-darwin.sh
    then
        echo "${TEXT_RED}エラーが発生しました。中止します。${TEXT_RESET}"
        exit 1
    fi

    link 'darwin'
fi

# Linux 環境の設定
if [ 'Linux' == ${OS} ]
then
    echo "${TEXT_BOLD}Linux の設定を開始します...${TEXT_RESET}"
    link 'linux'
fi

# 共通の設定
echo "${TEXT_BOLD}共通設定を開始します...${TEXT_RESET}"
link 'common'

# Git 設定の初期化
if [ -z "$(git config --global user.name)" ]
then
    read -p "${TEXT_BOLD}Git の user.name を入力:${TEXT_RESET} " GIT_CONFIG_USER_NAME
    git config --global user.name "${GIT_CONFIG_USER_NAME}"
    unset GIT_CONFIG_USER_NAME
fi

if ! echo $(git config --global user.email) | grep -q '^.*@.*\..*$'
then
    read -p "${TEXT_BOLD}Git の user.email を入力:${TEXT_RESET} " GIT_CONFIG_USER_EMAIL
    git config --global user.email "${GIT_CONFIG_USER_EMAIL}"
    unset GIT_CONFIG_USER_EMAIL
fi

echo 'Git の設定を更新しました。'

# 完了処理
echo "${TEXT_BOLD}${TEXT_GREEN}全て完了しました。${TEXT_RESET}"

unset \
    OS \
    CWD \
    TEXT_BOLD \
    TEXT_RED \
    TEXT_GREEN \
    TEXT_RESET \
    DOTFILES_REPO \
    DOTFILES_PATH

unset -f \
    update \
    link
