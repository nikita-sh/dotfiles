# Multi-harness agents module

Replaces `shared/claude/` with `shared/agents/`, a home-manager module that configures several coding-agent CLIs from one shared source. The first pass covers Claude Code (Anthropic), Codex (OpenAI), and Prime Agent. Prime Agent is not in nixpkgs, so this also adds a package for it.

## Motivation

`shared/claude/` hard-codes everything about one harness: the instruction file, the skills directory, the settings schema, and the activation script that merges nix-managed keys into a runtime-mutable `settings.json`. Adding a second harness by copying that file would duplicate the instruction content, the skills source, and the settings-merge logic. The module needs an interface that a new harness plugs into.

## Scope of abstraction

The shared layer owns instruction text, the skills source, normalized model knobs, and the destructive-command guard. It does not own approval policy. Auto-approval settings differ enough between harnesses that a normalized option would hide which harness actually approves what, so those stay in each harness's raw settings.

The guard is shared because dcg supports all three harnesses directly. The rendering differs per harness, but the decision being enforced is the same binary and the same rule set, so a single `guard.enable` is honest rather than lossy.

## Capability differences

| | Claude Code | Codex | Prime Agent |
|---|---|---|---|
| global instructions | `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` | `~/.prime/agent/AGENTS.md` |
| skills | `~/.claude/skills` | `~/.agents/skills` | `~/.prime/agent/skills` and `~/.agents/skills` |
| settings file | `settings.json`, rewritten by the CLI at runtime | `config.toml`, static | `~/.prime/agent/settings.json`, rewritten by the CLI at runtime |
| model key | `model` | `model` | `defaultModel` |
| reasoning key | `effortLevel` | `model_reasoning_effort` | `defaultThinkingLevel` |
| dcg guard mechanism | `PreToolUse` hook in `settings.json` | `PreToolUse` hook in `~/.codex/hooks.json` | TypeScript extension in `~/.prime/agent/extensions/` |
| statusline, subagent definitions | yes | no | no |

All three implement the Agent Skills standard, so a single skills directory serves all of them.

Prime Agent is a distribution of `earendil-works/pi`; its dependencies are `@earendil-works/pi-core`, `pi-ai`, and `pi-tui`. That matters because dcg documents a Pi integration, which is what makes the guard reachable on the third harness.

Claude Code and Codex have upstream home-manager modules (`programs.claude-code`, `programs.codex`). Prime Agent has none, so its files are written directly.

The pinned home-manager's `programs.codex` is narrower than the current one on that project's main branch: it offers `enable`, `package`, `settings`, and `custom-instructions`, and nothing for skills or rules. Codex still finds the shared skills, because it reads `~/.agents/skills` on its own and the module links that path independently of `programs.codex`.

## Directory layout

