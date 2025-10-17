# Repository Guidelines

## Project Structure & Module Organization
- Root-level `dot-*` files map directly to home directory dotfiles (`dot-zshrc`, `dot-gitconfig`, etc.).
- `dot-config/` mirrors `~/.config/`; key subfolders include `nvim` (general Neovim setup), `nvimpython` (Python-focused profile), `tmux` (plugins tracked as submodules), window manager configs under `i3/`, and terminal profiles in `alacritty/` and `kitty/`.
- Scripts and helper utilities live in `dot-config/scripts/`; keep new helpers self-contained and document invocation in this guide or in-line comments.

## Build, Test, and Development Commands
- `stow --dotfiles .` — symlink repository-managed files into your home directory; run after cloning or whenever structure changes.
- `nvim --headless "+Lazy sync" +qa` — install or update Neovim plugins defined in both `nvim` profiles; add `NVIM_APPNAME=nvimpython` to target the Python profile.
- `tmux` then `<prefix> I` — install tmux plugins via `tpm`; repeat when updating `dot-config/tmux/plugins`.
- `ruff check --config dot-config/ruff/ruff.toml <path>` — lint Python helpers or scripts before committing.

## Coding Style & Naming Conventions
- Lua files under `nvim/` follow 2-space indentation and module naming that mirrors directory layout (e.g., `config/options.lua` exposed as `config.options`); format with `stylua` where available.
- Python scripts and plugin hooks should satisfy `ruff` and prefer `black` formatting (handled automatically by Neovim’s conform config).
- Shell snippets use lowercase function names and `set -euo pipefail`; keep environment-specific paths in variables at the top of the file.

## Testing Guidelines
- Validate Neovim changes with `nvim --headless "+checkhealth" +qa` and open relevant filetypes to ensure LSP/formatter autoloading.
- For tmux updates, spawn a session, reload with `<prefix> r`, and verify new key bindings or plugins.
- When modifying window manager configs, use a temporary X session or `i3-msg reload` instead of restarting your primary session.

## Commit & Pull Request Guidelines
- Follow the existing Conventional Commits pattern (`feat:`, `fix:`, `chore:`) visible in `git log`.
- Each PR or shared patch should describe the affected tools (zsh, Neovim, i3, etc.), note manual steps (e.g., rerunning `stow`), and include screenshots or recordings when UI changes are involved.
- Reference related issues or external docs when introducing new plugins or dependencies, and call out any secrets or machine-specific values that collaborators must supply locally.

## Security & Configuration Tips
- Never commit machine-specific secrets, API keys, or SSH material; prefer placeholder tokens and document expected env vars.
- When adding new submodules, verify upstream licenses and ensure `.gitmodules` points to read-only URLs unless write access is required.
- Use `git update-index --skip-worktree` only for files intentionally unmanaged by Stow; document the choice in this file for future agents.
