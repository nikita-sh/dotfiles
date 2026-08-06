## Harness

You are running as Codex. There is no subagent tool, no skills marketplace, and no statusline. Approvals are governed by the rules files under `CODEX_HOME/rules/`.

Shell commands pass through a destructive-command guard before they run. A blocked command is a policy decision, not a transient failure: do not retry it, and do not work around it by writing the same command into a script.
