#!/usr/bin/env bash

# script for installing scim in stow directory

if [ "$EUID" != "0" ]; then
	echo "Please run this script with sudo"
	echo "sudo $0"
	exit 1
fi

user=${SUDO_USER:-${USER}}
home=/home/$user

if [ "$user" == "root" ]; then
	echo "Please run this script as a regular user using sudo"
	echo "sudo $0"
	exit 1
fi

echo "INFO: Installing scim dependencies"
apt-get update
apt-get install -y stow
apt-get install -y bison libncurses5-dev libncursesw5-dev libxml2-dev libzip-dev
echo "INFO: Installing scim dependencies DONE"

if [ ! -d "/usr/local/stow" ]; then
	echo "Creating /usr/local/stow directory"
	mkdir -p /usr/local/stow
	echo "Creating /usr/local/stow directory DONE"
fi

echo "INFO: Removing required /tmp and /usr/local/stow directories"
cd /usr/local/stow
stow --verbose=2 -D scim
cd $home
rm -rf /tmp/scim /usr/local/stow/scim
echo "INFO: Removing required /tmp and /usr/local/stow directories DONE"

echo "INFO: Installing scim from source"
sudo -u $user git clone https://github.com/andmarti1424/sc-im --depth=1 /tmp/scim
cd /tmp/scim/src
sed -i -E '0,/name\s*=/s/name\s*=.*/name = scim/' Makefile
sed -i -E '0,/prefix\s*=/s/prefix.*/prefix = \/usr\/local\/stow\/scim/' Makefile
sudo -u $user make
make install
echo "INFO: Installing scim from source DONE"

echo "INFO: Symlinking scim bin files"
cd /usr/local/stow
stow --verbose=2 scim
echo "INFO: Symlinking scim bin files DONE"

# TODO check that dotfiles in correct directory
echo "INFO: Symlinking .scimrc file"
cd $home/.dotfiles
stow --verbose=2 scim
echo "INFO: Symlinking .scimrc file DONE"

echo "INFO: Updating scim alternatives"
update-alternatives --install /usr/bin/scim scim /usr/local/bin/scim 60
echo "INFO: Updating scim alternatives"

