# Clone

`git clone --recurse-submodules git@github.com:jaimeferj/dotfiles.git`

# Dependencies:

- stow
- zsh
- tmux
- fzf
- zoxide
- neovim
- node > 22 (curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash && nvm install --lts)

# Configure

- On dotfiles: `stow --dotfiles .`
- `chsh -s /bin/zsh`
- Do: `tmux` and execute `ctrl+space I` to install plugins
