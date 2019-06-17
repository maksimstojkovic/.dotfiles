#!/usr/bin/env bash

# script for uninstalling neovim

# ensure script is not run with sudo so current user can be identified
if [ "$EUID" == "0" ]; then
	echo "Please run this script without sudo"
	echo "$0"
	exit 1
fi


# determine linux distro
distro=$(cat /etc/*release | grep -oP '\bID=.*\b' | sed 's/ID=//')
echo "INFO: Distro: $distro"
home=$HOME

# uninstalling neovim
echo "INFO: Uninstalling neovim"
rm -rf ~/.vim ~
if [ "$distro" == "ubuntu" ]; then
	sudo apt-get remove -y neovim
elif [ "$distro" == "raspbian" ]; then
	sudo rm -f /usr/local/bin/nvim
	sudo rm -rf /usr/local/share/nvim/
fi
echo "INFO: Uninstalling neovim DONE"
