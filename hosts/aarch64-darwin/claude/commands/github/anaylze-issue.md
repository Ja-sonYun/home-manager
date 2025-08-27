---
description: Analyze GitHub issue and create implementation plan
---

## Context

- Issue: !`gh issue view $ARGUMENTS --json title,body,labels,milestone`
- Related PRs: !`gh pr list --search "is:pr $ARGUMENTS"`

## Analysis Tasks

1. Summarize the issue and its business impact
2. Identify technical requirements and constraints
3. List affected components and dependencies
4. Propose 2-3 solution approaches with trade-offs
5. Recommend the best approach with reasoning
6. Create step-by-step implementation plan
7. Estimate effort and identify risks
