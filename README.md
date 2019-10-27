# Using Dotfiles

Install stow:

```bash
sudo apt-get install stow
```

Clone the repo into `~/.dotfiles`:

```bash
git clone https://github.com/silentdigit/dotfiles ~/.dotfiles
```

Enter the `.dotfiles` directory and use `stow` on a directory to symlink it in the home directory (`~`):

```bash
cd ~/.dotfiles
stow --verbose=2 vim
```

To remove symlinks, use the `-D` flag with stow:

```bash
cd ~/.dotfiles
stow --verbose=2 -D vim
```

https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login

Run the following commands after stowing the ssh-agent and bash folders to enable ssh-agent on startup:

```bash
systemctl --user enable ssh-agent
systemctl --user start ssh-agent
```

'AddKeysToAgent yes' should also be added to individual hosts in `~/.ssh/config`
