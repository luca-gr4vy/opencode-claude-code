## OpenCode default config

Shareable OpenCode setup with:

- runtime config in `opencode.json`
- TUI config in `tui.json`
- reusable project rules in `AGENTS.md`
- custom slash commands in `commands/`

This repo keeps the existing config as-is (including Ollama and model/provider choices).

## Recommended usage

Use both env vars so users get JSON config and directory-based assets:

```bash
export OPENCODE_CONFIG=/absolute/path/to/opencode/opencode.json
export OPENCODE_CONFIG_DIR=/absolute/path/to/opencode
```

Then run OpenCode from any project:

```bash
opencode
```

## Why this setup

- `OPENCODE_CONFIG` loads `opencode.json` (models, providers, permissions, mcp, tools, agents)
- `OPENCODE_CONFIG_DIR` loads directory assets (`commands/`, `agents/`, `skills/`, `plugins/`, etc.)
- both are needed for full portability of this repo

## Included commands

- `/investigate` - feature investigation workflow
- `/pin-dep` - pin/update a dependency with lockfile focus
- `/upgrade-dep` - safer dependency upgrade flow, including major checks
- `/validate-investigation` - validate and revise an investigation doc

## Prerequisites

- OpenCode installed
- access to the configured models/providers in `opencode.json`
- optional local Ollama at `http://localhost:11434/v1` for local agents
- optional env vars for configured integrations (for example `CONTEXT7_API_KEY`)

## Install scripts

Use the scripts in `scripts/` to install OpenCode and Claude config with backups.

### OpenCode installer

```bash
./scripts/install-opencode.sh --dry-run
./scripts/install-opencode.sh --copy
```

Options:

- `--copy` (default) copies files into `~/.config/opencode`
- `--symlink` symlinks from this repo
- `--force` replaces existing targets in symlink mode
- `--no-env` skips writing `~/.config/opencode/env.sh`

Behavior:

- Installs `opencode.json`, `tui.json`, `AGENTS.md`, and `commands/`
- Backs up existing files/directories before replacing (`*.bak-YYYYmmdd-HHMMSS`)
- Writes `~/.config/opencode/env.sh` with `OPENCODE_CONFIG` and `OPENCODE_CONFIG_DIR`

### Combined installer

```bash
./scripts/install-all.sh --dry-run
```

Runs both OpenCode and Claude installers with the same flags.

## Claude Code setup

This repo also includes a Claude Code-compatible setup under `claude/`, plus `CLAUDE.md` and `.claude.json`.

### Included Claude assets

- `CLAUDE.md` - Claude memory/instructions equivalent of `AGENTS.md`
- `.claude.json` - user-level Claude config template (MCP servers)
- `claude/settings.json` - settings template (model, status line, permissions, and desktop notification hooks)
- `claude/agents/` - custom subagents (`deep`, `fast`, `tiny`)
- `claude/skills/` - migrated command workflows as Claude skills

This template already includes your preferred defaults:
- `model: "opus"`
- powerline status line via `@owloops/claude-powerline`

### Install script (user-scoped)

Use the helper script to install everything into `~/.claude`:

```bash
./scripts/install-claude.sh --dry-run
./scripts/install-claude.sh --copy
```

Options:

- `--copy` (default) copies files into `~/.claude`
- `--symlink` symlinks `CLAUDE.md`, `agents/`, and `skills/` from this repo
- `--force` replaces existing targets in symlink mode
- `--no-claude-json` skips install/merge of `~/.claude.json`

Behavior:

- Backs up existing files before replacing/merging (`*.bak-YYYYmmdd-HHMMSS`)
- Merges `claude/settings.json` into `~/.claude/settings.json` when `jq` is installed
- Merges `.claude.json` into `~/.claude.json` when `jq` is installed

### Install globally for your user

```bash
mkdir -p ~/.claude
cp /absolute/path/to/opencode/CLAUDE.md ~/.claude/CLAUDE.md
cp /absolute/path/to/opencode/claude/settings.json ~/.claude/settings.json
```

Install user-level MCP/template config:

```bash
cp /absolute/path/to/opencode/.claude.json ~/.claude.json
```

For reusable agents/skills across all repos:

```bash
mkdir -p ~/.claude/agents ~/.claude/skills
cp -R /absolute/path/to/opencode/claude/agents/. ~/.claude/agents/
cp -R /absolute/path/to/opencode/claude/skills/. ~/.claude/skills/
```

### Ollama with Claude Code

You can run Claude Code against Ollama's Anthropic-compatible endpoint:

```bash
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_API_KEY=""
export ANTHROPIC_BASE_URL=http://localhost:11434
claude --model qwen3.5
```

Or use the launcher:

```bash
ollama launch claude --model kimi-k2.5:cloud
```

Notes:

- Subagents are supported with Ollama integration.
- Subagent behavior is model-dependent; Ollama cloud models generally work best.
- Per-subagent model routing like OpenCode JSON agents is not a direct 1:1 mapping.

## Repo layout

```text
.
├── AGENTS.md
├── CLAUDE.md
├── commands/
├── claude/
├── .claude.json
├── opencode.json
├── README.md
├── scripts/
└── tui.json
```

