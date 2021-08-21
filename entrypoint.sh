#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

# ホストで使っているユーザとコンテナで使っているユーザで UID と GID の不一致があると、パーミッションの問題が生じる
# Dockerコンテナ上にpublic-userというユーザーを用意してあるので、public-userをホスト側のユーザーと合わせることで解消する
USER_ID=${LOCAL_UID:-1000}
GROUP_ID=${LOCAL_GID:-1000}

echo $@

echo `whoami`
# Dockerコンテナ上でbundle installをする際に public-userでは Permission deniedになるため
if [ $1 = "bundler" ]; then
    echo "exec by root user"
    exec "$@"
elif [ `whoami` = "root" ]; then
    echo "is root user => exec by public-user"
    usermod -u $USER_ID -o public-user
    groupmod -g $GROUP_ID public-user
    # public-userをsudoのグループに追加したかったが、すでに存在するuserは追加できない（groupadd: group 'public-user' already exists）
    # かわりにgosuで実行することにした
    exec /usr/sbin/gosu public-user "$@"
else
    # Herokuはユーザーが u50849 のようなものでコマンドが実行される
    # usermod: user 'public-user' does not exist　で引っかかるので以下のようにする必要がある
    echo "another"
    exec "$@"
fi
