#!/usr/bin/env bash


echo Killing synergys daemon
killall synergys

pid=`ps -ax -o pid,command | egrep -- 'ssh -fNR .* 10.255.253.50' | grep -v grep | awk '{print $1}' | tr '\n' ' '`
if [ "$pid" ]; then
    echo "Killing reverse port-forward ssh sessions ( $pid)"
    for i in $pid; do
        kill $i
    done
fi

set -e

echo Starting Synergys
/usr/bin/synergys -f --debug INFO --name twigz -c ~/.config/synergy/config --address 127.0.0.1:24800 &

echo Starting SSH
ssh -fNR 127.0.0.1:24800:127.0.0.1:24800 10.255.253.50
