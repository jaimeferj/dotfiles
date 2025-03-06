# README

## Clone

`git clone --recurse-submodules git@github.com:jaimeferj/dotfiles.git`

## Dependencies

- stow
- zsh
- tmux
- fzf
- zoxide
- neovim

## Configure

- On dotfiles: `stow .`
- `chsh -s /bin/zsh`
- Do: `tmux` and execute `ctrl+space I` to install plugins

## Develop

In order to develop and test the configuration, all you have to do is create a
worktree in ~/test-dotfiles (`git worktree add ../test-dotfiles -b develop`)
and a test home folder in `~/test-home`. After than
execute `envsubst < ~/.config/alacritty/alacritty-dev.sample.toml >
~/.config/alacritty/alacritty-dev.toml` to populate the development alacritty
configuration (to set $HOME env variable correctly), and then run `alacritty
--config-file=~/.config/alacritty/alacritty-dev.toml`. After that you can work
on ~/test-dotfiles and see the changes on your development environment.
There is also a script that updates the alacritty config with $HOME and runs alacritty
with the correct configuartion file in `.scripts/run-dev-session.sh`.
