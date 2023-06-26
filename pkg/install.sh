#!/bin/sh
set -e

if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit 1
fi

SOFTWARE="sed -e 's/#.*$//' -e '/^$/d' package.main"

pacman -Syyu --needed $(echo $SOFTWARE)
