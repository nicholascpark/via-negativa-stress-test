# Via Negativa Stress Test

A metacognitive skill that equips an LLM with apophatic perception — the ability to see what's **absent, assumed, and structurally excluded** from any artifact or system.

Most review asks *"is what's here correct?"*
Most debugging asks *"where is the error?"*
This asks *"what's NOT here, and does its absence matter?"*

## Two Modes

**Prophetic** (review / stress test): Nothing is broken yet. What's absent that will become the failure? What's invisible that would change the decision if seen?

**Diagnostic** (debugging / root cause): Something is broken. What structural absence made this class of failure inevitable? What's missing from the system that would make this bug impossible?

## Quick Start

### As a Claude Skill

Drop `SKILL.md` and `references/` into your Claude project or skill directory. Then:

```
# Prophetic mode
stress test this PR
poke holes in this architecture doc
what am I not seeing in this business plan?

# Diagnostic mode
why does this test keep flaking?
what's really going on with this memory leak?
this bug doesn't make sense — what am I missing?
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

Four-layer progressive analysis: **Absence Inventory** → **Load-Bearing Assumptions** → **Frame Exclusions** → **Via Negativa Design**. Default depth includes frame analysis (Layers 1–3) — that's where the differentiating insight lives.

See `SKILL.md` for full methodology.
See `references/` for worked examples (code review, strategy, debugging).

## License

MIT
