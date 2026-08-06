# Multi-harness agents module implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `shared/claude/` with `shared/agents/`, a home-manager module that configures Claude Code, Codex, and Prime Agent from one shared instruction body, one skills directory, one normalized set of model knobs, and one destructive-command guard.

**Architecture:** `shared/agents/default.nix` declares `my.agents` and imports one module per harness. Each harness module reads its own entry under `my.agents.harnesses.<name>` and renders native configuration. Two helpers in `lib.nix` carry the logic that would otherwise be duplicated: an activation-script merge for settings files the agent rewrites at runtime, and instruction-file concatenation. Prime Agent is not in nixpkgs, so this also adds a derivation for it.

**Tech Stack:** Nix, home-manager (`release-25.11`), `nixpkgs-unstable` for Codex, Node 22 for Prime Agent, jq for the settings merge.

## Global Constraints

- Read the spec at `docs/superpowers/specs/2026-08-06-agents-module-design.md` before starting. Do not restate it here; this plan is the execution order.
- Never edit files under `~/.claude`, `~/.codex`, or `~/.prime` by hand. They are produced by the module. Edit the repo and rebuild.
- Nix files are formatted with `nixfmt-rfc-style`. Run `nix fmt` or match the surrounding style exactly.
- Claude Code `effortLevel` accepts exactly `low`, `medium`, `high`, `xhigh`.
- Codex must come from `inputs.nixpkgs-unstable`; `release-25.11` has 0.92.0, below the 0.125.0 hook floor and the 0.94.0 skills floor.
- Prime Agent is pinned at version `0.7.0`.
- Comments must explain something not evident from the code, a tradeoff, domain knowledge, or an external constraint. Do not narrate what the code does.
- Commit after every task. Do not push.

## Rebuilding and verifying

`homes/eule/flake.nix` locks `shared` as a path input by narHash, so a change under `shared/` is not picked up until the lock is refreshed. Every verification step in this plan uses this pair:

```bash
nix flake update shared --flake ~/dev/dotfiles/homes/eule
home-manager build --flake ~/dev/dotfiles/homes/eule#nikita@eule
```

`build` produces a `./result` symlink without activating, so generated files can be inspected before anything touches the home directory. Activation-script content lives in `result/activate`. Only the final task runs `hmrb switch`.

Working on `eule` is assumed. For a different host, substitute the hostname in both commands.

---

## File structure

| Path | Responsibility |
|---|---|
| `shared/agents/default.nix` | Declares `my.agents`, imports harness modules, links the shared skills directory, puts the guard binary on `PATH`. |
| `shared/agents/lib.nix` | `harnessOptions`, `mkInstructions`, `mkMutableSettings`, `mapEffort`. No harness knowledge. |
| `shared/agents/instructions.md` | Harness-neutral instruction body. |
| `shared/agents/skills/` | Single skills source. Moved from `shared/claude/skills/`. |
| `shared/agents/guard/dcg.nix` | The dcg derivation. Moved from `shared/claude/dcg.nix`. |
| `shared/agents/guard/prime-agent-extension.ts` | `tool_call` handler that shells out to dcg. |
| `shared/agents/pkgs/prime-agent.nix` | Prime Agent derivation. |
| `shared/agents/harnesses/claude-code.nix` | Renders `programs.claude-code` plus the managed `settings.json` merge. |
| `shared/agents/harnesses/claude-code/` | `instructions.md`, `agents/`, `statusline-command.sh`, `claude-code-log.nix`. |
| `shared/agents/harnesses/codex.nix` | Renders `programs.codex` plus the `hooks.json` merge. Codex reads the shared skills through the `~/.agents/skills` link `default.nix` creates, so this module says nothing about skills. |
| `shared/agents/harnesses/codex/instructions.md` | Codex-specific instructions. |
| `shared/agents/harnesses/prime-agent.nix` | Writes `AGENTS.md`, `settings.json`, and the guard extension. |
| `shared/agents/harnesses/prime-agent/instructions.md` | Prime Agent-specific instructions. |

---

## Task 1: Rename the module and port Claude Code unchanged

Move `shared/claude/` to `shared/agents/` and keep behavior byte-identical. No option interface yet — this task exists so that a later failure can be attributed to the interface rather than to the move.

**Files:**
- Move: `shared/claude/` to `shared/agents/`
- Modify: `shared/flake.nix:44` (the module path list)
- Modify: `homes/eule/flake.nix:90`, `homes/mynah/flake.nix:53`, `homes/kolibri/flake.nix:70`, `homes/falke/flake.nix:72`

- [ ] **Step 1: Record the current generated output as a baseline**

```bash
cd ~/dev/dotfiles
nix flake update shared --flake ~/dev/dotfiles/homes/eule
home-manager build --flake ~/dev/dotfiles/homes/eule#nikita@eule
mkdir -p /tmp/claude
shasum -a 256 result/home-files/.claude/CLAUDE.md > /tmp/claude/agents-baseline.txt
ls result/home-files/.claude/skills >> /tmp/claude/agents-baseline.txt
cat /tmp/claude/agents-baseline.txt
```

Expected: a sha256 for `CLAUDE.md` and a listing of skill directories. Keep this file; Step 6 compares against it.

- [ ] **Step 2: Move the directory**

