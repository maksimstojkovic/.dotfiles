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
stow vim
```

To remove symlinks, use the `-D` flag with stow:

```bash
cd ~/.dotfiles
stow -D vim
```
