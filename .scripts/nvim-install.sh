#!/usr/bin/env bash

# script for setting up neovim on a fresh linux OS
# only tested on ubuntu
# installs all pre-requisites required to edit and export Rmarkdown files to PDF

if [ "$EUID" != "0" ]; then
	echo "Please run this script with sudo"
	echo "sudo $0"
	exit 1
fi

user=${SUDO_USER:-${USER}}
home=/home/$user
dir="$(dirname "$(readlink -f "$0")")"
moved=false

if [ "$user" == "root" ]; then
	echo "Please run this script as a regular user using sudo"
	echo "sudo $0"
	exit 1
fi

if [ "$dir" == "${dir/$home\/.dotfiles/}" ]; then
	echo "INFO: Moving dotfiles to ~/.dotfiles"
	cd $home
	sudo -u $user rm -rf .dotfiles
	sudo -u $user mkdir -p .dotfiles
	sudo -u $user cp -v -r $dir/.. $home/.dotfiles
	cd $home/.dotfiles
	sudo -u $user rm -v -rf ${dir/.scripts/}
	dir="$home/.dotfiles/.scripts"
	echo "INFO: Moving dotfiles to ~/.dotfiles DONE"
	moved=true
fi

echo "INFO: Installing neovim dependencies"
apt-get update
apt-get remove -y neovim
apt-get install -y stow
apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
apt-get install -y python-dev python-pip python3-dev python3-pip
sudo -u $user pip install --user pynvim
echo "INFO: Installing neovim dependencies DONE"

if [ ! -d "/usr/local/stow" ]; then
	echo "Creating /usr/local/stow directory"
	mkdir -p /usr/local/stow
	echo "Creating /usr/local/stow directory DONE"
fi

echo "INFO: Removing required /tmp and /usr/local/stow directories"
rm -rf /tmp/neovim /tmp/fonts /usr/local/stow/nvim /usr/local/stow/tinytex
echo "INFO: Removing required /tmp and /usr/local/stow directories DONE"

echo "INFO: Installing neovim from source"
sudo -u $user git clone https://github.com/neovim/neovim --depth=1 /tmp/neovim
cd /tmp/neovim
rm -rf build
sudo -u $user make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/usr/local/stow/nvim
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/usr/local/stow/nvim install
echo "INFO: Installing neovim from source DONE"

echo "INFO: Symlinking neovim bin files"
cd /usr/local/stow
stow --verbose=2 nvim
echo "INFO: Symlinking neovim bin files DONE"

echo "INFO: Symlinking .vimrc and init.vim files"
cd $home/.dotfiles
stow --verbose=2 vim
echo "INFO: Symlinking .vimrc and init.vim files DONE"

echo "INFO: Updating default editors"
#	update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 60
	update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
	update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 60
echo "INFO: Updating default editors DONE"

echo "INFO: Installing vim plugins"
vim +"PlugInstall | q! | q!" ~/$RANDOM.txt --headless
echo "INFO: Installing vim plugins DONE"

# On Windows, install all of the source code pro fonts from https://github.com/powerline/fonts/tree/master/SourceCodePro
# Windows - Change terminal font to Source Code Pro for Powerline
# Additional instructions can be found at https://github.com/vim-airline/vim-airline/wiki/Dummies-Guide-to-the-status-bar-symbols-(Powerline-fonts)-on-Fedora,-Ubuntu-and-Windows
echo "INFO: Installing airline/powerline patched fonts"
git clone https://github.com/powerline/fonts.git --depth=1 /tmp/fonts
cd /tmp/fonts
./install.sh
echo "INFO: Installing airline/powerline patched fonts DONE"

echo "INFO: Installing R and R-markdown pre-requisites"
apt-get install -y r-base pandoc pandoc-citeproc
R --no-save << EOF
	install.packages("tinytex")
	tinytex::install_tinytex(dir = "/usr/local/stow/tinytex")
EOF
rm -rf $home/bin
cd /usr/local/stow/tinytex/bin
stow --verbose=2 -t /usr/local/bin x86_64-linux
echo "INFO: Installing R and R-markdown pre-requisites DONE"

echo
echo "INFO: Installation complete"
echo "INFO: Neovim source files can be found in /tmp/neovim"
echo "INFO: To complete setup, change the terminal font to Source Code Pro for Powerline"
echo "INFO: Font files can be found in /tmp/fonts"
if [ "$moved" = true ]; then
	echo "INFO: To proceed, execute one of the following:"
	echo "cd ~"
	echo "cd ~/.dotfiles"
fi
