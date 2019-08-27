#!/usr/bin/env bash


echo Killing synergys daemon
killall synergys

CLIENT=10.255.253.50
#CLIENT=10.255.252.52
PROXY=10.255.252.1

pid=`ps -ax -o pid,command | egrep -- "ssh -fNR .* $CLIENT|ssh -fNR .* $PROXY" | grep -v grep | awk '{print $1}' | tr '\n' ' '`
if [ "$pid" ]; then
    echo "Killing reverse port-forward ssh sessions ( $pid)"
    for i in $pid; do
        kill $i
    done
fi

set -e

if [ "$1" == "kill" ]; then
    exit 0
fi

echo Starting Synergys
/usr/bin/synergys -f --debug INFO --name twigz -c ~/.config/synergy/config --address 127.0.0.1:24800 &

echo Starting SSH
if [ "$1" == "proxy" ]; then
    ssh -fNR 127.0.0.1:24800:$CLIENT:24800 $PROXY
else
    ssh -fNR 127.0.0.1:24800:127.0.0.1:24800 $CLIENT
fi
