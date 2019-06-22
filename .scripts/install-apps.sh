#!/usr/bin/env bash

# script which installs useful applications
# script currently assumes system is debian

# ensure script is not run with sudo so current user can be identified
if [ "$EUID" == "0" ]; then
	echo "Please run this script without sudo"
	echo "$0"
	exit 1
fi

# install tmux
echo "INFO: Installing tmux"
sudo apt-get update
sudo apt-get install tmux
echo "INFO: Installing tmux DONE"

