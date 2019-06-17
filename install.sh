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
echo "INFO: Home path: $home"
echo "INFO: Dotfiles path: $dot_dir_path"

# determine linux distro
distro=$(cat /etc/*release | grep -oP '\bID=.*\b' | sed 's/ID=//')
echo "INFO: Distro: $distro"

# move folder to ~/.dotfiles
if [ "$dot_dir_path" != "$home/.dotfiles" ]; then
	echo "INFO: Moving files from $dot_dir_path to $home/.dotfiles"
	rm -v -rf $home/.dotfiles
	mkdir -v -p $home/.dotfiles
	cp -v -a $dot_dir_path/. $home/.dotfiles
	cd $home/.dotfiles
	rm -v -rf $dot_dir_path
	dot_dir_path=$home/.dotfiles
	echo "INFO: Moving files from $dot_dir_path to $home/.dotfiles DONE"
fi

# installing neovim
echo "INFO: Installing neovim"
sudo apt-get update
sudo apt-get remove -y neovim
rm -rf ~/.vim
if [ "$distro" == "ubuntu" ]; then
	sudo apt-get install -y software-properties-common
	sudo add-apt-repository -y ppa:neovim-ppa/stable
	sudo apt-get update
	sudo apt-get install -y neovim
	sudo apt-get install -y python-dev python-pip python-neovim python3-dev python3-pip python3-neovim
elif [ "$distro" == "raspbian" ]; then
	sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
	sudo apt-get install -y python python-dev python3 python3-dev python-pip
	cd $dot_dir_path
	git clone https://github.com/neovim/neovim
	cd neovim
	git checkout stable
	make CMAKE_BUILD_TYPE=RelWithDebInfo
	sudo make install
	cd ..
	rm -rf neovim
	pip install --user neovim
fi
echo "INFO: Installing neovim DONE"

# add neovim to alternatives list
echo "INFO: Updating default editors"
if [ "$distro" == "ubuntu" ]; then
	sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
	sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
	sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
elif [ "$distro" == "raspbian" ]; then
	sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 60
	sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
	sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 60
fi
echo "INFO: Updating default editors DONE"

# create init.vim file which points to .vimrc in home directory
echo "INFO: Configuring init.vim"
mkdir -p $home/.config/nvim
echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after" > $home/.config/nvim/init.vim
echo "let &packpath = &runtimepath" >> $home/.config/nvim/init.vim
echo "source ~/.vimrc" >> $home/.config/nvim/init.vim
echo "INFO: Configuring init.vim DONE"

# create symbolic link to .vimrc in git repo
echo "INFO: Creating symbolic link at $home/.vimrc"
ln -sfn $home/.dotfiles/.vimrc $home/.vimrc
echo "INFO: Creating symbolic link at $home/.vimrc DONE"

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