```
shared/agents/
  default.nix                    option declarations, dispatch to enabled harnesses
  lib.nix                        mkMutableSettings, mkInstructions
  instructions.md                harness-neutral instruction body
  skills/                        single skills source for all harnesses
  guard/
    dcg.nix                      the dcg binary, shared by every harness
    prime-agent-extension.ts     tool_call handler that shells out to dcg
  pkgs/prime-agent.nix
  harnesses/
    claude-code.nix
    claude-code/
      instructions.md
      agents/                    reader.md, verifier.md
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
  guard.enable = true;

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

Alongside `harnesses` sits `guard`:

| Option | Type | Meaning |
|---|---|---|
| `guard.enable` | bool | Wire the destructive-command guard into every enabled harness. |
| `guard.package` | package | Defaults to the dcg derivation in `guard/dcg.nix`. |

The guard applies uniformly to whichever harnesses are enabled. There is no per-harness opt-out until something needs one.

## Shared helpers

`mkMutableSettings { path, defaults, managed }` generates the activation-script merge that `shared/claude/default.nix` currently performs inline: seed defaults, preserve whatever the CLI wrote at runtime, then overwrite the nix-managed keys. The merge is `jq -S '$defaults * . * $managed'`, which merges objects and replaces arrays. A store symlink cannot be used for these files because the CLI writes a temporary file next to the resolved symlink target and renames it, which fails inside the store. Claude Code and Prime Agent both need this for their `settings.json`. Codex's `config.toml` is static and does not, but its `hooks.json` is written through the same helper so that hook entries from other sources survive.

`mkInstructions harness` concatenates the shared instruction body, the harness's own `instructions.md`, and its `extraInstructions` into one store path, used as `CLAUDE.md` or `AGENTS.md`.

Skills need no helper. The single `shared/agents/skills` source is linked to `~/.agents/skills`, which Codex from 0.94 and Prime Agent both read, and is passed to `programs.claude-code.skillsDir`.

## Destructive-command guard

One dcg derivation is built and placed on `PATH` once. Each harness wires it in the way that harness supports.

**Claude Code** keeps what it has today: a `PreToolUse` hook with a `Bash` matcher in the managed half of `settings.json`, invoking the dcg store path.

**Codex** gets a `PreToolUse` hook with a `Bash` matcher in `~/.codex/hooks.json`. dcg treats Codex as a first-class target from Codex 0.125.0. The pinned `release-25.11` nixpkgs has Codex 0.92.0, which is below that floor and also below the 0.94.0 needed for `~/.agents/skills`, so Codex is taken from the `nixpkgs-unstable` input that `shared/flake.nix` already declares, where it is 0.146.0. Codex's hook input resembles Claude Code's but its parser rejects unknown fields, so dcg identifies Codex payloads by the non-empty `turn_id` field and emits only Codex's documented denial fields. The home-manager `programs.codex` module manages `config.toml` and `rules` but not `hooks.json`, so that file is written by this module using `mkMutableSettings` rather than a store symlink, which leaves any hook entries Codex or another installer added in place.

**Prime Agent** gets a generated `~/.prime/agent/extensions/dcg.ts`, following dcg's published Pi recipe. The extension registers a `tool_call` handler, which runs before the tool executes and denies by returning `{ block: true, reason }`. It shells out to `dcg --robot test "<command>"`, where exit 0 means allow, exit 1 means deny with a JSON payload carrying the reason, and exit 3 or above means dcg itself failed. A dcg failure fails open, matching the posture of dcg's other integrations, so a broken install cannot wedge the agent. The extension is a static store symlink with the dcg store path baked in, since nothing writes to it at runtime.

### Guard caveats

Codex requires opening its `/hooks` interface once to trust the hook, which is a manual step no nix rebuild can perform. Codex's `PreToolUse` also does not intercept every `unified_exec` shell path, and in all three harnesses the model can still write a script to disk and run that. The guard is a guardrail, not an enforcement boundary.

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
- `~/.codex/hooks.json` contains the dcg `PreToolUse` hook, and `~/.prime/agent/extensions/dcg.ts` exists with the dcg store path baked in.
- A destructive command is denied through each path: piping a Claude-shaped payload to `dcg` returns a deny decision, piping a Codex-shaped payload with a non-empty `turn_id` returns Codex's documented deny fields, and `dcg --robot test "<destructive command>"` exits 1.
- `prime-agent --version` runs from the store and reports 0.7.0.
- `nix build ./shared#prime-agent` succeeds.
- `shared/claude/` is gone and no flake references `shared.homeManagerModules.claude`.

## Open item for implementation

Both items are settled.

Claude Code's `effortLevel` accepts `low`, `medium`, `high`, and `xhigh`. The `"med"` currently seeded in `shared/claude/default.nix` is not a valid value; the live `settings.json` reads `"medium"` because Claude rewrote it at runtime. The normalized `off` and `minimal` have no Claude Code equivalent and throw during evaluation.

The Codex hook entry is byte-identical to the Claude Code one: an object with a `Bash` matcher wrapping a `command` hook. The `codex_hooks` feature has been default-enabled since 0.125.0, so no flag is needed. `~/.codex/hooks.json` already exists on `eule` with a hook pointing at a non-nix dcg under `~/.local/bin`, which the managed merge replaces with the store path.
