#!/usr/bin/env bash

# 要恢复的配置目录
CONFIG_DIRS=(
  "hypr"
  "niri"
  "fish"
  "kitty"
  "foot"
  "fnott"
  "waybar"
  "fuzzel"
  "swaylock"
  "nvim"
)

# 要恢复的家目录文件
# HOME_FILES=(
#   ".bashrc"
#   ".inputrc"
# )

# 要恢复的家目录子目录
# HOME_SUBDIRS=(
#   "bash"
# )

# 恢复配置目录
for dir in "${CONFIG_DIRS[@]}"; do
  mkdir -p "$HOME/.config/$dir"
  rsync -a "./.config/$dir" "$HOME/.config/"
done

# 恢复家目录子目录
# for subdir in "${HOME_SUBDIRS[@]}"; do
#   mkdir -p "$HOME/$subdir"
#   rsync -a "./$subdir" "$HOME/"
# done

# 恢复家目录文件
# for file in "${HOME_FILES[@]}"; do
#   rsync "./$file" "$HOME/"
# done
