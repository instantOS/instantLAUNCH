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

CHOICE="$(echo "run AppImage $1
:gInstall to Applications folder
:rClose menu" | imenu -l -i "instantLAUNCH")"
case "$CHOICE" in
run*)
    echo "running"
    chmod +x "$1"
    IMGPATH="$(realpath "$1")"
    cd "${IMGPATH%/*}" || exit 1
    bash -c "$1"
    ;;
*folder)
    [ -e ~/Applications ] || mkdir ~/Applications || exit 1
    chmod +x "$1"
    mv "$1" ~/Applications/
    if ! [ -e ~/.local/bin/appimaged ]; then
        mkdir -p ~/.cache/instantlaunch
        cd ~/.cache/instantlaunch || exit 1
        notify-send "downloading needed files"
        wget "https://github.com/AppImage/appimaged/releases/download/continuous/appimaged-x86_64.AppImage"
        chmod +x ./*.AppImage
        ./appimaged-x86_64.AppImage --install
        sleep 1
    fi
    notify-send "installing appimage to applications folder"
    timeout 30 ~/.local/bin/appimaged &
    echo "installing AppImage to applications folder"
    echo 'your appimage has been installed to the Applications folder.
This makes it accessible from the global application launcher' | imenu -M
    ;;
*menu)
    echo "not running"
    exit
    ;;
esac
