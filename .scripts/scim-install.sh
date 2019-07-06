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

if [ ! -d "/usr/local/stow" ]; then
	echo "Creating /usr/local/stow directory"
	mkdir -p /usr/local/stow
	echo "Creating /usr/local/stow directory DONE"
fi

echo "INFO: Installing scim dependencies"
apt-get update
apt-get install -y stow autotools-dev
apt-get install -y bison libncurses5-dev libncursesw5-dev libxml2-dev libzip-dev
echo "INFO: Installing scim dependencies DONE"

echo "INFO: Removing required /tmp and /usr/local/stow directories"
cd /usr/local/stow
# TODO only unstow if directory exists
stow --verbose=2 -D scim
stow --verbose=2 -D libxls
stow --verbose=2 -D libxlsxwriter
cd $home
rm -rf /tmp/scim /tmp/libxlsxwriter /tmp/libxls /usr/local/stow/scim /usr/local/stow/libxlsxwriter /usr/local/stow/libxls
echo "INFO: Removing required /tmp and /usr/local/stow directories DONE"

echo "INFO: Installing xls dependencies"
sudo -u $user git clone https://github.com/libxls/libxls --depth=1 /tmp/libxls
cd /tmp/libxls
sudo -u $user ./bootstrap
sudo -u $user ./configure
sudo -u $user make prefix=/usr/local/stow/libxls
make install prefix=/usr/local/stow/libxls
cd /usr/local/stow
stow --verbose=2 libxls
ldconfig
echo "INFO: Installing xls dependencies DONE"

echo "INFO: Installing xlsx dependencies"
sudo -u $user git clone https://github.com/jmcnamara/libxlsxwriter.git --depth=1 /tmp/libxlsxwriter
cd /tmp/libxlsxwriter
sudo -u $user make INSTALL_DIR=/usr/local/stow/libxlsxwriter
make install INSTALL_DIR=/usr/local/stow/libxlsxwriter
cd /usr/local/stow
stow --verbose=2 libxlsxwriter
ldconfig
echo "INFO: Installing xlsx dependencies DONE"

echo "INFO: Installing scim from source"
sudo -u $user git clone https://github.com/andmarti1424/sc-im --depth=1 /tmp/scim
cd /tmp/scim/src
# TODO add flags for xls compatibility
sudo -u $user make name=scim prefix=/usr/local/stow/scim
make install name=scim prefix=/usr/local/stow/scim
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
echo "INFO: Updating scim alternatives DONE"

