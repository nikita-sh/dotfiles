# Multi-harness agents module

Replaces `shared/claude/` with `shared/agents/`, a home-manager module that configures several coding-agent CLIs from one shared source. The first pass covers Claude Code (Anthropic), Codex (OpenAI), and Prime Agent. Prime Agent is not in nixpkgs, so this also adds a package for it.

## Motivation

`shared/claude/` hard-codes everything about one harness: the instruction file, the skills directory, the settings schema, and the activation script that merges nix-managed keys into a runtime-mutable `settings.json`. Adding a second harness by copying that file would duplicate the instruction content, the skills source, and the settings-merge logic. The module needs an interface that a new harness plugs into.

## Scope of abstraction

The shared layer owns instruction text, the skills source, and normalized model knobs. It does not own approval policy or guard hooks. A Claude Code `PreToolUse` hook, a Codex `prefix_rule`, and a Prime Agent JS extension express different things, and a normalized policy option would have to be lossy in a way that hides which harness is actually guarded. Those stay harness-specific.

## Capability differences

| | Claude Code | Codex | Prime Agent |
|---|---|---|---|
| global instructions | `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` | `~/.prime/agent/AGENTS.md` |
| skills | `~/.claude/skills` | `~/.agents/skills` | `~/.prime/agent/skills` and `~/.agents/skills` |
| settings file | `settings.json`, rewritten by the CLI at runtime | `config.toml`, static | `~/.prime/agent/settings.json`, rewritten by the CLI at runtime |
| model key | `model` | `model` | `defaultModel` |
| reasoning key | `effortLevel` | `model_reasoning_effort` | `defaultThinkingLevel` |
| command guard | `PreToolUse` hook | `rules` | JS extension API |
| statusline, subagent definitions | yes | no | no |

All three implement the Agent Skills standard, so a single skills directory serves all of them.

Claude Code and Codex have upstream home-manager modules (`programs.claude-code`, `programs.codex`). Prime Agent has none, so its files are written directly.

## Directory layout

```
shared/agents/
  default.nix                    option declarations, dispatch to enabled harnesses
  lib.nix                        mkMutableSettings, mkInstructions
  instructions.md                harness-neutral instruction body
  skills/                        single skills source for all harnesses
  pkgs/prime-agent.nix
  harnesses/
    claude-code.nix
    claude-code/
      instructions.md
      agents/                    reader.md, verifier.md
      dcg.nix
      statusline-command.sh
      claude-code-log.nix
    codex.nix
    codex/instructions.md
    prime-agent.nix
    prime-agent/instructions.md
```

Assets that only Claude Code can consume live under `harnesses/claude-code/` rather than in the shared layer.

`shared/flake.nix` exports modules keyed by directory name, so the module becomes `shared.homeManagerModules.agents`. All four home flakes import `shared.homeManagerModules.claude` today and need the import line changed.

## Interface

```nix
my.agents = {
  instructions = ./instructions.md;
  skillsDir = ./skills;

  harnesses.claude-code = {
    enable = true;
    model = "claude-opus-5[1m]";
    reasoningEffort = "medium";
    theme = "dark-ansi";
  };
  harnesses.codex.enable = true;
  harnesses.prime-agent = {
    enable = true;
    model = "gpt-5";
  };
};
```

`harnesses` is `attrsOf (submodule harnessOptions)` where `harnessOptions` is declared once in `lib.nix`:

| Option | Type | Meaning |
|---|---|---|
| `enable` | bool | Install and configure this harness. |
| `model` | nullOr str | Passed through to the harness's model key. Not validated against a catalog. |
| `reasoningEffort` | nullOr (enum) | One of `off`, `minimal`, `low`, `medium`, `high`, `xhigh`. |
| `theme` | nullOr str | Passed through where the harness has a theme setting. |
| `extraInstructions` | lines or path | Appended after the shared body and the harness's own instruction file. |
| `settings` | attrs | Raw harness-native settings, merged last. Escape hatch for anything the normalized options do not cover. |

