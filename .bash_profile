#
# MAC OS X ログインシェルカスタマイズ
#
# メモ 1:
# `.bash_profile` と `.profile` は同時に存在できません。優先順位は
# `.bash_profile` が高く設定されているため。両方存在した場合は、こちらの
# 設定内容が優先されます。
#
# メモ 2:
# `.bash_profile` と `.bashrc` の違いは、前者がログイン時に読み込まれる
# のに対して、後者は新規ターミナルを開く度に読み込まれます。
#
# メモ 3:
# `.bash_profile` や `.bashrc` の設定を読み込み直すコマンド:
# source ~/.bash_profile


##
# 環境変数

# 言語 `locale` の設定
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

# Glob 無視パターンに `.` と `..` を指定
export GLOBIGNORE=.:..

# 256 色ターミナルの有効化 (Solarized テーマ使用のため)
export TERM=xterm-256color

# `ls` コマンドのハイライト
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad

# `grep` コマンドのハイライト
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;37;41'


##
# 環境変数パス

# Homebrew
export PATH="${HOME}/.homebrew/sbin:${PATH}"
export PATH="${HOME}/.homebrew/bin:${PATH}"
export MANPATH="${HOME}/.homebrew/share/man:${MANPATH}"
export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}"
export PKG_CONFIG_PATH="${HOME}/.homebrew/lib/pkgconfig:${PKG_CONFIG_PATH}"


##
# 追加設定

# リダイレクトによるファイル内容消失を保護
# リダイレクトで上書きしたい場合は `>` の代わりに `>|` を使う
set -o noclobber


##
# 追加エイリアス

# CLI 操作ミスによるファイル/ディレクトリ消失を保護
alias mv='mv -i'

if ! which rmtrash &> /dev/null
then
    alias rm='rm -i'
else
    alias rm='rmtrash'
    alias rmdir='rmtrash'
fi

# ls -la
alias ll='ls -la'


##
# エディタ設定

# CLI のデフォルトテキストエディタを設定
export EDITOR='vim'


##
# Generic Colouriser によるシンタックスハイライト
# `brew install grc` でインストールしておく事

if [ -f "$(brew --prefix)/etc/grc.bashrc" ]
then
    source "$(brew --prefix)/etc/grc.bashrc"
fi

##
# Git シェル補助

if [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ] \
    && [ -f "$(brew --prefix)/etc/bash_completion.d/git-prompt.sh" ] \
    && [ -f "$(brew --prefix)/etc/bash_completion.d/git-extras" ]
then
    source "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
    source "$(brew --prefix)/etc/bash_completion.d/git-prompt.sh"
    source "$(brew --prefix)/etc/bash_completion.d/git-extras"
    PS1='\h:\W$(__git_ps1 " (%s)") \u\$ '
fi

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"
