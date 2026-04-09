#!/usr/bin/env bash
set -euo pipefail

AZAHAR_DIR=${1:-azahar-src}
REPO_URL="https://github.com/azahar-emu/azahar"

SHORT_SHA="${SHORT_SHA:?}"
FULL_SHA="${FULL_SHA:?}"
BUILD_DATE="${BUILD_DATE:?}"
PREV_SHA="${PREV_SHA:-}"

CHANGELOG="changelog.md"

if [ -n "$PREV_SHA" ] && git -C "$AZAHAR_DIR" cat-file -e "${PREV_SHA}^{commit}" 2>/dev/null; then
    RANGE="${PREV_SHA}..HEAD"
    DIFF_URL="${REPO_URL}/compare/${PREV_SHA}...${FULL_SHA}"
    SINCE_LINE="**Changes since:** [${PREV_SHA:0:7}...${SHORT_SHA}](${DIFF_URL})  "
else
    RANGE="HEAD~30..HEAD"
    SINCE_LINE=""
fi

{
    echo "## Azahar Nightly — ${BUILD_DATE}"
    echo ""
    echo "**Commit:** [\`${SHORT_SHA}\`](${REPO_URL}/commit/${FULL_SHA})  "
    [ -n "$SINCE_LINE" ] && echo "$SINCE_LINE"
    echo ""
    echo "---"
    echo ""
    echo "**List of latest commits** (newest first):"
    echo ""
} > "$CHANGELOG"

HAS_COMMITS=false
while IFS= read -r entry; do
    [ -z "$entry" ] && continue
    HASH="${entry:0:40}"
    MSG="${entry:41}"
    SHORT="${HASH:0:7}"
    echo "- ${MSG} ([\`${SHORT}\`](${REPO_URL}/commit/${HASH}))" >> "$CHANGELOG"
    HAS_COMMITS=true
done < <(git -C "$AZAHAR_DIR" log "$RANGE" --pretty=format:"%H %s" 2>/dev/null)

if [ "$HAS_COMMITS" = false ]; then
    echo "_No changes found for this range._" >> "$CHANGELOG"
fi

echo "=== changelog.md ==="
cat "$CHANGELOG"
