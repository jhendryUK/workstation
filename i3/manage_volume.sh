#!/usr/bin/env bash

function usage {
    echo "Usage: $0 [higher/lower/toggle_sound/toggle_mic]" >&2
    exit 1
}

function run {
    $@ >/dev/null 2>&1
}

function notify {
    notify-send -u normal -c -- "AMixer" -t 1250 -- "$1"
}

function volume_level {
    case $1 in
        higher)
            action="+" ;;
        lower)
            action="-" ;;
    esac

    volume_increments=10
    run amixer -c 0 sset Master $volume_increments%$action
    volume=`amixer -c 0 sget Master | grep 'Mono:' | awk '{print $4}' | sed -e 's/\[//g' -e 's/\]//g'`
    notify "Volume level $volume"
}

function toggle_sound {
    # Due to bugs in amixer, https://bugs.launchpad.net/ubuntu/+source/alsa-utils/+bug/1026331 and https://bugs.launchpad.net/ubuntu/+source/pulseaudio/+bug/878986
    # the toggle action does not work properly, We need to perform some trickery-hackery

    state=`amixer -c 0 sget Master | grep 'Mono:' | awk '{print $6}'`
    if [[ "$state" =~ "on" ]]; then
        action="mute"
        notify "Speakers muted"
    else
        action="unmute"
        notify "Speakers un-muted"
    fi

    # Mute Master/Speaker/Header on all devices, regardless if the speaker exists
    for id in `amixer | egrep '^Simple' | awk -F',' '{print $2}'`; do
        run amixer -c $id sset Master $action
        run amixer -c $id sset Speaker $action
        run amixer -c $id sset Headphone $action
    done
}

function toggle_mic {
    state=`amixer -c 2 sget Mic | grep 'Mono:' | awk '{print $11}'`
    if [[ "$state" =~ "on" ]]; then
        action="nocap"
        notify "Headphone microphone muted"
    else
        action="cap"
        notify "Headphone microphone un-muted"
    fi
    run amixer -c 2 sset Mic toggle

## This awesomeness does not work
#    echo $state
#    action="toggle"
#    for id in `amixer | egrep '^Simple' | awk -F',' '{print $2}'`; do
#        IFS_orig=$IFS
#        IFS='
#'
#        for name in `amixer -c $id scontrols | awk -F"'" '{print $2}' | egrep -i 'capture|mic' | grep -iv boost`; do
#            if [[ $name =~ " " ]]; then
#                name="'$name'"
#            fi
#            run amixer -c $id sset $name $action
#        done
#        IFS=$IFS_orig
#    done
}

[[ $# -gt 1 ]] && usage

case $1 in
    higher|lower)
        volume_level $1 ;;
    toggle_sound)
        toggle_sound ;;
    toggle_mic)
        toggle_mic ;;
    *)
        usage ;;
esac
