#!/bin/sh
set -e

if [ $EUID -ne 0 ]
then
    echo "This script must be run as root!"
    exit 1
fi

systemctl start libvirt
systemctl enable libvirt
usermod -aG libvirt $USER
cp ../etc/libvirt/libvirtd.conf /etc/libvirt/libvirtd.conf
systemctl restart libvirt
echo "Libvirt has sucessfully been set up, please logout now"
exit 0
