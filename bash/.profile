#
# ~/.bash_profile
#

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# update PATH
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.bin" ] ; then
	PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/anaconda3/bin" ] ; then
	PATH="$PATH:$HOME/anaconda3/bin"
fi

if [ -d "/opt/tinytex/bin/x86_64-linux" ] ; then
	PATH="$PATH:/opt/tinytex/bin/x86_64-linux"
fi

if [ -d "$HOME/.dotfiles/scripts" ] ; then
	PATH="$PATH:$HOME/.dotfiles/scripts"
fi

# Make file viewers acknowledge special characters in file names
export LC_COLLATE=C

# ssh-agent socket
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
