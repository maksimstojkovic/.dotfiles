#!/usr/bin/env bash

user=${SUDO_USER:-${USER}}
home=/home/${user}
dir=$(dirname "$(readlink -f "$0")")
stow_dir=/usr/local/stow
scim_stow=${stow_dir}/scim

if [ "$EUID" != "0" ]; then
	echo "PLEASE RUN THIS SCRIPT WITH SUDO"
	echo "sudo $0"
	exit 1
fi

if [ "$user" == "root" ]; then
	echo "PLEASE RUN THIS SCRIPT AS A REGULAR USER USING 'sudo'"
	echo "sudo $0"
	exit 1
fi

if [ -z "$dir" ]; then
	echo "COULD NOT LOCATE SCRIPT DIRECTORY, PLEASE RUN WITHIN '~/.dotfiles/.scripts'"
	exit 1
fi

if [ "$dir" == "${dir/${home}\/.dotfiles/}" ]; then
	echo "SCRIPTS DIRECTORY NOT LOCATED AT '~/.dotfiles/.scripts'"
	exit 1
fi

echo "INSTALLING DEPENDENCIES"
apt-get install -y stow build-essential autotools-dev sed
apt-get install -y bison libncurses5-dev libncursesw5-dev libxml2-dev libzip-dev
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
unstow scim
unstow libxls
unstow libxlsxwriter
cd $home
rm -v -rf /tmp/scim /tmp/libxls /tmp/libxlsxwriter ${stow_dir}/scim ${stow_dir}/libxls ${stow_dir}/libxlsxwriter
echo "REMOVING REQUIRED DIRECTORIES DONE"

echo "INSTALLING XLS DEPENDENCIES"
sudo -u $user git clone https://github.com/libxls/libxls /tmp/libxls
cd /tmp/libxls
sudo -u $user ./bootstrap
sudo -u $user ./configure
sudo -u $user make prefix=${stow_dir}/libxls
make install prefix=${stow_dir}/libxls
cd $stow_dir
stow --verbose=2 libxls
ldconfig
echo "INSTALLING XLS DEPENDENCIES DONE"

echo "INSTALLING XLSX DEPENDENCIES"
sudo -u $user git clone https://github.com/jmcnamara/libxlsxwriter.git /tmp/libxlsxwriter
cd /tmp/libxlsxwriter
sudo -u $user make INSTALL_DIR=${stow_dir}/libxlsxwriter
make install INSTALL_DIR=${stow_dir}/libxlsxwriter
cd $stow_dir
stow --verbose=2 libxlsxwriter
ldconfig
echo "INSTALLING XLSX DEPENDENCIES DONE"

echo "INSTALLING SCIM FROM SOURCE"
sudo -u $user git clone https://github.com/andmarti1424/sc-im /tmp/scim
cd /tmp/scim/src

# Flags for xls compatibility
sed -i -E '0,/#\s*CFLAGS\s*\+=\s*-DXLS\s/s/#\s*CFLAGS\s*\+=\s*-DXLS/CFLAGS += -DXLS/' Makefile
sed -i -E '0,/#\s*LDLIBS\s*\+=\s*-lxlsreader\s/s/#\s*LDLIBS\s*\+=\s*-lxlsreader/LDLIBS += -lxlsreader/' Makefile

sudo -u $user make name=scim prefix=${stow_dir}/scim
make install name=scim prefix=${stow_dir}/scim
cd $stow_dir
stow --verbose=2 scim
echo "INSTALLING SCIM FROM SOURCE DONE"

echo "SYMLINKING .scimrc FILES"
cd ${home}/.dotfiles
stow --verbose=2 scim
echo "SYMLINKING .scimrc FILES DONE"
