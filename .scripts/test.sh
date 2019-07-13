#!/usr/bin/env bash

# script for setting up neovim on a fresh linux OS
# only tested on ubuntu
# installs all pre-requisites required to edit and export Rmarkdown files to PDF

unstow() {
	package=$(basename ${1})
	if [ -d "${stow_dir}/${package}" ]; then
		cd ${stow_dir}
		stow --verbose=2 -D ${package}
	fi
}

if [ "$EUID" != "0" ]; then
	echo "INFO: Please run this script with sudo"
	echo "sudo $0"
	exit 1
fi

user=${SUDO_USER:-${USER}}
home=/home/${user}
dir="$(dirname "$(readlink -f "$0")")"
moved=false
stow_dir=/usr/local/stow
nvim_prefix=${stow_dir}/nvim
tinytex_opt_prefix=/opt/tinytex
tinytex_stow_prefix=${stow_dir}/tinytex

rm -rf ${nvim_prefix}

echo "INFO: Installing neovim from source"
# sudo -u ${user} git clone https://github.com/neovim/neovim /tmp/neovim
# cp -v -r $home/vim /tmp/neovim
cd /tmp/neovim
# rm -rf build
sudo -u ${user} make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=${nvim_prefix}
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=${nvim_prefix} install
echo "INFO: Installing neovim from source DONE"
exit ##############################################

echo "INFO: Symlinking neovim bin files"
cd ${stow_dir}
stow --verbose=2 nvim
echo "INFO: Symlinking neovim bin files DONE"

echo "INFO: Symlinking .vimrc and init.vim files"
cd ${home}/.dotfiles
stow --verbose=2 vim
echo "INFO: Symlinking .vimrc and init.vim files DONE"

echo "INFO: Updating default editors"
# update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 60
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
git clone https://github.com/powerline/fonts.git /tmp/fonts
cd /tmp/fonts
./install.sh
echo "INFO: Installing airline/powerline patched fonts DONE"

echo "INFO: Installing R and R-markdown pre-requisites"
apt-get install -y r-base pandoc pandoc-citeproc
R --no-save << EOF
	install.packages("tinytex")
	tinytex::install_tinytex(dir = "${tinytex_opt_prefix}")
EOF
find ${home}/bin -lname '${tinytex_opt_prefix}/*' -delete
rm -d ${home}/bin
mkdir -p ${tinytex_stow_prefix}/bin
ln -s -v ${tinytex_opt_prefix}/bin/x86_64-linux/* ${tinytex_stow_prefix}/bin
cd ${stow_dir}
stow --verbose=2 tinytex
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
