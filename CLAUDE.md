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
- `programs/claude-code/` - Claude Code settings; prompts are generated and checked by eunomia (`pkgs/eunomia/`)

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

Skills, agents, commands, and the user CLAUDE.md are written as eunomia origin XML under `programs/claude-code/src/`:

```
programs/claude-code/
├── src/
│   ├── skills/<name>.xml     # -> ~/.claude/skills/<name>/SKILL.md
│   ├── agents/<name>.xml     # -> ~/.claude/agents/<name>.md
│   ├── commands/<name>.xml   # -> ~/.claude/commands/<name>.md
│   └── memory/user.xml       # -> ~/.claude/CLAUDE.md
├── eunomia.nix               # mkClaudeConfig: platform profile, MCP tools, extra front-matter (hooks)
├── settings.nix              # settings.json (permissions, hooks)
├── mcp-servers.nix           # MCP servers (serena, context7, playwright)
├── hooks/                    # hook scripts
└── skills/slide-generating/  # external skill, deployed as-is via `extra`
```

- The name and kind of each entity come from its path; do not write `key` or `cc:name`.
- Never edit `~/.claude/` directly; it is a build output.
- References to tools, skills, agents, and commands must be marked (`cc:useTool`, `cc:useSkill`, `cc:delegate`, `cc:seeAlso`) so that eunomia can check them. Unmarked tool/skill/agent/command names are reported as errors.
- Claude Code version-specific facts (available tools, removed tools, built-in skills and agents) live in the platform profile `pkgs/eunomia/platforms/claude-code-<version>.nix`. When Claude Code is updated, add or update a profile and run `nix flake check` to see what breaks.
- `nix flake check` runs the checks (`claude-code-schema`, `claude-code-refs`, `claude-code-prompts`). Deployment also depends on them, so `rake switch` fails while any check fails.
- See `pkgs/eunomia/README.md` for the vocabulary and the full list of checks.

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
