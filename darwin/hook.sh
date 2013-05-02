#!/bin/bash

#
# MAC OS X ログインフック
#
# LoginHook スクリプトは管理者権限で実行されます!
#
# スクリプトのインストール:
# chmod +x /path/to/hook.sh
# sudo defaults write com.apple.loginwindow LoginHook /path/to/hook.sh
#
# インストール状況の確認:
# sudo defaults read com.apple.loginwindow LoginHook
#
# スクリプトの削除:
# sudo defaults delete com.apple.loginwindow LoginHook


logger "LoginHook: ユーザー ${1} のログインフックを開始します。"


##
# 変数定義

USER=${1}
eval HOMELOC=~${USER}


##
# Ramdisk 設定

RD_SIZE=262144  # 128 MB!!
RD_MOUNTPOINT=/Volumes/ramdisk

if [ ! -d ${RD_MOUNTPOINT} ]
then
    RD_IMAGE=$(hdid -nomount ram://${RD_SIZE})

    mkdir -p ${RD_MOUNTPOINT}
    newfs_hfs -v ramdisk ${RD_IMAGE}
    mount -t hfs ${RD_IMAGE} ${RD_MOUNTPOINT}
    chmod 777 ${RD_MOUNTPOINT}

    unset RD_IMAGE
fi


##
# キャッシュディレクトリを Ramdisk 上にマウント

RAMDISK_CACHE_PATH=${RD_MOUNTPOINT}/Caches

UA_RAMDISK_PATHS=(
    "${RAMDISK_CACHE_PATH}/com.apple.Safari"
    "${RAMDISK_CACHE_PATH}/com.google.Chrome"
    "${RAMDISK_CACHE_PATH}/com.google.Chrome.canary"
    "${RAMDISK_CACHE_PATH}/com.operasoftware.Opera/"
    "${RAMDISK_CACHE_PATH}/org.mozilla.firefox"
    "${RAMDISK_CACHE_PATH}/Firefox"
    "${RAMDISK_CACHE_PATH}/Google"
    "${RAMDISK_CACHE_PATH}/Opera"
)

UA_CACHE_PATHS=(
    "${HOMELOC}/Library/Caches/com.apple.Safari"
    "${HOMELOC}/Library/Caches/com.google.Chrome"
    "${HOMELOC}/Library/Caches/com.google.Chrome.canary"
    "${HOMELOC}/Library/Caches/com.operasoftware.Opera"
    "${HOMELOC}/Library/Caches/org.mozilla.firefox"
    "${HOMELOC}/Library/Caches/Firefox"
    "${HOMELOC}/Library/Caches/Google"
    "${HOMELOC}/Library/Caches/Opera"
)

mkdir -p ${RAMDISK_CACHE_PATH}

for (( I=0; I < ${#UA_RAMDISK_PATHS[@]}; ++I ))
do
    mkdir -p ${UA_RAMDISK_PATHS[${I}]}

    # キャッシュディレクトリがシンボリックリンクか確認
    if [ ! -d ${UA_CACHE_PATHS[${I}]} ] || [ ! -L ${UA_CACHE_PATHS[${I}]} ]
    then
        rm -rf ${UA_CACHE_PATHS[${I}]}
        sudo -u ${USER} ln -s ${UA_RAMDISK_PATHS[${I}]} ${UA_CACHE_PATHS[${I}]}
    fi
done

chmod -R u=rwX,g=rwX,o=rwX ${RAMDISK_CACHE_PATH}


# 終了処理
unset \
    USER \
    HOMELOC \
    RD_SIZE \
    RD_MOUNTPOINT \
    RAMDISK_CACHE_PATH \
    UA_RAMDISK_PATHS \
    UA_CACHE_PATHS
