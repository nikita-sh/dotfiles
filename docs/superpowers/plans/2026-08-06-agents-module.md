# Multi-harness agents module implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `shared/claude/` with `shared/agents/`, a home-manager module that configures Claude Code and Codex from one shared instruction body, one skills directory, one normalized set of model knobs, and one destructive-command guard.

**Architecture:** `shared/agents/default.nix` declares `my.agents` and imports one module per harness. Each harness module reads its own entry under `my.agents.harnesses.<name>` and renders native configuration. Two helpers in `lib.nix` carry the logic that would otherwise be duplicated: an activation-script merge for settings files the agent rewrites at runtime, and instruction-file concatenation.

**Tech Stack:** Nix, home-manager (`release-25.11`), `nixpkgs-unstable` for Codex, jq for the settings merge.

## Global Constraints

- Read the spec at `docs/superpowers/specs/2026-08-06-agents-module-design.md` before starting. Do not restate it here; this plan is the execution order.
- Never edit files under `~/.claude` or `~/.codex` by hand. They are produced by the module. Edit the repo and rebuild.
- Nix files are formatted with `nixfmt-rfc-style`. Run `nix fmt` or match the surrounding style exactly.
- Claude Code `effortLevel` accepts exactly `low`, `medium`, `high`, `xhigh`.
- Codex must come from `inputs.nixpkgs-unstable`; `release-25.11` has 0.92.0, below the 0.125.0 hook floor and the 0.94.0 skills floor.
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
| `shared/agents/harnesses/claude-code.nix` | Renders `programs.claude-code` plus the managed `settings.json` merge. |
| `shared/agents/harnesses/claude-code/` | `instructions.md`, `agents/`, `statusline-command.sh`, `claude-code-log.nix`. |
| `shared/agents/harnesses/codex.nix` | Renders `programs.codex` plus the `hooks.json` merge. Codex reads the shared skills through the `~/.agents/skills` link `default.nix` creates, so this module says nothing about skills. |
| `shared/agents/harnesses/codex/instructions.md` | Codex-specific instructions. |

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

    # Codex from 0.94 reads this location.
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

- [ ] **Step 6: Confirm both instruction files exist and share a body**

```bash
for f in ~/.claude/CLAUDE.md ~/.codex/AGENTS.md; do
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

- [ ] **Step 8: Confirm both binaries run**

```bash
claude --version
codex --version
```

Expected: Codex reports 0.146.0.

- [ ] **Step 9: Trust the Codex hook**

Start `codex`, run `/hooks`, and trust the dcg entry. Codex silently skips an untrusted user hook, which looks the same as a hook that failed open. No nix rebuild can do this step.

- [ ] **Step 10: Confirm the guard blocks in each harness**

In a throwaway git repository, ask each agent to run `git reset --hard HEAD~1`. Expected: each refuses, the repository is unchanged, and Codex's log shows `hook: PreToolUse Blocked`.

- [ ] **Step 11: Build the other three hosts**

```bash
cd ~/dev/dotfiles
for h in mynah kolibri falke; do
  nix flake update shared --flake ~/dev/dotfiles/homes/$h
  nix eval --raw ~/dev/dotfiles/homes/$h#homeConfigurations."nikita@$h".activationPackage.drvPath \
    && echo "  $h ok"
done
```

Expected: three `ok` lines. Those hosts have only `claude-code` enabled, so Codex should not appear in their closure.

- [ ] **Step 12: Add a Results section to this plan and commit**

Append a `## Results` section recording what changed, where, and how it was verified, then:

```bash
cd ~/dev/dotfiles
git add -A
git commit -m "enable codex harness on eule"
```

---

## Acceptance criteria

- `hmrb switch` succeeds on `eule` with both harnesses enabled, and the other three homes still evaluate.
- `~/.claude/settings.json` is a real writable file and a runtime `effortLevel` change survives a rebuild.
- `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` each contain the shared body followed by their harness-specific section.
- `~/.agents/skills` and `~/.claude/skills` resolve to the same store path.
- `~/.codex/config.toml` is seeded with the normalized model and reasoning values, keeps everything Codex wrote there itself, and `~/.codex/hooks.json` points at the dcg store path.
- A destructive command is denied through both paths.
- `shared/claude/` is gone and no flake references `shared.homeManagerModules.claude`.

## Known risks

Codex's `PreToolUse` does not intercept every `unified_exec` shell path, and in both harnesses the model can write a script to disk and run that. The guard is a guardrail, not an enforcement boundary.

## Results

Prime Agent was dropped from the scope. This plan and the spec were edited to cover Claude Code and Codex only; no Prime Agent package, harness module, or guard extension was written.

`shared/agents/` replaces `shared/claude/`. `default.nix` declares `my.agents` with a shared instruction body, one skills source, one dcg guard, and an `attrsOf` submodule per harness carrying `model`, `reasoningEffort`, `theme`, `extraInstructions`, and raw `settings`. `lib.nix` holds `harnessOptions`, `mapEffort`, `mkInstructions`, and `mkMutableSettings`. `harnesses/claude-code.nix` and `harnesses/codex.nix` translate those into `programs.claude-code` and `programs.codex` plus their activation merges. `eule` enables both harnesses; `mynah`, `kolibri`, and `falke` enable Claude Code alone.

`mkMutableSettings` gained a `format` argument. Codex rewrites `config.toml` at runtime, so a store symlink there would have stranded the plugin registry, marketplace entries, project trust levels, and hook trust hashes already in that file. `programs.codex.settings` is left empty, which suppresses the module's own `config.toml`, and the file is merged in TOML mode instead. The merge converts through JSON with `remarshal`, so comments and key order are not preserved, and it writes the result 0600 to match what Codex creates. Model and reasoning effort are seeded as defaults, so a runtime `/model` change wins over the nix value.

Verified on `eule`: `hmrb switch` activated `claudeSettings`, `codexConfig`, and `codexHooks` without error. Before the switch, a copy of the live `config.toml` was run through the same merge pipeline and compared as normalized JSON against the original, which matched. After the switch, `~/.claude/settings.json` still reads `effortLevel: medium`, `model: opus[1m]`, `theme: dark-ansi`, its managed keys point at store paths, and `~/.codex/config.toml` still carries every runtime section. Both `~/.claude/settings.json` and `~/.codex/hooks.json` now invoke the dcg store path instead of `~/.local/bin/dcg`. `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` both open with the shared body. `~/.agents/skills` and `~/.claude/skills` list the same skills.

Two things could not be verified from a rebuild. The Codex hook must be trusted once through `/hooks`, and rewriting its command to the store path invalidated the trust hash recorded in `config.toml`, so that step is outstanding. And `mynah`, `kolibri`, and `falke` cannot be evaluated from this machine at all: their `flake.lock` files carry a mutable `path:../../shared` input with no `narHash`, which nix refuses to read or update. That predates this branch — the same lock entries are on `main` — and it is unrelated to the agents module.
