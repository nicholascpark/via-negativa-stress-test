#!/usr/bin/env bash
set -euo pipefail

# churn-report.sh — Identify fragile, frequently-changed areas
#
# Shows commit frequency, distinct authors, and velocity on changed files.
# High churn = fragile area that keeps getting patched.
# Answers: "Is this a fragile area that keeps getting patched?"
#
# Usage: ./churn-report.sh <file1> [file2] ...

if [ $# -eq 0 ]; then
    echo "Usage: churn-report.sh <changed-file> [changed-file...]"
    exit 1
fi

if ! git rev-parse --show-toplevel &>/dev/null; then
    echo "Error: not inside a git repository."; exit 1
fi

cd "$(git rev-parse --show-toplevel)"

echo "═══════════════════════════════════════════════════════"
echo "  CHURN REPORT"
echo "═══════════════════════════════════════════════════════"
echo ""

FLAGS=""

for FILE in "$@"; do
    if ! git log --oneline -1 -- "$FILE" &>/dev/null; then
        echo "  ⚠ $FILE — no git history (new file?)"
        echo ""
        continue
    fi

    echo "┌─────────────────────────────────────────────────────"
    echo "│ $FILE"
    echo "└─────────────────────────────────────────────────────"

    TOTAL=$(git log --oneline -- "$FILE" | wc -l | tr -d ' ')
    RECENT=$(git log --oneline --since="90 days ago" -- "$FILE" | wc -l | tr -d ' ')
    MONTH=$(git log --oneline --since="30 days ago" -- "$FILE" | wc -l | tr -d ' ')
    AUTHORS=$(git log --format="%aN" -- "$FILE" | sort -u | grep -c . || echo 0)
    RECENT_AUTHORS=$(git log --format="%aN" --since="90 days ago" -- "$FILE" | sort -u | grep -c . || echo 0)
    LAST_MOD=$(git log -1 --format="%ar" -- "$FILE")

    echo "  Total commits:    $TOTAL"
    echo "  Last 90 days:     $RECENT commits"
    echo "  Last 30 days:     $MONTH commits"
    echo "  Authors:          $AUTHORS (all time), $RECENT_AUTHORS (90 days)"
    echo "  Last modified:    $LAST_MOD"
    echo ""

    if [ "$RECENT" -ge 8 ]; then
        echo "  🔴 HIGH CHURN — $RECENT changes in 90 days."
        echo "     This area is being patched frequently. Consider whether"
        echo "     the underlying design needs attention, not just another fix."
        echo ""
        FLAGS="${FLAGS}HIGH "
    elif [ "$RECENT" -ge 4 ]; then
        echo "  🟡 MODERATE CHURN — $RECENT changes in 90 days."
        echo ""
        FLAGS="${FLAGS}MOD "
    fi

    echo "  Recent commits:"
    git log --oneline --since="90 days ago" -10 -- "$FILE" | sed 's/^/    /'
    RC=$(git log --oneline --since="90 days ago" -- "$FILE" | wc -l | tr -d ' ')
    [ "$RC" -gt 10 ] && echo "    ... and $((RC - 10)) more"
    echo ""
done

echo "═══════════════════════════════════════════════════════"
echo "  SUMMARY"
echo "═══════════════════════════════════════════════════════"
if echo "$FLAGS" | grep -q "HIGH"; then
    echo "  ⚠ High-churn files detected. This PR touches code that"
    echo "  changes frequently — structural attention may be needed."
elif echo "$FLAGS" | grep -q "MOD"; then
    echo "  Moderate churn detected. Worth monitoring."
else
    echo "  No unusual churn."
fi
echo ""
