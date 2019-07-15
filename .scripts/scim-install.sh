#!/usr/bin/env bash

# script for installing scim in stow directory

unstow() {
	package=$(basename ${1})
	d=${2:-${stow_dir}}
	if [ -d "$d" ]; then
		cd ${d}
		stow --verbose=2 -D ${package}
	fi
}

stow() {
	package=$(basename ${1})
	d=${2:-${stow_dir}}
	if [ -d "$d" ]; then
		cd ${d}
		stow --verbose=2 ${package}
	fi
}

if [ "$EUID" != "0" ]; then
	echo "Please run this script with sudo"
	echo "sudo $0"
	exit 1
fi

user=${SUDO_USER:-${USER}}
home=/home/$user
stow_dir=/usr/local/stow

if [ "$user" == "root" ]; then
	echo "Please run this script as a regular user using sudo"
	echo "sudo $0"
	exit 1
fi

if [ ! -d "${stow_dir}" ]; then
	echo "Creating ${stow_dir} directory"
	mkdir -p ${stow_dir}
	echo "Creating ${stow_dir} directory DONE"
fi

echo "INFO: Installing scim dependencies"
apt-get update
apt-get install -y stow autotools-dev sed build-essential
apt-get install -y bison libncurses5-dev libncursesw5-dev libxml2-dev libzip-dev
echo "INFO: Installing scim dependencies DONE"

echo "INFO: Removing required directories"
unstow scim
unstow libxls
unstow libxlsxwriter
cd ${home}
rm -rf /tmp/scim /tmp/libxls /tmp/libxlsxwriter ${stow_dir}/scim ${stow_dir}/libxls ${stow_dir}/libxlsxwriter
echo "INFO: Removing required directories DONE"

echo "INFO: Installing xls dependencies"
sudo -u ${user} git clone https://github.com/libxls/libxls --depth=1 /tmp/libxls
cd /tmp/libxls
sudo -u ${user} ./bootstrap
sudo -u ${user} ./configure
sudo -u ${user} make prefix=/usr/local/stow/libxls
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
sudo -u $user git clone https://github.com/andmarti1424/sc-im /tmp/scim
cd /tmp/scim/src

# Flags for xls compatibility
# sed -i -E '0,/#\s*CFLAGS\s*\+=\s*-DXLS\s/s/#\s*CFLAGS\s*\+=\s*-DXLS/CFLAGS += -DXLS/' Makefile
# sed -i -E '0,/#\s*LDLIBS\s*\+=\s*-lxlsreader\s/s/#\s*LDLIBS\s*\+=\s*-lxlsreader/LDLIBS += -lxlsreader/' Makefile

sudo -u $user make name=scim prefix='${stow_dir}/scim' CFLAGS='-DXLS' LDLIBS='-lxlsreader'
make install name=scim prefix='${stow_dir}/scim' CFLAGS='-DXLS' LDLIBS='-lxlsreader'
echo "INFO: Installing scim from source DONE"

echo "INFO: Symlinking scim bin files"
cd ${stow_dir}
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

