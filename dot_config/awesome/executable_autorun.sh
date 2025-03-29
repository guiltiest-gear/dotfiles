#!/bin/sh

# Set up monitors
if [[ $(xrandr -q | grep "HDMI-1-0 connected") ]]; then
  xrandr --output eDP-1 --primary --auto --pos 1920x0 --rotate normal \
    --output HDMI-1-0 --auto --pos 0x0 --rotate normal
else
  xrandr --output eDP-1 --primary --auto --pos 0x0 --rotate normal
fi

# Start picom
pgrep picom || picom -b

# Start polkit-gnome
pgrep -af polkit-gnome-au || exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Start thunar daemon
pgrep thunar || exec thunar --daemon &

# Start emote
pgrep emote || exec emote &

# Fix java applications misbehaving
wmname LG3D

# Ensure clipmenu has the DISPLAY environment variable
systemctl --user import-environment DISPLAY
