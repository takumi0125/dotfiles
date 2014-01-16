scriptencoding utf-8
set nocompatible
filetype off

if has('vim_starting')
  filetype plugin off
  filetype indent off
  execute 'set runtimepath+=' . expand('~/.vim/bundle/neobundle.vim')
endif
call neobundle#rc(expand('~/.vim/bundle'))

NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'The-NERD-tree'
NeoBundle 'The-NERD-Commenter'
NeoBundle 'mattn/zencoding-vim'
NeoBundle 'taichouchou2/surround.vim'
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'taichouchou2/html5.vim'
NeoBundle 'taichouchou2/vim-javascript' " jQuery syntax追加
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'ctrlp.vim'
NeoBundle 'tpope/vim-surround'
NeoBundle 'jade.vim'
NeoBundle 'leafgarland/typescript-vim'

NeoBundle 'w0ng/vim-hybrid'

filetype plugin indent on

"-----------------------------
" 全体設定
"-----------------------------

" カラースキーム
colorscheme hybrid

" シンタックスハイライト
syntax on

set number " 行番号を表示する
set ruler " カーソルが何行目の何列目に置かれているかを表示する。
set cursorline " カーソル行の背景色を変える
set cursorcolumn " カーソル位置のカラムの背景色を変える
set laststatus=2 " ステータス行を常に表示
set cmdheight=2 " メッセージ表示欄を2行確保
set showmatch " 対応する括弧を強調表示
set helpheight=999 " ヘルプを画面いっぱいに開く
set list " 不可視文字を表示

" 不可視文字の表示記号指定
set listchars=tab:▸\ ,eol:↲,extends:❯,precedes:❮

set backspace=indent,eol,start " Backspaceキーの影響範囲に制限を設けない
set whichwrap=b,s,h,l,<,>,[,] " 行頭行末の左右移動で行をまたぐ
set scrolloff=8 " 上下8行の視界を確保
set sidescrolloff=16 " 左右スクロール時の視界を確保
set sidescroll=1 " 左右スクロールは一文字づつ行う

set hlsearch " 検索文字列をハイライトする
set incsearch " インクリメンタルサーチを行う
set ignorecase " 大文字と小文字を区別しない
set smartcase " 大文字と小文字が混在した言葉で検索を行った場合に限り、大文字と小文字を区別する
set wrapscan " 最後尾まで検索を終えたら次の検索で先頭に移る

set confirm " 保存されていないファイルがあるときは終了前に保存確認
set hidden " 保存されていないファイルがあるときでも別のファイルを開くことが出来る
set autoread " 外部でファイルに変更がされた場合は読みなおす
set nobackup " ファイル保存時にバックアップファイルを作らない
set noswapfile " ファイル編集中にスワップファイルを作らない

" OSのクリップボードをレジスタ指定無しで Yank, Put 出来るようにする
set clipboard=unnamed,unnamedplus

set mouse=a " マウスの入力を受け付ける
set expandtab " タブ入力を複数の空白入力に置き換える
set tabstop=2 " 画面上でタブ文字が占める幅
set shiftwidth=2 " 自動インデントでずれる幅
set softtabstop=2 " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent " 改行時に前の行のインデントを継続する
set smartindent " 改行時に入力された行の末尾に合わせて次の行のインデントを増減する

set backupdir=$HOME/vimbackup " バックアップファイルを作るディレクトリ
set directory=$HOME/vimbackup "スワップファイル用のディレクトリ
set browsedir=buffer "ファイル保存ダイアログの初期ディレクトリをバッファファイル位置に設定

"-----------------------------
" インサートモードキーマップ
"-----------------------------

" 挿入モードでのカーソル移動
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>

" 引用符, 括弧の設定
inoremap { {}<Left>
inoremap [ []<Left>
inoremap ( ()<Left>
inoremap " ""<Left>
inoremap ' ''<Left>
inoremap < <><Left>


"-----------------------------↲ 
" プラグイン設定↲   
"-----------------------------
" NERDTree
let g:NERDTreeShowHidden=1
let g:NERDTreeIgnore=['\.clean$', '\.swp$', '\.bak$', '\~$']
autocmd vimenter * if !argc() | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
