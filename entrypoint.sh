#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

USER_ID=${LOCAL_UID:-1000}
GROUP_ID=${LOCAL_GID:-1000}

echo $@

echo `whoami`
if [ `whoami` = "root" ]; then
    echo "is root user => exec by public-user"
    usermod -u $USER_ID -o public-user
    groupmod -g $GROUP_ID public-user
    exec /usr/sbin/gosu public-user "$@"
else
    echo "another"
    exec "$@"
fi
