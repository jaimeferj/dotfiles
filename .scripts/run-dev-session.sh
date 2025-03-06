#!/bin/zsh
envsubst <.config/alacritty/alacritty-dev.sample.toml >.config/alacritty/alacritty-dev.toml
alacritty --config-file .config/alacritty/alacritty-dev.toml
