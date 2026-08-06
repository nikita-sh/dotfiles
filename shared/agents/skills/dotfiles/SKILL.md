---
name: dotfiles
description: How this machine's nix dotfiles are structured and how to rebuild home-manager and nix-darwin configs. Use when changing shell config, installed packages, or Claude Code settings (settings.json, skills, hooks, CLAUDE.md).
---

# Nix dotfiles

- Repo: `~/dev/dotfiles`. Per-host home-manager flakes in `homes/<host>/`, nix-darwin/NixOS system flakes in `systems/<host>/`, shared home-manager modules in `shared/` (exported via `shared/flake.nix` as `homeManagerModules`).
- Rebuild home config: `hmrb switch` (alias for `home-manager --flake ~/dev/dotfiles/homes/<host>#nikita@<host>`).
- Rebuild system config: `nixosrb switch`.
- `~/.zshrc`, `~/.zprofile`, `~/.claude/settings.json`, `~/.claude/CLAUDE.md`, `~/.claude/skills/` etc. are read-only nix store symlinks. Never edit them in place — edit the source in the repo, then rebuild. Claude Code's own settings mutations ("always allow", `/config`) won't persist; use a project-level `.claude/settings.local.json` for local overrides instead.
- Claude Code config lives in `shared/claude/`: `default.nix` (module: settings.json, dcg hook, statusline), `claude.md` (global CLAUDE.md), `skills/<name>/SKILL.md` (each subdirectory becomes a skill in `~/.claude/skills/` — adding one requires no extra wiring), `dcg.nix` (destructive-command-guard binary).
- Mercury-work-only config (fnm, Homebrew shellenv, bootstrap-mercury) lives in `homes/eule/mercury.nix`, not in `shared/`.
