## Agent Use

- When spawning subagents, pick the cheapest model and effort level that fits the task — Haiku for mechanical work, Sonnet for routine coding, Opus for hard reasoning. Never spawn a Fable subagent without asking me first (state the intended model and effort). In autonomous runs where I can't be prompted, use Opus instead.

- When running as Fable or Opus, additionally: delegate self-contained work to subagents on a cheaper model. Fable tokens cost 4x Sonnet and 10x Haiku and 2x Opus, and everything read inline (files, tool output) is re-processed on every later turn. So the test is not "is this task small" — it is "will doing this inline pull new content into my context". Reading files, running tests or typechecks, broad searches, mechanical edits, and boilerplate always go to subagents.

    Keep inline only work that meets at least one of: the decision is hard to reverse (schema, API shape, architecture); the output can't be mechanically verified; or the reading is exploratory — you can't yet phrase what you're looking for as a question a subagent could answer. If you can phrase the question ("what props does X take", "how does Y handle Z"), send it to a subagent and use the answer.

    The only other exception: a single edit to a file already fully in context, where nothing new must be read and no command must be run. If the task involves reading a file or running a command, delegation is cheaper — do not reason about whether the prompt "costs more than the task".

    When executing a plan or a task with many pinned steps, split up front: decisions stay inline; every mechanical step goes into subagent batches. Point the subagent at the plan file instead of restating its contents. If a subagent hits something needing judgment, it reports back and the judgment happens inline — that round trip is expected and still cheaper than doing the mechanical work inline.

- The cost-based delegation rules above apply to the top-level Fable/Opus session. When you are working on a task handed to you by another agent, do the core of that task yourself with your own tools. Spawning your own subagents is fine only when it shrinks the work: parallel fan-out over independent pieces, or offloading a self-contained sub-piece that is clearly smaller than your assigned task. Never delegate your entire task onward, and never spawn a subagent on a larger model than your own — if a piece needs more judgment than your model has, report back instead.

- When spawning a subagent, state in its prompt what it should do itself versus what it may further delegate.

---

## Review

Codex, using the latest frontier model of GPT, will be used to review your work
