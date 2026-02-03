# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix-based dotfiles repository managing configurations for NixOS (WSL) and macOS (nix-darwin) using home-manager. The primary programming language for Neovim configuration is Lua.

## Common Commands

```bash
# Apply configuration changes (detects OS automatically)
rake switch

# Update flake.lock and apply
rake update

# Enter development shell
nix develop
```

`rake update` runs nvd to show package version changes and uses the diff as a git commit template.

## Architecture

### Host Configurations

- `hosts/wsl.nix` - NixOS on WSL2 configuration
- `hosts/sechs.nix` - macOS (nix-darwin) configuration

Both hosts import `home.nix` which sets up overlays and common packages.

### Program Configurations

Programs are organized in `programs/` as home-manager modules. Three presets control which programs are loaded:
- `programs/base.nix` - Core CLI programs (neovim, fish, git, etc.)
- `programs/cli.nix` - CLI-only preset (imports base.nix)
- `programs/gui.nix` - Full preset with GUI apps (imports base.nix + rio terminal)

WSL uses `cli.nix`, macOS uses `gui.nix`.

Key programs:
- `programs/neovim/` - Neovim configuration (Lua-based, in `config.d/`)
- `programs/claude-code/` - Claude Code agents, commands, and skills (XML format)

### Neovim Configuration Structure

```
programs/neovim/config.d/
├── init.lua              # Entry point
├── lua/config/
│   ├── plugins/          # Plugin configurations (lazy.nvim)
│   ├── lsp.lua           # LSP configuration
│   └── *.lua             # Feature modules
├── after/lsp/            # Per-server LSP configs
├── ftplugin/             # Filetype-specific settings
├── compiler/             # Compiler definitions
└── queries/              # Tree-sitter queries
```

### Claude Code Configuration

Agents, commands, and skills are defined as XML files in `programs/claude-code/` and composed using `lib.nix`. The configuration uses Serena and Context7 MCP servers.

## Code Style

### Lua (Neovim)

Formatting via StyLua (`.stylua.toml`):
- 120 column width, 2-space indentation
- Single quotes, no call parentheses

### Nix

- Use pipe operator (`|>`) for chaining
- experimental features: flakes, pipe-operators

## Language Notes

- Code comments: English
- User-facing text and commit messages: Japanese is acceptable
