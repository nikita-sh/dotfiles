export const DcgGuard = async () => {
  const dcg = Bun.which("dcg")
  if (!dcg) throw new Error("dcg is enabled but is not available on PATH")

  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return

      const process = Bun.spawn([dcg], {
        stdin: "pipe",
        stdout: "pipe",
        stderr: "pipe",
        env: { ...Bun.env, DCG_ROBOT: "1" },
      })
      process.stdin.write(
        JSON.stringify({
          tool_name: "Bash",
          tool_input: { command: output.args.command },
        }),
      )
      process.stdin.end()

      const [exitCode, stdout, stderr] = await Promise.all([
        process.exited,
        new Response(process.stdout).text(),
        new Response(process.stderr).text(),
      ])
      if (exitCode !== 0) {
        throw new Error(stderr.trim() || `dcg exited with status ${exitCode}`)
      }

      const line = stdout.trimEnd().split("\n").pop()
      if (!line) return

      const result = JSON.parse(line)
      if (result?.hookSpecificOutput?.permissionDecision === "deny") {
        throw new Error(result.hookSpecificOutput.permissionDecisionReason ?? "blocked by dcg")
      }
    },
  }
}