```bash
cd ~/dev/dotfiles
git mv shared/claude shared/agents
```

- [ ] **Step 3: Update the module export list**

In `shared/flake.nix`, inside `homeManagerModules = transformModulePaths [ ... ]`, replace the `./claude` entry with `./agents`. The list is alphabetical; `./agents` goes first, before `./bat`.

- [ ] **Step 4: Update all four home flakes**

In each of `homes/eule/flake.nix`, `homes/mynah/flake.nix`, `homes/kolibri/flake.nix`, `homes/falke/flake.nix`, replace:

```nix
          (shared.homeManagerModules.claude)
```

with:

```nix
          (shared.homeManagerModules.agents)
```

Each file lists modules alphabetically, so move the line above the `bat` entry.

- [ ] **Step 5: Build**

```bash
cd ~/dev/dotfiles
nix flake update shared --flake ~/dev/dotfiles/homes/eule
home-manager build --flake ~/dev/dotfiles/homes/eule#nikita@eule
```

Expected: build succeeds.

- [ ] **Step 6: Confirm the output is unchanged**

```bash
cd ~/dev/dotfiles
shasum -a 256 result/home-files/.claude/CLAUDE.md
ls result/home-files/.claude/skills
cat /tmp/claude/agents-baseline.txt
```

Expected: the sha256 and the skills listing match the baseline exactly. A move must not change generated content. If the sha differs, the move dropped or reformatted a file — fix before continuing.

- [ ] **Step 7: Confirm the other three hosts still evaluate**

```bash
cd ~/dev/dotfiles
for h in mynah kolibri falke; do
  nix flake update shared --flake ~/dev/dotfiles/homes/$h
  nix eval --raw ~/dev/dotfiles/homes/$h#homeConfigurations."nikita@$h".activationPackage.drvPath \
    && echo "  $h ok"
done
```

Expected: three `ok` lines. This evaluates without building, which is enough to catch a broken import on a host you cannot build from here.

- [ ] **Step 8: Commit**

```bash
cd ~/dev/dotfiles
git add -A
git commit -m "rename shared/claude to shared/agents

Behavior is unchanged; the interface lands in the next commit."
```

---

## Task 2: Add the option interface and put Claude Code on it

**Files:**
- Create: `shared/agents/lib.nix`
- Create: `shared/agents/harnesses/claude-code.nix`
- Rewrite: `shared/agents/default.nix`

**Interfaces:**
- Produces: `my.agents.instructions`, `my.agents.skillsDir`, `my.agents.harnesses.<name>.{enable,model,reasoningEffort,theme,extraInstructions,settings}`.
- Produces `agentsLib`, passed to harness modules via `_module.args`, exposing `harnessOptions`, `mkInstructions`, `mkMutableSettings`, and `mapEffort`.

- [ ] **Step 1: Write `shared/agents/lib.nix`**

```nix
{ lib, pkgs }:
{
  # Options every harness accepts. Each harness module translates these into
  # its own native keys; nothing here is passed through verbatim.
  harnessOptions =
    { name, ... }:
    {
      options = {
        enable = lib.mkEnableOption "the ${name} coding agent";

        model = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Model identifier, in whatever form ${name} expects. Not validated against a catalog.";
        };

        reasoningEffort = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.enum [
              "off"
              "minimal"
              "low"
              "medium"
              "high"
              "xhigh"
            ]
          );
          default = null;
          description = "Normalized reasoning effort. A harness that cannot express the chosen value fails during evaluation.";
        };

        theme = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };

        extraInstructions = lib.mkOption {
          type = lib.types.either lib.types.lines lib.types.path;
          default = "";
          description = "Appended after the shared body and the harness's own instruction file.";
        };

        settings = lib.mkOption {
          type = (pkgs.formats.json { }).type;
          default = { };
          description = "Raw harness-native settings, merged last. Escape hatch for anything the normalized options do not cover.";
        };
      };
    };

  # Translate a normalized reasoningEffort through a harness lookup table.
  # An absent key throws rather than silently dropping the setting.
  mapEffort =
    harness: table: value:
    if value == null then
      null
    else
      table.${value}
        or (throw "my.agents: harness ${harness} cannot express reasoningEffort \"${value}\"");

  mkInstructions =
    name: parts:
    let
      render = part: if lib.isPath part then builtins.readFile part else part;
      rendered = lib.filter (s: s != "") (map render parts);
    in
    pkgs.writeText "${name}-instructions.md" (lib.concatStringsSep "\n\n" rendered);

  # For settings files the agent rewrites at runtime. A store symlink cannot be
  # used: the agent writes a temporary file next to the resolved symlink target
  # and renames it, which fails inside the store. Precedence is
  # defaults < whatever the agent wrote < nix-managed keys. jq `*` merges
  # objects and replaces arrays, so a managed array replaces wholesale.
  mkMutableSettings =
    {
      path,
      defaults ? { },
      managed ? { },
    }:
    let
      jsonFmt = pkgs.formats.json { };
      defaultsJson = jsonFmt.generate "agents-defaults.json" defaults;
      managedJson = jsonFmt.generate "agents-managed.json" managed;
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      target="$HOME/${path}"
      run mkdir -p "$(dirname "$target")"
      # Older generations may have left a store symlink here.
      [ -L "$target" ] && run rm -f "$target"
      existing="$(cat "$target" 2>/dev/null || echo '{}')"
      printf '%s' "$existing" \
        | ${pkgs.jq}/bin/jq -S \
            --slurpfile d ${defaultsJson} \
            --slurpfile m ${managedJson} \
            '$d[0] * . * $m[0]' > "$target.tmp"
      run mv "$target.tmp" "$target"
    '';
}
```

