#!/bin/usr/env bash

# Script for installing zsh and tmux

# Script currently assumes system is debian

echo "INFO: Installing zsh and tmux"
sudo apt-get update
sudo apt-get install zsh tmux

shell=$(cat /etc/shells | grep /usr/bin/zsh)

if [ "$shell" != "/usr/bin/zsh" ]; then
	echo "INFO: Shell is not listed as authorised in /etc/shells"
	exit 1
fi

chsh -s $(which zsh)

echo "INFO: Installing zsh and tmux DONE"
echo ""
echo "To use zsh logout and log back in"
