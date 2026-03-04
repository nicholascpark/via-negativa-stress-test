---
name: via-negativa-stress-test
description: >
  Apply rigorous via negativa analysis to ANY artifact — code, pull requests, git branches,
  entire codebases, subdirectories, images, UI screenshots, emails, datasets, configs,
  strategies, documents, architectures, processes, conversations, or ideas. Use this skill
  whenever the user asks to "stress test", "poke holes in", "find what's missing", "challenge
  assumptions", "red team", "devil's advocate", "what am I not seeing", "what could go wrong",
  or any request to critically examine an artifact by surfacing what is absent, assumed, or
  excluded. Also trigger when the user mentions "via negativa", or "negative space
  analysis". Truly target-agnostic: if something exists, this skill can analyze what's missing
  from it.
---

# Via Negativa Stress Test

## Core Principle

Most review asks: **"Is what's here correct?"**
This skill asks: **"What's NOT here, and does its absence matter?"**

Every artifact is shaped as much by what it omits as by what it contains.
Omissions are where real risk hides — they're invisible to the creator because
they sit outside the frame that produced the artifact.

## Where This Skill Delivers (read this first)

This skill provides different kinds of value depending on the artifact type.
Be honest about which kind you're delivering.

**Revelation value** — findings the creator structurally could not have seen:
Best on: strategy docs, architecture proposals, business plans, early-stage
ideas, design docs. These are artifacts where the creator is often also the
only reviewer, the framing choices are genuinely the creator's own, and
Layer 3 frame analysis can surface blindspots that no amount of rigor within
the original frame would reveal.

**Investigation value** — prompting the reviewer to gather context they
wouldn't have gathered, producing findings that live in the relationship
between the artifact and its surroundings:
Best on: PRs, config changes, component-level code, email replies — any
embedded artifact. The skill's value here is not in analyzing the diff
harder but in directing attention outward to the system the diff touches.
The oh-shit moment for a PR is almost never inside the diff. It's in
what the diff does to the system around it that nobody checked.

**Articulation value** — giving precise structural language to gut feelings
the reviewer already has, making vague unease actionable:
Good on: everything. A senior engineer who feels "something is off" about
a PR but can't articulate why benefits from the skill translating that
intuition into a structural claim that can block a bad merge. "I don't
love this" gets ignored in a PR comment. "This PR silently introduces a
system-level auth contract that three other PRs are building incompatible
assumptions against" changes the outcome.

**Consistency value** — ensuring rigor on every review, not just the
reviewer's best day on the module they know best:
Good on: everything, especially at scale. Senior reviewers have off days.
The skill doesn't replace expertise; it prevents expertise from being
unevenly applied.

Do not oversell. If you're providing consistency value, don't frame it as
revelation. If a finding is something a competent senior reviewer would
catch on a good day, say so — and then say why it's still worth flagging.

## How It Works: Progressive Disclosure

The skill operates in **four layers**, each deeper than the last. By default,
run Layers 1–2. Go to Layer 3 when stakes are high. Layer 4 is generative
and optional — use it when the user wants constructive output, not just critique.

The user can request a specific depth:
- "Quick check" → Layer 1 only
- "Stress test" → Layers 1–2 (default)
- "Deep analysis" → Layers 1–3
- "Full via negativa" → All four layers

---

## Step 0: Intake — Identify and Acquire the Artifact

Before any analysis, determine WHAT you're looking at and HOW to look at it.
Different artifact types require different acquisition strategies.

### Acquisition strategies by input type:

**Text already in context** (pasted code, message, idea described verbally):
→ Proceed directly. No acquisition needed.

**File attachment** (image, PDF, doc, spreadsheet):
→ View/read the file. For images, perform visual analysis — describe what
  you see AND what you notice is absent from the visual.

**Code file or diff** (single file, PR, patch):
→ Read the full content. Note file boundaries and what's touched vs untouched.

**Directory or subdirectory** (codebase, project folder):
→ First: `view` the directory tree to understand structure and boundaries.
→ Then: read key files (READMEs, configs, entry points, tests).
→ The structure itself is an artifact — analyze what the organization reveals and conceals.