- [ ] **Step 2: Write `shared/agents/harnesses/claude-code.nix`**

This is the existing `default.nix` logic, reading from the option interface. The managed settings, the statusline, and the hook are unchanged from what the module produces today.

```nix
{
  pkgs,
  lib,
  config,
  agentsLib,
  ...
}:
let
  cfg = config.my.agents;
  # `harnesses` is attrsOf, so an unmentioned harness has no attribute at all.
  hcfg = cfg.harnesses.claude-code or null;
  enabled = hcfg != null && hcfg.enable;

  claude-code-log = pkgs.python3Packages.callPackage ./claude-code/claude-code-log.nix { };

  statusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [
      pkgs.jq
      pkgs.git
    ];
    text = builtins.readFile ./claude-code/statusline-command.sh;
  };

  optionalDir = dir: if builtins.pathExists dir then dir else null;

  effort = agentsLib.mapEffort "claude-code" {
    low = "low";
    medium = "medium";
    high = "high";
    xhigh = "xhigh";
  } hcfg.reasoningEffort;

  instructions = agentsLib.mkInstructions "claude-code" [
    cfg.instructions
    ./claude-code/instructions.md
    hcfg.extraInstructions
  ];

  # Policy plus store-path keys: nix always wins, refreshed every rebuild.
  managedSettings = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";
    skipWorkflowUsageWarning = true;
    permissions = {
      defaultMode = "acceptEdits";
      # Bare "Bash" auto-approves every shell command; the dcg PreToolUse hook
      # stays in front as the destructive-command guard (hook denials override
      # permission allows).
      allow = [ "Bash" ];
    };
    statusLine = {
      type = "command";
      command = lib.getExe statusline;
    };
  }
  // lib.optionalAttrs cfg.guard.enable {
    hooks.PreToolUse = [
      {
        matcher = "Bash";
        hooks = [
          {
            type = "command";
            command = lib.getExe cfg.guard.package;
          }
        ];
      }
    ];
  }
  // hcfg.settings;

  # Seeded on first run; Claude may overwrite these at runtime (/effort, /model,
  # /config) and the overwrite survives rebuilds via the activation merge.
  defaultSettings = lib.filterAttrs (_: v: v != null) {
    model = hcfg.model;
    effortLevel = effort;
    theme = hcfg.theme;
  };
in
{
  config = lib.mkIf enabled {
    home.packages = [ claude-code-log ];

    programs.claude-code = {
      enable = true;

      memory.source = instructions;

      # Repo-owned customizations, symlinked into ~/.claude/. Dropping a new
      # skills/<name>/SKILL.md (or agents/commands/hooks file) is all that's
      # needed - no extra wiring.
      skillsDir = cfg.skillsDir;
      agentsDir = optionalDir ./claude-code/agents;
      commandsDir = optionalDir ./claude-code/commands;
      hooksDir = optionalDir ./claude-code/hooks;

      # Written by the activation merge below, not the module, so the file
      # stays writable for runtime settings changes.
      settings = { };
    };

    home.activation.claudeSettings = agentsLib.mkMutableSettings {
      path = ".claude/settings.json";
      defaults = defaultSettings;
      managed = managedSettings;
    };
  };
}
```

- [ ] **Step 3: Rewrite `shared/agents/default.nix`**

```nix
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.agents;
  agentsLib = import ./lib.nix { inherit lib pkgs; };
in
{
  imports = [ ./harnesses/claude-code.nix ];

  options.my.agents = {
    instructions = lib.mkOption {
      type = lib.types.either lib.types.lines lib.types.path;
      default = ./instructions.md;
      description = "Harness-neutral instruction body, rendered into every enabled harness.";
    };

    skillsDir = lib.mkOption {
      type = lib.types.path;
      default = ./skills;
      description = "Single skills source. Every harness reads the same directory.";
    };

    guard = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Wire the destructive-command guard into every enabled harness.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.callPackage ./guard/dcg.nix { };
      };
    };

    harnesses = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule agentsLib.harnessOptions);
      default = { };
    };
  };

  config = {
    # Nested under config, not top level: the module system rejects a bare
    # `_module` attribute in a module that also has an explicit `config` block.
    _module.args.agentsLib = agentsLib;

    # On PATH for manual testing: `echo '{"tool_name":...}' | dcg`
    home.packages = lib.optional cfg.guard.enable cfg.guard.package;
  };
}
```

- [ ] **Step 4: Move the Claude-only assets into place**

```bash
cd ~/dev/dotfiles/shared/agents
mkdir -p harnesses/claude-code guard
git mv agents harnesses/claude-code/agents
git mv statusline-command.sh harnesses/claude-code/statusline-command.sh
git mv claude-code-log.nix harnesses/claude-code/claude-code-log.nix
git mv dcg.nix guard/dcg.nix
git mv claude.md harnesses/claude-code/instructions.md
touch instructions.md
```

