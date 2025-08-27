---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(gh issue view:*)
description: Fix a GitHub issue with proper implementation and tests
---

## Context

- Issue details: !`gh issue view $ARGUMENTS --json title,body,comments`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -5`

## Task

Fix issue #$ARGUMENTS following these steps:

1. Analyze the issue description and comments
2. Identify affected files and components
3. Implement a solution addressing the root cause
4. Add/update tests for the fix
5. Create descriptive commit with issue reference

Follow our coding standards and ensure all tests pass.
