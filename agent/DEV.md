## `ADF` - Agent Development Framework

Instructors and agents shape `PROMPT.md` or `DESIGN.md` together. Agents reason
critically, continually challenge complexity, and validate feasibility.

| Level          | Subject     | Definition     | Type         | Instructor op       |
| -------------- | ----------- | -------------- | ------------ | ------------------- |
| `PROMPT.md`    | Idea        | Intent         | Theoretical  | Write, Prompt, Read |
| `DESIGN.md`    | Approach    | Architecture   | Practical    | Prompt, Read        |
| `SPEC.md`      | Requirement | Specification  | Reproducible | Read                |
| `src/`, `lib/` | Source Code | Implementation |              | —                   |

`DESIGN.md` is recommended; `SPEC.md` is optional.

### Delegation

Sub-agents own their work and send no unsolicited updates. The parent must not
micromanage, poll, inspect, or duplicate their work; request and relay reports
only when the user asks.

For example, a voice session manages the conversation while local or remote
sub-agents perform the work.

### Branches

Name new branches `<model>-YYYY-MM-DD`, using the model name and ISO date
when the branch is created; for example, `gpt-6.1-sol-2026-11-11`.

## `RWL` - Recommended Workspace Layout

The `WORK` variable is defined in [DDD 12](SYSTEM.md#ddd-12-the-work-environment-variable).

```text
$WORK/
├── dev/PROJECT/             # Named projects
├── job/YYYY-MM-DD/TASK/     # Work tasks
├── tmp/
│
├── AGENTS.md
├── doc/
├── PLAN.md                  # Todo
├── STATUS.md                # Monitor
└── BACKLOG.md               # Issues
```

Use `dev/` for named projects and dated `job/` directories for ad hoc work.

Other artifacts, such as workspace-unrelated files, go in `tmp/` pending migration.

`PLAN.md` describes goals and the work needed to achieve them.
Agents add items only with explicit instructor approval.
Organize items hierarchically because tasks can depend on other tasks.
Use a Todo section for planned and ongoing work, and a Done section for completed work.

`BACKLOG.md` collects issues to revisit, with enough context to continue later.
Agents add items only with explicit instructor approval.
Use it to defer issues and avoid switching context away from the current task.

`STATUS.md` is the workspace dashboard for agents, task progress, blockers, and
system resources. Workspace management agents update it in real time as events occur.
Use concise sections with keywords and numbers, with a single
second-precision timestamp at the top.