`instructions.md` stays empty for now; Task 3 splits content into it. An empty part is filtered out by `mkInstructions`, so the rendered file is identical to today's `claude.md`.

- [ ] **Step 5: Set the options on eule**

In `homes/eule/flake.nix`, in the module block that already sets `my.email` and `my.p10k`, add:

```nix
            my.agents.harnesses.claude-code = {
              enable = true;
              model = "claude-opus-5[1m]";
              reasoningEffort = "medium";
              theme = "dark-ansi";
            };
```

Add the same block to `homes/mynah/flake.nix`, `homes/kolibri/flake.nix`, and `homes/falke/flake.nix`. Those three currently get Claude Code with no host-specific settings, and this keeps that true.

- [ ] **Step 6: Build and confirm the rendered instructions are unchanged**

```bash
cd ~/dev/dotfiles
nix flake update shared --flake ~/dev/dotfiles/homes/eule
home-manager build --flake ~/dev/dotfiles/homes/eule#nikita@eule
shasum -a 256 result/home-files/.claude/CLAUDE.md
cat /tmp/claude/agents-baseline.txt
```

Expected: the sha256 still matches the Task 1 baseline. The interface changed how the file is produced, not what it contains.

- [ ] **Step 7: Confirm the managed settings survived the port**

```bash
cd ~/dev/dotfiles
grep -o 'claude-managed[^ ]*\.json' result/activate | head -1
```

Take the store path that prints and read it:

```bash
cat "$(grep -oE '/nix/store/[a-z0-9]+-agents-managed\.json' result/activate | head -1)" | jq .
```

Expected: `permissions.allow` is `["Bash"]`, `statusLine.command` points at a `claude-statusline` store path, and `hooks.PreToolUse[0].hooks[0].command` points at a `dcg` store path.

- [ ] **Step 8: Confirm the effort mapping throws on an unsupported value**

Temporarily set `reasoningEffort = "minimal";` in `homes/eule/flake.nix`, then:

```bash
cd ~/dev/dotfiles
nix flake update shared --flake ~/dev/dotfiles/homes/eule
home-manager build --flake ~/dev/dotfiles/homes/eule#nikita@eule
```

Expected: evaluation fails with `harness claude-code cannot express reasoningEffort "minimal"`. Set it back to `"medium"` and rebuild to confirm it passes.

- [ ] **Step 9: Commit**

```bash
cd ~/dev/dotfiles
git add -A
git commit -m "add my.agents option interface, port claude code onto it

Shared skills source, instruction concatenation, and the runtime-mutable
settings merge move into lib.nix so a second harness can reuse them."
```

---

## Task 3: Split the instruction body

**Files:**
- Modify: `shared/agents/instructions.md`
- Modify: `shared/agents/harnesses/claude-code/instructions.md`

- [ ] **Step 1: Move the harness-neutral sections**

`harnesses/claude-code/instructions.md` currently holds the whole of the old `claude.md`. Move these sections verbatim into `shared/agents/instructions.md`, keeping their order and their `##` heading levels:

- `## Response Style`
- `## Tool Use`
- `## Investigations & Research`
- `## Writing Documents`
- `## Source Accuracy & Drafting Protocol`
- `## Coding`
- `## Code Comments`
- `## Task Management (File-Based, Auditable)`

Keep the `# AI Agent Guidelines` title at the top of `shared/agents/instructions.md`.

- [ ] **Step 2: Leave the Claude-specific sections behind**

`harnesses/claude-code/instructions.md` keeps only `## Agent Use`, which names Fable, Opus, Sonnet, and Haiku tiers and the Agent tool. Drop its `# AI Agent Guidelines` title, since the shared body supplies one.

Within `## Coding`, the line stating that Codex reviews the work is Claude-specific. Move that `### Review` subsection out of the shared body and into the Claude Code file.

- [ ] **Step 3: Verify nothing was lost**

```bash
cd ~/dev/dotfiles
nix flake update shared --flake ~/dev/dotfiles/homes/eule
home-manager build --flake ~/dev/dotfiles/homes/eule#nikita@eule
diff <(git show HEAD~1:shared/agents/harnesses/claude-code/instructions.md | grep -E '^#{1,3} ' | sort) \
     <(grep -hE '^#{1,3} ' result/home-files/.claude/CLAUDE.md | sort)
```

Expected: no output. Every heading that existed before still appears in the rendered file. Prose changes are caught by review; a missing heading means a section was dropped.

- [ ] **Step 4: Commit**

```bash
cd ~/dev/dotfiles
git add -A
git commit -m "split agent instructions into shared body and claude code section"
```

---

## Task 4: Add the Codex harness

**Files:**
- Create: `shared/agents/harnesses/codex.nix`
- Create: `shared/agents/harnesses/codex/instructions.md`
- Modify: `shared/agents/default.nix` (imports, shared skills link)
- Modify: `homes/eule/flake.nix`

**Interfaces:**
- Consumes: `agentsLib.mkInstructions`, `agentsLib.mkMutableSettings`, `agentsLib.mapEffort`, `cfg.guard.{enable,package}`, `cfg.skillsDir`.

- [ ] **Step 1: Link the shared skills directory**

