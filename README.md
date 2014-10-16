dotfiles
========

よくある dotfiles リポジトリの一つです。PC (主に Mac OS X) で CLI 環境を比較的簡単に構築できるようにする目的で作成しています。

インストール
------------

インストールと更新は下記のコマンドをコピーアンドペーストして実行して下さい:

```bash
bash <(curl -L https://raw.github.com/takumi0125/dotfiles/master/bootstrap.sh)
```

Git を使用せずインストール/更新を行う場合は `~/.dotfiles` にリポジトリの中身を展開し、下記コマンドを実行して下さい:

```bash
bash ~/.dotfiles/bootstrap.sh sync
```

必要環境
--------

### Mac OS X

* Mac OS X 10.7 (Lion) 以上
* [Xcode](http://itunes.apple.com/en/app/xcode/id497799835)
* [Command Line Tools](http://developer.apple.com/xcode/) (Xcode SDK をインストールしたくない場合)

機能
----

### Mac OS X

インストール時のおおまかな処理の流れは以下の通りです。更新時はインストール時のみの処理は基本的にスキップします:

1. `~/.dotfiles` ディレクトリを作成しリポジトリのファイルをダウンロードします。
2. Time Machine のローカルスナップショット機能を無効化します。
3. ログイン時実行される `~/.dotfiles/darwin/hook.sh` をインストールします。
4. `.DS_Store` をネットワークドライブ上で作成しない設定をします。
5. 隠しファイルを非表示から表示するように変更します。
6. Kotoeri のデフォルト空白文字を全角から半角に設定します。
7. スクリーンショットの影を無効にします。
8. XQuartz をインストールします。
9. Asepsis をインストールします。
10. Xcode のライセンス同意画面を表示します。
11. Homebrew をインストールします。
12. Homebrew で基本的なライブラリをインストールします。
13. nenv で Node.js をインストールします。
14. `~/.dotfiles/darwin` ディレクトリのドットファイルをホームディレクトリにシンボリックリンクします。

### グルーバルな初期処理

* [XQuartz](http://xquartz.macosforge.org/landing/) のインストール
    * Mac OS X で最新の X Window 環境を使用可能にします。
    * 標準でインストールされている X11 の置換が目的です。
* [Asepsis](http://asepsis.binaryage.com/) のインストール
    * `.DS_Store` ファイルを `/usr/local/.dscage` ディレクトリ下に集約して作成するようにします。
    * `.DS_Store` ファイルは標準だとあちこちのディレクトリに無断で作成され、無駄なので、これを改善します。

### ローカルな初期処理

* [Homebrew](http://mxcl.github.io/homebrew/) のインストール
    * MacPorts より開発コミュニティが活発な Homebrew をパッケージマネージャーとして使用します。
    * グローバル環境をなるべく綺麗な状態に保つため、`~/.homebrew` にインストールします。
    * *Git*, *Python*, *Ruby* を Homebrew 経由で最新版をインストールします。グローバルの Python や Ruby 環境を綺麗な状態に保つのも目的です。
* [nenv](https://github.com/ryuone/nenv) を使用して [Node.js](http://nodejs.org/) をインストールします。
    * Node.js は `~/.nenv` 下にインストールされます。
    * Node.js はまた開発途上のためバージョンアップが頻繁なので、簡単に以前のバージョンや最新バージョンへ切り替えられるようにするのが目的です。

### グローバルな設定変更

* Time Machine のローカルスナップショットを無効にします。パフォーマンス改善と SSD 環境での書き込み回数の消費数削減が目的です。
* LoginHook をインストールします。ユーザーログイン毎に次のスクリプトが毎回実行されます:
    * `~/.dotfiles/darwin/hook.sh`
    * スクリプトの内容はメモリ上に 128 MB の ramdisk を作成し、`~/Library/Caches` 内の web ブラウザキャッシュディレクトリを ramdisk 上にシンボリックリンクします。
    * Ramdisk なので、再起動毎にキャッシュディレクトリは削除されます。
    * ブラウザキャッシュは削除する機会が多いので、自動化できる事、SSD 環境での書き込み回数消費数削減が目的です。

### ローカルな設定変更

* 以下のファイルを置換します。既存のファイルは `.orig` の接尾辞を付けた名前に変更してバックアップします。
    * `~/.bash_profile`
    * `~/.bashrc`
    * `~/.gitattributes`
    * `~/.gitconfig`
    * `~/.gitignore`
* Git のデフォルト `user.name` と `user.email` を入力プロンプトから設定してもらいます。

謝辞
----

* [GitHub does dotfiles - dotfiles.github.io](http://dotfiles.github.io/)
* [altercation/solarized · GitHub](https://github.com/altercation/solarized)
* [github/gitignore · GitHub](https://github.com/github/gitignore)
* [seebi/dircolors-solarized · GitHub](https://github.com/seebi/dircolors-solarized)

ライセンス
----------

Distributed under the [Unlicense](http://unlicense.org/).
