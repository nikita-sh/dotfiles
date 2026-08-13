---
name: explain-diff-html
description: Use when the user asks for a rich explanation of a code change, diff, branch, or PR. Produces HTML output.
---

# Explain Diff

Please make me a rich, interactive explanation of the specified code change.

It should have these sections:

- Recommended review path: A walkthrough ordered for the mechanical act of going through the diff in a review tool. Check what order the host actually presents the files in (GitHub sorts them alphabetically by path), say whether to follow that order or override it, and why — a consumer shown before the module it depends on reads backwards. Then give numbered stops: the file and roughly where in it, what to look at, and what question that stop answers. Say which hunks deserve scrutiny (behaviour changes, duplicated logic, signature changes with callers elsewhere) and which are safe to skim (moved code, unchanged bodies under a new wrapper). If the branch has more than one commit and they are individually coherent, say so and describe what each one does, since reviewing commit-by-commit is often easier than the unified diff.
- Background: Explain the existing system relevant to this change. (You should broadly explore surrounding code for this.) We don't know how much the reader already knows, so include a deep background for beginners (note that it can be skipped if the reader is already familiar), and then a more narrow background directly relevant to the change.
- Intuition: Explain the core intuition for the code change. The focus here is to explain the essence, not the full details. Use concrete examples with toy data. Use figures and diagrams liberally.
- Code: Do a high-level walkthrough of the changes to the code. Group/order the changes in an understandable way.
- Quiz: Come up with five questions that test the reader's knowledge of this PR. This should be medium difficulty, difficult enough that you actually need to understand the substance of the PR to answer them, but not gotchas. The goal is to help the reader make sure that they've actually understood. These should be presented as interactive multiple-choice questions, and when the user clicks, it tells them whether they were correct and gives feedback.

Format:

- Start from `template.html` in this skill's directory. It holds the page chrome — CSS, the table-of-contents shell, section headings, the diagram families, and the quiz-rendering script — none of which changes between explanations. Copy it to the output path and fill in the marked regions in place:

    ```
    cp <skill dir>/template.html /tmp/agent/YYYY-MM-DD-explanation-<slug>.html
    chmod 644 /tmp/agent/YYYY-MM-DD-explanation-<slug>.html
    ```

    The `chmod` matters: the template is a read-only nix store symlink, and the copy inherits that mode, so edits fail without it. Never re-emit the CSS or the quiz script — editing the copy is what makes the template worth having. Reuse the diagram families the template defines rather than inventing new ones; add CSS only for a diagram the change genuinely needs, and put it in the existing `<style>` block. If you find yourself writing the same new diagram a second time on a later change, add it to the template.
- Output a single self-contained HTML file which includes CSS and JavaScript. Make the whole thing one long page with section headers and a table of contents. Don't use tabs for the top-level structure. Basic responsive styling so you can view it on a phone is nice too. Put the file in a global place on my computer outside of the code repo, and make sure the filename always starts with today's date in `YYYY-MM-DD-` format, because it helps keep the files time-sorted and out of version control. For example: /tmp/2026-01-12-explanation-<slug>.html
- Please write with the clarity and flow of Martin Kleppmann, making it engaging and written in classic style. Transitions between sections should be smooth.
- Some tips on diagrams. Ideally, you should pick a small number of diagram families that can be reused throughout the explanation to explain various cases. Some useful kinds of diagrams:
  - A very simplified version of the UI that the user sees in the app, to explain UI changes.
  - A system diagram showing data flow or communication between components. Make sure to include example data here!
- Don't use ASCII diagrams. Always use simple HTML designs for your diagrams, HTML lists for lists of things, etc.
  - For code blocks, always use `<pre>` tags. If you use a custom styled div instead, it **must** have
    `white-space: pre-wrap` in its CSS, or the browser will collapse all newlines into a single line.
    Before saving the file, scan each code block in the HTML source and confirm its CSS includes
    `white-space: pre` or `pre-wrap`.
- Use callouts for key concepts or definitions, important edge cases, etc.