Each `harnesses/<name>.nix` reads `config.my.agents.harnesses.<name>` and produces native configuration under `lib.mkIf cfg.enable`. Normalized values are translated through a per-harness lookup table, so a `reasoningEffort` a harness cannot express fails during evaluation rather than being dropped.

## Shared helpers

`mkMutableSettings { path, defaults, managed }` generates the activation-script merge that `shared/claude/default.nix` currently performs inline: seed defaults, preserve whatever the CLI wrote at runtime, then overwrite the nix-managed keys. The merge is `jq -S '$defaults * . * $managed'`, which merges objects and replaces arrays. A store symlink cannot be used for these files because the CLI writes a temporary file next to the resolved symlink target and renames it, which fails inside the store. Claude Code and Prime Agent both need this. Codex writes a static TOML file and does not.

`mkInstructions harness` concatenates the shared instruction body, the harness's own `instructions.md`, and its `extraInstructions` into one store path, used as `CLAUDE.md` or `AGENTS.md`.

Skills need no helper. The single `shared/agents/skills` source is linked to `~/.agents/skills`, which Codex from 0.94 and Prime Agent both read, and is passed to `programs.claude-code.skillsDir`.

## Instruction content

The existing `claude.md` mixes harness-neutral guidance with Claude Code specifics: skill names, slash commands, the Fable and Opus model tiers, and the note that Codex reviews the work. The neutral parts move to `shared/agents/instructions.md`. The Claude-specific parts move to `harnesses/claude-code/instructions.md`. Codex and Prime Agent start with short instruction files of their own.

## Prime Agent package

Prime Agent is distributed as an npm tarball on GitHub releases and on Prime's R2 bucket. It is not published to the npm registry. Its dependencies include three sibling tarballs referenced by URL, a native `zeromq` binding, and a wasm image module. It requires Node 22.8 or later.

`pkgs/prime-agent.nix` pins version 0.7.0 and builds in two stages. First a fixed-output derivation fetches the release tarball and runs `npm install --omit=dev` with network access, producing a `node_modules` tree under a pinned output hash. Then the final derivation copies the package and its `node_modules` into the store and wraps `dist/bundle/cli.js` with `nodejs_22`.

The wrapper sets `PI_SKIP_VERSION_CHECK=1` so the CLI does not attempt to self-update over a read-only store path, and points `PRIME_AGENT_KERNEL_PYTHON` at a nixpkgs Python with IPython instead of letting the postinstall script provision an interpreter.

Bumping the version means editing the release tarball hash and the `node_modules` output hash.

`shared/flake.nix` currently exports only `homeManagerModules`. It gains a `packages.<system>.prime-agent` output so the package can be built on its own.

### Known limitation

The `node_modules` output hash depends on what `npm install` resolves. If a floating dependency range or a different npm version changes the tree, the build fails with a hash mismatch. That is a visible failure rather than a silent wrong result, but it does mean rebuilds are not guaranteed to succeed indefinitely without a hash refresh.

## Rollout

Claude Code is ported with no behavior change: the same managed settings, the same destructive-command-guard hook, the same statusline. Codex and Prime Agent are enabled on `eule` only. The other three homes keep Claude Code alone, matching what they run today.

## Acceptance criteria

- `hmrb switch` succeeds on `eule` with all three harnesses enabled, and on at least one other home with Claude Code alone.
- `~/.claude/settings.json` is a real writable file, and a runtime change to `effortLevel` survives a rebuild.
- `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and `~/.prime/agent/AGENTS.md` each contain the shared instruction body followed by their harness-specific section.
- `~/.agents/skills` and `~/.claude/skills` both resolve to the same skills source.
- `~/.codex/config.toml` and `~/.prime/agent/settings.json` are written with the normalized model and reasoning values.
- `prime-agent --version` runs from the store and reports 0.7.0.
- `nix build ./shared#prime-agent` succeeds.
- `shared/claude/` is gone and no flake references `shared.homeManagerModules.claude`.

## Open item for implementation

The accepted values for Claude Code's `effortLevel` are not confirmed beyond the `"med"` currently in `settings.json`. The mapping from the normalized `reasoningEffort` enum needs to be checked against the harness before the lookup table is written.
