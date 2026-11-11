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
└── BACKLOG.md               # Issues
```

Use `dev/` for named projects and dated `job/` directories for ad hoc work.

Other artifacts, such as workspace-unrelated files, go in `tmp/` pending migration.
