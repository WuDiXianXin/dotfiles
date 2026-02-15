#!/usr/bin/env bash

# 要备份的配置目录
CONFIG_DIRS=(
  "niri"
  "fish"
  "foot"
  "nvim"
  "dgop"
  "fastfetch"
  "obs-studio"
  "DankMaterialShell"
)

# 要备份的家目录文件
# HOME_FILES=(
# ".bashrc"
# ".inputrc"
# ".condarc"
# )

# 要备份的家目录子目录
# HOME_SUBDIRS=(
#   "bash"
# )

# 备份配置目录
for dir in "${CONFIG_DIRS[@]}"; do
  rsync -a "$HOME/.config/$dir" ".config/"
done

# # 备份家目录子目录
# for subdir in "${HOME_SUBDIRS[@]}"; do
#   rsync -a "$HOME/$subdir" "./"
# done

# 备份家目录文件
# for file in "${HOME_FILES[@]}"; do
#   rsync "$HOME/$file" "./"
# done