**Git branch** (branch name, commit history, branch topology):
→ Examine commit log, diff against base branch, and branch naming/structure.
→ The commit narrative is an artifact — what story does the sequence tell,
  and what changes are suspiciously absent from that story?

**Email or message thread**:
→ Read full thread. The artifact includes: what's said, what's NOT said,
  who's included, who's NOT included, what's explicit vs implicit.

**URL or external resource**:
→ Fetch and read. Treat the page/doc as the artifact.

**Verbal idea or plan** (described in conversation, no artifact):
→ The conversation IS the artifact. Analyze what the person said
  and what they haven't said. Ask clarifying questions if needed
  before running layers — but note what you had to ask about as
  Layer 1 findings, because those gaps exist in the idea itself.

---

## Step 0.5: Context Acquisition (for embedded artifacts)

Some artifacts are self-contained (an essay, a business plan, a design doc).
Others are **embedded** — they only have meaning relative to the system they
live inside. PRs, config changes, individual commits, email replies, slide
edits, hotfixes, and migrations are all embedded artifacts.

**For embedded artifacts, the analysis target is not the artifact itself —
it's the artifact's effect on its host system.**

Before running Layers 1–4, actively investigate the context. Don't just
reason about it — use available tools to gather information. The highest-value
findings for embedded artifacts come from this investigation, not from
analyzing the artifact in isolation.

### For PRs / code diffs:

Use the investigation scripts in `scripts/` to gather context. If scripts
aren't available, perform these steps manually with git commands.

1. **Blast radius** → `scripts/blast-radius.sh`
   Find all files that import/call/reference modified interfaces.
   These are files affected by your change that the diff doesn't show.

2. **Churn report** → `scripts/churn-report.sh`
   Check change frequency and author count on modified files.
   High churn = fragile area. Is this PR adding complexity to an
   already-fragile surface?

3. **Abandoned approaches** → `scripts/abandoned-approaches.sh`
   Search git history for reverts and WIP commits on these files.
   Surfaces failed attempts the PR description doesn't mention — context
   the next engineer would otherwise rediscover the hard way.

4. **Complexity trajectory** → `scripts/trajectory.sh`
   Track file size growth over time. Detects complexity creep — files
   that keep growing commit after commit without refactoring.

5. **Co-change gaps** → `scripts/co-change-gaps.sh`
   **Highest-value investigation.** Find files that historically change
   in the same commits as the PR's files but are missing from this PR.
   Co-change violations are invisible to reasoning — you need the history.

6. If accessible, check roadmap/tickets for what's planned in this area.
   The canonical finding: a PR that solves today's problem while silently
   foreclosing next quarter's approach.

Run all at once: `scripts/run-all.sh --base <branch>`
5. If accessible, check roadmap/tickets for what's planned in this area.
   The canonical embedded-artifact finding: a PR that solves today's problem
   while silently foreclosing next quarter's approach.

**To run all investigations at once:** `scripts/run-all.sh [base-branch]`

### For config / infrastructure changes:
1. Map what services or systems consume this config.
2. Check for environment-specific drift (dev/staging/prod differences).
3. Identify the blast radius — what breaks if this value is wrong?

### For emails / messages in a thread:
1. Read the full thread, not just the latest message.
2. Note who's on the thread and who's been dropped or is conspicuously absent.
3. Track what was asked vs what was actually answered — the delta is the finding.

### For components within a larger architecture:
1. Map the component's dependencies and dependents.
2. Identify the contracts (explicit and implicit) this component must honor.
3. Check for other components that overlap in responsibility.

### Shifting the analysis target

Once context is acquired, reframe each layer's question for embedded artifacts:

- **Layer 1** becomes: "What's missing from the artifact's *effect on the system*?"
  not just "What's missing from the artifact?"
- **Layer 2** becomes: "What assumptions does the artifact *inherit* from its
  environment, and are any of them *newly fragile* because of this change?"
  (Distinguish inherited assumptions from chosen ones — see Layer 2.)
- **Layer 3** becomes: "Does the artifact's framing match the system's framing,
  and if not, is that a feature or a bug?"

