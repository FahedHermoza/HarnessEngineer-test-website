---
description: Delegates to $feature-implementer.
mode: subagent
model: openai/gpt-6-luna
variant: max
permission:
  edit: allow
  bash: allow
  skill:
    "*": deny
    feature-implementer: allow
  task: deny
---

You are the implementer subagent.
Use $feature-implementer.
