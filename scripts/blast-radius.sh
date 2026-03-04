#!/usr/bin/env bash
# blast-radius.sh — Find every file that depends on the changed interfaces
#
# Answers: "Who is affected by this change that the diff doesn't show?"
#
# Usage:
#   ./blast-radius.sh                          # auto-detect from staged/uncommitted changes
#   ./blast-radius.sh --branch main            # diff against a branch
#   ./blast-radius.sh --files "src/auth.ts src/middleware.ts"

set -euo pipefail

BRANCH=""
FILES=""
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

while [[ $# -gt 0 ]]; do
    case $1 in
        --branch) BRANCH="$2"; shift 2 ;;
        --files) FILES="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 [--branch <base>] [--files \"file1 file2\"]"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -n "$FILES" ]]; then
    CHANGED_FILES="$FILES"
elif [[ -n "$BRANCH" ]]; then
    CHANGED_FILES=$(git diff --name-only "$BRANCH"...HEAD 2>/dev/null || git diff --name-only "$BRANCH" HEAD)
else
    CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || true)
    STAGED=$(git diff --cached --name-only 2>/dev/null || true)
    CHANGED_FILES=$(echo -e "${CHANGED_FILES}\n${STAGED}" | sort -u | grep -v '^$')
fi

if [[ -z "$CHANGED_FILES" ]]; then
    echo "No changed files detected."
    exit 0
fi

echo "═══════════════════════════════════════════════════"
echo "  BLAST RADIUS ANALYSIS"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Changed files:"
echo "$CHANGED_FILES" | sed 's/^/  ✦ /'
echo ""

# Extract searchable symbols from changed files
declare -A SEARCH_TERMS

for file in $CHANGED_FILES; do
    [[ ! -f "$REPO_ROOT/$file" ]] && continue

    basename_no_ext=$(basename "$file" | sed 's/\.[^.]*$//')
    # Skip overly generic names
    if [[ ${#basename_no_ext} -gt 2 ]] && [[ "$basename_no_ext" != "index" ]] && [[ "$basename_no_ext" != "main" ]]; then
        SEARCH_TERMS["$basename_no_ext"]=1
    fi

    # Extract exported/public symbols
    case "$file" in
        *.ts|*.tsx|*.js|*.jsx)
            while IFS= read -r sym; do
                [[ -n "$sym" ]] && [[ ${#sym} -gt 2 ]] && SEARCH_TERMS["$sym"]=1
            done < <(grep -oP '(?<=export\s+(default\s+)?(function|class|const|let|var|interface|type)\s+)\w+' "$REPO_ROOT/$file" 2>/dev/null || true)
            ;;
        *.py)
            while IFS= read -r sym; do
                [[ -n "$sym" ]] && [[ ${#sym} -gt 2 ]] && SEARCH_TERMS["$sym"]=1
            done < <(grep -oP '(?<=^def\s)\w+|(?<=^class\s)\w+' "$REPO_ROOT/$file" 2>/dev/null || true)
            ;;
        *.go)
            while IFS= read -r sym; do
                [[ -n "$sym" ]] && [[ ${#sym} -gt 2 ]] && SEARCH_TERMS["$sym"]=1
            done < <(grep -oP '(?<=^func\s)[A-Z]\w+|(?<=^type\s)[A-Z]\w+' "$REPO_ROOT/$file" 2>/dev/null || true)
            ;;
    esac
done

if [[ ${#SEARCH_TERMS[@]} -eq 0 ]]; then
    echo "Could not extract searchable symbols from changed files."
    exit 0
fi

echo "Searching for references to: ${!SEARCH_TERMS[*]}"
echo ""

GREP_PATTERN=$(printf '%s\|' "${!SEARCH_TERMS[@]}" | sed 's/\\|$//')

RESULTS=$(grep -rl "$GREP_PATTERN" "$REPO_ROOT" \
    --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
    --include='*.py' --include='*.go' --include='*.rb' --include='*.java' \
    --include='*.rs' --include='*.c' --include='*.cpp' --include='*.h' \
    --include='*.yaml' --include='*.yml' --include='*.json' --include='*.toml' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=vendor \
    --exclude-dir=dist --exclude-dir=build --exclude-dir=__pycache__ \
    --exclude-dir=.next --exclude-dir=target --exclude-dir=venv \
    2>/dev/null | sort -u || true)

AFFECTED=""
for result in $RESULTS; do
    rel=$(realpath --relative-to="$REPO_ROOT" "$result" 2>/dev/null || echo "$result")
    is_self=false
    for cf in $CHANGED_FILES; do [[ "$rel" == "$cf" ]] && is_self=true && break; done
    $is_self || AFFECTED="${AFFECTED}${rel}\n"
done

if [[ -z "$AFFECTED" ]]; then
    echo "No other files reference the changed interfaces."
    echo "Blast radius appears contained."
else
    COUNT=$(echo -e "$AFFECTED" | grep -cv '^$')
    echo "───────────────────────────────────────────────────"
    echo "  BLAST RADIUS: ${COUNT} files outside the diff"
    echo "───────────────────────────────────────────────────"
    echo ""
    echo -e "$AFFECTED" | grep -v '^$' | while read -r f; do
        matches=$(grep -oh "$GREP_PATTERN" "$REPO_ROOT/$f" 2>/dev/null | sort -u | head -5 | tr '\n' ', ' | sed 's/,$//')
        echo "  → $f"
        [[ -n "$matches" ]] && echo "    references: $matches"
    done
    echo ""
    echo "These files depend on interfaces modified by this change."
    echo "Verify they remain compatible."
fi
