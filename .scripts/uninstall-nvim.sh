#!/usr/bin/env bash

# TODO Check that directories exist before changing or stowing

cd /usr/local/stow
stow --verbose=2 -D nvim

cd tinytex/bin
stow --verbose=2 -D -t /usr/local/bin/ x86_64-linux/
# TODO run R command for uninstalling, with same directory

cd /usr/local/stow
rm -rf nvim tinytex

