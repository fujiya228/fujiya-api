#!/bin/bash

# ホストで使っているユーザとコンテナで使っているユーザで UID と GID の不一致があると、パーミッションの問題が生じる
# Dockerコンテナ上にpublic-userというユーザーを用意してあるので、public-userをホスト側のユーザーと合わせることで解消する
LOCAL_UID=$(id -u $USER)
LOCAL_GID=$(id -g $USER)
base='docker-compose run --rm -e $LOCAL_UID -e $LOCAL_GID web'
exec $base $*

# setup
# ./sh rails new . --force --no-deps --database=postgresql --skip-test --skip-bundle
# ./sh bundler
# ./sh rails webpacker:install
# docker-compose build
# cp config/database.yml.default config/database.yml
# ./sh rake db:create
# docker-compose up

# herokuへデプロイ
# heroku login
# heroku container:login
# heroku create sample-app
# heroku container:push web
# heroku addons:create heroku-postgresql:hobby-dev
# heroku container:release web
# heroku run rails db:migrate
# heroku run rails assets:precompile

# 再デプロイ（基本は以下、必要に応じて追加のコマンド）
# heroku container:push web
# heroku container:release web

# デフォルトはdevelopmentでdeployされるため、以下で環境をproductionに変更する
# heroku config:add RAILS_ENV=production

# developmentで確認したい場合はconfig/environments/development.rbに以下を追加
# config.hosts << "<アプリ名>.herokuapp.com" <= ホストがデフォルト（変更なし）の場合