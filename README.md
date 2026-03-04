# Via Negativa Stress Test

A via negativa analysis framework and toolset for reviewing any artifact — code, PRs, designs, strategies, or ideas — by surfacing what's **absent, assumed, or excluded**.

Most review asks *"is what's here correct?"* This asks *"what's NOT here, and does its absence matter?"*

## Quick Start

### As a Claude Skill

Drop `SKILL.md` and `references/` into your Claude project or skill directory. Then:

```
stress test this PR
poke holes in this architecture doc
what am I not seeing in this business plan?
```

### Investigation Scripts (for PRs and code)

```bash
./scripts/run-all.sh --base main              # full investigation
./scripts/blast-radius.sh --base main         # blast-radius only
./scripts/co-change-gaps.sh --base main       # co-change only
```

**Requirements**: bash, git, grep, bc. No external dependencies.

## Scripts

| Script | Answers |
|--------|---------|
| `blast-radius.sh` | Who is affected by this change that the diff doesn't show? |
| `co-change-gaps.sh` | What files usually change alongside this but weren't changed? |
| `churn-report.sh` | Is this a fragile area that keeps getting patched? |
| `abandoned-approaches.sh` | What did previous engineers try and abandon here? |
| `trajectory.sh` | Is this the Nth PR adding complexity without refactoring? |
| `run-all.sh` | Run all of the above. |

## The Skill

Four-layer progressive analysis: Absence Inventory → Load-Bearing Assumptions → Frame Exclusions → Via Negativa Design. See `SKILL.md` for full details.

## License

MIT
