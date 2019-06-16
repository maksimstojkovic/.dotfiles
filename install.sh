#!/usr/bin/env bash

# script for setting up neovim to use .vimrc in home directory, which symbolically links to the dotfiles git repo

# ensure script is not run with sudo so current user can be identified
if [ "$EUID" == "0" ]; then
	echo "Please run this script without sudo"
	echo "$0"
	exit 1
fi

# save path of dotfiles directory and current user home
dot_dir_path=$(echo $0 | grep -oP '(\b|\.{1}[^\/]{1})\S*(?=\/.*)\b')
if [ ! -z "$dot_dir_path" ]; then
	dot_dir_path="/$dot_dir_path"
fi
dot_dir_path="$PWD$dot_dir_path"
home=$HOME

: <<'END'
# install neovim from source
echo "Installing neovim from source"
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
# neovim is installed to /usr/local/bin, and can be uninstalled in the future using:
# sudo rm /usr/local/bin/nvim
# sudo rm -r /usr/local/share/nvim/
echo "Installing neovim from source DONE"

# add neovim to alternatives list
echo "Updating default editors"
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 60
sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 60
echo "Updating default editors DONE"
END

# create init.vim file which points to .vimrc in home directory
mkdir -p $home/.config/nvim
echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after" > $home/.config/nvim/init.vim
echo "let &packpath = &runtimepath" >> $home/.config/nvim/init.vim
echo "source ~/.vimrc" >> $home/.config/nvim/init.vim

# move folder to ~/.dotfiles
if [ "$dot_dir_path" != "$home/.dotfiles" ]; then
	echo "Moving files"
	cd $home
	mv -v $dot_dir_path $home/.dotfiles
	echo "Moving files DONE"
fi

# create symbolic link to .vimrc in git repo
ln -sfn $home/.dotfiles/.vimrc $home/.vimrc

# install vim-plug and all plugins in .vimrc
echo "Installing vim plugins"
vim +"PlugInstall | q! | q!" /dev/null --headless
echo "Installing vim plugins DONE"

