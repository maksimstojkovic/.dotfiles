#/bin/usr/env bash

# script for automatically setting up bash aliases

# ensure script is not run with sudo so current user can be identified
if [ "$EUID" == "0" ]; then
	echo "Please run this script without sudo"
	echo "$0"
	exit 1
fi

home=$HOME
bashrc="$home/.bashrc"

# check if ~/.bashrc file exists
if [ ! -f "$bashrc" ]; then
	echo "INFO: Creating $bashrc"
	touch $bashrc
	echo "INFO: Creating $bashrc DONE"
fi

alias_auto=$(cat $bashrc | grep "\. ~\/\.bash_aliases")

# run alias file in .bashrc if not already included
# explicitly run .bash_aliases from home directory
if [ -z "$alias_auto" ]; then
	echo "INFO: Automatically running ~/.bash_aliases in .bashrc"
	echo "if [ -f ~/.bash_aliases ]; then" >> $bashrc
	echo -e "\t. ~/.bash_aliases" >> $bashrc
	echo "fi" >> $bashrc
	echo "INFO: Automatically running ~/.bash_aliases in .bashrc DONE"
fi

# uncommenting alias file in .bashrc
echo "INFO: Uncommenting alias file execution in .bashrc"
hash perl 2>/dev/null || sudo apt-get install perl
perl -i -p0e 's/.*if \[ -f ~\/\.bash_aliases \]; then\s*.*\. ~\/\.bash_aliases\s*.*fi/if \[ -f ~\/\.bash_aliases \]; then\n\t\. ~\/\.bash_aliases\nfi/g' $bashrc
echo "INFO: Uncommenting alias file execution in .bashrc DONE"

# create symbolic link to .bash_aliases file
echo "INFO: Creating symbolic link at ~/.bash_aliases"
ln -sfn $home/.dotfiles/.bash_aliases $home/.bash_aliases
echo "INFO: Creating symbolic link at ~/.bash_aliases DONE"

# reload .bashrc
. $bashrc

