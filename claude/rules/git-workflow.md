# Git Workflow

## Commit Message Format

```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

## Pull Request Workflow

When creating PRs:
1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch

## Feature Implementation Workflow

1. **Plan First**
   - Use **dev-pm** agent to analyze requirements and create task list
   - Identify dependencies and risks
   - Break down into phases

2. **Design**
   - Use **dev-ux-designer** for CLI/UX design
   - Use **dev-architect** for technical architecture

3. **TDD Approach**
   - Use **dev-tester** agent
   - Write tests first (RED)
   - Implement to pass tests (GREEN)
   - Refactor (IMPROVE)
   - Verify 80%+ coverage

4. **Code Review**
   - Use **dev-reviewer** agent immediately after writing code
   - Address CRITICAL and HIGH issues
   - Fix MEDIUM issues when possible

5. **MAGI Approval**
   - Run `/magi-vote` for critical design/implementation decisions

6. **Commit & Push**
   - Detailed commit messages
   - Follow conventional commits format
