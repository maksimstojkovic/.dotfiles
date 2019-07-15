#!/usr/bin/env bash

user=${SUDO_USER:-${USER}}
home=/home/${user}
dir=$(dirname "$(readlink -f "$0")")
stow_dir=/usr/local/stow
nvim_stow=${stow_dir}/nvim
tinytex_opt=/opt/tinytex
tinytex_stow=${stow_dir}/tinytex

if [ "$EUID" != "0" ]; then
	echo "PLEASE RUN THIS SCRIPT WITH SUDO"
	echo "sudo $0"
	exit 1
fi

if [ -z "$dir" ]; then
	echo "COULD NOT LOCATE SCRIPT DIRECTORY, PLEASE RUN WITHIN '~/.dotfiles/.scripts'"
	exit 1
fi

if [ "$user" == "root" ]; then
	echo "PLEASE RUN THIS SCRIPT AS A REGULAR USER USING 'sudo'"
	echo "sudo ${0}"
	exit 1
fi

if [ "$dir" == "${dir/${home}\/.dotfiles/}" ]; then
	echo "SCRIPTS DIRECTORY NOT LOCATED AT '~/.dotfiles/.scripts'"
	exit 1
fi

echo "INSTALLING DEPENDENCIES"
# 	apt-get remove -y neovim
# 	apt-get install -y stow build-essential
# 	apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
# 	apt-get install -y python-dev python-pip python3-dev python3-pip
# 	sudo -u ${user} pip install -q --user pynvim
echo "INSTALLING DEPENDENCIES DONE"

# helper for unstowing packages if they exist
unstow() {
	package=$(basename $1)
	if [ -d "${stow_dir}/${package}" ]; then
		cd $stow_dir
		stow --verbose=2 -D $package
	fi
}

echo "REMOVING REQUIRED DIRECTORIES"
unstow nvim
unstow tinytex
rm -rf /tmp/nvim /tmp/fonts $nvim_stow $tinytex_opt $tinytex_stow
cd /usr/local
find -type f -name '*nvim*' -delete
echo "REMOVING REQUIRED DIRECTORIES DONE"

echo "INSTALLING NEOVIM FROM SOURCE"
#	sudo -u ${user} git clone https://github.com/neovim/neovim /tmp/nvim
	sudo -u $user cp -r -v /tmp/vim /tmp/nvim
	cd /tmp/nvim
	rm -rf build
	sudo -u $user make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${nvim_stow}
	make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${nvim_stow} install
	cd $stow_dir
	stow --verbose=2 nvim
	update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
echo "INSTALLING NEOVIM FROM SOURCE DONE"



