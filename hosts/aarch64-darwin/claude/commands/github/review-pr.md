---
description: Comprehensive code review for a pull request
---

## PR Information

- Checkout PR: !`gh pr checkouth $ARGUMENTS`
- PR Details: !`gh pr view $ARGUMENTS --json number,title,body,author,state,labels,milestone`
- Changed Files: !`gh pr diff $ARGUMENTS --name-only`
- Diff Stats: !`gh pr diff $ARGUMENTS --patch`
- PR Checks: !`gh pr checks $ARGUMENTS`
- Existing Reviews: !`gh pr view $ARGUMENTS --json reviews --jq '.reviews[:3]'`

## Review Tasks

Perform a comprehensive code review for PR #$ARGUMENTS:

### 1. Code Quality

- **Style & Conventions**: Check adherence to project coding standards
- **Naming**: Evaluate variable, function, and class names for clarity
- **Documentation**: Verify comments and docstrings are present and helpful
- **DRY Principle**: Identify code duplication or repetition

### 2. Logic & Functionality

- **Correctness**: Verify the implementation matches the PR description
- **Edge Cases**: Identify unhandled edge cases or error conditions
- **Performance**: Flag potential performance bottlenecks
- **Security**: Check for security vulnerabilities (injection, XSS, etc.)

### 3. Testing

- **Test Coverage**: Verify tests are added for new functionality
- **Test Quality**: Assess if tests are meaningful and comprehensive
- **Edge Case Testing**: Check if edge cases are tested

### 4. Architecture

- **Design Patterns**: Evaluate if appropriate patterns are used
- **Separation of Concerns**: Check for proper code organization
- **Dependencies**: Review new dependencies for necessity and security

### 5. Review Summary

Provide:

1. **Overall Assessment**: Brief summary of the PR quality
2. **Must Fix**: Critical issues that block approval
3. **Should Fix**: Important improvements recommended
4. **Consider**: Optional suggestions for enhancement
5. **Positive Feedback**: What was done well

Format feedback constructively and suggest specific improvements, in Korean.
