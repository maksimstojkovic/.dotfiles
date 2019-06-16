#!/usr/bin/env bash

# script for setting up neovim to use .vimrc in home directory, which symbolically links to the dotfiles git repo

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

# install neovim from source
sudo apt-get update
sudo apt-get -y install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
cd ~
git clone https://github.com/neovim/neovim
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=Release
sudo make install
cd ~
rm -rf neovim
# uninstall in the future using:
# sudo rm /usr/local/bin/nvim
# sudo rm -r /usr/local/share/nvim/

# add neovim to alternatives list
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 60
sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 60

# create init.vim file which points to .vimrc in home directory
mkdir -p $home/.config/nvim
echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after" > $home/.config/nvim/init.vim
echo "let &packpath = &runtimepath" >> $home/.config/nvim/init.vim
echo "source ~/.vimrc" >> $home/.config/nvim/init.vim

# move folder to ~/.dotfiles
if [ "$dir" != "$home/.dotfiles" ]; then
	echo "Moving files"
	cd ..
	pwd
	mv -v $dir $home/.dotfiles
fi

# create symbolic link to .vimrc in git repo
ln -sfn $home/.dotfiles/.vimrc $home/.vimrc