**The key question for all embedded artifacts:**
> "What does this change make true about the host system that wasn't true before,
> and did anyone explicitly decide that should be true?"

If the answer is "no one decided that," you've found an assumption that was
introduced silently. These are the highest-value findings for embedded artifacts.

---

## Layer 1: Absence Inventory

**Question: "What is not here that could be?"**

This is the most concrete layer. Scan the artifact for missing elements
that a competent practitioner would expect to find.

### Universal method (works on ANY artifact):

Rather than relying on domain checklists, derive the absence categories
from the artifact itself using these five universal probes:

1. **The failure probe**: "What happens when this fails, breaks, or is wrong?"
   → Look for: missing error handling, no rollback path, no failure criteria,
     no plan B, no acknowledgment that failure is possible.

2. **The boundary probe**: "Where are the edges of this, and what's on the other side?"
   → Look for: undefined scope, missing constraints, no interaction with
     adjacent systems/people/ideas, no acknowledgment of what's out of scope.

3. **The lifecycle probe**: "What happens before, during, and after this?"
   → Look for: missing setup/teardown, no migration path, no maintenance plan,
     no consideration of how this ages or evolves, no exit strategy.

4. **The stakeholder probe**: "Who else is affected, and are they accounted for?"
   → Look for: missing audiences, unaddressed personas, absent collaborators,
     people who will encounter this artifact who weren't considered.

5. **The evidence probe**: "What claims are made without support?"
   → Look for: unvalidated assertions, missing data, assumed causation,
     absent benchmarks or comparisons, untested hypotheses.

### Domain-specific accelerators (optional — use when applicable):

For certain domains, common absences are well-known. Use these as checklists
to supplement the universal probes, not replace them. See
`references/domain-checklists.md` for accelerators covering: code/PRs,
architecture, strategy/business, writing, visual/UI, data/datasets,
infrastructure/config, communication/emails, and processes/workflows.

**Output format for Layer 1:**
Run every candidate finding through the Relevance Gate (see Usage Notes)
before including it. Then present passing absences as a prioritized list, each with:
- **What's missing** (specific, not vague)
- **Risk if unaddressed** (concrete scenario, one sentence)
- **Severity** (critical / significant / minor)

Aim for 3–7 findings. Fewer is better if fewer is honest.

---

## Layer 2: Load-Bearing Assumptions

**Question: "What invisible premises is this standing on?"**

These aren't missing features — they're unstated beliefs that the artifact
requires to be true in order to work. They're more dangerous than missing
features because they're structural.

### Method:
1. For each major decision or component, ask: "What must be true about
   the world for this to be the right choice?"
2. Make implicit assumptions explicit.
3. Classify each assumption:
   - **Validated**: Evidence exists that this is true
   - **Plausible**: Reasonable but unverified
   - **Fragile**: Could easily become false
   - **Invisible**: The creator likely doesn't know they're assuming this

### For embedded artifacts — distinguish inherited vs chosen:

Some assumptions in a PR or component aren't the author's — they're inherited
from the system. "This assumes a relational database" isn't the PR author's
assumption; the team chose Postgres two years ago. Surfacing inherited
assumptions is only valuable when:
- The change makes an inherited assumption **newly fragile** (e.g., adding
  a cache to a system that assumed all reads are fresh)
- The inherited assumption **conflicts** with where the system is heading
- The author inherited an assumption **without knowing it exists** (e.g.,
  an implicit ordering guarantee in a message queue that this PR now depends on)

Don't surface inherited assumptions that are stable, well-known, and
unaffected by the change. That's noise, not insight.

### Common assumption categories:
- **Environmental**: "The network is reliable", "Latency is low", "Users have modern browsers"
- **Behavioral**: "Users will read instructions", "Teams will follow the process", "Growth is linear"
- **Temporal**: "This won't need to change", "We have time to fix it later", "Current trends continue"
- **Organizational**: "The team stays the same size", "Priorities don't shift", "This team owns this forever"
- **Economic**: "Cost stays constant", "Funding continues", "Unit economics hold at scale"

