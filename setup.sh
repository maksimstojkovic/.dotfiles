#!/usr/bin/env bash

# script for setting up neovim to use .vimrc in home directory, which symbolically links to the dotfiles git repo

echo $0
echo $1
exit 0

# ensure script is not run with sudo so current user can be identified
if [ "" == "0" ]; then
	echo "Please run this script without sudo"
	echo "$0"
	exit 1
fi

# save current directory path and path of current user home
dir=$(pwd)
home=$(echo ~)

echo $dir
echo $home

# install neovim
sudo apt-get install neovim

# create init.vim file which points to .vimrc in home directory
mkdir -p $home/.config/nvim
echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after" > $home/.config/nvim/init.vim
echo "let &packpath = &runtimepath" >> $home/.config/nvim/init.vim
echo "source ~/.vimrc" >> $home/.config/nvim/init.vim

echo .
echo ..

# move folder to ~/.dotfiles
if [ "$dir" != "$home/.dotfiles" ]; then
	echo "Moving files"
	cd ..
	pwd
	mv -v $dir $home/.dotfiles
fi
