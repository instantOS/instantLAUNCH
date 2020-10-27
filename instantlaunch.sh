#!/bin/bash

# appimage helper for chmodding and integrating into the system

if [ -z "$1" ]; then
    echo "usage: instantlaunch file"
    exit
fi

if ! [ -e "$1" ]; then
    echo "target file $1 not existing"
    exit 1
fi

CHOICE="$(echo "run $1
nope" | imenu -l)"
case "$CHOICE" in
run*)
    echo "running"
    ;;
nope)
    echo "not running"
    exit
    ;;
esac

chmod +x "$1"
"$1"
