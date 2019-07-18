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

if [ "$user" == "root" ]; then
	echo "PLEASE RUN THIS SCRIPT AS A REGULAR USER USING 'sudo'"
	echo "sudo ${0}"
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

# echo "INSTALLING DEPENDENCIES" TODO uncomment
# apt-get remove -y neovim
# apt-get install -y stow build-essential
# apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
# apt-get install -y python-dev python-pip python3-dev python3-pip
# apt-get install -y r-base pandoc pandoc-citeproc
# sudo -u ${user} pip install -q --user pynvim
# echo "INSTALLING DEPENDENCIES DONE"

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
rm -v -rf /tmp/nvim /tmp/fonts $nvim_stow $tinytex_opt $tinytex_stow
cd /usr/local
find -type f -name "*nvim*" -delete
echo "REMOVING REQUIRED DIRECTORIES DONE"

echo "INSTALLING NEOVIM FROM SOURCE"
# sudo -u ${user} git clone https://github.com/neovim/neovim /tmp/nvim TODO uncomment and remove cp below
sudo -u $user cp -v -r /tmp/vim /tmp/nvim
cd /tmp/nvim
rm -rf build
sudo -u $user make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${nvim_stow}
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${nvim_stow} install
cd $stow_dir
stow --verbose=2 nvim
update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
echo "INSTALLING NEOVIM FROM SOURCE DONE"

echo "SYMLINKING .vimrc AND init.vim FILES"
cd ${home}/.dotfiles
stow --verbose=2 vim
echo "SYMLINKING .vimrc AND init.vim FILES DONE"

echo "INSTALLING VIM PLUGINS"
vim +"PlugInstall | q! | q!" ~/$RANDOM.txt --headless
echo "INSTALLING VIM PLUGINS DONE"

echo "SETTING UP VIM R-MARKDOWN"
R --no-save << EOF
install.packages("tinytex")
tinytex::install_tinytex(dir = "${tinytex_opt}")
EOF

find ${home}/bin -lname "${tinytex_opt}/*" -delete
rm -v -d ${home}/bin
mkdir -p ${tinytex_stow}/bin
ln -v -s ${tinytex_opt}/bin/x86_64-linux/* ${tinytex_stow}/bin
cd ${stow_dir}
stow --verbose=2 tinytex
echo "SETTING UP VIM R-MARKDOWN DONE"

# On Windows, install all of the source code pro fonts from https://github.com/powerline/fonts/tree/master/SourceCodePro
# Windows - Change terminal font to Source Code Pro for Powerline
# Additional instructions can be found at https://github.com/vim-airline/vim-airline/wiki/Dummies-Guide-to-the-status-bar-symbols-(Powerline-fonts)-on-Fedora,-Ubuntu-and-Windows
# echo "INSTALLING AIRLINE/POWERLINE PATCHED FONTS" TODO uncomment
# git clone https://github.com/powerline/fonts.git /tmp/fonts
# cd /tmp/fonts
# ./install.sh
# echo "INSTALLING AIRLINE/POWERLINE PATCHED FONTS DONE"

echo
echo "INSTALLATION COMPLETE"
echo "NEOVIM SOURCE FILES CAN BE FOUND IN /tmp/nvim"
echo "ENSURE THAT THE TERMINAL FONT IS SET TO Source Code Pro for Powerline"
echo "FONT FILES CAN BE FOUND IN /tmp/fonts"
