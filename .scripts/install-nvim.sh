#!/usr/bin/env bash

# script for setting up neovim to use .vimrc in home directory, which symbolically links to the dotfiles git repo

# ensure script is not run with sudo so current user can be identified
if [ "$EUID" == "0" ]; then
	echo "Please run this script without sudo"
	echo "$0"
	exit 1
fi

home=$HOME

# TODO: check if ~/.dotfiles exists

# installing neovim
echo "INFO: Installing neovim from source"
sudo apt-get update
sudo apt-get remove -y neovim
	sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
	sudo apt-get install -y python python-dev python3 python3-dev python-pip

	mkdir -p /usr/local/stow

# TODO check if neovim folder exists
# TODO check if stow folder exists

	git clone https://github.com/neovim/neovim $home/neovim
	cd $home/neovim
	git checkout stable
	rm -rf build
	make CMAKE_BUILD_TYPE=RelWithDebInfo
	sudo make CMAKE_INSTALL_PREFIX=/usr/local/stow/nvim install
	pip install --user neovim
echo "INFO: Installing neovim DONE"

# TODO symlink .vimrc and .config/nvim using stow

# add neovim to alternatives list
echo "INFO: Updating default editors"
	sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 60
	sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
	sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 60
echo "INFO: Updating default editors DONE"

# create init.vim file which points to .vimrc in home directory
#echo "INFO: Configuring init.vim"
#mkdir -p $home/.config/nvim
#echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after" > $home/.config/nvim/init.vim
#echo "let &packpath = &runtimepath" >> $home/.config/nvim/init.vim
#echo "source ~/.vimrc" >> $home/.config/nvim/init.vim
#echo "INFO: Configuring init.vim DONE"

# install vim-plug and all plugins in .vimrc
echo "INFO: Installing vim plugins"
vim +"PlugInstall | q! | q!" ~/$RANDOM.vim --headless
echo "INFO: Installing vim plugins DONE"

# setting up vim-airline
# more instructions here https://github.com/vim-airline/vim-airline/wiki/Dummies-Guide-to-the-status-bar-symbols-(Powerline-fonts)-on-Fedora,-Ubuntu-and-Windows
# On Windows, install all of the source code pro fonts from here https://github.com/powerline/fonts/tree/master/SourceCodePro
# On Windows the terminal font should also be changed to source code pro
echo "INFO: Installing airline/powerline patched fonts"
cd $home/.dotfiles
git clone https://github.com/powerline/fonts.git --depth=1
fonts/install.sh
rm -rf fonts
echo "INFO: Installing airline/powerline patched fonts DONE"

echo ""
echo "INFO: ~/neovim can now be removed"
echo "INFO: To complete setup, change the terminal font to Source Code Pro for Powerline"