**Output format for Layer 2:**
Apply the Relevance Gate. For each passing assumption:
- **The assumption** (stated explicitly)
- **Inherited or chosen** (for embedded artifacts)
- **Where it's load-bearing** (what breaks if it's wrong)
- **Fragility rating** (robust / moderate / fragile)
- **How to validate or hedge** (actionable next step)

---

## Layer 3: Frame Exclusions

**Question: "What does the framing itself make impossible to see?"**

This is the meta-analytical layer and where the deepest insight lives.
Layers 1–2 find things the creator missed. Layer 3 finds things the creator
*could not have seen* from inside their chosen frame. The difference matters:
missing something is a fixable error; being structurally blind to it is a
design-level revelation. When delivering Layer 3 findings, make this
distinction clear — it's the moment that changes how the creator relates
to their own work.

### Method:
1. **Identify the frame**: What paradigm, tool, methodology, or mental model
   produced this artifact? (REST vs event-driven, waterfall vs agile,
   quantitative vs qualitative, individual vs systemic)
2. **Name the frame's blindspots**: What does this paradigm structurally
   exclude? Every frame has them.
3. **Consider alternative frames**: What would a different paradigm reveal
   that this one hides?
4. **Assess frame-artifact fit**: Is this the right frame for this problem,
   or was it chosen by default/habit?

### For embedded artifacts — avoid the tautology trap:

"A PR's frame is that it's an incremental change" is true and useless —
everyone already knows that. Instead, look for frame **mismatches** between
the artifact and its host system:

- Does the PR's internal framing conflict with the system's direction?
  (e.g., adding synchronous coupling to a system migrating toward async)
- Does the PR solve the problem at the wrong level of abstraction?
  (e.g., patching a symptom at the endpoint layer when the issue is in
  the data model)
