---
name: dotfiles
description: How this machine's nix dotfiles are structured and how to rebuild home-manager and nix-darwin configs. Use when changing shell config, installed packages, or Claude Code settings (settings.json, skills, hooks, CLAUDE.md).
---

# Nix dotfiles

- Repo: `~/dev/dotfiles`. Per-host home-manager flakes in `homes/<host>/`, nix-darwin/NixOS system flakes in `systems/<host>/`, shared home-manager modules in `shared/` (exported via `shared/flake.nix` as `homeManagerModules`).
- Rebuild home config: `hmrb switch` (alias for `home-manager --flake ~/dev/dotfiles/homes/<host>#nikita@<host>`).
- Rebuild system config: `nixosrb switch`.
- Changes under `shared/` need `git add` and a re-lock before they reach a rebuild. The host flake pins `shared` as `path:../../shared`, so `hmrb switch` alone installs the locked revision and reports success while your edit is still absent. Full sequence: `git add` the changed files, `nix flake update shared` in `homes/<host>/`, then `hmrb switch`. Confirm by grepping the rendered target under `~/.claude/`, not the source.
- `~/.zshrc`, `~/.zprofile`, `~/.claude/settings.json`, `~/.claude/CLAUDE.md`, `~/.claude/skills/` etc. are read-only nix store symlinks. Never edit them in place — edit the source in the repo, then rebuild. Claude Code's own settings mutations ("always allow", `/config`) won't persist; use a project-level `.claude/settings.local.json` for local overrides instead.
- Agent config lives in `shared/agents/`, shared across harnesses: `default.nix` (module, builds the skills directory), `lib.nix` (`mkInstructions`, which concatenates the instruction sources), `instructions.md` (harness-neutral body), `skills/<name>/SKILL.md` (each subdirectory becomes a skill in `~/.claude/skills/` — adding one requires no extra wiring), `guard/dcg.nix` (destructive-command-guard binary).
- Per-harness config sits under `shared/agents/harnesses/`: `claude-code.nix` (settings.json, hooks, statusline) with `claude-code/instructions.md`, `claude-code/agents/*.md` (subagent definitions), and `claude-code/statusline-command.sh`; `codex.nix` with `codex/instructions.md`.
- `~/.claude/CLAUDE.md` is generated, not copied: `mkInstructions` concatenates `shared/agents/instructions.md`, then `harnesses/claude-code/instructions.md`, then any per-host `extraInstructions`. Put a preference in the neutral body when it should apply to Codex too, in the harness file when it is Claude Code-specific.
- Mercury-work-only config (fnm, Homebrew shellenv, bootstrap-mercury) lives in `homes/eule/mercury.nix`, not in `shared/`.