In `shared/agents/default.nix`, extend `config` so every harness that reads the cross-agent location finds the same source:

```nix
  config = {
    # On PATH for manual testing: `echo '{"tool_name":...}' | dcg`
    home.packages = lib.optional cfg.guard.enable cfg.guard.package;

    # Codex from 0.94 and Prime Agent both read this location.
    home.file.".agents/skills".source = cfg.skillsDir;
  };
```

- [ ] **Step 2: Write `shared/agents/harnesses/codex/instructions.md`**

```markdown
## Harness

You are running as Codex. There is no subagent tool, no skills marketplace, and no statusline. Approvals are governed by the rules files under `CODEX_HOME/rules/`.

Shell commands pass through a destructive-command guard before they run. A blocked command is a policy decision, not a transient failure: do not retry it, and do not work around it by writing the same command into a script.
```

- [ ] **Step 3: Write `shared/agents/harnesses/codex.nix`**

```nix
{
  pkgs,
  lib,
  config,
  inputs,
  agentsLib,
  ...
}:
let
  cfg = config.my.agents;
  # `harnesses` is attrsOf, so an unmentioned harness has no attribute at all.
  hcfg = cfg.harnesses.codex or null;
  enabled = hcfg != null && hcfg.enable;

  # release-25.11 has codex 0.92.0, below the 0.125.0 floor for PreToolUse
  # hooks and the 0.94.0 floor for reading ~/.agents/skills.
  codexPkg = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.codex;

  effort = agentsLib.mapEffort "codex" {
    minimal = "minimal";
    low = "low";
    medium = "medium";
    high = "high";
  } hcfg.reasoningEffort;

  instructions = agentsLib.mkInstructions "codex" [
    cfg.instructions
    ./codex/instructions.md
    hcfg.extraInstructions
  ];
in
{
  config = lib.mkIf enabled {
    programs.codex = {
      enable = true;
      package = codexPkg;

      # The pinned home-manager's codex module has only enable, package,
      # settings, and custom-instructions. custom-instructions is typed as
      # lines and written as text to ~/.codex/AGENTS.md, so it needs the file
      # contents rather than the store path mkInstructions returns.
      custom-instructions = builtins.readFile instructions;

      settings = lib.filterAttrs (_: v: v != null) {
        model = hcfg.model;
        model_reasoning_effort = effort;
      }
      // hcfg.settings;
    };

    # programs.codex manages config.toml and rules, not hooks.json. The file
    # already exists on machines where dcg's own installer ran, so it is merged
    # rather than symlinked: that replaces dcg's path with the store path and
    # leaves unrelated hook entries alone.
    home.activation.codexHooks = lib.mkIf cfg.guard.enable (agentsLib.mkMutableSettings {
      path = ".codex/hooks.json";
      managed = {
        hooks.PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = lib.getExe cfg.guard.package;
              }
            ];
          }
        ];
      };
    });
  };
}
```

- [ ] **Step 4: Import it**

In `shared/agents/default.nix`:

```nix
  imports = [
    ./harnesses/claude-code.nix
    ./harnesses/codex.nix
  ];
```

- [ ] **Step 5: Enable Codex on eule only**

In `homes/eule/flake.nix`, next to the `claude-code` block:

```nix
            my.agents.harnesses.codex = {
              enable = true;
              reasoningEffort = "high";
            };
```

Leave `model` unset so Codex uses its own default.

- [ ] **Step 6: Build and inspect the generated Codex config**

```bash
cd ~/dev/dotfiles
nix flake update shared --flake ~/dev/dotfiles/homes/eule
home-manager build --flake ~/dev/dotfiles/homes/eule#nikita@eule
cat result/home-files/.codex/config.toml
head -20 result/home-files/.codex/AGENTS.md
readlink result/home-files/.agents/skills
```

Expected: `config.toml` contains `model_reasoning_effort = "high"`, `AGENTS.md` opens with the shared `# AI Agent Guidelines` body, and `.agents/skills` resolves to the same store path as `.claude/skills`.

- [ ] **Step 7: Confirm the hooks merge targets the right file**

```bash
cd ~/dev/dotfiles
grep -A3 'codex/hooks.json' result/activate | head -20
```

Expected: the activation script writes `$HOME/.codex/hooks.json` through jq with a managed store path.

- [ ] **Step 8: Verify the Codex deny protocol against the real binary**

```bash
printf '%s\n' \
  '{"session_id":"s","turn_id":"turn-1","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git reset --hard HEAD~1"},"tool_use_id":"call-1"}' \
  | dcg > /tmp/claude/dcg-codex-out.json 2>/tmp/claude/dcg-codex-err.txt
echo "exit=$?"
jq . /tmp/claude/dcg-codex-out.json
```

Expected: exit 0, and stdout is exactly `hookSpecificOutput` with the three keys `hookEventName`, `permissionDecision` set to `deny`, and `permissionDecisionReason`. Any extra key means Codex's strict parser would reject it. Confirm the Claude path still differs by rerunning without `turn_id` and observing a richer JSON body.

- [ ] **Step 9: Commit**

```bash
cd ~/dev/dotfiles
git add -A
git commit -m "add codex harness with shared skills and dcg hook

Codex comes from nixpkgs-unstable; release-25.11 has 0.92.0, below both the
hook and skills floors."
```

