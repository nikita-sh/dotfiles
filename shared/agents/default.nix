{ pkgs, lib, ... }:
let
  claude-code-log = pkgs.python3Packages.callPackage ./claude-code-log.nix { };
  dcg = pkgs.callPackage ./dcg.nix { };

  statusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [
      pkgs.jq
      pkgs.git
    ];
    text = builtins.readFile ./statusline-command.sh;
  };

  optionalDir = dir: if builtins.pathExists dir then dir else null;

  # Policy + store-path keys: nix always wins, refreshed every rebuild.
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
    hooks.PreToolUse = [
      {
        matcher = "Bash";
        hooks = [
          {
            type = "command";
            command = lib.getExe dcg;
          }
        ];
      }
    ];
  };

  # Seeded on first run; Claude may overwrite these at runtime (/effort, /model,
  # /config) and the overwrite survives rebuilds via the activation merge below.
  defaultSettings = {
    model = "claude-opus-5[1m]";
    effortLevel = "med";
    theme = "dark-ansi";
  };

  jsonFmt = pkgs.formats.json { };
  managedJson = jsonFmt.generate "claude-managed.json" managedSettings;
  defaultsJson = jsonFmt.generate "claude-defaults.json" defaultSettings;
in
{
  home.packages = [
    claude-code-log
    dcg # also on PATH for manual testing: `echo '{"tool_name":...}' | dcg`
  ];

  programs.claude-code = {
    enable = true;

    # ~/.claude/CLAUDE.md
    memory.source = ./claude.md;

    # Repo-owned customizations, symlinked into ~/.claude/. Dropping a new
    # skills/<name>/SKILL.md (or agents/commands/hooks file) is all that's
    # needed - no extra wiring.
    skillsDir = ./skills;
    agentsDir = optionalDir ./agents;
    commandsDir = optionalDir ./commands;
    hooksDir = optionalDir ./hooks;

    # settings.json is written by the activation script below, not the module.
    # The module would symlink it into the read-only store, which breaks runtime
    # writes like /effort (Claude writes a .tmp next to the resolved symlink
    # target and renames -> EACCES in /nix/store). Leaving this empty skips the
    # symlink; the activation merge produces a real, writable file instead.
    settings = { };
  };

  # Merge nix-managed keys over Claude's own settings.json on every switch:
  # defaults (seed) < existing runtime values (preserve /effort etc.) <
  # managed keys (always refresh store paths). jq `*` merges objects and
  # replaces arrays, so permissions.allow and hooks come wholesale from managed.
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.claude"
    # Was a store symlink under the old scheme; drop it so we can write a real file.
    [ -L "$HOME/.claude/settings.json" ] && run rm -f "$HOME/.claude/settings.json"
    existing="$(cat "$HOME/.claude/settings.json" 2>/dev/null || echo '{}')"
    printf '%s' "$existing" \
      | ${pkgs.jq}/bin/jq -S \
          --slurpfile d ${defaultsJson} \
          --slurpfile m ${managedJson} \
          '$d[0] * . * $m[0]' > "$HOME/.claude/settings.json.tmp"
    run mv "$HOME/.claude/settings.json.tmp" "$HOME/.claude/settings.json"
  '';
}