- Does the PR import a paradigm from a different context that doesn't
  fit here? (e.g., applying a pattern from a previous job that conflicts
  with this system's conventions)
- Is the artifact shaped by an organizational container rather than the
  problem? (e.g., the PR's scope matches a Jira ticket but not a coherent
  unit of change; the email answers the question asked but not the question
  that should have been asked)

If you can't find a frame mismatch, and the frame is appropriate, say so.
Not every artifact has a frame problem. Forcing a Layer 3 finding when
none exists is the skill at its worst.

### Frame exclusion patterns:
- **Tool-shaped thinking**: "We used a spreadsheet, so we only modeled quantifiable factors"
- **Paradigm lock**: "We built a REST API because that's what we know, not because it fits"
- **Survivorship framing**: "We studied successful companies but not failed ones"
- **Legibility bias**: "We optimized for what we can measure, not what matters"
- **Temporal framing**: "We designed for current state, not for how the landscape is shifting"

**Output format for Layer 3:**
- **Frame identified** (the paradigm/tool/model being used)
- **What this frame illuminates** (its strengths — be fair)
- **What this frame structurally excludes** (its necessary blindspots)
- **Alternative frame** (a different lens that would reveal something new)
- **Reframe recommendation** (is a frame shift warranted, or just awareness?)

---

## Layer 4: Via Negativa Design (Generative)

**Question: "What does the shape of the negative space suggest should exist?"**

After Layers 1–3 have mapped the absences, assumptions, and frame exclusions,
this layer asks: does the negative space itself have a coherent shape? Often,
the pattern of what's missing reveals a latent design that the artifact is
reaching toward but hasn't articulated.

### Method:
1. Look across all findings from Layers 1–3
2. Ask: "If I built something to fill exactly this negative space, what would it be?"
3. Propose the smallest intervention that addresses the most critical gaps
4. Frame it as a constructive next step, not a rewrite

**Output format for Layer 4:**
- **Pattern in the negative space** (what the absences collectively suggest)
- **The latent design** (what the artifact is trying to become)
- **Minimum viable intervention** (smallest change with highest impact)
- **What to resist adding** (via negativa discipline — not everything missing should be added)

---

## Usage Notes

### Tone
This is not adversarial. Frame findings as "here's what I notice is absent"
not "here's what you got wrong." The goal is to make invisible things visible
so the creator can make informed decisions about them.

### The Via Negativa Paradox
Not everything that's missing should be added. The most important output of
this analysis is often: "These three absences are intentional and correct.
These two are dangerous." Good design is defined by what it excludes.

### The Relevance Gate (critical — prevents noise)

Via negativa analysis can generate infinite findings. An email is also "missing"
a business plan, a test suite, and a poem. The skill becomes useless if it
surfaces absences that don't matter. Apply this gate to EVERY finding before
including it:

**A finding passes the gate only if ALL THREE are true:**

1. **Proximate**: The absence is within the artifact's zone of responsibility.
   For self-contained artifacts: "Would the creator agree this is within the
   boundaries of what they were trying to do?"
   For embedded artifacts: "Is this within the blast radius of what the
   change actually affects?" (Note: for embedded artifacts, the zone extends
   beyond the artifact itself into its effects on the host system. A PR that
   introduces a system-level property nobody decided on IS proximate even
   though it's outside the diff.)

2. **Consequential**: The absence creates a concrete risk, not a theoretical one.
   "Could go wrong" is not enough — you must be able to name a specific,
   plausible scenario in which the absence causes harm. If you can't
   describe the scenario in one sentence, the finding is too speculative.

3. **Non-obvious**: The creator probably doesn't already know about it.
   Don't surface absences that are clearly intentional simplifications
   or known tradeoffs. The value is in finding what's *invisibly* missing,
   not in restating conscious decisions. For embedded artifacts, also filter
   out inherited system properties that are stable, well-known, and
   unaffected by the change.

**Findings that fail the gate** should be silently dropped, not presented
with caveats. The goal is a short, high-signal list — not a comprehensive
catalog of everything that could theoretically exist.

**Aim for 3–7 findings per layer.** If you have more than 7, you haven't
filtered hard enough. If you have fewer than 3, you may need to look deeper
or the artifact is genuinely solid (which is a valid finding: say so).

### Scaling
- **Quick pass** (5 min): Layer 1 only, top 3 absences
- **Standard review** (15 min): Layers 1–2, full findings
- **Deep review** (30 min): Layers 1–3, with frame analysis
- **Generative session**: All 4 layers, produces constructive recommendations

### When the artifact is solid
The skill should not manufacture findings. If the Relevance Gate filters out
most candidates, that's a real and valuable result: "This artifact is
well-considered. The significant absences are intentional." Say so directly.
The worst failure mode of this skill is generating performative criticism
of something that's actually good. Via negativa rigor means being honest about
the *presence* of quality, not just the absence of it.

### Combining with other review methods
This skill complements (doesn't replace) standard review practices.
Use it alongside, not instead of, functional correctness checks.
The absence inventory (Layer 1) overlaps with standard review;
Layers 2–4 are where this approach adds unique value.

### Compound artifacts
Sometimes the target is not one thing but many things — a whole codebase,
a directory of configs, a chain of emails, a set of design screens.
For compound artifacts:
1. Run Step 0 (Intake) to map the components
2. Run Layer 1 at TWO levels: absences within individual components,
   AND absences in the relationships between components (what's not
   connected that should be? what's missing from the seams?)
3. Layers 2–4 often reveal more at the compound level than the component
   level — assumptions live in the gaps between parts

### What this skill cannot do
Be honest about the ceiling. Some findings require information that no
analytical framework can produce from the artifact alone:
- **Cross-repository emergence**: patterns forming across repos that no
  single-repo reviewer sees
- **Historical incident correlation**: this module causes outages when
  changed, but that requires incident database access
- **Organizational blindspots**: another team depends on this interface
  but there's no cross-team review process

The skill can *prompt the reviewer to go ask about* these things. It cannot
answer them from the artifact alone. When a finding depends on information
you don't have, say so explicitly: "This would be worth checking but I
can't verify it from what's available."

---

## Quick Reference

For deeper examples and domain-specific templates, see:
- `references/domain-checklists.md` — Absence checklists for 10+ artifact types (code, git, UI, data, infra, email, strategy, writing, processes)
- `references/code-review-examples.md` — Worked examples for PRs and code
- `references/strategy-examples.md` — Worked examples for business/strategy artifacts