---

## Task 5: Package Prime Agent

**Files:**
- Create: `shared/agents/pkgs/prime-agent.nix`
- Modify: `shared/flake.nix` (add a `packages` output)

**Interfaces:**
- Produces: a derivation with `pname = "prime-agent"`, `version = "0.7.0"`, `meta.mainProgram = "prime-agent"`, exposing `$out/bin/prime-agent`.

- [ ] **Step 1: Write the derivation with placeholder hashes**

Both hashes are discovered by building. Start with `lib.fakeHash` in each slot.

```nix
{
  lib,
  stdenvNoCC,
  fetchurl,
  nodejs_22,
  makeWrapper,
  cacert,
  python3,
}:
let
  version = "0.7.0";

  src = fetchurl {
    url = "https://github.com/PrimeIntellect-ai/prime-agent/releases/download/v${version}/prime-agent-${version}.tgz";
    hash = lib.fakeHash;
  };

  # Prime Agent is not on the npm registry and three of its dependencies are
  # referenced by URL, so there is no lockfile to feed buildNpmPackage. The
  # tree is resolved once inside a fixed-output derivation instead.
  nodeModules = stdenvNoCC.mkDerivation {
    pname = "prime-agent-node-modules";
    inherit version src;

    nativeBuildInputs = [
      nodejs_22
      cacert
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      export npm_config_cache=$TMPDIR/npm-cache
      npm install --omit=dev --no-audit --no-fund
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r node_modules $out
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = lib.fakeHash;
  };

  kernelPython = python3.withPackages (ps: [ ps.ipython ]);
in
stdenvNoCC.mkDerivation {
  pname = "prime-agent";
  inherit version src;

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/prime-agent
    cp -r . $out/lib/prime-agent/
    ln -s ${nodeModules} $out/lib/prime-agent/node_modules

    makeWrapper ${lib.getExe nodejs_22} $out/bin/prime-agent \
      --add-flags "$out/lib/prime-agent/dist/bundle/cli.js" \
      --set PI_SKIP_VERSION_CHECK 1 \
      --set PRIME_AGENT_INSTALL_UV 0 \
      --set PRIME_AGENT_KERNEL_PYTHON ${lib.getExe kernelPython}
    runHook postInstall
  '';

  meta = {
    description = "Self-improving RLM coding agent from Prime Intellect";
    homepage = "https://github.com/PrimeIntellect-ai/prime-agent";
    mainProgram = "prime-agent";
    platforms = lib.platforms.unix;
  };
}
```

The wrapper pins three environment variables for external reasons: the CLI would otherwise try to self-update over a read-only store path, provision its own `uv`, and provision its own Python for the IPython kernel.

- [ ] **Step 2: Resolve the source hash**

```bash
cd ~/dev/dotfiles
nix-build --no-out-link -E '(import <nixpkgs> {}).callPackage ./shared/agents/pkgs/prime-agent.nix {}' 2>&1 | grep -A2 'got:'
```

Expected: a `got: sha256-...` line for the tarball. Paste that value over the first `lib.fakeHash`.

- [ ] **Step 3: Resolve the node_modules hash**

Rerun the same command. Expected: a second `got: sha256-...`, this time for `prime-agent-node-modules`. Paste it over the remaining `lib.fakeHash`.

If instead the build fails inside `npm install`, read the error before changing hashes. A missing native toolchain for `zeromq` means its prebuilt binding was not used; that is a real packaging problem, not a hash problem, and it needs `zeromq`'s prebuild path investigated rather than worked around.

- [ ] **Step 4: Build and run it**

```bash
cd ~/dev/dotfiles
nix-build --no-out-link -E '(import <nixpkgs> {}).callPackage ./shared/agents/pkgs/prime-agent.nix {}'
```

Then run the binary from the store path that prints:

```bash
"$(nix-build --no-out-link -E '(import <nixpkgs> {}).callPackage ./shared/agents/pkgs/prime-agent.nix {}')/bin/prime-agent" --version
```

Expected: `0.7.0`.

- [ ] **Step 5: Expose it as a flake package**

In `shared/flake.nix`, add a `packages` output alongside `homeManagerModules`. Add to the `let` block:

```nix
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
```

and to the output set:

```nix
      packages = forAllSystems (pkgs: {
        prime-agent = pkgs.callPackage ./agents/pkgs/prime-agent.nix { };
      });
```

- [ ] **Step 6: Build through the flake**

```bash
cd ~/dev/dotfiles
nix build ./shared#prime-agent
./result/bin/prime-agent --version
```

Expected: `0.7.0`.

- [ ] **Step 7: Commit**

```bash
cd ~/dev/dotfiles
git add -A
git commit -m "package prime-agent 0.7.0

Not on the npm registry and no lockfile, so node_modules resolves inside a
fixed-output derivation."
```

---

## Task 6: Add the Prime Agent harness and its guard extension

**Files:**
- Create: `shared/agents/harnesses/prime-agent.nix`
- Create: `shared/agents/harnesses/prime-agent/instructions.md`
- Create: `shared/agents/guard/prime-agent-extension.ts`
- Modify: `shared/agents/default.nix` (imports)
- Modify: `homes/eule/flake.nix`

