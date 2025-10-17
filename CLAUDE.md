# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with GNU Stow. The repository uses a `dot-` prefix naming convention (e.g., `dot-zshrc`, `dot-config/`) which Stow automatically converts to dot-prefixed files (`.zshrc`, `.config/`) when deployed to `$HOME`.

## Initial Setup & Installation

```bash
# Clone with submodules (tmux plugin manager and plugins)
git clone --recurse-submodules git@github.com:jaimeferj/dotfiles.git

# Deploy dotfiles using Stow
stow --dotfiles .

# Change default shell to zsh
chsh -s /bin/zsh

# Install tmux plugins (from within tmux)
tmux
# Press: Ctrl+Space I
```

### Dependencies

Required packages: `stow`, `zsh`, `tmux`, `fzf`, `zoxide`, `neovim`

## Directory Structure

### Neovim Configuration (`dot-config/nvim/`)

Uses lazy.nvim plugin manager with a modular Lua structure:

- **`init.lua`**: Entry point that loads config modules
- **`lua/config/`**: Core configuration
  - `options.lua`: Editor options (tabs=4 spaces, leader=space, etc.)
  - `lazy.lua`: Plugin manager bootstrap and setup
  - `keymaps.lua`: Custom key mappings
  - `autocmds.lua`: Autocommands
- **`lua/plugins/`**: Plugin configurations (auto-loaded by lazy.nvim)
  - `coding.lua`: Code completion, snippets
  - `lsp.lua`: Language server configurations
  - `ui.lua`: UI enhancements
  - `editor.lua`: Editor functionality
  - `treesitter.lua`: Syntax highlighting
  - `utils.lua`: Utility plugins
  - `debug.lua`, `test.lua`: Debugging and testing tools
  - **`languages/`**: Language-specific LSP/formatter configs (Python, Go, JavaScript, Lua, Java, SQL)

**Python Configuration Special Case**: There's a `symlink-python.sh` script that creates a separate nvim-python config by symlinking nvim files but excluding the `/languages/` directory. This allows different language server configurations for general development vs Python-specific work.

### Tmux Configuration (`dot-config/tmux/`)

- Uses TPM (Tmux Plugin Manager) as a git submodule
- Prefix: `Ctrl+Space`
- Plugins: sensible, vim-tmux-navigator, rose-pine theme, yank, open, resurrect
- Vi-mode enabled for copy mode
- Nested tmux support: `Ctrl+Space b` sends prefix to inner session (useful for SSH)

### i3 Window Manager (`dot-config/i3/`)

Configured with named workspaces and startup applications:

- **Workspace assignments**:
  - `1:main` - Firefox + main tmux session
  - `2:qsearch` - Firefox with ChatGPT in Personal container
  - `3:docs` - Code tmux session + Firefox
  - `5:tasks` - taskwarrior-tui in tmux
  - `6:chat` - irssi IRC client in tmux
- **Multi-monitor setup**: `multi-monitor-setup.sh` automatically assigns workspaces to monitors when 2+ displays detected
- **Terminal**: kitty with tmux auto-attach
- **Keybindings**: Vim-style (hjkl) for navigation
- **Screenshots**: `Print` key captures region to `~/Pictures/` and copies to clipboard

### Zsh Configuration (`dot-zshrc`)

- Plugin manager: zinit
- Theme: Powerlevel10k
- Plugins: syntax-highlighting, autosuggestions, completions, fzf-tab
- Vi mode with custom bindings:
  - `Ctrl+p/n`: History search
  - `Ctrl+y`: Accept autosuggestion
  - `Ctrl+e`: Edit command in editor
- Shell integrations: fzf, zoxide (aliased to `cd`)
- Conditional loading of completions: uv, uvx, rabbitmqadmin, AWS CLI
- Custom helper scripts loaded from `~/.config/zsh/*.zsh`
- SDK managers: nvm, SDKMAN, Go, Spicetify

### Git Configuration (`dot-gitconfig`)

Uses conditional includes and has user-specific settings configured separately.

## Stow Configuration

The `.stow-local-ignore` file excludes version control and documentation files from being symlinked:
- README.md, .gitmodules, .gitignore, .git

## Common Development Workflows

### Adding a new Neovim plugin

1. Create or edit a file in `dot-config/nvim/lua/plugins/`
2. For language-specific plugins, use `dot-config/nvim/lua/plugins/languages/<language>.lua`
3. Lazy.nvim auto-loads all files in these directories

### Modifying keybindings

- **i3**: Edit `dot-config/i3/config`
- **tmux**: Edit `dot-config/tmux/tmux.conf`
- **nvim**: Edit `dot-config/nvim/lua/config/keymaps.lua`
- **zsh**: Edit `dot-zshrc` (vi-mode bindings section)

### Testing changes

After modifying dotfiles, re-run `stow --dotfiles .` from the repository root to update symlinks. Most applications require reload:
- i3: `Mod+Shift+r`
- tmux: `tmux source ~/.config/tmux/tmux.conf`
- nvim: `:source $MYVIMRC` or restart
- zsh: `source ~/.zshrc`
