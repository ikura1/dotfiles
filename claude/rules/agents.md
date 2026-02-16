# Agent Orchestration

## Available Agents

### Development Team

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| dev-pm | Requirements analysis, task breakdown | Start of any new feature or project |
| dev-ux-designer | CLI UX design | Before implementation, after requirements |
| dev-architect | Technical architecture design | Before implementation, for structural decisions |
| dev-developer | Code implementation | After design is approved |
| dev-reviewer | Code review | After writing or modifying code |
| dev-tester | Test creation and execution | After implementation; enforces TDD |
| security-reviewer | Security vulnerability analysis | Before commits; whenever handling user input, auth, APIs |

### MAGI Decision System

| Agent | Perspective | When to Use |
|-------|------------|-------------|
| magi-melchior | Technical/Logical (MELCHIOR-1) | Part of MAGI vote — evaluates correctness and efficiency |
| magi-balthasar | Risk/Maintainability (BALTHASAR-2) | Part of MAGI vote — evaluates safety and long-term risks |
| magi-casper | UX/Practical (CASPER-3) | Part of MAGI vote — evaluates user value and usability |

## Immediate Agent Usage

No user prompt needed — use proactively:
1. New feature request → Use **dev-pm** agent
2. Code just written/modified → Use **dev-reviewer** agent
3. New feature implementation → Use **dev-tester** agent (TDD)
4. Architectural decision → Use **dev-architect** agent
5. Any auth/input/API code → Use **security-reviewer** agent

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```
# GOOD: Parallel execution
Launch agents in parallel when tasks are independent:
- Agent 1: Security analysis
- Agent 2: Performance review
- Agent 3: Type checking

# BAD: Sequential when unnecessary
First agent 1, then agent 2, then agent 3
```

## MAGI Voting

For critical decisions (architecture approval, implementation acceptance):
- Run `/magi-vote` with the proposal or file paths
- Requires 2/3 APPROVE to proceed
- On REJECT: incorporate feedback, revise, re-vote