**Interfaces:**
- Consumes: the derivation from Task 5, `agentsLib.mkInstructions`, `agentsLib.mkMutableSettings`, `agentsLib.mapEffort`, `cfg.guard.{enable,package}`.

- [ ] **Step 1: Write `shared/agents/guard/prime-agent-extension.ts`**

```ts
import { execFile } from "node:child_process";

// Substituted with the dcg store path at build time.
const DCG = "@dcg@";

type ToolCallEvent = {
  toolName: string;
  input?: { command?: string };
};

export default function (pi: {
  on: (
    event: "tool_call",
    handler: (event: ToolCallEvent) => Promise<{ block: true; reason: string } | undefined>,
  ) => void;
}) {
  pi.on("tool_call", async (event) => {
    if (event.toolName !== "bash") return undefined;

    const command = event.input?.command;
    if (typeof command !== "string" || command === "") return undefined;

    return await new Promise((resolve) => {
      execFile(DCG, ["--robot", "test", command], (error, stdout) => {
        // Exit 0 allows, exit 1 denies, exit 3 and above is a dcg failure.
        // A dcg failure fails open so a broken guard cannot wedge the agent,
        // matching the posture of dcg's other integrations.
        const code = typeof error?.code === "number" ? error.code : 0;
        if (code !== 1) return resolve(undefined);

        let reason = "Destructive command blocked by dcg.";
        try {
          const parsed = JSON.parse(stdout);
          if (typeof parsed.reason === "string") reason = parsed.reason;
        } catch {
          // Denial stands even when the payload is unreadable.
        }
        resolve({ block: true, reason });
      });
    });
  });
}
```

- [ ] **Step 2: Write `shared/agents/harnesses/prime-agent/instructions.md`**

```markdown
## Harness

You are running as Prime Agent. You have a persistent IPython kernel available as a tool; prefer it over one-shot shell invocations for anything stateful.

Shell commands pass through a destructive-command guard before they run. A blocked command is a policy decision, not a transient failure: do not retry it, and do not work around it by writing the same command into a script.
```

- [ ] **Step 3: Write `shared/agents/harnesses/prime-agent.nix`**

```nix
{
  pkgs,
  lib,
  config,
  agentsLib,
  ...
}:
let
  cfg = config.my.agents;
  # `harnesses` is attrsOf, so an unmentioned harness has no attribute at all.
  hcfg = cfg.harnesses.prime-agent or null;
  enabled = hcfg != null && hcfg.enable;

  prime-agent = pkgs.callPackage ../pkgs/prime-agent.nix { };

  effort = agentsLib.mapEffort "prime-agent" {
    off = "off";
    minimal = "minimal";
    low = "low";
    medium = "medium";
    high = "high";
    xhigh = "xhigh";
  } hcfg.reasoningEffort;

  instructions = agentsLib.mkInstructions "prime-agent" [
    cfg.instructions
    ./prime-agent/instructions.md
    hcfg.extraInstructions
  ];

  guardExtension = pkgs.replaceVars ../guard/prime-agent-extension.ts {
    dcg = lib.getExe cfg.guard.package;
  };
in
{
  config = lib.mkIf enabled {
    home.packages = [ prime-agent ];

    home.file.".prime/agent/AGENTS.md".source = instructions;

    home.file.".prime/agent/extensions/dcg.ts" = lib.mkIf cfg.guard.enable {
      source = guardExtension;
    };

    home.activation.primeAgentSettings = agentsLib.mkMutableSettings {
      path = ".prime/agent/settings.json";
      defaults = lib.filterAttrs (_: v: v != null) {
        defaultModel = hcfg.model;
        defaultThinkingLevel = effort;
        theme = hcfg.theme;
      };
      managed = hcfg.settings;
    };
  };
}
```

Model, effort, and theme are seeded rather than managed because Prime Agent rewrites `settings.json` when you use `/settings`, and a managed key would overwrite that on every rebuild. Anything set through `settings` is managed and does win.

- [ ] **Step 4: Import it**

In `shared/agents/default.nix`:

```nix
  imports = [
    ./harnesses/claude-code.nix
    ./harnesses/codex.nix
    ./harnesses/prime-agent.nix
  ];
```

- [ ] **Step 5: Enable it on eule**

In `homes/eule/flake.nix`:

```nix
            my.agents.harnesses.prime-agent = {
              enable = true;
              reasoningEffort = "xhigh";
            };
```

- [ ] **Step 6: Build and inspect**

```bash
cd ~/dev/dotfiles
nix flake update shared --flake ~/dev/dotfiles/homes/eule
home-manager build --flake ~/dev/dotfiles/homes/eule#nikita@eule
head -20 result/home-files/.prime/agent/AGENTS.md
cat result/home-files/.prime/agent/extensions/dcg.ts | head -5
```

Expected: `AGENTS.md` opens with the shared body, and `dcg.ts` has a real `/nix/store/...-dcg-.../bin/dcg` path in place of `@dcg@`.

- [ ] **Step 7: Verify the robot-mode contract the extension depends on**

```bash
dcg --robot test "git status"; echo "allow exit=$?"
dcg --robot test "rm -rf ./src"; echo "deny exit=$?"
```

