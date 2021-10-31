#!/bin/bash

# launcher for various application formats

if [ -z "$1" ]; then
    echo "usage: instantlaunch file"
    exit
fi

if ! [ -e "$1" ]; then
    echo "target file $1 not existing"
    exit 1
fi

if grep -q '\.AppImage$' <<<"$1"; then
    # file is an appimage
    CHOICE="$(echo "run AppImage $1
:gInstall to Applications folder
:rClose menu" | imenu -l -i "instantLAUNCH")"
    case "$CHOICE" in
    run*)
        echo "running"
        chmod +x "$1"
        IMGPATH="$(realpath "$1")"
        cd "${IMGPATH%/*}" || exit 1
        "$IMGPATH"
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
        ;;
    esac
elif grep -q '\.desktop$' <<<"$1" && file "$1" | grep -q 'text' && grep -q '\[Desktop Entry\]' "$1"; then
    # file is a desktop file
    CHOICE="$(
        echo ">>h Desktop entry  $1
:gLaunch
:yOpen in editor
:bAdd to system menu
:rClose menu" | imenu -l -i "instantLAUNCH"
    )"
    case "$CHOICE" in
    *Launch)
        echo "launching $1"
        instantinstall glib2 || exit 1
        gio launch "$1"
        ;;
    editor*)
        instantutils open editor "$1"
        ;;
    *menu)
        instantinstall alacarte
        notify-send "added desktop entry to super + y menu"
        cp "$1" ~/.local/share/applications/
        imenu -t 'desktop entries can be managed through alacarte'
        ;;
    *)
        echo 'no selection'
        ;;
    esac

elif grep -q '\.flatpakref$' <<<"$1" && file "$1" | grep -q 'text' && grep -q '\[Flatpak Ref\]' "$1"; then
    FLATPAKNAME="$(grep -o '^Name=.*' "$1" | head -1 | sed 's/^[^=]*=//g')"
    echo "$FLATPAKNAME"
    [ -z "$FLATPAKNAME" ] && {
        imenu -E "flatpakref invalid"
        exit 1
    }
    if flatpak list | grep -q "$FLATPAKNAME"; then
        echo "flatpak already installed"
        imenu -t 'opening flatpak application'
        flatpak run "$FLATPAKNAME"
        exit
    fi

    realpath "$1"

    if imenu -c "application needs to download additional data. continue?"; then
        instantutils open terminal -e bash -c "flatpak install '$(realpath "$1")' && notify-send 'flatpak installed successfully' && flatpak run '$FLATPAKNAME'"
    else
        notify-send 'flatpak installation aborted'
    fi

fi
