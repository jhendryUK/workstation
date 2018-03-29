#!/usr/bin/env bash

if [ "x$1" != "xrun" ]; then
    flock -n /tmp/screen_lock.lock "$0" run
    exit 0
fi

if [ "x$1" == "xrun" ]; then
    scrot --silent /tmp/screen_locked.png
    mogrify -scale 10% -scale 1000% /tmp/screen_locked.png
    i3lock -f -t -i /tmp/screen_locked.png
fi

lock_file=/tmp/screen_lock.lock
[[ -e "$lock_file" ]] && rm -f $lock_file