Expected: exit 0 for the first, exit 1 for the second with JSON on stdout carrying a `reason`. If the deny exit code is not 1, the extension's `code !== 1` check is wrong and must be corrected before continuing.

- [ ] **Step 8: Commit**

```bash
cd ~/dev/dotfiles
git add -A
git commit -m "add prime-agent harness with dcg tool_call extension"
```

---

## Task 7: Activate and verify end to end

**Files:**
- Modify: `shared/agents/harnesses/claude-code/instructions.md` if the switch surfaces anything wrong

- [ ] **Step 1: Capture the current runtime settings**

```bash
jq '{effortLevel, model, theme}' ~/.claude/settings.json | tee /tmp/claude/agents-pre-switch.json
```

- [ ] **Step 2: Switch**

```bash
cd ~/dev/dotfiles
nix flake update shared --flake ~/dev/dotfiles/homes/eule
hmrb switch
```

Expected: activation succeeds.

- [ ] **Step 3: Confirm runtime settings survived**

```bash
jq '{effortLevel, model, theme}' ~/.claude/settings.json
cat /tmp/claude/agents-pre-switch.json
```

Expected: identical. The merge preserves values Claude wrote itself.

- [ ] **Step 4: Confirm the managed keys refreshed**

```bash
jq '.permissions, .statusLine, .hooks.PreToolUse[0].hooks[0].command' ~/.claude/settings.json
```

Expected: `permissions.allow` is `["Bash"]`, and both the statusline and hook commands are `/nix/store/...` paths, not `~/.local/bin` paths.

- [ ] **Step 5: Confirm the Codex hook was rewritten to the store path**

```bash
jq '.hooks.PreToolUse[0].hooks[0].command' ~/.codex/hooks.json
```

Expected: a `/nix/store/...` dcg path, replacing the previous `/Users/nikita/.local/bin/dcg`.

- [ ] **Step 6: Confirm all three instruction files exist and share a body**

```bash
for f in ~/.claude/CLAUDE.md ~/.codex/AGENTS.md ~/.prime/agent/AGENTS.md; do
  echo "== $f"; head -3 "$f"; echo "   sections: $(grep -c '^## ' "$f")"
done
```

Expected: each opens with `# AI Agent Guidelines`, and each has the shared sections plus its own.

- [ ] **Step 7: Confirm the skills directories agree**

```bash
readlink -f ~/.agents/skills
readlink -f ~/.claude/skills
ls ~/.agents/skills
```

Expected: the two paths are identical and the listing shows the skill directories.

- [ ] **Step 8: Confirm all three binaries run**

```bash
claude --version
codex --version
prime-agent --version
```

Expected: Codex reports 0.146.0 and Prime Agent reports 0.7.0.

- [ ] **Step 9: Trust the Codex hook**

Start `codex`, run `/hooks`, and trust the dcg entry. Codex silently skips an untrusted user hook, which looks the same as a hook that failed open. No nix rebuild can do this step.

- [ ] **Step 10: Confirm the guard blocks in each harness**

In a throwaway git repository, ask each of the three agents to run `git reset --hard HEAD~1`. Expected: each refuses, the repository is unchanged, and Codex's log shows `hook: PreToolUse Blocked`.

- [ ] **Step 11: Build the other three hosts**

```bash
cd ~/dev/dotfiles
for h in mynah kolibri falke; do
  nix flake update shared --flake ~/dev/dotfiles/homes/$h
  nix eval --raw ~/dev/dotfiles/homes/$h#homeConfigurations."nikita@$h".activationPackage.drvPath \
    && echo "  $h ok"
done
```

Expected: three `ok` lines. Those hosts have only `claude-code` enabled, so neither Codex nor Prime Agent should appear in their closure.

- [ ] **Step 12: Add a Results section to this plan and commit**

Append a `## Results` section recording what changed, where, and how it was verified, then:

```bash
cd ~/dev/dotfiles
git add -A
git commit -m "enable codex and prime-agent harnesses on eule"
```

---

## Acceptance criteria

- `hmrb switch` succeeds on `eule` with all three harnesses enabled, and the other three homes still evaluate.
- `~/.claude/settings.json` is a real writable file and a runtime `effortLevel` change survives a rebuild.
- `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and `~/.prime/agent/AGENTS.md` each contain the shared body followed by their harness-specific section.
- `~/.agents/skills` and `~/.claude/skills` resolve to the same store path.
- `~/.codex/config.toml` carries the normalized model and reasoning values, and `~/.codex/hooks.json` points at the dcg store path.
- `~/.prime/agent/settings.json` is seeded and `~/.prime/agent/extensions/dcg.ts` has the dcg store path baked in.
- A destructive command is denied through all three paths.
- `prime-agent --version` reports 0.7.0 and `nix build ./shared#prime-agent` succeeds.
- `shared/claude/` is gone and no flake references `shared.homeManagerModules.claude`.

## Known risks

The `node_modules` fixed-output hash depends on what `npm install` resolves. A floating dependency range or a different npm version changes the tree and the build fails with a hash mismatch. That is a visible failure, not a silent wrong result, but it means a rebuild months from now may need a hash refresh.

Codex's `PreToolUse` does not intercept every `unified_exec` shell path, and in all three harnesses the model can write a script to disk and run that. The guard is a guardrail, not an enforcement boundary.
