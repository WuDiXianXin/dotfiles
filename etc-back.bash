#!/usr/bin/env bash

sudo rsync -a /etc/default/grub etc/default/
sudo rsync -a /etc/modprobe.d/nvidia-pm.conf etc/modprobe.d/
sudo rsync -a /etc/pacman.d/mirrorlist etc/pacman.d/
sudo rsync -a /etc/pacman.conf etc/
