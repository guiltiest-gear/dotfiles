#!/bin/sh
set -e

SOFTWARE="sed -e 's/#.*$//' -e '/^$/d' package.aur"

paru -S $(echo $SOFTWARE)
