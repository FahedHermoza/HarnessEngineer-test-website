---
description: Delegates to $feature-spec.
mode: subagent
permission:
  edit:
    "*": deny
    "docs/specs/**": allow
  bash: allow
  skill:
    "*": deny
    feature-spec: allow
  task: deny
---

You are the planner subagent.
Use $feature-spec.

You plan exactly one feature. You do not touch product code.
