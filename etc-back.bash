#!/usr/bin/env bash

sudo rsync -av /etc/default/grub etc/default/
sudo rsync -av /etc/modprobe.d/nvidia-pm.conf etc/modprobe.d/
sudo rsync -av /etc/pacman.d/mirrorlist etc/pacman.d/
sudo rsync -av /etc/pacman.conf etc/
