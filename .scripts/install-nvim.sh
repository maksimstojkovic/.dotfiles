#!/usr/bin/env bash

# script for setting up neovim to use .vimrc in home directory, which symbolically links to the dotfiles git repo

# ensure script is not run with sudo so current user and home can be identified
if [ "$EUID" == "0" ]; then
	echo "Please run this script without sudo"
	echo "$0"
	exit 1
fi

home=$HOME

# check that ~/.dotfiles exists for the current user
if [ ! -d "$home/.dotfiles" ]; then
	echo "Please install dotfiles repo at ~/.dotfiles"
	exit 1
fi

# ensure that script is run from .scripts directory
if [ "$PWD" != "$home/.dotfiles/.scripts" ]; then
	echo "Please run this script from within ~/.dotfiles/.scripts"
	exit 1
fi

# installing neovim dependencies
echo "INFO: Installing neovim dependencies"
sudo apt-get update
sudo apt-get remove -y neovim
sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
sudo apt-get install -y python-dev python-pip python3-dev python3-pip
pip install --user pynvim
sudo apt-get install -y stow
echo "INFO: Installing neovim dependencies DONE"

# remove neovim directory if it exists in home directory
if [ -d "$home/neovim" ]; then
	rm -rf $home/neovim
fi

# create stow directory if it does not exist
if [ ! -d "/usr/local/stow" ]; then
	sudo mkdir -p /usr/local/stow
fi

# installing neovim from source
echo "INFO: Installing neovim from source"
git clone https://github.com/neovim/neovim $home/neovim
cd $home/neovim
rm -rf build
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/usr/local/stow/nvim
sudo make install
echo "INFO: Installing neovim from source DONE"

# symlinking neovim binary files
echo "INFO: Symlinking neovim bin files"
cd /usr/local/stow
sudo stow --verbose=2 nvim
echo "INFO: Symlinking neovim bin files DONE"

# symlinking .vimrc and init.vim files
echo "INFO: Symlinking .vimrc and init.vim files"
cd $home/.dotfiles
stow --verbose=2 vim
echo "INFO: Symlinking .vimrc and init.vim files DONE"

# add neovim to alternatives list
echo "INFO: Updating default editors"
	sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 60
	sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
	sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 60
echo "INFO: Updating default editors DONE"

# install vim-plug and all plugins in .vimrc
echo "INFO: Installing vim plugins"
vim +"PlugInstall | q! | q!" ~/$RANDOM.txt --headless
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
