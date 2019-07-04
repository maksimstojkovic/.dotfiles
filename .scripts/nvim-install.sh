#!/usr/bin/env bash

# script for setting up neovim to use .vimrc in home directory, which symbolically links to the dotfiles git repo

# ensure script is not run with sudo so current user and home can be identified
if [ "$EUID" != "0" ]; then
	echo "Please run this script with sudo"
	echo "sudo $0"
	exit 1
fi

# determine current user, home and script directory after executing with sudo
user=${SUDO_USER:-${USER}}
home=/home/$user
dir="$(dirname "$(readlink -f "$0")")"

# TODO move dotfiles repo within script
# check if dotfiles repo has been moved to ~/.dotfiles
if [ "$dir" == "${dir/$home\/.dotfiles/}" ]; then
	echo "Please move the dotfiles repo to $home/.dotfiles"
	exit 1
fi

# installing neovim dependencies
echo "INFO: Installing neovim dependencies"
apt-get update
apt-get remove -y neovim
apt-get install -y stow
apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
apt-get install -y python-dev python-pip python3-dev python3-pip
sudo -u $user pip install --user pynvim
echo "INFO: Installing neovim dependencies DONE"

# create stow directory if it does not exist
if [ ! -d "/usr/local/stow" ]; then
	echo "Creating /usr/local/stow directory"
	mkdir -p /usr/local/stow
	echo "Creating /usr/local/stow directory DONE"
fi

# installing neovim from source
echo "INFO: Installing neovim from source"
git clone https://github.com/neovim/neovim /tmp/neovim
cd /tmp/neovim
rm -rf build
sudo -u $user make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/usr/local/stow/nvim
make install
echo "INFO: Installing neovim from source DONE"

# symlinking neovim binary files
echo "INFO: Symlinking neovim bin files"
cd /usr/local/stow
stow --verbose=2 nvim
echo "INFO: Symlinking neovim bin files DONE"

# symlinking .vimrc and init.vim files
echo "INFO: Symlinking .vimrc and init.vim files"
cd $home/.dotfiles
stow --verbose=2 vim
echo "INFO: Symlinking .vimrc and init.vim files DONE"

# add neovim to alternatives list
echo "INFO: Updating default editors"
	update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 60
	update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
	update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 60
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

git clone https://github.com/powerline/fonts.git --depth=1 /tmp/fonts
cd /tmp/fonts
install.sh
echo "INFO: Installing airline/powerline patched fonts DONE"

# TODO install Rmarkdown pre-requisites

echo ""
echo "INFO: Neovim source files can be found in /tmp/neovim"
echo "INFO: To complete setup, change the terminal font to Source Code Pro for Powerline"
