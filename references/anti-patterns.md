# Anti-Patterns: What Bad Via Negativa Output Looks Like

These are failure modes of the skill itself. Study them so you can recognize
when you're producing noise instead of insight. If your output resembles any
of these, stop and recalibrate.

---

## 1. The Performative Critique

**What it looks like**: Manufacturing findings for an artifact that's actually solid.

> **Bad**: "This PR lacks a distributed tracing strategy, has no chaos
> engineering plan, and doesn't address multi-region failover."
>
> (The PR adds a 20-line utility function to a single-region internal tool.)

**Why it fails**: The findings are technically "absences" but they fail the
Relevance Gate on all three criteria. They're not proximate, not consequential
for this artifact, and the creator intentionally didn't address them because
they're irrelevant.

**The fix**: If the Relevance Gate filters out most candidates, say so: "This
artifact is well-considered. I don't see significant absences." That's a valid,
valuable output. Silence is better than noise.

---

## 2. The Obvious Finding in Fancy Clothes

**What it looks like**: Restating something any competent reviewer would catch,
but wrapping it in via negativa language to make it sound deeper.

> **Bad**: "The structural absence that makes this system fragile is the lack
> of input validation on the user-facing endpoint — a missing boundary that
> exposes the system to injection attacks."
>
> (This is just "add input validation." Every code reviewer checks for this.)

**Why it fails**: It fails the non-obvious criterion. The finding is correct
but the creator almost certainly knows about it or would catch it in standard
review. Dressing it up in "structural absence" language doesn't make it an
insight.

**The fix**: If a finding is standard review territory, either skip it or be
honest: "This is a straightforward review finding, not a structural insight,
but it's worth flagging for completeness."

---

## 3. The Tautological Frame Analysis

**What it looks like**: Layer 3 "identifying" a frame that's so obvious it
provides no information.

> **Bad**: "The frame of this PR is that it's an incremental code change.
> This frame illuminates: what changed. It structurally excludes: everything
> that didn't change. An alternative frame would be to consider the entire
> system holistically."

**Why it fails**: Every PR is an incremental change. Saying so is true and
useless. The frame analysis adds nothing the creator didn't already know.

**The fix**: Layer 3 should identify a *specific* frame mismatch — where the
artifact's paradigm conflicts with its context. "This PR adds synchronous
coupling to a system migrating toward async" is a frame finding. "This PR
is incremental" is not. If you can't find a real frame mismatch, skip Layer 3
and say so.

---

## 4. The Infinite Regression

**What it looks like**: Findings that could apply to literally any artifact.

> **Bad**: "This architecture document doesn't address what happens if the
> company's strategic priorities change." / "This PR doesn't account for
> the possibility that the programming language itself becomes obsolete."

**Why it fails**: These are true of everything. They're not findings — they're
philosophical observations. They fail the consequential criterion because you
can't name a specific, plausible scenario.

**The fix**: Every finding must connect to a specific, plausible failure
scenario you can describe in one sentence. "If X happens, then Y breaks"
where X is realistic and Y is concrete.

---

## 5. The Inherited Assumption Dump

**What it looks like**: Surfacing every assumption the system makes, including
stable, well-known ones unaffected by the change.

> **Bad** (for a PR adding a new API endpoint): "This assumes a relational
> database. This assumes HTTP as the transport protocol. This assumes the
> team will continue using TypeScript. This assumes cloud hosting."

**Why it fails**: These are inherited assumptions that are stable, well-known,
and unaffected by the change. Listing them is noise. Layer 2 for embedded
artifacts should only surface inherited assumptions that are *newly fragile*
because of this change.

**The fix**: Ask "does this change make any existing assumption more fragile
than it was before?" If no, don't surface the assumption.

---

## 6. The Forced Layer 3

**What it looks like**: Generating a frame analysis when the frame is
appropriate and there's no mismatch to find.

> **Bad**: "The frame is REST. REST excludes event-driven patterns.
> Consider whether event-driven would be better."
>
> (The system is a simple CRUD app with no real-time requirements.)

**Why it fails**: Not every artifact has a frame problem. REST is the right
frame for a CRUD app. Suggesting alternatives for the sake of completing
Layer 3 is the skill at its worst — it's performing insight rather than
producing it.

**The fix**: "The framing is appropriate for the problem. No frame mismatch
detected." Say it and move on.

---

## 7. The Laundry List

**What it looks like**: 15+ findings of varying quality, presented without
prioritization.

**Why it fails**: The skill's value is in the Relevance Gate, not in
exhaustive enumeration. A list of 15 findings signals that you haven't
filtered. The creator will skim, miss the 2 findings that actually matter,
and dismiss the whole analysis.

**The fix**: 3-7 findings per layer, ruthlessly filtered. If you have more,
you haven't been honest about which ones actually pass the gate.

---

## The Meta-Pattern

All seven anti-patterns share a root cause: **prioritizing completeness over
signal.** The skill's value is not in finding everything that's absent — it's
in finding the *few things* whose absence actually matters. When in doubt,
cut the finding. A short list where every item changes the creator's thinking
is worth infinitely more than a long list that gets ignored.
